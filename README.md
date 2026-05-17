# Vending Machine — VHDL trên DE0 (bản tối giản)

Máy bán hàng tự động 2 sản phẩm (A=$1.00, B=$1.50), nhận $0.50/lần qua BUTTON0. Thiết kế VHDL-93 cho Altera DE0 (Cyclone III EP3C16F484C6).

## Cấu trúc

```
rtl/             12 module VHDL (top = vending_top)
sim/             4 test bench + Makefile/wrapper
quartus/         project (.qpf/.qsf/.sdc) + Tcl tái tạo
```

## Cài đặt

### Trên Linux / macOS

```bash
sudo apt install ghdl gtkwave        # Ubuntu/Debian
# brew install ghdl gtkwave          # macOS
```
Cài Quartus II 13.0.1 Web Edition từ trang Altera (legacy).

### Trên Windows 10/11

| Phần mềm | Cách cài | Test sau khi cài |
|---|---|---|
| **Quartus II 13.0.1 Web Edition** | Tải từ [Intel/Altera Legacy](https://www.intel.com/content/www/us/en/software-kit/711790/intel-quartus-ii-web-edition-design-software-version-13-0sp1-for-windows.html) | Mở `Quartus II 13.0sp1 → Quartus II 32-bit` |
| **GHDL** (cho mô phỏng) | Tải `ghdl-X.X-mcode-mingw64.zip` từ [github.com/ghdl/ghdl/releases](https://github.com/ghdl/ghdl/releases). Giải nén vào `C:\ghdl\`, thêm `C:\ghdl\bin` vào PATH | `ghdl --version` |
| **GTKWave** (xem waveform) | Tải installer Windows từ [gtkwave.sourceforge.net](http://gtkwave.sourceforge.net) | `gtkwave --version` |
| **Git for Windows** (clone repo) | [git-scm.com/download/win](https://git-scm.com/download/win) | `git --version` trong Git Bash |

> Trên Windows **không cần** cài `make` — repo đã có wrapper `run_sim.bat` (cmd) và `run_sim.ps1` (PowerShell).

## Chạy mô phỏng

### Linux / macOS / Git Bash

```bash
cd sim
make tb_full_adder    # 8 case full adder
make tb_alu           # 14 case ALU ADD/SUB
make tb_fsm           # 7 assertion FSM
make tb_top           # 5 scenario end-to-end + sinh tb_top.ghw
gtkwave tb_top.ghw    # xem waveform
make clean            # xóa artifact
```

### Windows cmd.exe

```cmd
cd sim
run_sim.bat tb_full_adder
run_sim.bat tb_alu
run_sim.bat tb_fsm
run_sim.bat tb_top
run_sim.bat clean
run_sim.bat all              :: chạy tất cả 4 test bench tuần tự

gtkwave tb_top.ghw
```

### Windows PowerShell

```powershell
cd sim
.\run_sim.ps1 tb_full_adder
.\run_sim.ps1 tb_alu
.\run_sim.ps1 tb_fsm
.\run_sim.ps1 tb_top
.\run_sim.ps1 clean
.\run_sim.ps1 all

gtkwave tb_top.ghw
```

> Lần đầu chạy `.ps1` có thể bị block — `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` để bypass cho phiên hiện tại.

Mỗi target in `ALL CASES PASSED` hoặc `ALL SCENARIOS COMPLETED`.

## Tổng hợp Quartus

### Cả Linux & Windows (lệnh giống nhau)

```bash
cd quartus
quartus_sh --flow compile vending
```

Output: `quartus/vending.sof`. Resource ~167 LE, 96 register, timing slack +15 ns.

Nếu file `vending.qpf` / `vending.qsf` bị mất, tái tạo:
```bash
cd quartus
quartus_sh -t create_project.tcl
```

Hoặc dùng GUI: mở `quartus/vending.qpf` → `Processing → Start Compilation`.

## I/O DE0

| Tín hiệu | Pin | Vai trò |
|---|---|---|
| `clk` | PIN_G21 (CLOCK_50) | 50 MHz |
| `sw[0]` | SW0 | Reset đồng bộ |
| `sw[8]` | SW8 | Display: 0=balance, 1=coin trả |
| `sw[9]` | SW9 | Cancel |
| `btn[0]` | BUTTON0 | +$0.50 |
| `btn[1]` | BUTTON1 | Mua A ($1.00) |
| `btn[2]` | BUTTON2 | Mua B ($1.50) |
| `hex2.hex1.hex0` | HEX2..HEX0 | `D.CC` hiển thị giá |
| `ledg[0/1]` | LEDG0/1 | Đang nhả A/B |
| `ledg[2]` | LEDG2 | Insufficient |
| `ledg[3]` | LEDG3 | Pulse mỗi lần thối $0.50 |
| `ledg[9]` | LEDG9 | IDLE |

## Nạp DE0

### Linux / Windows (lệnh giống nhau)

```bash
quartus_pgm -l                          # liệt kê USB-Blaster
cd quartus
quartus_pgm -m jtag -o "p;vending.sof"  # nạp
```

Trên Windows có thể cần driver USB-Blaster (đi kèm Quartus installer).

### Test trên board

1. Gạt SW0 ↑ rồi ↓ → reset, HEX hiển thị `0.00`, LEDG9 sáng.
2. BUTTON0 ×2 → HEX `1.00`. BUTTON1 → LEDG0 sáng 1 s → HEX `0.00`.
3. BUTTON0 ×4 → HEX `2.00`. BUTTON2 → LEDG1 1 s → LEDG3 nháy 1 lần → HEX `0.00`. SW8 ↑ → HEX `0.50` (đã thối).
4. BUTTON0 ×1, BUTTON1 → LEDG2 sáng 1 s.
5. BUTTON0 ×3, SW9 ↑ → LEDG3 nháy 3 lần.

## Khắc phục sự cố

### `make: *** missing separator. Stop.` (Linux)
File Makefile đã có CRLF do edit trên Windows. Fix:
```bash
sed -i 's/\r$//' sim/Makefile
```
(Repo đã có `.gitattributes` ép LF khi clone — vấn đề chỉ xảy ra nếu edit thủ công).

### `ghdl: command not found`
Chưa cài GHDL hoặc chưa thêm vào PATH. Linux: `sudo apt install ghdl`. Windows: thêm `C:\ghdl\bin` vào biến môi trường PATH (Settings → System → Advanced system settings → Environment Variables).

### `.\run_sim.ps1: cannot be loaded because running scripts is disabled` (PowerShell)
Bypass execution policy cho phiên hiện tại:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\run_sim.ps1 tb_top
```

### Quartus không thấy USB-Blaster (Windows)
Mở Device Manager → cài lại driver từ `C:\altera\13.0sp1\quartus\drivers\usb-blaster\`.

### Quartus báo lỗi libpng12 (Linux Ubuntu 22.04+)
```bash
cd /tmp && wget http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_i386.deb
mkdir libpng12-extract && dpkg-deb -x libpng12-0_1.2.54-1ubuntu1_i386.deb libpng12-extract/
sudo cp -P libpng12-extract/lib/i386-linux-gnu/libpng12.so.* /usr/lib/i386-linux-gnu/
sudo ldconfig
```
