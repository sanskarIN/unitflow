$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $RootDir "app")

flutter create . `
  --project-name unitflow `
  --org com.sanskarin `
  --platforms android,ios,web,windows,linux,macos

flutter pub get

Write-Host "UnitFlow Flutter platform folders are ready."
