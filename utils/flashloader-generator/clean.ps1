[CmdletBinding()]
param(
    [string]$Root,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ewarmKeepFiles = @('browse\.gitkeep', 'list\.gitkeep', 'obj\.gitkeep', 'out\.gitkeep')
$flmKeepFiles = @('flm\.gitkeep', 'list\.gitkeep', 'obj\.gitkeep')

$prunedNames = @(
    'build', 'bin', 'obj', 'list', 'out', 'browse', 'flm',
    'node_modules', '.git', '.github', '.dsh'
)

function Write-Step($message) {
    Write-Host ''
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Write-Detail($message) {
    Write-Host "    $message"
}

function Resolve-FullPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $PWD.Path $Path))
}

function Find-ProjectFolder {
    param(
        [string]$SearchRoot,
        [string]$NameMatch,
        [string]$ProjDir
    )

    $found = @()
    $pending = New-Object 'System.Collections.Generic.Queue[string]'
    $pending.Enqueue($SearchRoot)

    while ($pending.Count -gt 0) {
        $current = $pending.Dequeue()
        $children = @(Get-ChildItem -LiteralPath $current -Directory -Force -ErrorAction SilentlyContinue)

        foreach ($child in $children) {
            if ($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }

            $isProject = ($child.Name -like $NameMatch) -and
                (Test-Path -LiteralPath (Join-Path $child.FullName $ProjDir) -PathType Container)
            if ($isProject) {
                $found += $child.FullName
                continue
            }

            if ($prunedNames -contains $child.Name) { continue }
            $pending.Enqueue($child.FullName)
        }
    }

    return @($found | Sort-Object)
}

function Get-UnpublishedArtifact {
    param(
        [string[]]$Projects,
        [string]$SourceDir,
        [string]$Pattern,
        [string]$PublishedDir
    )

    $missing = @()
    foreach ($project in $Projects) {
        $sourceDir = Join-Path $project $SourceDir
        if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) { continue }

        $files = @(Get-ChildItem -LiteralPath $sourceDir -File -Filter $Pattern -Force -ErrorAction SilentlyContinue)
        foreach ($file in $files) {
            if (-not (Test-Path -LiteralPath (Join-Path $PublishedDir $file.Name))) {
                $missing += $file.FullName
            }
        }
    }

    return @($missing)
}

