"""
BSD 3-Clause License

Copyright (c) 2018, alessandrocomodi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

#
# This ugly script uses a JSON configuration file to produce shell logic within which the user's FPGA kernel is instantiated.
# It produces a TCL script that provide parameters to the Xilinx kernel wizard.
#
# There seems to be no documentation of the JSON format. It corresponds to the CONFIG arguments of the Xilinx wizard.


import os
import sys
import json

def json_to_tcl_config (string):
  append = "set cmd \"set_property -dict \[list "
  try:
    json_file = open(string)
  except:
    print("ERROR: file " + string + " does not exist")
    sys.exit(0)

  try:
    json_data = json.load(json_file)
  except:
    print("ERROR: wrong json format")
    sys.exit(0)

  append += "CONFIG.NUM_CLOCKS {" + str(json_data['clocks']) + "} CONFIG.NUM_RESETS {1} "

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
  print("Usage: ", __file__, " <config-file> <output-file>")
  sys.exit(0)

#lib_dir_path = os.environ['LIB_DIR']
#fn = lib_dir_path + "/src/tcl/rtl_kernel_wiz.tcl"

fh = open(fn, "w")



string = ('# This file has been produced by:' + sys.argv[0] + '\n'
          '#\n'
          '# This tcl script produces User Logic (UL) using the rtl_kernel_wizard,\n'
          '# configured according to JSON configuration parameters reflected in this file.\n'
          '# It is sourced through an invocation of Vivado, with -tclargs of:\n'
          '#   $1: the name of the kernel\n'
          '#   $2: the directory in which to create the project\n'
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
