$ErrorActionPreference = "Stop"

# GitHub repository details
$repoOwner = "ianpatt"
$repoName = "skse64"

# 7-Zip path
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Skyrim SE default installation path
$defaultSkyrimPath = "C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition"

# Check if 7-Zip exists
if (-not (Test-Path $sevenZipPath)) {
    Write-Host "7-Zip not found at $sevenZipPath"
    exit
}

# Check if Skyrim installation exists
if (-not (Test-Path $defaultSkyrimPath)) {
    $skyrimPath = Read-Host "Enter path to your Skyrim Special Edition installation"
} else {
    $skyrimPath = $defaultSkyrimPath
}

if (-not (Test-Path "$skyrimPath\SkyrimSE.exe")) {
    Write-Host "Skyrim installation not found at $skyrimPath"
    exit
}

# Create temporary directory
$tempDir = Join-Path $env:TEMP "skse_install"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    # Get latest release information
    $apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{
        "Accept" = "application/vnd.github.v3+json"
    }

    # Find the .7z asset
    $skseAsset = $release.assets | Where-Object { $_.name -like "skse64_*.7z" } | Select-Object -First 1
    
    if (-not $skseAsset) {
        throw "No SKSE 7z archive found in the latest release"
    }

    # Download the SKSE archive
    $downloadPath = Join-Path $tempDir $skseAsset.name
    Write-Host "Downloading $($skseAsset.name)..."
    Invoke-WebRequest -Uri $skseAsset.browser_download_url -OutFile $downloadPath

    # Extract SKSE archive
    Write-Host "Extracting SKSE files..."
    & $sevenZipPath x $downloadPath -o"$tempDir" | Out-Null

    # Find the extracted directory
    $extractedFolder = Get-ChildItem $tempDir -Directory | Select-Object -First 1
    if (-not $extractedFolder) {
        throw "No files extracted from SKSE archive"
    }

    # Copy required files using Filter
    Write-Host "Installing SKSE files to $skyrimPath..."
    
    # Copy .exe and .dll files
    foreach ($filter in @("*.exe", "*.dll")) {
        Get-ChildItem -Path $extractedFolder.FullName -Filter $filter -File | ForEach-Object {
            Copy-Item $_.FullName -Destination $skyrimPath -Force
        }
    }

    # Copy Data folder contents
    $dataSource = Join-Path $extractedFolder.FullName "Data"
    if (Test-Path $dataSource) {
        Get-ChildItem -Path $dataSource -Filter "*" | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination "$skyrimPath\Data" -Recurse -Force
        }
    }

    Write-Host "`nSKSE version $($release.tag_name) installed successfully!"
}
catch {
    Write-Host "`nError: $($_.Exception.Message)"
}
finally {
    # Cleanup temporary files
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}
