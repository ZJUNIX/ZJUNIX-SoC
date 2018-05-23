#
# fileset.tcl : TCL script recording source files for project ZJUNIX-SoC 
# $origin_dir = ZJUNIX-SoC/src
#

#RTL sources shared across all platforms
set rtl_common [list \
 "[file normalize "$origin_dir/v/Infrastructure/ClockDomainCross.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_CRC.v"]"\
 "[file normalize "$origin_dir/v/CPU/divider.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/FIFO.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_RxUpscaler.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_DataReceiver.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_DataTransmitter.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_TxDownscaler.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_DMA.v"]"\
 "[file normalize "$origin_dir/v/CPU/TLBRNG.v"]"\
 "[file normalize "$origin_dir/v/CPU/TLBDefines.vh"]"\
 "[file normalize "$origin_dir/v/CPU/TLBHeader.v"]"\
 "[file normalize "$origin_dir/v/CPU/TLBEntry.v"]"\
 "[file normalize "$origin_dir/v/CPU/MulDiv.v"]"\
 "[file normalize "$origin_dir/v/CPU/InstDecoder.v"]"\
 "[file normalize "$origin_dir/v/CPU/Cp0Reg.v"]"\
 "[file normalize "$origin_dir/v/CPU/ALU.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_Datapath.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_Cmdpath.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_Clocking.v"]"\
 "[file normalize "$origin_dir/v/SD/SDC_Registers.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/UART.v"]"\
 "[file normalize "$origin_dir/v/CPU/TranslatePredict.v"]"\
 "[file normalize "$origin_dir/v/CPU/TLB.v"]"\
 "[file normalize "$origin_dir/v/CPU/StageMem.v"]"\
 "[file normalize "$origin_dir/v/CPU/StageID.v"]"\
 "[file normalize "$origin_dir/v/CPU/stageEX.v"]"\
 "[file normalize "$origin_dir/v/CPU/Regs.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/PS2Driver.v"]"\
 "[file normalize "$origin_dir/v/CPU/FwdUnit.v"]"\
 "[file normalize "$origin_dir/v/CPU/ExcControl.v"]"\
 "[file normalize "$origin_dir/v/CPU/Cp0.v"]"\
 "[file normalize "$origin_dir/v/Cache/CacheFlags.v"]"\
 "[file normalize "$origin_dir/v/Cache/CacheData.v"]"\
 "[file normalize "$origin_dir/v/CPU/BranchPredictor.v"]"\
 "[file normalize "$origin_dir/v/SD/SDController.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/VRAM.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/VGAScan.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/UARTWrapper.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/ReprogInterface.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/PS2Wrapper.v"]"\
 "[file normalize "$origin_dir/v/CPU/PCPU.v"]"\
 "[file normalize "$origin_dir/v/Cache/ICache.v"]"\
 "[file normalize "$origin_dir/v/Cache/DCache.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/AntiJitter.v"]"\
 "[file normalize "$origin_dir/v/SD/SDWrapper.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/VGADevice.v"]"\
 "[file normalize "$origin_dir/v/CPUCacheTop.v"]"\
 "[file normalize "$origin_dir/v/CPUBus.v"]"\
 "[file normalize "$origin_dir/v/DBusArbiter.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/BiosMem.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/ResetGen.v"]"\
 "[file normalize "$origin_dir/v/Infrastructure/SRAM.v"]"\
]

#RTL sources and IP cores for N4DDR platform
set rtl_N4DDR [list \
 "[file normalize "$origin_dir/platform/N4DDR/Infrastructure_Nexys4.v"]"\
 "[file normalize "$origin_dir/platform/N4DDR/DDR2_wsWrapper.v"]"\
 "[file normalize "$origin_dir/platform/N4DDR/Top.v"]"\
 "[file normalize "$origin_dir/platform/N4DDR/Seg7Device.v"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/DDR/mig_a.prj"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/DDR/mig_b.prj"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/DDR/DDR.xci"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/ClockGen/ClockGen.xci"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/ClockGen_DDR/ClockGen_DDR.xci"]"\
 "[file normalize "$origin_dir/platform/N4DDR/ip/GraphicVRAM/GraphicVRAM.xci"]"\
]

#RTL sources and IP cores for SWORD4 platform
set rtl_SWORD4 [list \
 "[file normalize "$origin_dir/platform/SWORD4/ShiftReg.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/Keypad.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/Seg7Device.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/Infrastructure_Sword.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/Top.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/DDR3_wsWrapper.v"]"\
 "[file normalize "$origin_dir/platform/SWORD4/ip/DDR3/mig_a.prj"]"\
 "[file normalize "$origin_dir/platform/SWORD4/ip/DDR3/mig_b.prj"]"\
 "[file normalize "$origin_dir/platform/SWORD4/ip/DDR3/DDR3.xci"]"\
 "[file normalize "$origin_dir/platform/SWORD4/ip/ClockGen/ClockGen.xci"]"\
 "[file normalize "$origin_dir/platform/SWORD4/ip/GraphicVRAM/GraphicVRAM.xci"]"\
]

#Verilog headers
set header_common [list \
 "[file normalize "$origin_dir/v/CPU/TLBDefines.vh"]"\
]

#Constraints for N4DDR platform
set constr_N4DDR [list \
 "[file normalize "$origin_dir/platform/N4DDR/Nexys4_phy.xdc"]"\
 "[file normalize "$origin_dir/platform/N4DDR/Nexys4_pin.xdc"]"\
]
#Target constraint file for N4DDR platform
set constr_N4DDR_target "[file normalize "$origin_dir/platform/N4DDR/Nexys4_phy.xdc"]"

#Constraints for SWORD4 platform
set constr_SWORD4 [list \
 "[file normalize "$origin_dir/platform/SWORD4/Sword_phy.xdc"]"\
 "[file normalize "$origin_dir/platform/SWORD4/Sword_pin.xdc"]"\
]

#Target constraint file for SWORD4 platform
set constr_SWORD4_target "[file normalize "$origin_dir/platform/SWORD4/Sword_phy.xdc"]"
