ifndef DES
DES=mips
endif

VPATH=../mips ../test

all: compile dot map sim view 

fetch_top.hcl: fetch_top.ht fetch.ht types.ht

compile: $(DES).hcl

%.hcl: %.ht
	htcomp -input $< $*

map: $(DES)_sim.v 

%_sim.v: %.hcl
	htmap -mon -tech generic -ConstPins -input $< $*

dot: $(DES).dot

%.dot: %.hcl
	htmap -dot -tech generic -input $< $*

sim: $(DES).vxl

%.vxl: %_tb.v %_sim.v
	verilog $^ < /dev/null

view: $(DES).vxl
	htview  $(DES)

clean:
	- \rm *_sim.v *.hcl *_htmap.v *_mon.v *_netlist.v *.paths verilog.*
	- \rm async_lib_generic.v *.vxl HT_simulation_models.v
	- \rm -rf log hss rpt rundir *.dot *.trn *.vcd *.dsn
