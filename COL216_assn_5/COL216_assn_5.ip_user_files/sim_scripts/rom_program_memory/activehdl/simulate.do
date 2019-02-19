onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+rom_program_memory -L dist_mem_gen_v8_0_11 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.rom_program_memory xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {rom_program_memory.udo}

run -all

endsim

quit -force
