<# 
.SYNOPSIS
  Test the UFT MCP extension.
.DESCRIPTION
  - Validates build artifacts
  - Checks manifest integrity
  - Verifies JavaScript syntax
  - Runs basic smoke tests
.PARAMETER SkipBuild
  Skip the build step (assumes build was already run)
.PARAMETER Verbose
  Show detailed test information
.EXAMPLE
  pwsh tools/test.ps1
  pwsh tools/test.ps1 -SkipBuild -Verbose
#>
[CmdletBinding()]
param(
  [switch]$SkipBuild,
  [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Setup paths
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $RepoRoot

$Src       = Join-Path $RepoRoot 'src/extension'
$Artifacts = Join-Path $RepoRoot 'artifacts'
$BuildScript = Join-Path $RepoRoot 'tools/build.ps1'

# Test result tracking
$TestResults = @{
  Passed = 0
  Failed = 0
  Skipped = 0
  Details = @()
}

# Helper functions
function Write-TestInfo {
  param(
    [string]$Message, 
    [string]$Type = "Info"
  )
  
  $color = switch ($Type) {
    "Pass"    { "Green" }
    "Fail"    { "Red" }
    "Skip"    { "Yellow" }
    "Warning" { "Yellow" }
    default   { "Cyan" }
  }
  
  Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Test-Assert {
  param(
    [string]$TestName,
    [scriptblock]$Condition,
    [string]$ErrorMessage = "Assertion failed"
  )
  
  try {
    Write-Host "  Testing: $TestName..." -NoNewline
    
    $result = & $Condition
    if ($result) {
      Write-Host " PASS" -ForegroundColor Green
      $TestResults.Passed++
      $TestResults.Details += @{
        Name = $TestName
        Status = "Passed"
        Message = "OK"
      }
      return $true
    } else {
      Write-Host " FAIL" -ForegroundColor Red
      Write-Host "    Error: $ErrorMessage" -ForegroundColor Red
      $TestResults.Failed++
      $TestResults.Details += @{
        Name = $TestName
        Status = "Failed"
        Message = $ErrorMessage
      }
      return $false
    }
  } catch {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "    Exception: $_" -ForegroundColor Red
    $TestResults.Failed++
    $TestResults.Details += @{
      Name = $TestName
      Status = "Failed"
      Message = "Exception: $_"
    }
    return $false
  }
}

function Test-FileExists {
  param([string]$FilePath, [string]$Description)
  
  Test-Assert -TestName $Description -Condition {
    Test-Path $FilePath
  } -ErrorMessage "File not found: $FilePath"
}

function Test-JsonValid {
  param([string]$FilePath)
  
  Test-Assert -TestName "JSON validity for $(Split-Path $FilePath -Leaf)" -Condition {
    try {
      $null = Get-Content $FilePath -Raw | ConvertFrom-Json
      $true
    } catch {
      $false
    }
  } -ErrorMessage "Invalid JSON in file"
}

function Test-JavaScriptSyntax {
  param([string]$FilePath)
  
  $fileName = Split-Path $FilePath -Leaf
  
  Test-Assert -TestName "JavaScript syntax for $fileName" -Condition {
    $content = Get-Content $FilePath -Raw
    
    # Basic syntax checks
    $openBraces = ($content.ToCharArray() | Where-Object {$_ -eq '{'}).Count
    $closeBraces = ($content.ToCharArray() | Where-Object {$_ -eq '}'}).Count
    $openParens = ($content.ToCharArray() | Where-Object {$_ -eq '('}).Count
    $closeParens = ($content.ToCharArray() | Where-Object {$_ -eq ')'}).Count
    $openBrackets = ($content.ToCharArray() | Where-Object {$_ -eq '['}).Count
    $closeBrackets = ($content.ToCharArray() | Where-Object {$_ -eq ']'}).Count
    
    # Check for balanced brackets
    if ($openBraces -ne $closeBraces) {
      Write-Host "    Unbalanced braces: { = $openBraces, } = $closeBraces" -ForegroundColor Yellow
      return $false
    }
    if ($openParens -ne $closeParens) {
      Write-Host "    Unbalanced parentheses: ( = $openParens, ) = $closeParens" -ForegroundColor Yellow
      return $false
    }
    if ($openBrackets -ne $closeBrackets) {
      Write-Host "    Unbalanced brackets: [ = $openBrackets, ] = $closeBrackets" -ForegroundColor Yellow
      return $false
    }
    
    # Check for common JS errors
    if ($content -match 'console\.(log|error|warn|info|debug)\s*\(\s*\)') {
      Write-Host "    Warning: Empty console statement found" -ForegroundColor Yellow
    }
    
    if ($content -match '^\s*\}\s*\)?\s*;?\s*$' -and $content -notmatch '\(function') {
      Write-Host "    Warning: Potential syntax error with closing braces" -ForegroundColor Yellow
    }
    
    $true
  } -ErrorMessage "JavaScript syntax issues detected"
}

function Test-ManifestIntegrity {
  $manifestPath = Join-Path $Src 'manifest.json'
  
  Write-Host "`n[Test Group] Manifest Integrity" -ForegroundColor Magenta
  
  Test-FileExists -FilePath $manifestPath -Description "Manifest file exists"
  Test-JsonValid -FilePath $manifestPath
  
  Test-Assert -TestName "Manifest has required fields" -Condition {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $required = @('name', 'id', 'version', 'files', 'vendor', 'description')
    $missing = @()
    
    foreach ($field in $required) {
      if (-not $manifest.PSObject.Properties.Name.Contains($field)) {
        $missing += $field
      }
    }
    
    if ($missing.Count -gt 0) {
      Write-Host "    Missing fields: $($missing -join ', ')" -ForegroundColor Yellow
      return $false
    }
    $true
  } -ErrorMessage "Required fields missing from manifest"
  
  Test-Assert -TestName "Manifest files exist" -Condition {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $missing = @()
    
    foreach ($file in $manifest.files) {
      $filePath = Join-Path $Src $file
      if (-not (Test-Path $filePath)) {
        $missing += $file
      }
    }
    
    if ($missing.Count -gt 0) {
      Write-Host "    Missing files: $($missing -join ', ')" -ForegroundColor Yellow
      return $false
    }
    $true
  } -ErrorMessage "Files referenced in manifest do not exist"
}

function Test-SourceFiles {
  Write-Host "`n[Test Group] Source Files" -ForegroundColor Magenta
  
  Test-FileExists -FilePath (Join-Path $Src 'extension.js') -Description "extension.js exists"
  Test-FileExists -FilePath (Join-Path $Src 'extension.css') -Description "extension.css exists"
  
  Test-JavaScriptSyntax -FilePath (Join-Path $Src 'extension.js')
  
  Test-Assert -TestName "Extension.js contains MCP keywords" -Condition {
    $content = Get-Content (Join-Path $Src 'extension.js') -Raw
    $keywords = @('MCP_Ping', 'MCP_SendRequest', 'MCP_ValidateResponse')
    $missing = @()
    
    foreach ($keyword in $keywords) {
      if ($content -notmatch $keyword) {
        $missing += $keyword
      }
    }
    
    if ($missing.Count -gt 0) {
      Write-Host "    Missing keywords: $($missing -join ', ')" -ForegroundColor Yellow
      return $false
    }
    $true
  } -ErrorMessage "Expected MCP keywords not found"
}

function Test-BuildArtifacts {
  Write-Host "`n[Test Group] Build Artifacts" -ForegroundColor Magenta
  
  if (-not (Test-Path $Artifacts)) {
    Write-TestInfo "Artifacts directory not found. Run build first." "Skip"
    $TestResults.Skipped++
    return
  }
  
  $dxtFiles = Get-ChildItem $Artifacts -Filter *.dxt -ErrorAction SilentlyContinue
  
  Test-Assert -TestName "DXT bundle exists" -Condition {
    $null -ne $dxtFiles -and $dxtFiles.Count -gt 0
  } -ErrorMessage "No .dxt files found in artifacts"
  
  if ($dxtFiles -and $dxtFiles.Count -gt 0) {
    $latestDxt = $dxtFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    Test-Assert -TestName "DXT bundle is valid ZIP" -Condition {
      try {
        # DXT files are ZIP archives with different extension
        $tempZip = [System.IO.Path]::GetTempFileName() + ".zip"
        Copy-Item $latestDxt.FullName -Destination $tempZip -Force
        
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $archive = [System.IO.Compression.ZipFile]::OpenRead($tempZip)
        $entries = $archive.Entries
        $archive.Dispose()
        Remove-Item $tempZip -Force
        
        $entries.Count -gt 0
      } catch {
        $false
      }
    } -ErrorMessage "DXT bundle is not a valid ZIP archive"
    
    if ($VerboseOutput) {
      Write-Host "  Latest bundle: $($latestDxt.Name) ($($latestDxt.Length) bytes)" -ForegroundColor Cyan
    }
  }
}

function Test-ProjectStructure {
  Write-Host "`n[Test Group] Project Structure" -ForegroundColor Magenta
  
  Test-FileExists -FilePath (Join-Path $RepoRoot 'README.md') -Description "README.md exists"
  Test-FileExists -FilePath (Join-Path $RepoRoot 'LICENSE') -Description "LICENSE exists"
  Test-FileExists -FilePath (Join-Path $RepoRoot '.gitignore') -Description ".gitignore exists"
  Test-FileExists -FilePath (Join-Path $RepoRoot 'tools/build.ps1') -Description "Build script exists"
  Test-FileExists -FilePath (Join-Path $RepoRoot 'tools/test.ps1') -Description "Test script exists"
}

function Test-Documentation {
  Write-Host "`n[Test Group] Documentation" -ForegroundColor Magenta
  
  Test-Assert -TestName "README has installation instructions" -Condition {
    $readme = Get-Content (Join-Path $RepoRoot 'README.md') -Raw
    $readme -match 'install|Installation'
  } -ErrorMessage "README missing installation instructions"
  
  Test-Assert -TestName "README has usage examples" -Condition {
    $readme = Get-Content (Join-Path $RepoRoot 'README.md') -Raw
    $readme -match 'example|usage|Usage'
  } -ErrorMessage "README missing usage examples"
}

# Main test execution
try {
  Write-Host "`n==== UFT MCP Extension Tests ====" -ForegroundColor Magenta
  Write-TestInfo "Test suite started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Write-TestInfo "Repository: $RepoRoot"
  
  # Run build if not skipped
  if (-not $SkipBuild) {
    Write-Host "`n[Pre-test] Running build..." -ForegroundColor Yellow
    try {
      & $BuildScript -Clean
      Write-TestInfo "Build completed successfully" "Pass"
    } catch {
      Write-TestInfo "Build failed: $_" "Fail"
      exit 1
    }
  }
  
  # Run test groups
  Test-ProjectStructure
  Test-ManifestIntegrity
  Test-SourceFiles
  Test-BuildArtifacts
  Test-Documentation
  
  # Summary
  Write-Host "`n==== Test Summary ====" -ForegroundColor Magenta
  Write-Host "Passed:  $($TestResults.Passed)" -ForegroundColor Green
  Write-Host "Failed:  $($TestResults.Failed)" -ForegroundColor $(if ($TestResults.Failed -gt 0) { "Red" } else { "Gray" })
  Write-Host "Skipped: $($TestResults.Skipped)" -ForegroundColor $(if ($TestResults.Skipped -gt 0) { "Yellow" } else { "Gray" })
  
  $totalTests = $TestResults.Passed + $TestResults.Failed + $TestResults.Skipped
  $passRate = if ($totalTests -gt 0) { 
    [math]::Round(($TestResults.Passed / $totalTests) * 100, 1)
  } else { 0 }
  
  Write-Host "`nPass Rate: $passRate%" -ForegroundColor $(
    if ($passRate -ge 100) { "Green" }
    elseif ($passRate -ge 80) { "Yellow" }
    else { "Red" }
  )
  
  # Export results if verbose
  if ($VerboseOutput -and $TestResults.Details.Count -gt 0) {
    Write-Host "`nDetailed Results:" -ForegroundColor Cyan
    foreach ($test in $TestResults.Details) {
      $color = switch ($test.Status) {
        "Passed" { "Green" }
        "Failed" { "Red" }
        default { "Gray" }
      }
      Write-Host "  [$($test.Status)] $($test.Name)" -ForegroundColor $color
      if ($test.Status -eq "Failed" -and $test.Message) {
        Write-Host "    → $($test.Message)" -ForegroundColor DarkRed
      }
    }
  }
  
  # Exit code based on failures
  if ($TestResults.Failed -gt 0) {
    Write-Host "`n⚠ Tests completed with failures" -ForegroundColor Red
    exit 1
  } else {
    Write-Host "`n✓ All tests passed!" -ForegroundColor Green
    exit 0
  }
  
} catch {
  Write-TestInfo "Test suite failed: $_" "Fail"
  exit 1
}