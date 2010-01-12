ifndef DES
DES=mips
endif

VPATH=../mips ../test

all: build dot sim view 
build: compile map

fetch_top.hcl: fetch_top.ht fetch.ht types.ht
decode_top.hcl: decode_top.ht decode.ht types.ht
mips.hcl: mips.ht fetch.ht decode.ht execute.ht memory.ht writeback.ht types.ht
decode_top.vxl : decode_top_tb.v decode_top_sim.v dec_mem.list
mips.vxl: mips_sim.v mips_tb.v inst_mem.list data_mem.list

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
	\cp -f ../test/inst_mem.list ./inst_mem.list
	verilog $(filter %.v, $^) < /dev/null

view: $(DES).vxl
	htview  $(DES)

clean:
	- \rm *_sim.v *.hcl *_htmap.v *_mon.v *_netlist.v *.paths verilog.*
	- \rm async_lib_generic.v *.vxl HT_simulation_models.v
	- \rm -rf log hss rpt rundir *.dot *.trn *.vcd *.dsn
