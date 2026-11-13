set_switching_activity -static_probability 1.0 -toggle_rate 0.0 [get_nets -quiet -hier -filter {NAME =~ *rst_n* || NAME =~ *reset_n*}]
