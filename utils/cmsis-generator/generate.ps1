[CmdletBinding()]
param(
    [string]$ExcelDir = '..\..\doc\register-map',
    [string[]]$Fields = @('struct', 'macro', 'struct-ansic')
)

$ErrorActionPreference = 'Stop'

$releaseDir = $PSScriptRoot
$tempDir = Join-Path $releaseDir '.temp'
$binDir = 'bin'
$generator = Join-Path $binDir 'cmsis-svd-generator.exe'
$svdconv = Join-Path $binDir 'svdconv.exe'
$sfrcc = Join-Path $binDir 'sfrcc2.exe'

$svdDir = 'output\svd'
$sfdDir = 'output\sfd'
$sfrDir = 'output\sfr'
$headerDir = 'output\header'
$logDir = 'output\log'

$outputDirs = @($svdDir, $sfdDir, $sfrDir, $headerDir)
$lastSuffix = '_last'
$errorSuffix = '_error'

$descriptionDir = '..\..\validation\description'
$headerTargetDirs = @(
    '..\..\validation\lib\cmsis\device\include',
    '..\flashloader-generator\flm-generator\lib\cmsis\device\include',
    '..\flashloader-generator\ewarm-flashloader-generator\lib\cmsis\device\include'
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
        # No console available (redirected input): fall back to a line read.
        $null = Read-Host 'Press Enter to continue'
    }
}

function Clear-LogFiles {
    if (-not (Test-Path -LiteralPath $logDir)) { return }

    $logs = @(Get-ChildItem -LiteralPath $logDir -File -Force -ErrorAction SilentlyContinue)
    if ($logs.Count -eq 0) { return }

    foreach ($log in $logs) {
        Remove-Item -LiteralPath $log.FullName -Force -ErrorAction SilentlyContinue
    }
    Write-Detail "cleared $($logs.Count) log file(s) under $logDir"
}

function Get-SuffixedPath {
    param([string]$Path, [string]$Suffix)

    $directory = [System.IO.Path]::GetDirectoryName($Path)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $extension = [System.IO.Path]::GetExtension($Path)
    return (Join-Path $directory ($name + $Suffix + $extension))
}

function Test-SuffixName {
    param([string]$Name, [string]$Suffix)

    return ([System.IO.Path]::GetFileNameWithoutExtension($Name) -like "*$Suffix")
}

function Test-ArchivedName {
    param([string]$Name)

    return ((Test-SuffixName -Name $Name -Suffix $lastSuffix) -or
        (Test-SuffixName -Name $Name -Suffix $errorSuffix))
}

function Remove-ErrorOutput {
    $removed = 0

    foreach ($dir in $outputDirs) {
        if (-not (Test-Path -LiteralPath $dir)) { continue }

        foreach ($file in @(Get-ChildItem -LiteralPath $dir -File -Force)) {
            if (-not (Test-SuffixName -Name $file.Name -Suffix $errorSuffix)) { continue }
            Remove-Item -LiteralPath $file.FullName -Force
            $removed++
        }
    }

    if ($removed -gt 0) { Write-Detail "removed $removed leftover '$errorSuffix' file(s)" }
    return $removed
}

function Move-PreviousOutput {
    $archived = @()

    foreach ($dir in $outputDirs) {
        if (-not (Test-Path -LiteralPath $dir)) { continue }

        foreach ($file in @(Get-ChildItem -LiteralPath $dir -File -Force)) {
            if (Test-ArchivedName -Name $file.Name) { continue }

            $previous = Get-SuffixedPath -Path $file.FullName -Suffix $lastSuffix
            if (Test-Path -LiteralPath $previous) { Remove-Item -LiteralPath $previous -Force }
            Move-Item -LiteralPath $file.FullName -Destination $previous
            $archived += [pscustomobject]@{ Previous = $previous; Current = $file.FullName }
        }
    }

    return $archived
}

