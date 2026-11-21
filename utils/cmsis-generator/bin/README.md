# README

This directory holds two third-party command-line tools that the
[`cmsis-generator`](../) flow depends on. They are proprietary binaries
published by Arm as part of the Keil MDK toolchain, and are intentionally kept
out of version control (see [`.gitignore`](../../../.gitignore)).

## Tools

### `SVDConv.exe` — CMSIS-SVD Converter

SVDConv is the CMSIS-SVD converter command-line tool. It reads a CMSIS-SVD
(System View Description) XML file and generates various output formats,
including device header files (`--generate=header`) and System Function
Description files (`--generate=sfd`). In this project it produces both the `.h`
device header and the `.sfd` file consumed by SfrCC2.

### `SfrCC2.exe` — SFR Converter

SfrCC2 converts a CMSIS-SFD (System Function Description) file into the binary
`.SFR` register file that the µVision debugger uses to display peripheral
registers in the debug view. In this project it is invoked by
[`generate.ps1`](../generate.ps1) to turn the generated `.sfd` file into the
final `.sfr` file.

## Third-Party Tool Copyright

Both tools are proprietary software owned by Arm Limited and distributed as
part of the Keil MDK (µVision) toolchain. They are not open source and are not
covered by the license of this repository. Their use and redistribution are
governed by the Keil MDK End User License Agreement (EULA).

## How to obtain

Install Keil MDK-ARM from Arm:

- <https://www.keil.com/download/product/>

After installation, copy `SfrCC2.exe` and `SVDConv.exe` from the MDK `UV4`
directory into this folder, so that
[`generate.ps1`](../generate.ps1) can find them next to
`cmsis-svd-generator.exe`.
