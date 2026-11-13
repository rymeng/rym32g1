set_property IS_ENABLED 0 [get_drc_checks {DPIP-1 DPIP-2 DPIP-3}]
set_property IS_ENABLED 0 [get_drc_checks {DPOP-1 DPOP-2}]

set_property IS_ENABLED 0 [get_drc_checks {REQP-1839 REQP-1840}]

# ZPS7-1: pure PL design, Zynq PS deliberately unused (no ps7 instance)
set_property IS_ENABLED 0 [get_drc_checks {ZPS7-1}]