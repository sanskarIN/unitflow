$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$AppDir = Join-Path $RootDir 'apps/unitflow_app'
$Platforms = @('android', 'ios', 'web', 'windows', 'linux', 'macos')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'flutter is required and was not found on PATH.'
}

foreach ($Platform in $Platforms) {
    $PlatformPath = Join-Path $AppDir $Platform
    if (Test-Path $PlatformPath) {
        throw "Refusing to generate platform scaffolding because $PlatformPath already exists. Review existing native projects manually instead of regenerating them blindly."
    }
}

Push-Location $AppDir
try {
    Write-Host '==> Generating reviewed-target Flutter platform scaffolding'
    flutter create --platforms=android,ios,web,windows,linux,macos --org in.sanskar --project-name unitflow .
    if ($LASTEXITCODE -ne 0) { throw 'flutter create failed' }

    Write-Host '==> Resolving dependencies and generated localization sources'
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }

    flutter gen-l10n
    if ($LASTEXITCODE -ne 0) { throw 'flutter gen-l10n failed' }

    Write-Host '==> Running Flutter source checks after generation'
    dart format --output=none --set-exit-if-changed lib test
    if ($LASTEXITCODE -ne 0) { throw 'dart format failed' }

    flutter analyze --fatal-infos --fatal-warnings
    if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }

    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'flutter test failed' }

    Write-Host ''
    Write-Host 'Platform scaffolding was generated locally.'
    Write-Host 'Review application IDs, platform versions, permissions, signing, entitlements, runner metadata, icons, Web manifest/HTML assumptions, and generated changes before committing.'
    Write-Host 'Then run the platform-specific release/smoke checks in docs/native-platforms.md.'
}
finally {
    Pop-Location
}
