# README: About Cortex-M3 Design Start core files

This folder holds the two ARM Cortex-M3 DesignStart files the FPGA build needs.
They belong to ARM and are **not** committed (see `.gitignore`):

| File | Size | What it is |
| --- | --- | --- |
| `cortexm3ds_logic.v` | ~3.4 MB | Obfuscated Cortex-M3 netlist |
| `CORTEXM3INTEGRATIONDS.v` | ~14 KB | DesignStart integration wrapper |

The DesignStart Eval package ships the core as an obfuscated netlist, not as
readable RTL. The author of this repository does not take responsibility for the
correctness of that netlist.

## How to get them

The files are distributed by ARM under its End User License Agreement, so you
have to accept that agreement before you can download them.

1. Accept ARM's End User License Agreement, download the Cortex-M3 DesignStart
   Eval package `AT421-MN-80001-r0p0-02rel0` from ARM (developer.arm.com) and
   extract it.
2. Copy both files from

   ```
   <package>\m3designstart\logical\cortexm3integration_ds_obs\verilog\
   ```

   into this folder, without renaming them.
