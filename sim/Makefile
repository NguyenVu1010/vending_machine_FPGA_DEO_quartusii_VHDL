# sim/Makefile — chạy test bench bằng GHDL
# Dùng: make tb_full_adder, make tb_alu, make tb_fsm, make tb_top, make clean

GHDL      = ghdl
GHDLFLAGS = --std=93c --ieee=synopsys -fexplicit
RTL_DIR   = ../rtl

RTL_SRCS  = $(RTL_DIR)/full_adder_1bit.vhd \
            $(RTL_DIR)/adder_3bit.vhd \
            $(RTL_DIR)/alu_3bit.vhd \
            $(RTL_DIR)/reg_3bit.vhd \
            $(RTL_DIR)/comparator_3bit.vhd \
            $(RTL_DIR)/counter_coin.vhd \
            $(RTL_DIR)/timer_1hz.vhd \
            $(RTL_DIR)/debouncer.vhd \
            $(RTL_DIR)/hdu_to_bcd.vhd \
            $(RTL_DIR)/seven_seg_decoder.vhd \
            $(RTL_DIR)/fsm_control.vhd \
            $(RTL_DIR)/vending_top.vhd

.PHONY: tb_full_adder tb_alu tb_fsm tb_top clean

tb_full_adder:
	$(GHDL) -a $(GHDLFLAGS) $(RTL_DIR)/full_adder_1bit.vhd tb_full_adder.vhd
	$(GHDL) -e $(GHDLFLAGS) tb_full_adder
	$(GHDL) -r $(GHDLFLAGS) tb_full_adder --stop-time=1us

tb_alu:
	$(GHDL) -a $(GHDLFLAGS) $(RTL_DIR)/full_adder_1bit.vhd $(RTL_DIR)/adder_3bit.vhd $(RTL_DIR)/alu_3bit.vhd tb_alu.vhd
	$(GHDL) -e $(GHDLFLAGS) tb_alu
	$(GHDL) -r $(GHDLFLAGS) tb_alu --stop-time=1us

tb_fsm:
	$(GHDL) -a $(GHDLFLAGS) $(RTL_DIR)/fsm_control.vhd tb_fsm.vhd
	$(GHDL) -e $(GHDLFLAGS) tb_fsm
	$(GHDL) -r $(GHDLFLAGS) tb_fsm --stop-time=200us

tb_top:
	$(GHDL) -a $(GHDLFLAGS) $(RTL_SRCS) tb_vending_top.vhd
	$(GHDL) -e $(GHDLFLAGS) tb_vending_top
	$(GHDL) -r $(GHDLFLAGS) tb_vending_top --stop-time=2ms --wave=tb_top.ghw

clean:
	$(GHDL) --remove
	rm -f *.cf *.o *.ghw work-obj93.cf
