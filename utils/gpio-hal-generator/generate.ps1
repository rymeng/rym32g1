[CmdletBinding()]
param(
    [string]$InputDir = '..\..\doc\iomux',
    [string]$OutputDir = 'output',
    [string]$LastSuffix = '_last',
    [switch]$SkipReview
)

$ErrorActionPreference = 'Stop'

$releaseDir = $PSScriptRoot
$binDir = 'bin'
$generator = Join-Path $binDir 'HalGpioGenerator.exe'
$headerName = 'gpio.h'
$errorSuffix = '_error'

$headerTargetDirs = @(
    '..\..\validation\lib\hal\include',
    '..\ewarm-flashloader-generator\lib\hal\include',
    '..\flm-generator\lib\hal\include'
)

function Write-Step($message) {
    Write-Host ''
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Write-Detail($message) {
    Write-Host "    $message"
}

function Assert-ExitCode {
    param([string]$What, [int]$Code)
    if ($Code -ne 0) {
        throw "$What failed with exit code $Code."
    }
}

function Wait-AnyKey {
    param([string]$Message)

    Write-Host ''
    Write-Host $Message -ForegroundColor Green
    try {
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch {
        $null = Read-Host 'Press Enter to continue'
    }
}

function Get-SuffixedPath {
    param([string]$Path, [string]$Suffix)

    $directory = [System.IO.Path]::GetDirectoryName($Path)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $extension = [System.IO.Path]::GetExtension($Path)
    return (Join-Path $directory ($name + $Suffix + $extension))
}

Push-Location $releaseDir
try {
    Write-Step 'Checking tools and input'

    if (-not (Test-Path -LiteralPath $generator)) {
        throw "Required tool not found: $generator (publish the project into 'bin' first)."
    }
    if (-not (Test-Path -LiteralPath $InputDir)) {
        $wanted = [System.IO.Path]::GetFullPath((Join-Path $releaseDir $InputDir))
        throw "Input not found: $wanted"
    }
    Write-Host "    input : $((Resolve-Path -LiteralPath $InputDir).Path)"

    if (-not (Test-Path -LiteralPath $OutputDir)) {
        $null = New-Item -ItemType Directory -Path $OutputDir -Force
    }
    Write-Host "    output: $((Resolve-Path -LiteralPath $OutputDir).Path)"

    Write-Step 'Archiving the previous header'

    $headerPath = Join-Path $OutputDir $headerName
    $previousPath = Get-SuffixedPath -Path $headerPath -Suffix $LastSuffix
    $archived = $false

    if (Test-Path -LiteralPath $headerPath) {
        if (Test-Path -LiteralPath $previousPath) {
            Remove-Item -LiteralPath $previousPath -Force
        }
        Move-Item -LiteralPath $headerPath -Destination $previousPath
        $archived = $true
        Write-Detail "$headerName -> $([System.IO.Path]::GetFileName($previousPath))"
    } else {
        Write-Detail "no previous $headerName found"
    }

    $failure = $null
    try {
        Write-Step 'Generating'

        & (Join-Path $releaseDir $generator) --input-dir $InputDir --output-dir $OutputDir
        Assert-ExitCode 'HalGpioGenerator.exe' $LASTEXITCODE

        if (-not (Test-Path -LiteralPath $headerPath)) {
            throw "HalGpioGenerator.exe did not produce $headerPath."
        }
        Write-Detail "wrote $((Resolve-Path -LiteralPath $headerPath).Path)"
    } catch {
        $failure = @($_.Exception.Message -split '\r?\n' | Where-Object { $_.Trim() -ne '' })[0]
    }

    if ($null -ne $failure) {
        Write-Host ''
        Write-Host 'Generation did not finish cleanly.' -ForegroundColor Red
        Write-Detail $failure

        if (Test-Path -LiteralPath $headerPath) {
            $errorPath = Get-SuffixedPath -Path $headerPath -Suffix $errorSuffix
            if (Test-Path -LiteralPath $errorPath) {
                Remove-Item -LiteralPath $errorPath -Force
            }
            Move-Item -LiteralPath $headerPath -Destination $errorPath
            Write-Detail "kept this run's $headerName as $([System.IO.Path]::GetFileName($errorPath))"
        }

        if ($archived) {
            Move-Item -LiteralPath $previousPath -Destination $headerPath
            Write-Detail "restored the previous $headerName"
        }

        Write-Host ''
        Write-Host 'Aborted. Nothing was published.' -ForegroundColor Red
        exit 1
    }

    Write-Step 'Reviewing the generated header'
    $headerFull = (Resolve-Path -LiteralPath $headerPath).Path

    if ($archived) {
        Write-Host '    The previous header is kept next to the new one:'
        Write-Host ("        new: {0}" -f $headerName)
        Write-Host ("        old: {0}" -f [System.IO.Path]::GetFileName($previousPath))
        Write-Host '    Compare them with a third-party diff tool before publishing.'
    } else {
        Write-Detail "no previous header was found; the new one is $headerFull"
    }

    if ($SkipReview) {
        Write-Detail 'review skipped (-SkipReview)'
    } else {
        Wait-AnyKey 'Press any key to open the output folder...'

        Write-Detail "opening $(Split-Path -Parent $headerFull)"
        try {
            Invoke-Item -LiteralPath (Split-Path -Parent $headerFull)
        } catch {
            Write-Host "    could not open the folder: $($_.Exception.Message)" -ForegroundColor Yellow
        }

        Wait-AnyKey 'Press any key once you have compared the headers with a third-party tool...'
    }

    Write-Step 'Publishing the generated header'
    $published = 0
    foreach ($target in $headerTargetDirs) {
        if (-not (Test-Path -LiteralPath $target)) {
            $null = New-Item -ItemType Directory -Path $target -Force
        }
        Copy-Item -LiteralPath $headerPath -Destination (Join-Path $target $headerName) -Force
        $published++
        Write-Detail "$headerName -> $((Resolve-Path -LiteralPath $target).Path)"
    }
    Write-Detail "published $published file(s)"

    Write-Host ''
    Write-Host 'All done.' -ForegroundColor Green
} finally {
    Pop-Location
}
