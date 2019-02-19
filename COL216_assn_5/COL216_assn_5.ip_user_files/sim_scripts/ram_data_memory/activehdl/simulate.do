onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ram_data_memory -L dist_mem_gen_v8_0_11 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ram_data_memory xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ram_data_memory.udo}

run -all

endsim

quit -force
