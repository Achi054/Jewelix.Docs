#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Wiki Sync Script - Converts WIKI.md to MediaWiki format and updates Wikipedia page.

.DESCRIPTION
    This script reads WIKI.md, converts Markdown to MediaWiki format, and updates
    the corresponding Wikipedia page via the MediaWiki API.

.PARAMETERS
    None (uses environment variables)

.EXAMPLE
    .\wiki-sync.ps1

.NOTES
    Requires:
    - PowerShell Core 7+ or Windows PowerShell 5.1+
    - Internet connection for Wikipedia API access
    - WIKI_USERNAME and WIKI_PASSWORD environment variables
#>

param()

# Enable strict error handling
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ============================================================================
# Configuration
# ============================================================================

$WikiUsername = $env:WIKI_USERNAME
$WikiPassword = $env:WIKI_PASSWORD
$WikiPageTitle = $env:WIKI_PAGE_TITLE ?? 'Jewelix'
$WikiSite = 'https://en.wikipedia.org'
$WikiApiUrl = "$WikiSite/w/api.php"

# Get the path to WIKI.md
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommandPath
$WikiFilePath = Join-Path $ScriptDir '..\..' 'WIKI.md'
$WikiFilePath = (Resolve-Path $WikiFilePath).Path

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Title {
    param([string]$Message)
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host $('=' * 60) -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# ============================================================================
# Validation
# ============================================================================

function Validate-Prerequisites {
    Write-Title "🔍 Validating Prerequisites"
    
    # Check credentials
    if (-not $WikiUsername) {
        Write-Error-Custom "WIKI_USERNAME environment variable is required"
        exit 1
    }
    
    if (-not $WikiPassword) {
        Write-Error-Custom "WIKI_PASSWORD environment variable is required"
        exit 1
    }
    
    Write-Info "Using Wikipedia username: $WikiUsername"
    Write-Info "Page title: $WikiPageTitle"
    
    # Check WIKI.md exists
    if (-not (Test-Path $WikiFilePath)) {
        Write-Error-Custom "WIKI.md file not found at: $WikiFilePath"
        exit 1
    }
    
    Write-Success "All prerequisites validated"
}

# ============================================================================
# Markdown to MediaWiki Conversion
# ============================================================================

function ConvertTo-MediaWikiFormat {
    param([string]$MarkdownContent)
    
    Write-Info "Converting Markdown to MediaWiki format..."
    
    $content = $MarkdownContent
    
    # Headers (# → =, ## → ==, etc.)
    $content = $content -replace '^### (.*?)$', '=== $1 ===' -eq $true | % { $_ }
    $content = $content -replace '^## (.*?)$', '== $1 ==' -eq $true | % { $_ }
    $content = $content -replace '^# (.*?)$', '= $1 =' -eq $true | % { $_ }
    
    # Process headers properly for multiline content
    $lines = @($content -split "`n")
    $processedLines = @()
    
    foreach ($line in $lines) {
        if ($line -match '^### (.+)$') {
            $processedLines += "=== $($matches[1]) ==="
        }
        elseif ($line -match '^## (.+)$') {
            $processedLines += "== $($matches[1]) =="
        }
        elseif ($line -match '^# (.+)$') {
            $processedLines += "= $($matches[1]) ="
        }
        else {
            $processedLines += $line
        }
    }
    
    $content = $processedLines -join "`n"
    
    # Bold (**text** → '''text''')
    $content = $content -replace '\*\*(.*?)\*\*', '''$1'''
    
    # Italic (*text* → ''text'', but not ** or **)
    $content = $content -replace '(?<!\*)\*(.*?)(?!\*)\*', '''$1'''
    
    # Inline code (`code` → <code>code</code>)
    $content = $content -replace '`([^`]+)`', '<code>$1</code>'
    
    # Links [text](url) → [url text]
    $content = $content -replace '\[(.*?)\]\((.*?)\)', '[$2 $1]'
    
    # Unordered lists (* → *)
    $content = $content -replace '^\* ', '* '
    
    # Ordered lists (1. → #)
    $content = $content -replace '^\d+\. ', '# '
    
    # Horizontal rules (--- → ----)
    $content = $content -replace '^---+$', '----'
    
    # Blockquotes (> → :)
    $content = $content -replace '^> ', ': '
    
    Write-Success "Markdown to MediaWiki conversion completed"
    return $content
}

# ============================================================================
# Wikipedia API Functions
# ============================================================================

function Get-WikiApiToken {
    param([hashtable]$Session)
    
    Write-Info "Retrieving CSRF token..."
    
    $params = @{
        Uri = $WikiApiUrl
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body = @{
            action = 'query'
            meta = 'tokens'
            type = 'csrf'
            format = 'json'
        } | ConvertTo-QueryString
        WebSession = $Session
    }
    
    try {
        $response = Invoke-WebRequest @params -ErrorAction Stop
        $json = $response.Content | ConvertFrom-Json
        
        if ($json.query.tokens.csrftoken) {
            Write-Success "CSRF token retrieved"
            return $json.query.tokens.csrftoken
        }
        else {
            Write-Error-Custom "Failed to retrieve CSRF token"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error retrieving token: $_"
        exit 1
    }
}

function ConvertTo-QueryString {
    param([hashtable]$Parameters)
    
    $pairs = @()
    foreach ($key in $Parameters.Keys) {
        $value = $Parameters[$key]
        $pairs += "$([System.Net.WebUtility]::UrlEncode($key))=$([System.Net.WebUtility]::UrlEncode($value))"
    }
    return $pairs -join '&'
}

function Update-WikiPage {
    param(
        [string]$Content,
        [hashtable]$Session,
        [string]$Token
    )
    
    Write-Info "Updating Wikipedia page: $WikiPageTitle"
    
    $editParams = @{
        action = 'edit'
        title = $WikiPageTitle
        text = $Content
        summary = '🤖 Automated update from GitHub Actions - Syncing WIKI.md'
        token = $Token
        format = 'json'
    } | ConvertTo-QueryString
    
    $params = @{
        Uri = $WikiApiUrl
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body = $editParams
        WebSession = $Session
    }
    
    try {
        $response = Invoke-WebRequest @params -ErrorAction Stop
        $json = $response.Content | ConvertFrom-Json
        
        if ($json.edit.result -eq 'Success') {
            Write-Success "Successfully updated Wikipedia page: $WikiPageTitle"
            return $true
        }
        else {
            $error = $json.error.info ?? $json.edit.result
            Write-Error-Custom "Failed to update page: $error"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error updating Wikipedia page: $_"
        exit 1
    }
}

# ============================================================================
# Main Authentication
# ============================================================================

function Invoke-WikiLogin {
    param([hashtable]$Session)
    
    Write-Info "Authenticating with Wikipedia..."
    
    # Get login token
    $loginTokenParams = @{
        Uri = $WikiApiUrl
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body = @{
            action = 'query'
            meta = 'tokens'
            type = 'login'
            format = 'json'
        } | ConvertTo-QueryString
        WebSession = $Session
    }
    
    try {
        $tokenResponse = Invoke-WebRequest @loginTokenParams -ErrorAction Stop
        $tokenJson = $tokenResponse.Content | ConvertFrom-Json
        $loginToken = $tokenJson.query.tokens.logintoken
        
        if (-not $loginToken) {
            Write-Error-Custom "Failed to retrieve login token"
            exit 1
        }
        
        # Perform login
        $loginParams = @{
            action = 'clientlogin'
            username = $WikiUsername
            password = $WikiPassword
            logintoken = $loginToken
            loginreturnurl = "$WikiSite/wiki/Main_Page"
            format = 'json'
        } | ConvertTo-QueryString
        
        $loginResponse = Invoke-WebRequest `
            -Uri $WikiApiUrl `
            -Method 'POST' `
            -ContentType 'application/x-www-form-urlencoded' `
            -Body $loginParams `
            -WebSession $Session `
            -ErrorAction Stop
        
        $loginJson = $loginResponse.Content | ConvertFrom-Json
        
        if ($loginJson.clientlogin.status -eq 'PASS') {
            Write-Success "Successfully authenticated as: $WikiUsername"
            return $true
        }
        else {
            $message = $loginJson.clientlogin.message ?? "Unknown error"
            Write-Error-Custom "Login failed: $message"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Authentication error: $_"
        exit 1
    }
}

# ============================================================================
# Main Execution
# ============================================================================

function Main {
    Write-Title "🌐 Jewelix Wiki Sync - Markdown to Wikipedia (PowerShell)"
    
    # Validate prerequisites
    Validate-Prerequisites
    
    # Read WIKI.md
    Write-Info "Reading Wiki file: $WikiFilePath"
    try {
        $wikiContent = Get-Content -Path $WikiFilePath -Raw -Encoding UTF8
        Write-Success "Read $(($wikiContent | Measure-Object -Character).Characters) characters"
    }
    catch {
        Write-Error-Custom "Error reading WIKI.md: $_"
        exit 1
    }
    
    # Convert to MediaWiki format
    $mediaWikiContent = ConvertTo-MediaWikiFormat -MarkdownContent $wikiContent
    
    # Create web session for persistent cookies
    Write-Info "Establishing Wikipedia connection..."
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # Authenticate
    Write-Title "🔐 Authentication"
    Invoke-WikiLogin -Session $session
    
    # Get CSRF token
    Write-Title "🔑 Getting CSRF Token"
    $token = Get-WikiApiToken -Session $session
    
    # Update Wikipedia page
    Write-Title "📝 Updating Wikipedia"
    Update-WikiPage -Content $mediaWikiContent -Session $session -Token $token
    
    # Success message
    Write-Title "✨ Sync Completed Successfully!"
    Write-Host "Wikipedia page '$WikiPageTitle' has been updated.`n" -ForegroundColor Green
}

# ============================================================================
# Error Handling
# ============================================================================

trap {
    Write-Error-Custom "Fatal error: $_"
    exit 1
}

# ============================================================================
# Execute
# ============================================================================

Main
