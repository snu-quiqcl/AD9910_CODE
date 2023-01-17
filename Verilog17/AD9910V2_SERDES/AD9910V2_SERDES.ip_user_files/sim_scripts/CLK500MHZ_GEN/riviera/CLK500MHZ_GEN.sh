#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2017.3 (64-bit)
#
# Filename    : CLK500MHZ_GEN.sh
# Simulator   : Aldec Riviera-PRO Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Mon Jan 09 06:31:16 +0900 2023
# SW Build 2018833 on Wed Oct  4 19:58:22 MDT 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved. 
#
# usage: CLK500MHZ_GEN.sh [-help]
# usage: CLK500MHZ_GEN.sh [-lib_map_path]
# usage: CLK500MHZ_GEN.sh [-noclean_files]
# usage: CLK500MHZ_GEN.sh [-reset_run]
#
# Prerequisite:- To compile and run simulation, you must compile the Xilinx simulation libraries using the
# 'compile_simlib' TCL command. For more information about this command, run 'compile_simlib -help' in the
# Vivado Tcl Shell. Once the libraries have been compiled successfully, specify the -lib_map_path switch
# that points to these libraries and rerun export_simulation. For more information about this switch please
# type 'export_simulation -help' in the Tcl shell.
#
# You can also point to the simulation libraries by either replacing the <SPECIFY_COMPILED_LIB_PATH> in this
# script with the compiled library directory path or specify this path with the '-lib_map_path' switch when
# executing this script. Please type 'CLK500MHZ_GEN.sh -help' for more information.
#
# Additional references - 'Xilinx Vivado Design Suite User Guide:Logic simulation (UG900)'
#
#*********************************************************************************************************


# Script info
echo -e "CLK500MHZ_GEN.sh - Script generated by export_simulation (Vivado v2017.3 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  source compile.do 2>&1 | tee -a compile.log

}

# RUN_STEP: <simulate>
simulate()
{
  runvsimsa -l simulate.log -do "do {simulate.do}"
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./CLK500MHZ_GEN.sh -help\" for more information)\n"
        exit 1
      fi
     copy_setup_file $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
     copy_setup_file $2
  esac

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Copy library.cfg file
copy_setup_file()
{
  file="library.cfg"
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  else
    lib_map_path="C:/Jeonghyun/Lab/TaehyunKim/DDS/AD9910/JHPARK/JeonghyunPark/AD9910_CODE-AD9910V1_1/Verilog17/AD9910V2_SERDES/AD9910V2_SERDES.cache/compile_simlib/riviera"
  fi
  if [[ ($lib_map_path != "") ]]; then
    src_file="$lib_map_path/$file"
    cp $src_file .
  fi
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(compile.log elaboration.log simulate.log dataset.asdb work riviera)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./CLK500MHZ_GEN.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: CLK500MHZ_GEN.sh [-help]\n\
Usage: CLK500MHZ_GEN.sh [-lib_map_path]\n\
Usage: CLK500MHZ_GEN.sh [-reset_run]\n\
Usage: CLK500MHZ_GEN.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2
