#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 40727c11ba984237982046d8fd4e5c52 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip -L xpm --snapshot debouncer_behav xil_defaultlib.debouncer -log elaborate.log
