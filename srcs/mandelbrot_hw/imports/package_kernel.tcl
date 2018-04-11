# This is a generated file. Use and modify at your own risk.
################################################################################
proc package_project {path_to_packaged path_to_project kernel_vendor kernel_library} {

  ipx::package_project -root_dir $path_to_packaged -vendor $kernel_vendor -library $kernel_library -taxonomy /KernelIP -import_files -set_current false
  ipx::unload_core $path_to_packaged/component.xml
  ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $path_to_packaged $path_to_packaged/component.xml
  set_property core_revision 2 [ipx::current_core]
  foreach up [ipx::get_user_parameters] {
    ipx::remove_user_parameter [get_property NAME $up] [ipx::current_core]
  }
  ipx::create_xgui_files [ipx::current_core]
  ipx::associate_bus_interfaces -busif m00_axi -clock ap_clk [ipx::current_core]
  ipx::infer_bus_interface ap_clk_2 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
  ipx::infer_bus_interface ap_rst_n_2 xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

  ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]
  set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [ipx::current_core]
  set_property supported_families { } [ipx::current_core]
  set_property auto_family_support_level level_2 [ipx::current_core]
  set_property used_in {out_of_context implementation synthesis} [ipx::get_files -type xdc -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]] *_ooc.xdc]
  file mkdir $path_to_packaged/bd
  file copy -force $path_to_project/imports/bd.tcl $path_to_packaged/bd/bd.tcl
  set bd_file_group [ipx::add_file_group -type block_diagram xilinx_blockdiagram [ipx::current_core] ]
  ipx::add_file bd/bd.tcl $bd_file_group
  ipx::update_checksums [ipx::current_core]
  ipx::save_core [ipx::current_core]
  close_project -delete

}

set kernel_name    mandelbrot
set kernel_vendor  xilinx
set kernel_library kernel


set path_to_project [get_property DIRECTORY [current_project]]
set ip_name ${kernel_name}_v1_0
set xo_file ${path_to_project}/sdx_imports/${kernel_name}.xo
set kernel_xml_file ${path_to_project}/imports/kernel.xml
set path_to_packaged ${path_to_project}/${ip_name}
puts "INFO: Running package_project command"

if {[catch {package_project $path_to_packaged $path_to_project $kernel_vendor $kernel_library} ret]} {
  puts $ret
  puts "ERROR: Package project failed."
  return 1
} else {
  puts $ret
  puts "INFO: Successfully packaged project into IP: ${path_to_packaged}"
}

# Generate xo file
if {[file exists $xo_file]} {
  file delete -force $xo_file
}
puts "INFO: Running package_xo command"
if {[catch {set xo [package_xo -xo_path $xo_file -kernel_name $kernel_name -ip_directory $path_to_packaged -kernel_xml $kernel_xml_file]} ret]} {
  puts $ret
  puts "ERROR: Package kernel xo failed."
  return 1
} else {
  puts $ret
  puts "INFO: Successfully generated kernel xo file: $xo"
}

