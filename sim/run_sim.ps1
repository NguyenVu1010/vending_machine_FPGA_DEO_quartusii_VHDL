# ============================================================
# run_sim.ps1 — PowerShell wrapper cho GHDL (thay cho `make`)
# Sử dụng: .\run_sim.ps1 <target>
#   Targets: tb_full_adder, tb_alu, tb_fsm, tb_top, clean, all
# Yêu cầu: ghdl trong PATH (kiểm tra: ghdl --version)
# ============================================================

param(
    [Parameter(Position=0)]
    [ValidateSet('tb_full_adder','tb_alu','tb_fsm','tb_top','clean','all','help')]
    [string]$Target = 'help'
)

$ErrorActionPreference = 'Stop'

$GhdlFlags = @('--std=93c','--ieee=synopsys','-fexplicit')
$RtlDir    = '../rtl'

function Invoke-GhdlStep {
    param([string]$Phase, [string[]]$Args)
    Write-Host "+ ghdl -$Phase $($Args -join ' ')" -ForegroundColor DarkGray
    & ghdl "-$Phase" $GhdlFlags $Args
    if ($LASTEXITCODE -ne 0) {
        Write-Host "GHDL failed at phase: $Phase" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

function Run-Testbench {
    param([string[]]$Files, [string]$Tb, [string]$StopTime, [string]$Wave = $null)
    Invoke-GhdlStep -Phase 'a' -Args $Files
    Invoke-GhdlStep -Phase 'e' -Args @($Tb)
    $runArgs = @($Tb, "--stop-time=$StopTime")
    if ($Wave) { $runArgs += "--wave=$Wave" }
    Invoke-GhdlStep -Phase 'r' -Args $runArgs
}

function Show-Usage {
    Write-Host ""
    Write-Host "Usage: .\run_sim.ps1 <target>"
    Write-Host ""
    Write-Host "Targets:"
    Write-Host "  tb_full_adder  - test bench full adder (8 case)"
    Write-Host "  tb_alu         - test bench ALU (14 case)"
    Write-Host "  tb_fsm         - test bench FSM (7 assertion)"
    Write-Host "  tb_top         - integration test (5 scenario)"
    Write-Host "  clean          - xóa GHDL artifact"
    Write-Host "  all            - chạy tất cả 4 test bench tuần tự"
    Write-Host ""
}

function Invoke-Clean {
    Write-Host "Cleaning GHDL artifacts..."
    Get-ChildItem -Path . -Include *.cf,*.o,*.ghw,work-obj93.cf -File -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

switch ($Target) {
    'tb_full_adder' {
        Write-Host "===== tb_full_adder =====" -ForegroundColor Cyan
        Run-Testbench `
            -Files @("$RtlDir/full_adder_1bit.vhd", 'tb_full_adder.vhd') `
            -Tb 'tb_full_adder' -StopTime '1us'
    }
    'tb_alu' {
        Write-Host "===== tb_alu =====" -ForegroundColor Cyan
        Run-Testbench `
            -Files @(
                "$RtlDir/full_adder_1bit.vhd",
                "$RtlDir/adder_3bit.vhd",
                "$RtlDir/alu_3bit.vhd",
                'tb_alu.vhd'
            ) `
            -Tb 'tb_alu' -StopTime '1us'
    }
    'tb_fsm' {
        Write-Host "===== tb_fsm =====" -ForegroundColor Cyan
        Run-Testbench `
            -Files @("$RtlDir/fsm_control.vhd", 'tb_fsm.vhd') `
            -Tb 'tb_fsm' -StopTime '200us'
    }
    'tb_top' {
        Write-Host "===== tb_vending_top =====" -ForegroundColor Cyan
        $rtlModules = @(
            'full_adder_1bit','adder_3bit','alu_3bit','reg_3bit',
            'comparator_3bit','counter_coin','timer_1hz','debouncer',
            'hdu_to_bcd','seven_seg_decoder','fsm_control','vending_top'
        ) | ForEach-Object { "$RtlDir/$_.vhd" }
        Run-Testbench `
            -Files ($rtlModules + 'tb_vending_top.vhd') `
            -Tb 'tb_vending_top' -StopTime '2ms' -Wave 'tb_top.ghw'
    }
    'clean' {
        Invoke-Clean
    }
    'all' {
        Invoke-Clean; & $PSCommandPath 'tb_full_adder'
        Invoke-Clean; & $PSCommandPath 'tb_alu'
        Invoke-Clean; & $PSCommandPath 'tb_fsm'
        Invoke-Clean; & $PSCommandPath 'tb_top'
    }
    default { Show-Usage; exit 1 }
}
