# Rebuilds website/downloads/all-skills.zip from the current skill folders.
# Run this after adding, removing, or editing any skill, then commit + push +
# redeploy (vercel deploy ./website --prod) so the download stays in sync.
#
# Usage (from repo root):
#   powershell -File scripts/build-skills-zip.ps1

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$dest = "website\downloads\all-skills.zip"
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
if (Test-Path $dest) { Remove-Item $dest -Force }

Compress-Archive -Path "STLC_Skills","Automation_Playwright" -DestinationPath $dest -CompressionLevel Optimal

$sizeKB = [math]::Round((Get-Item $dest).Length / 1KB)
Write-Host "Built $dest ($sizeKB KB)"
