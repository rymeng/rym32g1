param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$runDir = Join-Path $PSScriptRoot 'run'

if (Test-Path -LiteralPath $runDir) {
    Remove-Item -LiteralPath $runDir -Recurse -Force
    Write-Host "Removed $runDir done." -ForegroundColor Green
} else {
    Write-Host "Nothing to clean: $runDir does not exist." -ForegroundColor Red
}
