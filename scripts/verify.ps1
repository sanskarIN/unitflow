$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$FlutterDir = Join-Path $RootDir 'apps/unitflow_app'

foreach ($Command in @('git', 'cargo', 'flutter', 'dart')) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "$Command is required and was not found on PATH."
    }
}

$PythonExecutable = $null
$PythonPrefix = @()
if (Get-Command 'python3' -ErrorAction SilentlyContinue) {
    $PythonExecutable = 'python3'
}
elseif (Get-Command 'python' -ErrorAction SilentlyContinue) {
    $PythonExecutable = 'python'
}
elseif (Get-Command 'py' -ErrorAction SilentlyContinue) {
    $PythonExecutable = 'py'
    $PythonPrefix = @('-3')
}
else {
    throw 'Python 3 is required and was not found on PATH.'
}

function Invoke-PythonCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    & $PythonExecutable @PythonPrefix @Arguments
    if ($LASTEXITCODE -ne 0) { throw $FailureMessage }
}

Push-Location $RootDir
try {
    Write-Host '==> Repository validator tests'
    Invoke-PythonCheck -Arguments @('-m', 'unittest', 'discover', '-s', 'scripts/tests', '-p', 'test_*.py') -FailureMessage 'Repository validator tests failed'

    Write-Host '==> Repository inventory'
    Invoke-PythonCheck -Arguments @('scripts/check_repository_inventory.py') -FailureMessage 'Repository inventory validation failed'

    Write-Host '==> Cross-platform support contract'
    Invoke-PythonCheck -Arguments @('scripts/check_platform_support.py') -FailureMessage 'Cross-platform support validation failed'

    Write-Host '==> Accessibility source contract'
    Invoke-PythonCheck -Arguments @('scripts/check_accessibility_contract.py') -FailureMessage 'Accessibility source-contract validation failed'

    Write-Host '==> Markdown links'
    Invoke-PythonCheck -Arguments @('scripts/check_markdown_links.py') -FailureMessage 'Markdown link validation failed'

    Write-Host '==> Release consistency'
    Invoke-PythonCheck -Arguments @('scripts/check_release_consistency.py') -FailureMessage 'Release consistency validation failed'

    Write-Host '==> Repository hygiene'
    Invoke-PythonCheck -Arguments @('scripts/check_repository_hygiene.py') -FailureMessage 'Repository hygiene validation failed'

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