function Clear-BuildFolder {
    param(
        [string]$BuildFolder,
        [string[]]$KeepFiles,
        [switch]$DryRun
    )

    $result = [pscustomobject]@{
        Exists       = $false
        RemovedFiles = 0
        RemovedDirs  = 0
        MissingKeeps = @()
    }

    if (-not (Test-Path -LiteralPath $BuildFolder -PathType Container)) { return $result }
    $result.Exists = $true

    $prefix = $BuildFolder.TrimEnd('\') + '\'

    $keepSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($keep in $KeepFiles) { $null = $keepSet.Add($keep) }

    $present = @{}
    foreach ($file in @(Get-ChildItem -LiteralPath $BuildFolder -Recurse -File -Force)) {
        $relative = $file.FullName.Substring($prefix.Length)
        if ($keepSet.Contains($relative)) {
            $present[$relative] = $true
            continue
        }

        if (-not $DryRun) { Remove-Item -LiteralPath $file.FullName -Force }
        $result.RemovedFiles++
    }
    $result.MissingKeeps = @($KeepFiles | Where-Object { -not $present.ContainsKey($_) })

    $keepDirs = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($keep in $KeepFiles) { $null = $keepDirs.Add([System.IO.Path]::GetDirectoryName($keep)) }

    $folders = @(Get-ChildItem -LiteralPath $BuildFolder -Directory -Recurse -Force |
        Sort-Object -Property @{ Expression = { $_.FullName.Length }; Descending = $true })

    foreach ($folder in $folders) {
        if (-not (Test-Path -LiteralPath $folder.FullName)) { continue }

        $relative = $folder.FullName.Substring($prefix.Length)
        if ($keepDirs.Contains($relative)) { continue }

        $keepLeft = @(Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -Force |
            Where-Object { $keepSet.Contains($_.FullName.Substring($prefix.Length)) })
        if ($keepLeft.Count -gt 0) { continue }

        if (-not $DryRun) { Remove-Item -LiteralPath $folder.FullName -Recurse -Force }
        $result.RemovedDirs++
    }

    return $result
}

function Clear-EwarmProject {
    param(
        [string]$Project,
        [switch]$DryRun
    )

    $projFolder = Join-Path $Project 'proj\ewarm'
    $removedFiles = 0
    $removedDirs = 0

    foreach ($pattern in @('*.ewd', '*.ewt')) {
        foreach ($file in @(Get-ChildItem -LiteralPath $projFolder -File -Filter $pattern -Force -ErrorAction SilentlyContinue)) {
            if (-not $DryRun) { Remove-Item -LiteralPath $file.FullName -Force }
            Write-Detail "- proj\ewarm\$($file.Name)"
            $removedFiles++
        }
    }

    $settings = Join-Path $projFolder 'settings'
    if (Test-Path -LiteralPath $settings -PathType Container) {
        $count = @(Get-ChildItem -LiteralPath $settings -Recurse -File -Force -ErrorAction SilentlyContinue).Count
        if (-not $DryRun) { Remove-Item -LiteralPath $settings -Recurse -Force }
        Write-Detail "- proj\ewarm\settings\ ($count file(s))"
        $removedFiles += $count
        $removedDirs++
    }

    $build = Clear-BuildFolder -BuildFolder (Join-Path $projFolder 'build') -KeepFiles $ewarmKeepFiles -DryRun:$DryRun
    if ($build.Exists) {
        Write-Detail ("- proj\ewarm\build\ ({0} file(s), {1} folder(s))" -f $build.RemovedFiles, $build.RemovedDirs)
        $removedFiles += $build.RemovedFiles
        $removedDirs += $build.RemovedDirs
        foreach ($missing in $build.MissingKeeps) {
            Write-Host "    ! proj\ewarm\build\$missing is missing" -ForegroundColor Yellow
        }
    }

    return [pscustomobject]@{ Files = $removedFiles; Folders = $removedDirs }
}

function Clear-MdkProject {
    param(
        [string]$Project,
        [switch]$DryRun
    )

    $projFolder = Join-Path $Project 'proj\mdk'
    $removedFiles = 0
    $removedDirs = 0

    foreach ($file in @(Get-ChildItem -LiteralPath $projFolder -File -Filter '*.uvguix*' -Force -ErrorAction SilentlyContinue)) {
        if (-not $DryRun) { Remove-Item -LiteralPath $file.FullName -Force }
        Write-Detail "- proj\mdk\$($file.Name)"
        $removedFiles++
    }

    $build = Clear-BuildFolder -BuildFolder (Join-Path $projFolder 'build') -KeepFiles $flmKeepFiles -DryRun:$DryRun
    if ($build.Exists) {
        Write-Detail ("- proj\mdk\build\ ({0} file(s), {1} folder(s))" -f $build.RemovedFiles, $build.RemovedDirs)
        $removedFiles += $build.RemovedFiles
        $removedDirs += $build.RemovedDirs
        foreach ($missing in $build.MissingKeeps) {
            Write-Host "    ! proj\mdk\build\$missing is missing" -ForegroundColor Yellow
        }
    }

    return [pscustomobject]@{ Files = $removedFiles; Folders = $removedDirs }
}

Push-Location $PSScriptRoot
try {
    if (-not $Root) { $Root = $PSScriptRoot }

    $rootFull = (Resolve-FullPath $Root).TrimEnd('\')
    if (-not (Test-Path -LiteralPath $rootFull -PathType Container)) {
        throw "Root folder not found: $rootFull"
    }

    $ewarmProjects = Find-ProjectFolder -SearchRoot $rootFull -NameMatch 'ewarm*' -ProjDir 'proj\ewarm'
    $flmProjects = Find-ProjectFolder -SearchRoot $rootFull -NameMatch 'flm*' -ProjDir 'proj\mdk'

    if (($ewarmProjects.Count + $flmProjects.Count) -eq 0) {
        Write-Host ''
        Write-Host "No generator project found below $rootFull." -ForegroundColor Yellow
        return
    }

    Write-Step "Targets below $rootFull"
    foreach ($project in $ewarmProjects) { Write-Detail "ewarm  $(Split-Path -Leaf $project)" }
    foreach ($project in $flmProjects) { Write-Detail "flm    $(Split-Path -Leaf $project)" }

    $publishedRoot = '..\..\validation\flashloader'
    $unpublished = @()
    $unpublished += Get-UnpublishedArtifact -Projects $ewarmProjects -SourceDir 'proj\ewarm\build\out' -Pattern '*.out' -PublishedDir (Join-Path $publishedRoot 'ewarm')
    $unpublished += Get-UnpublishedArtifact -Projects $flmProjects -SourceDir 'proj\mdk\build\flm' -Pattern '*.FLM' -PublishedDir (Join-Path $publishedRoot 'flm')

    if ($unpublished.Count -gt 0) {
        Write-Host ''
        Write-Host ("    ! {0} built image(s) are not in validation\flashloader yet - run collect.ps1 first:" -f $unpublished.Count) -ForegroundColor Yellow
        foreach ($artifact in $unpublished) {
            Write-Host "      $artifact" -ForegroundColor Yellow
        }
    }

    if (-not $DryRun -and -not $Force) {
        Write-Host ''
        Write-Host 'This deletes build output and IDE state files. It cannot be undone.' -ForegroundColor Yellow

        $answer = $null
        try {
            $answer = Read-Host 'Continue? (y/N)'
        } catch {
            $answer = $null
        }

        if ($answer -notmatch '^(y|yes)$') {
            Write-Host 'Aborted. Nothing was deleted (pass -Force to skip this prompt).' -ForegroundColor Yellow
            exit 1
        }
    }

    $totalFiles = 0
    $totalFolders = 0
    $totalProjects = 0

    foreach ($project in $ewarmProjects) {
        Write-Step "Cleaning $(Split-Path -Leaf $project)"
        $result = Clear-EwarmProject -Project $project -DryRun:$DryRun
        $totalFiles += $result.Files
        $totalFolders += $result.Folders
        $totalProjects++
    }

    foreach ($project in $flmProjects) {
        Write-Step "Cleaning $(Split-Path -Leaf $project)"
        $result = Clear-MdkProject -Project $project -DryRun:$DryRun
        $totalFiles += $result.Files
        $totalFolders += $result.Folders
        $totalProjects++
    }

    Write-Step 'Result'
    Write-Detail ("{0} project(s): {1} file(s) and {2} folder(s)" -f $totalProjects, $totalFiles, $totalFolders)

    Write-Host ''
    if ($DryRun) {
        Write-Host "Dry run: nothing was deleted." -ForegroundColor Green
    } else {
        Write-Host 'All done.' -ForegroundColor Green
    }
} finally {
    Pop-Location
}
