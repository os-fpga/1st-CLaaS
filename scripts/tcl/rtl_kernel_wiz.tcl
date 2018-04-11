# This file has been automatically produced by the python script
#
# This tcl file produces a rtl_kernel_wizard
# Usage:  insert the name of the kernel and the workspace where to create the project.
#         According to the different configurations (Master ports and arguments) the
#         produced verilog files and the host program will change

# Configuration variables
set kernelName [lindex $argv 0]
set workspace [lindex $argv 1]
set kernelVendor xilinx

set kernelPrjName ${kernelName}_ex
set wizardDir $workspace/kernel_wizard
set kernelDir $workspace/$kernelPrjName

# We first create a dummy project for the kernel wizard, which will create the
# actual kernel project
create_project kernel_wizard $wizardDir -force

# Instantiate the SDx kernel wizard IP
create_ip -name sdx_kernel_wizard -vendor xilinx.com -library ip -module_name $kernelName

set cmd "set_property -dict \[list CONFIG.NUM_CLOCKS {2} CONFIG.NUM_INPUT_ARGS {1} CONFIG.ARG00_NAME {ctrl_length} CONFIG.NUM_M_AXI {1} CONFIG.M00_AXI_NUM_ARGS {1} CONFIG.M00_AXI_ARG00_NAME {a} CONFIG.KERNEL_NAME {$kernelName} CONFIG.KERNEL_VENDOR {$kernelVendor}] \[get_ips $kernelName]"
eval $cmd
set kernelXci $wizardDir/kernel_wizard.srcs/sources_1/ip/$kernelName/$kernelName.xci

# Generate kernel wizard IP core
generate_target {instantiation_template} [get_files $kernelXci]
set_property generate_synth_checkpoint false [get_files $kernelXci]
generate_target all [get_files $kernelXci]
# Reopen project to generate cache
close_project
open_project $wizardDir/kernel_wizard.xpr

# Export files (potentially a lot of things can be removed here)
export_ip_user_files -of_objects [get_files $kernelXci] -no_script -sync -force -quiet
export_simulation -of_objects [get_files $kernelXci] -directory $wizardDir/kernel_wizard.ip_user_files/sim_scripts -ip_user_files_dir $wizardDir/kernel_wizard.ip_user_files -ipstatic_source_dir $wizardDir/kernel_wizard.ip_user_files/ipstatic -lib_map_path [list {modelsim=$wizardDir/kernel_wizard.cache/compile_simlib/modelsim} {questa=$wizardDir/kernel_wizard.cache/compile_simlib/questa} {ies=$wizardDir/kernel_wizard.cache/compile_simlib/ies} {vcs=$wizardDir/kernel_wizard.cache/compile_simlib/vcs} {riviera=$wizardDir/kernel_wizard.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# The IP will generate a script to generate the example project, which we now
# source. This implicitly closes the wizard project and opens the kernel
# project instead
open_example_project -force -dir $workspace [get_ips $kernelName]


# Close and clean up wizard project
close_project

open_project $kernelDir/$kernelPrjName
source $kernelDir/imports/package_kernel.tcl
file delete -force $wizardDir
