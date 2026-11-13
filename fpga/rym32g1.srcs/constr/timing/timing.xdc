create_clock -period 20.000  -name refclk_i  [get_ports {refclk_i}]
create_clock -period 200.000 -name swclk_i    [get_ports {swclk_i}]
create_clock -period 100.000 -name io_ref_clk

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks refclk_i] -group [get_clocks swclk_i]

set_false_path -from [get_ports {porst_n_i xrst_n_i}]

set_input_delay  -clock swclk_i -max 80.000 [get_ports {swdio_io}]
set_input_delay  -clock swclk_i -min 2.000  [get_ports {swdio_io}]
set_input_delay  -clock swclk_i -max 80.000 [get_ports {tdi_i ntrst_n_i}]
set_input_delay  -clock swclk_i -min 2.000  [get_ports {tdi_i ntrst_n_i}]
set_output_delay -clock swclk_i -max 70.000 [get_ports {swdio_io}]
set_output_delay -clock swclk_i -min 0.000  [get_ports {swdio_io}]
set_output_delay -clock swclk_i -max 70.000 [get_ports {tdo_o ntdoen_o}]
set_output_delay -clock swclk_i -min 0.000  [get_ports {tdo_o ntdoen_o}]

set_input_delay  -clock io_ref_clk -max 80.000 [get_ports {port_a_io[*] port_b_io[*]}]
set_input_delay  -clock io_ref_clk -min 2.000  [get_ports {port_a_io[*] port_b_io[*]}]
set_output_delay -clock io_ref_clk -max 70.000 [get_ports {trace_clk_o trace_data_o[*] swv_o}]
set_output_delay -clock io_ref_clk -min 0.000  [get_ports {trace_clk_o trace_data_o[*] swv_o}]
set_output_delay -clock io_ref_clk -max 70.000 [get_ports {port_a_io[*] port_b_io[*]}]
set_output_delay -clock io_ref_clk -min 0.000  [get_ports {port_a_io[*] port_b_io[*]}]
