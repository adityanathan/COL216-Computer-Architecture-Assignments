onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib unified_memory_opt

do {wave.do}

view wave
view structure
view signals

do {unified_memory.udo}

run -all

quit -force
