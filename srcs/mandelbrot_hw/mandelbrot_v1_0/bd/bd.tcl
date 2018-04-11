# This is a generated file. Use and modify at your own risk.
################################################################################
proc init { cell_name undefined_params } {
  set intf [get_bd_intf_pins  $cell_name/m00_axi]
  # Expliciting setting these block interface properties for optimal performance/area/timing.
  set_property CONFIG.SUPPORTS_NARROW_BURST           0            $intf
  set_property CONFIG.SUPPORTS_NARROW_BURST.VALUE_SRC CONSTANT     $intf
  set_property CONFIG.MAX_BURST_LENGTH                64           $intf
  set_property CONFIG.MAX_BURST_LENGTH.VALUE_SRC      CONSTANT     $intf
  set_property CONFIG.NUM_READ_OUTSTANDING            32           $intf
  set_property CONFIG.NUM_READ_OUTSTANDING.VALUE_SRC  CONSTANT     $intf
  set_property CONFIG.NUM_READ_THREADS                1            $intf
  set_property CONFIG.NUM_READ_THREADS.VALUE_SRC      CONSTANT     $intf
  set_property CONFIG.NUM_WRITE_OUTSTANDING           32           $intf
  set_property CONFIG.NUM_WRITE_OUTSTANDING.VALUE_SRC CONSTANT     $intf
  set_property CONFIG.NUM_WRITE_THREADS               1            $intf
  set_property CONFIG.NUM_WRITE_THREADS.VALUE_SRC     CONSTANT     $intf
  set_property CONFIG.HAS_BURST                       0            $intf
  set_property CONFIG.HAS_BURST.VALUE_SRC             CONSTANT     $intf
  set_property CONFIG.HAS_CACHE                       0            $intf
  set_property CONFIG.HAS_CACHE.VALUE_SRC             CONSTANT     $intf


}

# This proc intentionally left blank
proc post_config_ip { cell_name args } {
}

