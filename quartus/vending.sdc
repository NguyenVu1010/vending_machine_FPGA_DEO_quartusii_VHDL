create_clock -name CLOCK_50 -period 20.0 [get_ports {clk}]
derive_clock_uncertainty
