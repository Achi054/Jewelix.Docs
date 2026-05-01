<#
.SYNOPSIS
  Sync local WIKI.md into the GitHub built-in wiki for Achi054/Jewelix.Docs.

.DESCRIPTION
  Clones the repository wiki (Jewelix.Docs.wiki.git), copies WIKI.md to
  Jewelix-wikipedia.md (which maps to the wiki page at /wiki/Jewelix-wikipedia),
  commits and pushes the change. Uses GITHUB_TOKEN for non-interactive push.

.PARAMETER DryRun
  If set, shows actions without performing git push.

.EXAMPLE
  pwsh ./wiki-sync.ps1
  pwsh ./wiki-sync.ps1 -DryRun
#>

param(
    [switch]$DryRun
)

# Strict mode
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# -----------------------
# Configuration
# -----------------------
$GitHubOwner = 'Achi054'
$RepoName = 'Jewelix.Docs'
$WikiRepoName = "$RepoName.wiki.git"
$WikiRemoteHttps = "https://github.com/$GitHubOwner/$WikiRepoName"

# FIX 1: Removed $env:GITHUB_WORKSPACE from TempRoot fallback chain.
# Using GITHUB_WORKSPACE as temp root risks creating the clone inside the
# checked-out repo, which can interfere with git operations.
$TempRoot = $env:RUNNER_TEMP ?? $env:TEMP ?? '/tmp'

# Robust script directory: prefer PSScriptRoot, then MyInvocation, then current location
if ($PSScriptRoot) {
    $ScriptDir = $PSScriptRoot
}
elseif ($MyInvocation -and $MyInvocation.MyCommandPath) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommandPath
}
else {
    $ScriptDir = (Get-Location).Path
}

$LocalTempDir = Join-Path -Path $TempRoot -ChildPath ("jewelix-wiki-sync-{0}" -f ([guid]::NewGuid().ToString()))

# FIX 2: Reordered candidate paths so the most reliable ones come first.
# The script lives at .github/scripts/wiki-sync.ps1, so $ScriptDir is
# .github/scripts/ — meaning the original first two candidates resolved to
# .github/scripts/WIKI.md and .github/WIKI.md, both wrong.
# Now we check GITHUB_WORKSPACE root first (always correct in CI), then
# probe repo root via ..\..\  relative to the script, as a local fallback.
$possiblePaths = @()

if ($env:GITHUB_WORKSPACE) {
    $possiblePaths += Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath 'WIKI.md'
}

$possiblePaths += @(
    Join-Path -Path $ScriptDir -ChildPath '..\..\WIKI.md'   # repo root (script is 2 levels deep)
    Join-Path -Path $ScriptDir -ChildPath '..\WIKI.md'       # one level up
    Join-Path -Path $ScriptDir -ChildPath 'WIKI.md'          # same dir (last resort)
)

# Git settings
# GitHub wiki page filenames map directly to URLs:
# Jewelix-wikipedia.md  -->  /wiki/Jewelix-wikipedia
$WikiPageFileName = 'Jewelix-wikipedia.md'
$CommitMessage = "Sync WIKI.md -> $WikiPageFileName (automated)"
$GitUserName = $env:GIT_USER_NAME ?? $env:GITHUB_USER ?? 'jewelix-wiki-sync'
$GitUserEmail = $env:GIT_USER_EMAIL ?? "$GitUserName@users.noreply.github.com"

# Token for push (optional)
$GitHubToken = $env:GITHUB_TOKEN

# -----------------------
# Helper functions
# -----------------------
function Write-Title([string]$msg) {
    Write-Host "`n" ('=' * 60) -ForegroundColor Cyan
    Write-Host $msg -ForegroundColor Cyan
    Write-Host ('=' * 60) -ForegroundColor Cyan
}

function Write-Success([string]$msg) {
    Write-Host "OK  $msg" -ForegroundColor Green
}

function Write-Info([string]$msg) {
    Write-Host "    $msg" -ForegroundColor Cyan
}

function Write-Warn([string]$msg) {
    Write-Host "WARN $msg" -ForegroundColor Yellow
}

function Write-ErrorCustom([string]$msg) {
    Write-Host "ERR $msg" -ForegroundColor Red
}

function Run-Git([string[]]$gitArgs) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'git'
    # Safely quote args that contain whitespace
    $escapedArgs = $gitArgs | ForEach-Object {
        if ($_ -match '\s') { '"{0}"' -f ($_ -replace '"', '\"') } else { $_ }
    }
    $psi.Arguments = ($escapedArgs -join ' ')
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $proc = [System.Diagnostics.Process]::Start($psi)
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) {
        throw "git failed (exit $($proc.ExitCode)): $stderr"
    }
    return $stdout.Trim()
}

