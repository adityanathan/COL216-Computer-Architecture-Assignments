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
ExecStep $xv_path/bin/xsim debouncer_behav -key {Behavioral:sim_1:Functional:debouncer} -tclbatch debouncer.tcl -log simulate.log