# ZJUNIX-SoC

A simple System-on-Chip built on an FPGA, originally targeted at Zhejiang University's SWORD4 FPGA experiment platform. It is designed to support simple operating systems developed by students; the first operating system running on this SoC is [ZJUNIX](https://github.com/ZJUNIX/ZJUNIX).

Detailed documentation is currently in progress; a general description is provided in doc/SoC.md.

# Lisence

[BSD-3-Clause](./LICENSE)

# Creating the project

Follow these steps to create the SoC project from this repository:

1. Launch Vivado and open the TCL console.
2. Navigate to the ```project``` directory with the ```cd``` command.
   Note: The path to this directory should not contain spaces or non-ascii characters
3. Type ```source SoC_<platform>.tcl``` , where \<platform\> stands for the target platform; currently SWORD4 and N4 are supported.


Example:

![](doc/image/create_project.png)

