######################################################################
#
# File name : new_testbench_fifo_generator_compile.do
# Created on: Wed Aug 19 15:55:10 +0900 2020
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/fifo_generator_v13_2_0

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap fifo_generator_v13_2_0 modelsim_lib/msim/fifo_generator_v13_2_0

vlog -64 -incr -sv -L xil_defaultlib -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -64 -93 -work xpm  \
"C:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -64 -incr -work fifo_generator_v13_2_0  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.ip_user_files/ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -64 -93 -work fifo_generator_v13_2_0  \
"../../../../AD9910.ip_user_files/ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -64 -incr -work fifo_generator_v13_2_0  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.ip_user_files/ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -64 -incr -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sources_1/ip/fifo_generator_0/sim/fifo_generator_0.v" \
"../../../../AD9910.srcs/sources_1/new/WriteToRegister.v" \
"../../../../AD9910.srcs/sources_1/new/ascii2decimal.v" \
"../../../../AD9910.srcs/sources_1/new/ascii2hex.v" \
"../../../../AD9910.srcs/sources_1/new/async_receiver.v" \
"../../../../AD9910.srcs/sources_1/new/async_transmitter.v" \
"../../../../AD9910.srcs/sources_1/new/data_receiver_v1_00.v" \
"../../../../AD9910.srcs/sources_1/new/hex2ascii.v" \
"../../../../AD9910.srcs/sources_1/new/led_intensity_adjust.v" \

vlog -64 -incr -sv -L xil_defaultlib -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sources_1/new/data_sender_v1_01.sv" \
"../../../../AD9910.srcs/sources_1/new/AD9912_DAC8734_main.sv" \

vlog -64 -incr -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sources_1/imports/new/DAC8734.v" \
"../../../../AD9910.srcs/sources_1/imports/new/device_DNA.v" \

vlog -64 -incr -sv -L xil_defaultlib -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sources_1/new/spi_fsm_module.sv" \
"../../../../AD9910.srcs/sources_1/new/shift_register_out.sv" \
"../../../../AD9910.srcs/sources_1/new/shift_register_in.sv" \
"../../../../AD9910.srcs/sources_1/new/clock_divider.sv" \
"../../../../AD9910.srcs/sources_1/new/spi_single_output.sv" \
"../../../../AD9910.srcs/sources_1/new/gpo_core.sv" \

vlog -64 -incr -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sources_1/new/rto_core_prime.v" \
"../../../../AD9910.srcs/sources_1/ip/fifo_generator_1/sim/fifo_generator_1.v" \

vlog -64 -incr -sv -L xil_defaultlib -work xil_defaultlib  "+incdir+C:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../AD9910.srcs/sim_1/new/testbench_main.sv" \
"../../../../AD9910.srcs/sim_1/new/testbench_spi_fsm.sv" \
"../../../../AD9910.srcs/sim_1/new/test_bench_gpo_core.sv" \
"../../../../AD9910.srcs/sim_1/new/new_testbench_gpo_core.sv" \
"../../../../AD9910.srcs/sim_1/new/testbench_fifo_generator.sv" \
"../../../../AD9910.srcs/sim_1/new/new_testbench_fifo_generator.sv" \

# compile glbl module
vlog -work xil_defaultlib "glbl.v"

quit -force

