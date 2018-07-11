onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib slv_m00_axi_vip_opt

do {wave.do}

view wave
view structure
view signals

do {slv_m00_axi_vip.udo}

run -all

quit -force
