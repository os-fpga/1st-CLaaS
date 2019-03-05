#
# This file produces the script that will be used to generate the RTL kernel project
# The JSON file that contains the configuration of the kernel interface is needed
#

import os
import sys
import json

def json_to_tcl_config (string):
  append = "set cmd \"set_property -dict \[list "
  try: 
    json_file = open(string)
  except:
    print "ERROR: file " + string + " does not exist"
    sys.exit(0)

  try:
    json_data = json.load(json_file)
  except:
    print "ERROR: wrong json format"
    sys.exit(0)

  append += "CONFIG.NUM_CLOCKS {" + str(json_data['clocks']) + "} "

  append += "CONFIG.NUM_INPUT_ARGS {" + str(len(json_data['args'])) + "} "
  for index in range(len(json_data['args'])):
    append += "CONFIG.ARG0" + str(index) + "_NAME {" + str(json_data['args'][index]['id']) + "} "

  append += "CONFIG.NUM_M_AXI {" + str(len(json_data['master'])) + "} "
  for index in range(len(json_data['master'])):
    append += "CONFIG.M0" + str(index) + "_AXI_NUM_ARGS {" + str(len(json_data['master'][index]['port'])) + "} "
    for j in range(len(json_data['master'][index]['port'])):
      append += "CONFIG.M0" + str(index) + "_AXI_ARG0" + str(j) + "_NAME {" + str(json_data['master'][index]['port'][j]['id']) + "} "

  append += "CONFIG.KERNEL_NAME {$kernelName} CONFIG.KERNEL_VENDOR {$kernelVendor}] \[get_ips $kernelName]\"\n"
  return append

if len(sys.argv) > 2:
  config_file = sys.argv[1]
  fn = sys.argv[2]
else:
  print "Usage: ", __file__, " <config-file> <output-file>"
  sys.exit(0)

#lib_dir_path = os.environ['LIB_DIR']
#fn = lib_dir_path + "/src/tcl/rtl_kernel_wiz.tcl"

fh = open(fn, "w")



string = ('# This file has been automatically produced by the python script\n'
          '#\n' 
          '# This tcl file produces a rtl_kernel_wizard\n'
          '# Usage:  insert the name of the kernel and the workspace where to create the project.\n'
          '#         According to the different configurations (Master ports and arguments) the\n'
          '#         produced verilog files and the host program will change\n'
          '\n'
          '# Configuration variables\n'
          'set kernelName [lindex $argv 0]\n'
          'set workspace [lindex $argv 1]\n'
          'set kernelVendor xilinx\n'
          '\n'
          'set kernelPrjName ${kernelName}_ex\n'
          'set wizardDir $workspace/kernel_wizard\n'
          'set kernelDir $workspace/$kernelPrjName\n'
          '\n'
          '# We first create a dummy project for the kernel wizard, which will create the\n'
          '# actual kernel project\n'
          'create_project kernel_wizard $wizardDir -force\n'
          '\n'
          '# Instantiate the SDx kernel wizard IP\n'
          'create_ip -name sdx_kernel_wizard -vendor xilinx.com -library ip -module_name $kernelName\n\n')

string += json_to_tcl_config(config_file)

string += ('eval $cmd\n'
          'set kernelXci $wizardDir/kernel_wizard.srcs/sources_1/ip/$kernelName/$kernelName.xci\n'
          '\n'
          '# Generate kernel wizard IP core\n'
          'generate_target {instantiation_template} [get_files $kernelXci]\n'
          'set_property generate_synth_checkpoint false [get_files $kernelXci]\n'
          'generate_target all [get_files $kernelXci]\n'
          '# Reopen project to generate cache\n'
          'close_project\n'
          'open_project $wizardDir/kernel_wizard.xpr\n'
          '\n'
          '# Export files (potentially a lot of things can be removed here)\n'
          'export_ip_user_files -of_objects [get_files $kernelXci] -no_script -sync -force -quiet\n'
          'export_simulation -of_objects [get_files $kernelXci] -directory $wizardDir/kernel_wizard.ip_user_files/sim_scripts -ip_user_files_dir $wizardDir/kernel_wizard.ip_user_files -ipstatic_source_dir $wizardDir/kernel_wizard.ip_user_files/ipstatic -lib_map_path [list {modelsim=$wizardDir/kernel_wizard.cache/compile_simlib/modelsim} {questa=$wizardDir/kernel_wizard.cache/compile_simlib/questa} {ies=$wizardDir/kernel_wizard.cache/compile_simlib/ies} {vcs=$wizardDir/kernel_wizard.cache/compile_simlib/vcs} {riviera=$wizardDir/kernel_wizard.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet\n'
          '\n'
          '# The IP will generate a script to generate the example project, which we now\n'
          '# source. This implicitly closes the wizard project and opens the kernel\n'
          '# project instead\n'
          'open_example_project -force -dir $workspace [get_ips $kernelName]\n'
          '\n'
          '\n'
          '# Close and clean up wizard project\n'
          'close_project\n'
          '\n'
          'open_project $kernelDir/$kernelPrjName\n'
          'source $kernelDir/imports/package_kernel.tcl\n'
          'file delete -force $wizardDir\n')

fh.write(string)