param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$seed = Get-Random -Minimum 0 -Maximum 2147483647
$test = 'bus_icc_regression_test'

$scriptRoot  = $PSScriptRoot
$fpgaDir     = (Resolve-Path (Join-Path $scriptRoot '../../..')).Path
$rtlDir      = Join-Path $fpgaDir 'rym32g1.srcs/rtl/bus_icc'
$simDir      = Join-Path $fpgaDir 'rym32g1.srcs/verification/bus_icc_uvm'
$runDir      = Join-Path $scriptRoot 'run'

function Resolve-Tool {
    param([string]$Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command -and $command.CommandType -eq 'Application') {
        return $command.Source
    } else {
        if ($env:XILINX_VIVADO) {
            $candidatePath = Join-Path $env:XILINX_VIVADO "bin/$Name.bat"
            if (Test-Path -LiteralPath $candidatePath) {
                return $candidatePath
            }
        }
        throw "[ERROR] Please add the Vivado bin directory to PATH or set XILINX_VIVADO. Missing tool: $Name."
    }
}

function Execute-Vivado-Tools {
    param([string]$Name, [string[]]$Arguments)
    & $script:Tools[$Name] @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "[ERROR] $Name failed with exit code $LASTEXITCODE."
    }
}

$script:Tools = @{
    xvlog = Resolve-Tool 'xvlog'
    xelab = Resolve-Tool 'xelab'
    xsim  = Resolve-Tool 'xsim'
    xcrg  = Resolve-Tool 'xcrg'
}
$vivadoRoot = Split-Path (Split-Path $script:Tools.xvlog)
$uvmDir     = Join-Path $vivadoRoot 'data/system_verilog/uvm_1.2'
if (-not $env:XILINX_VIVADO) {
    $env:XILINX_VIVADO = $vivadoRoot
}
if (-not (Test-Path -LiteralPath (Join-Path $uvmDir 'xlnx_uvm_package.sv'))) {
    throw "[ERROR] Bundled UVM source missing under $uvmDir."
}

if (Test-Path -LiteralPath $runDir) {
    Remove-Item -LiteralPath $runDir -Recurse -Force
}

$failure = $null

New-Item -ItemType Directory -Path $runDir -Force | Out-Null
Push-Location $runDir
try {
    $sources = @(
        # UVM library shipped with Vivado
        (Join-Path $uvmDir 'xlnx_uvm_package.sv')
        # RTL package
        (Join-Path $rtlDir 'bus_icc_pkg.sv')
        # Verification packages and interface
        (Join-Path $simDir 'bus_icc_ref_pkg.sv')
        (Join-Path $simDir 'bus_icc_interface.sv')
        (Join-Path $simDir 'bus_icc_env_pkg.sv')
        (Join-Path $simDir 'bus_icc_seq_pkg.sv')
        (Join-Path $simDir 'bus_icc_test_pkg.sv')
        # DUT RTL sources
        (Join-Path $rtlDir 'bus_icc_arbiter.sv')
        (Join-Path $rtlDir 'bus_icc_slave_stage.sv')
        (Join-Path $rtlDir 'bus_icc_default_slave.sv')
        (Join-Path $rtlDir 'bus_icc_decoder.sv')
        (Join-Path $rtlDir 'bus_icc_master_stage.sv')
        (Join-Path $rtlDir 'bus_icc_core.sv')
        (Join-Path $rtlDir 'bus_icc_top.sv')
        # Testbench and checks
        (Join-Path $simDir 'bus_icc_checks.sv')
        (Join-Path $simDir 'bus_icc_tb.sv')
    )

    $xvlogArguments = @(
        '-sv'
        '-d', 'UVM_NO_DPI'
        '-i', $uvmDir
    ) + $sources
    Execute-Vivado-Tools 'xvlog' $xvlogArguments

    $xelabArguments = @(
        'bus_icc_tb'
        '-timescale', '1ns/1ps'
        '-s', 'bus_icc_uvm'
        '-cc_type', 'sbct'
    )
    Execute-Vivado-Tools 'xelab' $xelabArguments

    Write-Host "Bus interconnect UVM verification begin with seed $seed." -ForegroundColor DarkYellow

    $tag = "$test-$seed"
    $logFileName = "verification-$tag.log"
    $xsimArguments = @(
        'bus_icc_uvm'
        '--sv_seed', "$seed"
        '--runall'
        '--log', $logFileName
        '--testplusarg', ('"UVM_TESTNAME=' + $test + '"')
    )
    Execute-Vivado-Tools 'xsim' $xsimArguments

    $text = Get-Content -LiteralPath $logFileName -Raw
    if ($text -notmatch 'BUS_ICC_PASS') {
        Write-Host "[INFO] Bus interconnect UVM verification FAILED: no BUS_ICC_PASS in $logFileName (test=$test seed=$seed)." -ForegroundColor Red
    } elseif ($text -match 'UVM_FATAL\s*:\s*[1-9]' -or $text -match 'UVM_ERROR\s*:\s*[1-9]') {
        Write-Host "[INFO] Bus interconnect UVM verification FAILED: UVM errors reported (test=$test seed=$seed, see $logFileName)." -ForegroundColor Red
    } else {
        Write-Host "[INFO] Bus interconnect UVM verification PASS: $test seed=$seed." -ForegroundColor Green
    }

    $reportArguments = @(
        '-report_format', 'html'
        '-report_dir', 'coverage'
        '-cov_db_dir', $runDir
        '-cov_db_name', 'bus_icc_uvm'
    )
    Execute-Vivado-Tools 'xcrg' $reportArguments
} catch {
    $failure = $_.Exception.Message
} finally {
    Pop-Location
    if ($null -ne $failure) {
        Write-Host ($failure.TrimEnd('.') + '.') -ForegroundColor Red
    }
}

Write-Host 'Bus interconnect UVM verification end.' -ForegroundColor DarkYellow

if ($null -ne $failure) {
    exit 1
} else {
    exit 0
}
