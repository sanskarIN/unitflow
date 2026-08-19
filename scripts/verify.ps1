$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$FlutterDir = Join-Path $RootDir 'apps/unitflow_app'

foreach ($Command in @('cargo', 'flutter', 'dart')) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "$Command is required and was not found on PATH."
    }
}

Push-Location $RootDir
try {
    Write-Host '==> Rust formatting'
    cargo fmt --all -- --check
    if ($LASTEXITCODE -ne 0) { throw 'cargo fmt failed' }

    Write-Host '==> Rust lint'
    cargo clippy --workspace --all-targets --all-features -- -D warnings
    if ($LASTEXITCODE -ne 0) { throw 'cargo clippy failed' }

    Write-Host '==> Rust tests'
    cargo test --workspace --all-features
    if ($LASTEXITCODE -ne 0) { throw 'cargo test failed' }

    Set-Location $FlutterDir

    Write-Host '==> Flutter dependencies'
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }

    Write-Host '==> Flutter localizations'
    flutter gen-l10n
    if ($LASTEXITCODE -ne 0) { throw 'flutter gen-l10n failed' }

    Write-Host '==> Dart formatting'
    dart format --output=none --set-exit-if-changed lib test
    if ($LASTEXITCODE -ne 0) { throw 'dart format failed' }

    Write-Host '==> Flutter analysis'
    flutter analyze --fatal-infos --fatal-warnings
    if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }

    Write-Host '==> Flutter tests'
    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'flutter test failed' }

    Write-Host 'UnitFlow verification completed successfully.'
}
finally {
    Pop-Location
}
