#sim.do file
#quit -sim
vlib work
vmap work work
vlog -f flist.f 
vsim -t ns  -novopt -L altera_lib work.top_tb
do wave.do
.main clear
run 50000ns