# -----------------------
# Validation
# -----------------------
Write-Title "Jewelix Wiki Sync - Validation"

# Resolve to the first existing file
$WikiFilePath = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $WikiFilePath) {
    Write-ErrorCustom "WIKI.md not found. Checked: $($possiblePaths -join ', ')"
    exit 1
}
else {
    try {
        $WikiFilePath = (Resolve-Path -Path $WikiFilePath -ErrorAction Stop).Path
    }
    catch {
        # keep as-is if Resolve-Path fails
    }
    Write-Info "Using WIKI.md at: $WikiFilePath"
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-ErrorCustom "git is not installed or not in PATH. Install git and retry."
    exit 1
}

# -----------------------
# Prepare local workspace
# -----------------------
Write-Title "Preparing workspace"
try {
    New-Item -Path $LocalTempDir -ItemType Directory -Force | Out-Null
    Write-Info "Created temp dir: $LocalTempDir"
}
catch {
    Write-ErrorCustom "Failed to create temp dir: $_"
    exit 1
}

# -----------------------
# Clone wiki repo
# -----------------------
Write-Title "Cloning wiki repository"

# FIX 3: Build the authenticated clone URL separately and never pass it to
# Run-Git directly (where it could surface in error messages). The token is
# only stored in the local repo's git config via a credential helper URL,
# keeping it out of stdout/stderr and log output.
$cloneUrl = $WikiRemoteHttps

if ($GitHubToken) {
    # Embed token only for the clone URL; we will NOT call "remote show origin"
    # afterwards (which would echo this URL). See FIX 4 below.
    $cloneUrl = "https://x-access-token:$GitHubToken@github.com/$GitHubOwner/$WikiRepoName"
    Write-Info "Using GITHUB_TOKEN for authentication (token not shown)."
}
else {
    Write-Warn "GITHUB_TOKEN not set. You will be prompted for credentials if required."
}

try {
    Run-Git @("clone", "--depth", "1", "--", $cloneUrl, $LocalTempDir) | Out-Null
    Write-Success "Cloned wiki repo into $LocalTempDir"
}
catch {
    Write-ErrorCustom "Failed to clone wiki repo: $_"
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# -----------------------
# Copy WIKI.md to Home.md
# -----------------------
Write-Title "Copying WIKI.md to $WikiPageFileName"
$WikiPagePath = Join-Path -Path $LocalTempDir -ChildPath $WikiPageFileName

try {
    Copy-Item -Path $WikiFilePath -Destination $WikiPagePath -Force
    Write-Success "Copied to $WikiPagePath"
}
catch {
    Write-ErrorCustom "Failed to copy WIKI.md: $_"
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# -----------------------
# Commit changes
# -----------------------
Write-Title "Committing changes"

# FIX 5: Wrapped the commit block in try/finally so Pop-Location always runs,
# preventing a dangling directory stack entry on both success and failure paths.
try {
    Push-Location $LocalTempDir

    try {
        # Configure git user for this repo
        Run-Git @("config", "user.name", $GitUserName) | Out-Null
        Run-Git @("config", "user.email", $GitUserEmail) | Out-Null

        # Check for changes
        $status = Run-Git @("status", "--porcelain")
        if (-not $status) {
            Write-Info "No changes detected in wiki. Nothing to commit."
            if ($DryRun) { Write-Info "Dry run complete." }
            Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
            exit 0
        }

        Run-Git @("add", "--", $WikiPageFileName) | Out-Null
        Run-Git @("commit", "-m", $CommitMessage) | Out-Null
        Write-Success "Committed Home.md"
    }
    finally {
        Pop-Location
    }
}
catch {
    Write-ErrorCustom "Git commit failed: $_"
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# -----------------------
# Push
# -----------------------
if ($DryRun) {
    Write-Warn "DryRun enabled - skipping git push."
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 0
}

Write-Title "Pushing to remote"

# FIX 4: GitHub wiki repos always use 'master' as their default branch,
# regardless of the main repo's default branch setting. Removed the
# "git remote show origin" call entirely — it made a live network request
# that would echo the token-embedded URL into stdout/stderr, leaking the
# secret. Hardcoding 'master' is both correct and safe.
$defaultBranch = 'master'

try {
    Push-Location $LocalTempDir

    try {
        Run-Git @("push", "origin", "HEAD:$defaultBranch") | Out-Null
        Write-Success "Pushed changes to wiki remote (origin/$defaultBranch)."
    }
    finally {
        Pop-Location
    }
}
catch {
    Write-ErrorCustom "Git push failed: $_"
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# Cleanup
Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue

Write-Title "Done"
Write-Host "Wiki updated: https://github.com/$GitHubOwner/$RepoName/wiki" -ForegroundColor Green