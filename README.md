# SKSE Automated Installer

A PowerShell script to automatically download and install the latest version of SKSE (Skyrim Script Extender) for Skyrim Special Edition.

## Prerequisites
- [7-Zip](https://www.7-zip.org/) installed at `C:\Program Files\7-Zip\7z.exe`
- Steam version of Skyrim Anniversary Edition

## Installation & Usage

### 1. Set Execution Policy
Open PowerShell and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/vigovlugt/skse-install/refs/heads/main/skse-install.ps1'))
```

You can inspect the script at [https://raw.githubusercontent.com/vigovlugt/skse-install/refs/heads/main/skse-install.ps1](https://raw.githubusercontent.com/vigovlugt/skse-install/refs/heads/main/skse-install.ps1) prior to running the script to ensure safety.
