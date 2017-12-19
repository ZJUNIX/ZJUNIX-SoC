create_pblock pblock_ddr
add_cells_to_pblock [get_pblocks pblock_ddr] [get_cells -quiet [list ddr2/ddr_inst]]
resize_pblock [get_pblocks pblock_ddr] -add {CLOCKREGION_X1Y1:CLOCKREGION_X1Y1}
create_pblock pblock_cpu
add_cells_to_pblock [get_pblocks pblock_cpu] [get_cells -quiet [list core/cpu]]
resize_pblock [get_pblocks pblock_cpu] -add {SLICE_X52Y100:SLICE_X89Y149}
resize_pblock [get_pblocks pblock_cpu] -add {DSP48_X1Y40:DSP48_X2Y59}
resize_pblock [get_pblocks pblock_cpu] -add {RAMB18_X1Y40:RAMB18_X3Y59}
resize_pblock [get_pblocks pblock_cpu] -add {RAMB36_X1Y20:RAMB36_X3Y29}
create_pblock pblock_cache
add_cells_to_pblock [get_pblocks pblock_cache] [get_cells -quiet [list core/dcache core/icache]]
resize_pblock [get_pblocks pblock_cache] -add {RAMB18_X1Y20:RAMB18_X3Y59}
resize_pblock [get_pblocks pblock_cache] -add {RAMB36_X1Y10:RAMB36_X3Y29}

#create_pblock pblock_CPU
#add_cells_to_pblock [get_pblocks pblock_CPU] [get_cells -quiet [list cpu0]]
#resize_pblock [get_pblocks pblock_CPU] -add {SLICE_X0Y0:SLICE_X51Y49}
#resize_pblock [get_pblocks pblock_CPU] -add {DSP48_X0Y0:DSP48_X0Y19}
#resize_pblock [get_pblocks pblock_CPU] -add {RAMB18_X0Y0:RAMB18_X0Y19}
#resize_pblock [get_pblocks pblock_CPU] -add {RAMB36_X0Y0:RAMB36_X0Y9}

set_false_path -from [get_clocks -of_objects [get_pins infrastructure/C0/inst/mmcm_adv_inst/CLKOUT3]] -to [get_clocks -of_objects [get_pins infrastructure/C0/inst/mmcm_adv_inst/CLKOUT0]]

set_operating_conditions -airflow 0
set_operating_conditions -board_layers 4to7
set_operating_conditions -board small
set_operating_conditions -heatsink none

set_property IOB true [get_cells sdc/sd/sd_data_serial_host0/DAT_oe_o_reg]
set_property IOB true [get_cells sdc/sd/sd_data_serial_host0/DAT_dat_o_reg*]
set_property IOB true [get_cells sdc/sd/sd_data_serial_host0/DAT_dat_reg_reg*]
set_property IOB true [get_cells sdc/sd/cmd_serial_host0/cmd_oe_o_reg]
set_property IOB true [get_cells sdc/sd/cmd_serial_host0/cmd_out_o_reg]
set_property IOB true [get_cells sdc/sd/cmd_serial_host0/cmd_dat_reg_reg]
set_property IOB true [get_cells vga/U0/HSync_reg]
set_property IOB true [get_cells vga/U0/VSync_reg]
set_property IOB true [get_cells vga/U0/videoOut_reg*]
