# Vending Machine — VHDL trên DE0 (bản tối giản)

Máy bán hàng tự động 2 sản phẩm (A=$1.00, B=$1.50), nhận $0.50/lần qua BUTTON0. Thiết kế VHDL-93 cho Altera DE0 (Cyclone III EP3C16F484C6).

## Cấu trúc

```
rtl/             12 module VHDL (top = vending_top)
sim/             4 test bench + Makefile (GHDL)
quartus/         project file (.qpf, .qsf, .sdc) + Tcl tái tạo
```

## Yêu cầu

- `ghdl` ≥ 1.0 (`sudo apt install ghdl gtkwave`)
- Quartus II 13.0.1 Web Edition (Cyclone III)

## Chạy mô phỏng

```bash
cd sim
make tb_full_adder    # 8 case full adder
make tb_alu           # 14 case ALU ADD/SUB
make tb_fsm           # 7 assertion FSM
make tb_top           # 5 scenario end-to-end + sinh tb_top.ghw
gtkwave tb_top.ghw    # xem waveform
make clean            # xóa artifact
```

Mỗi target in `ALL CASES PASSED` hoặc `ALL SCENARIOS COMPLETED`.

## Tổng hợp Quartus

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

```bash
quartus_pgm -l                          # liệt kê USB-Blaster
cd quartus
quartus_pgm -m jtag -o "p;vending.sof"  # nạp
```

Test trên board:
1. Gạt SW0 ↑ rồi ↓ → reset, HEX hiển thị `0.00`, LEDG9 sáng.
2. BUTTON0 ×2 → HEX `1.00`. BUTTON1 → LEDG0 sáng 1 s → HEX `0.00`.
3. BUTTON0 ×4 → HEX `2.00`. BUTTON2 → LEDG1 1 s → LEDG3 nháy 1 lần → HEX `0.00`. SW8 ↑ → HEX `0.50` (đã thối).
4. BUTTON0 ×1, BUTTON1 → LEDG2 sáng 1 s.
5. BUTTON0 ×3, SW9 ↑ → LEDG3 nháy 3 lần.
