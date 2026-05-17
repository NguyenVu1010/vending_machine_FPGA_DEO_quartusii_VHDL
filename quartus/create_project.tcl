# quartus/create_project.tcl — tạo project từ đầu
package require ::quartus::project

project_new vending -overwrite
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name TOP_LEVEL_ENTITY vending_top
set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993
set_global_assignment -name SDC_FILE vending.sdc

foreach f { full_adder_1bit.vhd adder_3bit.vhd alu_3bit.vhd \
            reg_3bit.vhd comparator_3bit.vhd counter_coin.vhd \
            timer_1hz.vhd debouncer.vhd hdu_to_bcd.vhd \
            seven_seg_decoder.vhd fsm_control.vhd vending_top.vhd } {
    set_global_assignment -name VHDL_FILE ../rtl/$f
}

project_close
