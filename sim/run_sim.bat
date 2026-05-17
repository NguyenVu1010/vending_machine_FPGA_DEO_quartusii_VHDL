@echo off
REM ============================================================
REM run_sim.bat — Windows wrapper cho GHDL (thay cho `make`)
REM Sử dụng: run_sim.bat ^<target^>
REM   Targets: tb_full_adder, tb_alu, tb_fsm, tb_top, clean, all
REM ============================================================

setlocal
set "GHDLFLAGS=--std=93c --ieee=synopsys -fexplicit"
set "RTL=..\rtl"

if "%~1"=="" goto :usage
if /i "%~1"=="tb_full_adder"  goto :tb_full_adder
if /i "%~1"=="tb_alu"          goto :tb_alu
if /i "%~1"=="tb_fsm"          goto :tb_fsm
if /i "%~1"=="tb_top"          goto :tb_top
if /i "%~1"=="clean"           goto :clean
if /i "%~1"=="all"             goto :all
goto :usage

:tb_full_adder
echo ===== tb_full_adder =====
ghdl -a %GHDLFLAGS% %RTL%\full_adder_1bit.vhd tb_full_adder.vhd || exit /b 1
ghdl -e %GHDLFLAGS% tb_full_adder || exit /b 1
ghdl -r %GHDLFLAGS% tb_full_adder --stop-time=1us
goto :end

:tb_alu
echo ===== tb_alu =====
ghdl -a %GHDLFLAGS% %RTL%\full_adder_1bit.vhd %RTL%\adder_3bit.vhd %RTL%\alu_3bit.vhd tb_alu.vhd || exit /b 1
ghdl -e %GHDLFLAGS% tb_alu || exit /b 1
ghdl -r %GHDLFLAGS% tb_alu --stop-time=1us
goto :end

:tb_fsm
echo ===== tb_fsm =====
ghdl -a %GHDLFLAGS% %RTL%\fsm_control.vhd tb_fsm.vhd || exit /b 1
ghdl -e %GHDLFLAGS% tb_fsm || exit /b 1
ghdl -r %GHDLFLAGS% tb_fsm --stop-time=200us
goto :end

:tb_top
echo ===== tb_vending_top =====
ghdl -a %GHDLFLAGS% ^
    %RTL%\full_adder_1bit.vhd ^
    %RTL%\adder_3bit.vhd ^
    %RTL%\alu_3bit.vhd ^
    %RTL%\reg_3bit.vhd ^
    %RTL%\comparator_3bit.vhd ^
    %RTL%\counter_coin.vhd ^
    %RTL%\timer_1hz.vhd ^
    %RTL%\debouncer.vhd ^
    %RTL%\hdu_to_bcd.vhd ^
    %RTL%\seven_seg_decoder.vhd ^
    %RTL%\fsm_control.vhd ^
    %RTL%\vending_top.vhd ^
    tb_vending_top.vhd || exit /b 1
ghdl -e %GHDLFLAGS% tb_vending_top || exit /b 1
ghdl -r %GHDLFLAGS% tb_vending_top --stop-time=2ms --wave=tb_top.ghw
goto :end

:clean
echo Cleaning GHDL artifacts...
del /q *.cf *.o *.ghw work-obj93.cf 2>nul
goto :end

:all
call "%~f0" clean
call "%~f0" tb_full_adder || exit /b 1
call "%~f0" clean
call "%~f0" tb_alu || exit /b 1
call "%~f0" clean
call "%~f0" tb_fsm || exit /b 1
call "%~f0" clean
call "%~f0" tb_top || exit /b 1
goto :end

:usage
echo.
echo Usage: run_sim.bat ^<target^>
echo.
echo Targets:
echo   tb_full_adder  - chay test bench full adder (8 case)
echo   tb_alu         - chay test bench ALU (14 case)
echo   tb_fsm         - chay test bench FSM (7 assertion)
echo   tb_top         - chay integration test (5 scenario)
echo   clean          - xoa GHDL artifact
echo   all            - chay tat ca 4 test bench tuan tu
echo.
echo Yeu cau: ghdl phai co trong PATH (kiem tra: ghdl --version)
echo.
exit /b 1

:end
endlocal