function Restore-PreviousOutput {
    param([object[]]$Archived)

    $restored = 0
    foreach ($item in $Archived) {
        if (-not (Test-Path -LiteralPath $item.Previous)) { continue }
        if (Test-Path -LiteralPath $item.Current) { Remove-Item -LiteralPath $item.Current -Force }
        Move-Item -LiteralPath $item.Previous -Destination $item.Current
        $restored++
    }
    return $restored
}

function Rename-GeneratedToError {
    param([object[]]$Paths)

    $renamed = 0
    foreach ($path in $Paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $target = Get-SuffixedPath -Path $path -Suffix $errorSuffix
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Force }
        Move-Item -LiteralPath $path -Destination $target
        $renamed++
    }
    return $renamed
}

function Get-LogVerdict {
    param([string]$LogPath)

    $verdict = [pscustomobject]@{
        Log      = $LogPath
        Summary  = $null
        Errors   = 0
        Warnings = 0
    }
    if (-not (Test-Path -LiteralPath $LogPath)) { return $verdict }

    $text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $LogPath).Path)
    $found = [regex]::Matches($text, 'Found\s+(\d+)\s+Error\(s\)\s+and\s+(\d+)\s+Warning\(s\)')
    if ($found.Count -gt 0) {
        $last = $found[$found.Count - 1]
        $verdict.Summary = $last.Value
        $verdict.Errors = [int]$last.Groups[1].Value
        $verdict.Warnings = [int]$last.Groups[2].Value
    }
    return $verdict
}

function Publish-Generated {
    param([object[]]$Paths)

    $published = 0
    foreach ($path in $Paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $extension = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
        $targets = @()
        switch ($extension) {
            '.svd' { $targets = @($descriptionDir) }
            '.sfr' { $targets = @($descriptionDir) }
            '.h' { $targets = $headerTargetDirs }
        }
        if ($targets.Count -eq 0) { continue }

        $name = [System.IO.Path]::GetFileName($path)
        foreach ($target in $targets) {
            if (-not (Test-Path -LiteralPath $target)) {
                $null = New-Item -ItemType Directory -Path $target -Force
            }
            Copy-Item -LiteralPath $path -Destination (Join-Path $target $name) -Force
            $published++
            Write-Detail "$name -> $((Resolve-Path -LiteralPath $target).Path)"
        }
    }
    return $published
}

function Remove-TrailingWhitespace {
    param([string]$Path)

    $Path = (Resolve-Path -LiteralPath $Path).Path

    $latin1 = [System.Text.Encoding]::GetEncoding(28591)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $before = $latin1.GetString($bytes)

    $hits = ([regex]::Matches($before, '[ \t]+(?=\r?\n)')).Count
    $after = [regex]::Replace($before, '[ \t]+(?=\r?\n)', '')
    $after = [regex]::Replace($after, '[ \t]+\z', '')

    if ($after -ne $before) {
        [System.IO.File]::WriteAllBytes($Path, $latin1.GetBytes($after))
    }
    return $hits
}

