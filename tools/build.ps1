<# 
.SYNOPSIS
  Build the UFT MCP extension into a .dxt bundle.
.DESCRIPTION
  - Idempotent build process
  - Validates manifest.json
  - Produces artifacts/UFT-MCP-Ext_<version>.dxt
  - Normalizes line endings for cross-platform compatibility
.PARAMETER Clean
  Remove dist/artifacts before building
.PARAMETER Verbose
  Show detailed build information
.EXAMPLE
  pwsh tools/build.ps1 -Clean
  pwsh tools/build.ps1 -Verbose
#>
[CmdletBinding()]
param(
  [switch]$Clean,
  [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Setup paths
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $RepoRoot

$Dist      = Join-Path $RepoRoot 'dist'
$Artifacts = Join-Path $RepoRoot 'artifacts'
$Src       = Join-Path $RepoRoot 'src/extension'
$Manifest  = Join-Path $Src 'manifest.json'
$DxtName   = 'UFT-MCP-Ext'

# Helper functions
function Write-BuildInfo {
  param([string]$Message, [string]$Type = "Info")
  
  $color = switch ($Type) {
    "Success" { "Green" }
    "Warning" { "Yellow" }
    "Error"   { "Red" }
    default   { "Cyan" }
  }
  
  Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Ensure-Dir {
  param([string]$Path)
  
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    if ($VerboseOutput) {
      Write-BuildInfo "Created directory: $Path"
    }
  }
}

function Validate-Manifest {
  param([string]$ManifestPath)
  
  Write-BuildInfo "Validating manifest..."
  
  if (-not (Test-Path $ManifestPath)) {
    throw "Missing manifest.json at $ManifestPath"
  }
  
  try {
    $manifestObj = Get-Content $ManifestPath -Raw | ConvertFrom-Json
  } catch {
    throw "Invalid JSON in manifest.json: $_"
  }
  
  # Check required fields
  $requiredFields = @('name', 'id', 'version', 'files', 'vendor', 'description')
  foreach ($field in $requiredFields) {
    if (-not $manifestObj.PSObject.Properties.Name.Contains($field)) {
      throw "manifest.json missing required field: $field"
    }
  }
  
  # Validate version format (semantic versioning)
  if ($manifestObj.version -notmatch '^\d+\.\d+\.\d+$') {
    Write-BuildInfo "Warning: Version '$($manifestObj.version)' does not follow semantic versioning (x.y.z)" "Warning"
  }
  
  # Ensure referenced files exist
  foreach ($file in $manifestObj.files) {
    $filePath = Join-Path $Src $file
    if (-not (Test-Path $filePath)) {
      throw "Manifest references missing file: $file"
    }
  }
  
  Write-BuildInfo "Manifest validation successful" "Success"
  return $manifestObj
}

function Normalize-LineEndings {
  param([string]$Directory)
  
  if ($VerboseOutput) {
    Write-BuildInfo "Normalizing line endings in $Directory"
  }
  
  $textFiles = Get-ChildItem $Directory -Recurse -Include *.json,*.js,*.css,*.md,*.txt,*.html -ErrorAction SilentlyContinue
  
  foreach ($file in $textFiles) {
    try {
      $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
      if ($null -ne $content) {
        # Convert to Windows line endings (CRLF)
        $content = $content -replace "`r?`n", "`r`n"
        Set-Content $file.FullName -NoNewline -Value $content
        
        if ($VerboseOutput) {
          Write-BuildInfo "Normalized: $($file.Name)"
        }
      }
    } catch {
      Write-BuildInfo "Warning: Could not normalize $($file.Name): $_" "Warning"
    }
  }
}

function Create-Bundle {
  param(
    [string]$SourceDir,
    [string]$OutputPath,
    [string]$Version
  )
  
  Write-BuildInfo "Creating .dxt bundle..."
  
  $zipPath = $OutputPath -replace '\.dxt$', '.zip'
  
  # Remove existing files if they exist
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
  
  try {
    # Create ZIP archive
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $zipPath)
    
    # Rename to .dxt
    Rename-Item -Path $zipPath -NewName (Split-Path $OutputPath -Leaf) -ErrorAction Stop
    
    # Verify the bundle was created
    if (Test-Path $OutputPath) {
      $fileInfo = Get-Item $OutputPath
      Write-BuildInfo "Bundle created successfully: $($fileInfo.Name) ($($fileInfo.Length) bytes)" "Success"
      return $true
    } else {
      throw "Failed to create bundle at $OutputPath"
    }
  } catch {
    throw "Bundle creation failed: $_"
  }
}

# Main build process
try {
  Write-Host "`n==== UFT MCP Extension Build ====" -ForegroundColor Magenta
  Write-BuildInfo "Build started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Write-BuildInfo "Repository root: $RepoRoot"
  
  # Clean if requested
  if ($Clean) {
    Write-BuildInfo "Cleaning previous build artifacts..."
    if (Test-Path $Dist) { 
      Remove-Item $Dist -Recurse -Force 
      Write-BuildInfo "Removed dist directory"
    }
    if (Test-Path $Artifacts) { 
      Remove-Item $Artifacts -Recurse -Force 
      Write-BuildInfo "Removed artifacts directory"
    }
  }
  
  # Ensure directories exist
  Ensure-Dir $Dist
  Ensure-Dir $Artifacts
  
  # Validate manifest
  $manifestObj = Validate-Manifest -ManifestPath $Manifest
  $version = $manifestObj.version
  
  Write-BuildInfo "Building version: $version"
  
  # Copy source files to dist
  Write-BuildInfo "Copying source files to dist..."
  Copy-Item "$Src\*" -Destination $Dist -Recurse -Force
  
  # Check if the existing .dxt file should be included
  $existingDxt = Join-Path $RepoRoot 'uft-mcp-extension.dxt'
  if ((Test-Path $existingDxt) -and $VerboseOutput) {
    Write-BuildInfo "Note: Found existing uft-mcp-extension.dxt in root (not included in new build)"
  }
  
  # Normalize line endings for cross-platform compatibility
  Normalize-LineEndings -Directory $Dist
  
  # Create the .dxt bundle
  $outputPath = Join-Path $Artifacts "$DxtName`_$version.dxt"
  Create-Bundle -SourceDir $Dist -OutputPath $outputPath -Version $version
  
  # Create a copy without version for easy access
  $latestPath = Join-Path $Artifacts "$DxtName.dxt"
  Copy-Item $outputPath -Destination $latestPath -Force
  Write-BuildInfo "Created latest copy: $DxtName.dxt"
  
  # Summary
  Write-Host "`n==== Build Complete ====" -ForegroundColor Green
  Write-BuildInfo "Extension: $($manifestObj.name)"
  Write-BuildInfo "Version: $version"
  Write-BuildInfo "Output: $outputPath"
  
  if ($VerboseOutput) {
    Write-Host "`nBundle contents:" -ForegroundColor Cyan
    $bundleFiles = Get-ChildItem $Dist -Recurse -File
    foreach ($file in $bundleFiles) {
      $relativePath = $file.FullName.Replace("$Dist\", "").Replace("\", "/")
      Write-Host "  - $relativePath ($($file.Length) bytes)"
    }
  }
  
  Write-Host "`nTo install this extension in UFT:" -ForegroundColor Yellow
  Write-Host "  1. Open UFT One"
  Write-Host "  2. Go to Tools → Options → GUI Testing → Add-ins"
  Write-Host "  3. Click 'Install Extension' and browse to:"
  Write-Host "     $outputPath" -ForegroundColor Cyan
  Write-Host "  4. Restart UFT One`n"
  
} catch {
  Write-BuildInfo "Build failed: $_" "Error"
  exit 1
}