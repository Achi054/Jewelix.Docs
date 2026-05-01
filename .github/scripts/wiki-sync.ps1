<#
.SYNOPSIS
  Sync local WIKI.md into the GitHub built-in wiki for Achi054/Jewelix.Docs.

.DESCRIPTION
  Clones the repository wiki (Jewelix.Docs.wiki.git), copies WIKI.md to Home.md,
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

# Robust temp root: prefer runner-provided vars, fallback to /tmp
$TempRoot = $env:TEMP ?? $env:RUNNER_TEMP ?? $env:GITHUB_WORKSPACE ?? '/tmp'

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

# Build explicit candidate paths (strings only)
$possiblePaths = @(
    Join-Path -Path $ScriptDir -ChildPath 'WIKI.md'
    Join-Path -Path $ScriptDir -ChildPath '..\WIKI.md'
)

if ($env:GITHUB_WORKSPACE) {
    $possiblePaths += Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath 'WIKI.md'
}

# Git settings
$CommitMessage = "Sync WIKI.md → Home.md (automated)"
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
    Write-Host "✅ $msg" -ForegroundColor Green
}

function Write-Info([string]$msg) {
    Write-Host "ℹ️  $msg" -ForegroundColor Cyan
}

function Write-Warn([string]$msg) {
    Write-Host "⚠️  $msg" -ForegroundColor Yellow
}

function Write-ErrorCustom([string]$msg) {
    Write-Host "❌ $msg" -ForegroundColor Red
}

function Run-Git([string[]]$args) {
    $git = 'git'
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $git
    # join args safely: wrap each arg containing spaces in quotes
    $escapedArgs = $args | ForEach-Object {
        if ($_ -match '\s') { '"{0}"' -f ($_ -replace '"','\"') } else { $_ }
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
    # Optionally get absolute path
    try {
        $WikiFilePath = (Resolve-Path -Path $WikiFilePath -ErrorAction Stop).Path
    } catch {
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
$cloneUrl = $WikiRemoteHttps

# If token provided, embed it for non-interactive push/pull (HTTPS)
if ($GitHubToken) {
    # Avoid logging token
    $cloneUrlWithToken = "https://$($GitHubToken)@github.com/$GitHubOwner/$WikiRepoName"
    $cloneUrl = $cloneUrlWithToken
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
Write-Title "Copying WIKI.md → Home.md"
$HomeMdPath = Join-Path -Path $LocalTempDir -ChildPath 'Home.md'

try {
    Copy-Item -Path $WikiFilePath -Destination $HomeMdPath -Force
    Write-Success "Copied to $HomeMdPath"
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
try {
    Push-Location $LocalTempDir

    # Configure git user for this repo
    Run-Git @("config", "user.name", $GitUserName) | Out-Null
    Run-Git @("config", "user.email", $GitUserEmail) | Out-Null

    # Check for changes
    $status = Run-Git @("status", "--porcelain")
    if (-not $status) {
        Write-Info "No changes detected in wiki. Nothing to commit."
        Pop-Location
        if ($DryRun) { Write-Info "Dry run complete." }
        Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
        exit 0
    }

    Run-Git @("add", "--", "Home.md") | Out-Null
    Run-Git @("commit", "-m", $CommitMessage) | Out-Null
    Write-Success "Committed Home.md"
}
catch {
    Write-ErrorCustom "Git commit failed: $_"
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# -----------------------
# Determine default branch and push
# -----------------------
if ($DryRun) {
    Write-Warn "DryRun enabled — skipping git push."
    Pop-Location
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 0
}

Write-Title "Pushing to remote"
try {
    # detect remote default branch (if possible)
    $remoteInfo = Run-Git @("remote", "show", "origin")
    $defaultBranch = 'main'
    if ($remoteInfo) {
        $lines = $remoteInfo -split "`n"
        foreach ($line in $lines) {
            if ($line -match 'HEAD branch:\s*(\S+)') {
                $defaultBranch = $matches[1]
                break
            }
        }
    }

    Run-Git @("push", "origin", "HEAD:$defaultBranch") | Out-Null
    Write-Success "Pushed changes to wiki remote (origin $defaultBranch)."
}
catch {
    Write-ErrorCustom "Git push failed: $_"
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue
    exit 1
}

# Cleanup
Pop-Location
Remove-Item -Recurse -Force $LocalTempDir -ErrorAction SilentlyContinue

Write-Title "Done"
Write-Host "Wiki updated: https://github.com/$GitHubOwner/$RepoName/wiki" -ForegroundColor Green
