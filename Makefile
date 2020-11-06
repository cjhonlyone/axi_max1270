# SHELL := /bin/bash

DEVICE=xc7k325tffg900-1
Vivado_DIR=/cygdrive/c/Xilinx/Vivado/2017.4/bin

# ip:
ip:
	${Vivado_DIR}/vivado -mode tcl -source axi_max1270_ip.tcl

sim:
	iverilog -s tb_max1270_Phy -o Max1270.vvp \
		Max1270_AXIL_Reg.v Max1270_Phy.v Max1270_Top.v tb_axi_max1270.v
	vvp -N Max1270.vvp
	
clean:
	rm -rf .Xil
	rm -rf *ff.log *.jou *.dmp *.xml *.vvp *.vcd *.xpr
	rm -rf *.cache *.hw *.ip_user_files *.sim xgui