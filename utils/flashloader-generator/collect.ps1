[CmdletBinding()]
param(
    [string]$Root,
    [string]$DestinationRoot,
    [switch]$Copy,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$projectRules = @(
    [pscustomobject]@{
        Kind      = 'ewarm'
        NameMatch = 'ewarm*'
        ProjDir   = 'proj\ewarm'
        SourceDir = 'proj\ewarm\build\out'
        Pattern   = '*.out'
    },
    [pscustomobject]@{
        Kind      = 'flm'
        NameMatch = 'flm*'
        ProjDir   = 'proj\mdk'
        SourceDir = 'proj\mdk\build\flm'
        Pattern   = '*.FLM'
    }
)

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

Push-Location $PSScriptRoot
try {
    if (-not $Root) { $Root = $PSScriptRoot }
    if (-not $DestinationRoot) { $DestinationRoot = '..\..\validation\flashloader' }

    $rootFull = (Resolve-FullPath $Root).TrimEnd('\')
    if (-not (Test-Path -LiteralPath $rootFull -PathType Container)) {
        throw "Root folder not found: $rootFull"
    }
    $destFull = (Resolve-FullPath $DestinationRoot).TrimEnd('\')

    Write-Step "Scanning $rootFull"
    Write-Detail "target : $destFull"

    $plan = @()
    $conflicts = @()
    $takenDestinations = @{}

    foreach ($rule in $projectRules) {
        $projects = Find-ProjectFolder -SearchRoot $rootFull -NameMatch $rule.NameMatch -ProjDir $rule.ProjDir
        if ($projects.Count -eq 0) {
            Write-Detail "$($rule.Kind): no '$($rule.NameMatch)' project folder found"
            continue
        }

        foreach ($project in $projects) {
            $projectName = Split-Path -Leaf $project
            $sourceDir = Join-Path $project $rule.SourceDir

            if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
                Write-Detail "$projectName : no $($rule.SourceDir) - skipped"
                continue
            }

            $files = @(Get-ChildItem -LiteralPath $sourceDir -File -Filter $rule.Pattern -Force -ErrorAction SilentlyContinue)
            if ($files.Count -eq 0) {
                Write-Detail "$projectName : no $($rule.Pattern) file - skipped"
                continue
            }

            $destDir = Join-Path $destFull $rule.Kind
            foreach ($file in $files) {
                $destPath = Join-Path $destDir $file.Name
                $key = $destPath.ToLowerInvariant()

                if ($takenDestinations.ContainsKey($key)) {
                    $conflicts += ("{0} and {1} both map to {2}" -f $takenDestinations[$key], $file.FullName, $destPath)
                    continue
                }

                $takenDestinations[$key] = $file.FullName
                $plan += [pscustomobject]@{
                    Kind     = $rule.Kind
                    Project  = $projectName
                    Source   = $file.FullName
                    DestDir  = $destDir
                    DestPath = $destPath
                }
            }
        }
    }

    if ($conflicts.Count -gt 0) {
        Write-Step 'Name conflicts (kept the first source, the rest was left alone)'
        foreach ($conflict in $conflicts) {
            Write-Host "    $conflict" -ForegroundColor Yellow
        }
    }

    if ($plan.Count -eq 0) {
        Write-Host ''
        Write-Host "Nothing to collect below $rootFull." -ForegroundColor Yellow
        if ($conflicts.Count -gt 0) { exit 1 }
        return
    }

    $verb = if ($Copy) { 'copy' } else { 'move' }
    Write-Step ("$($plan.Count) file(s) to $verb")

    $done = @()
    foreach ($item in $plan) {
        $srcRel = $item.Source.Substring($rootFull.Length + 1)
        $dstRel = $item.DestPath.Substring($destFull.Length + 1)

        if ($DryRun) {
            Write-Detail "(dry run) $verb $srcRel -> $dstRel"
            $done += $item
            continue
        }

        if ($item.Source -eq $item.DestPath) {
            Write-Detail "already in place: $dstRel"
            continue
        }

        if (-not (Test-Path -LiteralPath $item.DestDir -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $item.DestDir -Force
        }
        if (Test-Path -LiteralPath $item.DestPath) {
            Remove-Item -LiteralPath $item.DestPath -Force
        }

        if ($Copy) {
            Copy-Item -LiteralPath $item.Source -Destination $item.DestPath -Force
        } else {
            Move-Item -LiteralPath $item.Source -Destination $item.DestPath
        }

        Write-Detail "$verb $srcRel -> $dstRel"
        $done += $item
    }

    Write-Step 'Result'
    foreach ($rule in $projectRules) {
        $count = @($done | Where-Object { $_.Kind -eq $rule.Kind }).Count
        Write-Detail ("{0,-5} {1} file(s) -> {2}" -f $rule.Kind, $count, (Join-Path $destFull $rule.Kind))
    }

    Write-Host ''
    if ($DryRun) {
        Write-Host "Dry run: nothing was changed." -ForegroundColor Green
    } else {
        Write-Host "All done: $($done.Count) file(s) published." -ForegroundColor Green
    }

    if ($conflicts.Count -gt 0) {
        Write-Host "Finished with $($conflicts.Count) name conflict(s); resolve them and rerun." -ForegroundColor Yellow
        exit 1
    }
} finally {
    Pop-Location
}