function Remove-SourcePathFromHeader {
    param([string]$Path, [string[]]$SourcePath)

    $Path = (Resolve-Path -LiteralPath $Path).Path

    $latin1 = [System.Text.Encoding]::GetEncoding(28591)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $before = $latin1.GetString($bytes)
    $after = $before

    foreach ($source in $SourcePath) {
        $sourceDir = [System.IO.Path]::GetDirectoryName((Resolve-Path -LiteralPath $source).Path)
        foreach ($separator in @('/', '\')) {
            $prefix = $sourceDir.Replace('\', $separator).TrimEnd($separator) + $separator
            $after = $after.Replace($prefix, '')
        }
    }

    if ($after -ne $before) {
        [System.IO.File]::WriteAllBytes($Path, $latin1.GetBytes($after))
    }
}

Push-Location $releaseDir
$originalTemp = $env:TEMP
$originalTmp = $env:TMP
try {
    # cmsis-svd-generator.exe is a one-file PyInstaller build: it unpacks itself
    # into %TEMP% before it can run and fails when that directory is not usable.
    # Keep its scratch area inside the project instead.
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $env:TEMP = $tempDir
    $env:TMP = $tempDir

    Write-Step 'Checking tools and input'

    foreach ($tool in @($generator, $svdconv, $sfrcc)) {
        if (-not (Test-Path $tool)) { throw "Required tool not found: $tool" }
    }

    $knownFields = @('enum', 'macro', 'struct', 'struct-ansic')
    foreach ($field in $Fields) {
        if ($knownFields -notcontains $field) {
            throw "Unknown --fields value '$field'. svdconv accepts $($knownFields -join ', ') and ignores anything else without an error."
        }
    }

    if (-not (Test-Path $ExcelDir)) {
        $wanted = [System.IO.Path]::GetFullPath((Join-Path $releaseDir $ExcelDir))
        throw "Excel folder not found: $wanted"
    }
    Write-Host "    Excel: $((Resolve-Path -LiteralPath $ExcelDir).Path)"
    Write-Host "    TEMP:  $tempDir"

    foreach ($dir in @($svdDir, $sfdDir, $sfrDir, $headerDir, $logDir)) {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    }

    Write-Step 'Clearing logs and archiving the previous output'
    Clear-LogFiles
    $null = Remove-ErrorOutput

    $archived = @(Move-PreviousOutput)
    Write-Detail "archived $($archived.Count) file(s) with the '$lastSuffix' suffix"

    $generated = @()
    $failure = $null

    try {
        Write-Step 'Generating'

        & $generator --input-dir $ExcelDir --output-dir $svdDir
        Assert-ExitCode 'cmsis-svd-generator.exe' $LASTEXITCODE

        $svdFiles = @(Get-ChildItem -LiteralPath $svdDir -File |
            Where-Object { $_.Extension -eq '.svd' -and -not (Test-ArchivedName -Name $_.Name) })
        if ($svdFiles.Count -eq 0) { throw "No .svd file was produced in $svdDir." }

        foreach ($svdFile in $svdFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($svdFile.Name)
            $svdRelative = Join-Path $svdDir $svdFile.Name

            $generated += $svdFile.FullName

            & $svdconv $svdRelative --generate=sfd `
                -o $sfdDir `
                -b (Join-Path $logDir "$name.sfd.log") | Out-Null
            Assert-ExitCode 'svdconv (--generate=sfd)' $LASTEXITCODE

            $sfdPath = Join-Path $sfdDir "$name.sfd"
            if (-not (Test-Path $sfdPath)) { throw "svdconv did not produce $sfdPath" }
            $generated += $sfdPath
            Write-Host "[Generate SFD] Wrote $((Resolve-Path -LiteralPath $sfdPath).Path)"

            & (Join-Path $releaseDir $sfrcc) $sfdPath | Out-Null
            Assert-ExitCode 'sfrcc2' $LASTEXITCODE

            $upperSfr = Join-Path $sfdDir "$name.SFR"
            if (-not (Test-Path $upperSfr)) { throw "sfrcc2 did not produce $upperSfr" }

            $lowerSfr = Join-Path $sfrDir "$name.sfr"
            if (Test-Path $lowerSfr) { Remove-Item $lowerSfr -Force }
            Move-Item -LiteralPath $upperSfr -Destination $lowerSfr
            $generated += $lowerSfr
            Write-Host "[Generate SFR] Wrote $((Resolve-Path -LiteralPath $lowerSfr).Path)"

            $headerArgs = @($svdRelative, '--generate=header')
            foreach ($field in $Fields) {
                $headerArgs += "--fields=$field"
            }
            $headerArgs += @('-o', $headerDir, '-b', (Join-Path $logDir "$name.header.log"))

            & $svdconv @headerArgs | Out-Null
            Assert-ExitCode 'svdconv (--generate=header)' $LASTEXITCODE

            $headerPath = Join-Path $headerDir "$name.h"
            if (-not (Test-Path $headerPath)) { throw "svdconv did not produce $headerPath" }
            $generated += $headerPath

            $stripped = Remove-TrailingWhitespace -Path $headerPath
            Remove-SourcePathFromHeader -Path $headerPath -SourcePath @($headerPath, $svdFile.FullName)
            Write-Host "[Generate Header] Wrote $((Resolve-Path -LiteralPath $headerPath).Path)"
            Write-Verbose "stripped trailing whitespace on $stripped line(s)"
        }

        Write-Step 'Checking the generator logs'

        $logFiles = @(Get-ChildItem -LiteralPath $logDir -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -eq '.log' })

        $errorCount = 0
        $warningCount = 0
        $clean = $logFiles.Count -gt 0

        foreach ($logFile in $logFiles) {
            $verdict = Get-LogVerdict -LogPath $logFile.FullName
            if ($null -eq $verdict.Summary) {
                $clean = $false
                Write-Host "    $($logFile.Name): no result summary found" -ForegroundColor Yellow
                continue
            }
            $errorCount += $verdict.Errors
            $warningCount += $verdict.Warnings
            if ($verdict.Errors -ne 0 -or $verdict.Warnings -ne 0) { $clean = $false }
            Write-Host "    $($logFile.Name): $($verdict.Errors) error(s), $($verdict.Warnings) warning(s)"
        }

        if ($logFiles.Count -eq 0) {
            $failure = "No log file was produced in $logDir; the result cannot be verified."
        } elseif (-not $clean) {
            $failure = "The generator reported $errorCount error(s) and $warningCount warning(s)."
        }
    } catch {
        $failure = @($_.Exception.Message -split '\r?\n' | Where-Object { $_.Trim() -ne '' })[0]
    }

    if ($null -ne $failure) {
        Write-Host ''
        Write-Host 'Generation did not finish cleanly.' -ForegroundColor Red
        Write-Detail $failure
        Write-Detail "Please check the Register Map: $((Resolve-Path -LiteralPath $ExcelDir).Path)"

        $renamed = Rename-GeneratedToError -Paths $generated
        Write-Detail "marked $renamed file(s) from this run with the '$errorSuffix' suffix"

        $restored = Restore-PreviousOutput -Archived $archived
        Write-Detail "restored $restored previous file(s) to their original names"

        Write-Detail "logs kept in $((Resolve-Path -LiteralPath $logDir).Path)"

        Write-Host ''
        Write-Host 'Aborted. Nothing was published; the previous output is back in place.' -ForegroundColor Red
        exit 1
    }

    $headerFull = (Resolve-Path -LiteralPath $headerDir).Path
    $archivedHeader = @($archived | Where-Object { (Split-Path -Parent $_.Current) -eq $headerFull })

    Write-Step 'Reviewing the generated header'
    if ($archivedHeader.Count -eq 0) {
        Write-Detail "no previous header was found; the new one is in $headerFull"
    } else {
        Write-Host '    The previous header is kept next to the new one:'
        foreach ($item in $archivedHeader) {
            Write-Host ("        new: {0}" -f [System.IO.Path]::GetFileName($item.Current))
            Write-Host ("        old: {0}" -f [System.IO.Path]::GetFileName($item.Previous))
        }
        Write-Host '    Compare them before the result is published.'
    }

    Wait-AnyKey 'Press any key to open the header folder...'

    Write-Detail "opening $headerFull"
    try {
        Invoke-Item -LiteralPath $headerFull
    } catch {
        Write-Host "    could not open the folder: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Wait-AnyKey 'Press any key once you have visually checked the header with a third-party tool...'

    Write-Step 'Publishing the generated files'
    $published = Publish-Generated -Paths $generated
    Write-Detail "published $published file(s)"

    Write-Step 'Cleaning up the logs'
    Clear-LogFiles

    Write-Host ''
    Write-Host 'All done.' -ForegroundColor Green
} finally {
    if ($null -ne $originalTemp) { $env:TEMP = $originalTemp } else { Remove-Item Env:TEMP -ErrorAction SilentlyContinue }
    if ($null -ne $originalTmp) { $env:TMP = $originalTmp } else { Remove-Item Env:TMP -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $tempDir) { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    Pop-Location
}
