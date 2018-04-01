#
# SoC.tcl: Tcl script for creating project ZJUNIX-SoC
#

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "../src"

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Include source file lists
source fileset.tcl

# Test whether target platform is set
if {[catch { set project_platform }]} {
  puts "ERROR: Target platform not specified. Please set project platform with 'set project_platform <platform>'."
  return 1
}

# Lookup part number for platforms
switch -regexp -- $project_platform {
  "N4DDR"  { set project_part "xc7a100tcsg324-1" }
  "SWORD4" { set project_part "xc7k325tffg676-1" }
  default {
    puts "ERROR: Unknown platform '$project_platform' specified."
	return 1
  }
}

# Set platform-specific configurations
set project_name "SoC_$project_platform"
set rtl_platform [set rtl_$project_platform]
set constr_platform [set constr_$project_platform]
set constr_target [set constr_${project_platform}_target]

puts "INFO: Creating project $project_name for part $project_part"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project $project_name ./$project_name -part $project_part

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
# None

# Set project properties
set obj [get_projects $project_name]
set_property "compxlib.activehdl_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/activehdl" $obj
set_property "compxlib.ies_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/ies" $obj
set_property "compxlib.modelsim_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/modelsim" $obj
set_property "compxlib.questa_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/questa" $obj
set_property "compxlib.riviera_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/riviera" $obj
set_property "compxlib.vcs_compiled_library_dir" "$proj_dir/$project_name.cache/compile_simlib/vcs" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "generate_ip_upgrade_log" "0" $obj
set_property "part" $project_part $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "xpm_libraries" "XPM_CDC XPM_MEMORY" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
add_files -norecurse -fileset $obj $rtl_common
add_files -norecurse -fileset $obj $rtl_platform

# Set 'sources_1' fileset file properties for remote files
set_property "file_type" "Verilog Header" [get_files -of_objects [get_filesets sources_1] $header_common]

# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set_property "top" "Top" [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file_added [add_files -norecurse -fileset $obj $constr_platform]
set file_obj [get_files -of_objects $obj $constr_platform]
set_property "file_type" "XDC" $file_obj

# Set 'constrs_1' fileset properties
set_property "target_constrs_file" $constr_target $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
# None

# Set 'sim_1' fileset file properties for remote files
# None

# Set 'sim_1' fileset file properties for local files
# None

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "Top" $obj
set_property "transport_int_delay" "0" $obj
set_property "transport_path_delay" "0" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part $project_part -flow {Vivado Synthesis 2016} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2016" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "needs_refresh" "1" $obj
set_property "part" $project_part $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part $project_part -flow {Vivado Implementation 2016} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2016" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "needs_refresh" "1" $obj
set_property "part" $project_part $obj
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:$project_name"
