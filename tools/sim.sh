#!/bin/bash

# Script to simulate (System)Verilog sources using iverilog, vvp and gtkwave on macOS.
# This script was tested with the following application versions:
# - macOS 10.12.5
# - bash 3.2
# - icarus-verilog 10.1.1
# - gtkwave 3.3.82

# Script terminates after the first non-zero exit code.
set -euo pipefail

# Define top level module name as command line argument.
export TOP=$1

#TODO: add optional argument to specify different wave config file.
#TODO: gtkwave might be refreshed using the keyboard shortcut: cmd+shift+R
#TODO: set the correct path (../sim/) for .gtkw files when directly saved instead of saved as.
#TODO: make TOP variable an input from the command line using getopts.
#TODO: test if Swith.pm is installed on host machine - invoking gtkwave from bash script needs to run perl script within gtkwave.app on macOS according to gtkwave manual. however this gave an error with perl since perl could not locate Switch.pm in @INC. run 'sudo cpan -f Switch' to install and then calling gtkwave works from command line.
#TODO: test if iverilog and gtkwave are installed
# - check which operating system is used.
# - check if iverilog, vvp and gtkwave are installed
# - set variables for GTKPATH accordingly.
# - decide on GTKPATH variable here since we already check the OS here.
#TODO: write setup script which checks if sim.sh and todo.sh are executable. If not, run chmod +x. It also should set the source file locations and that of the base library.
#TODO: reload VCD file:
# https://stackoverflow.com/questions/45063374/reload-vcd-file-in-gtkwave-from-command-line?noredirect=1#comment77113961_45063374

# Locations of the (System)Verilog source files.
export BASE=../../base
export SIM=../sim
export SRC=../src
#export SYNTH=../synth
export TB=../tb
export WORK=../work

# Test if directory 'work' exists. If not, create it.
if [ ! -d "$WORK" ]; then
	mkdir $WORK
fi

# Echo the top level entity.
echo "TOP = $TOP"

#TODO: add -Wall to display all warnings. timescale as well, but i dont use that.
#TODO: use lxt format which is faster
#TODO: for uram/bram sims, ifdef XILINX use their module, otherwise use behav model. So be able to pass iverilog macros as a command line option with a switch using getopts.
iverilog -DVCD -Wall -o $WORK/$TOP.out -s $TOP $BASE/*.sv $SRC/*.sv $TB/*.sv
vvp $WORK/$TOP.out
mv $TOP.vcd $WORK/$TOP.vcd # VCD file is dumped in same directory as this script. Move it to the work folder.

# Check if gtkwave is already running. If so, let the user press the reload butten. If not, open gtkwave.
SERVICE='gtkwave'

if ps ax | grep -v grep | grep $SERVICE > /dev/null ; then
    echo "$SERVICE service running, press the reload button."
	#TODO: if gtkwave is already open, use the reload function from the command line.
else
    echo "$SERVICE is not running, $SERVICE starts up now."

	# Check which operating system is used to decide where gtkwave is located.
	OS=$(uname -s)
	if [ "$OS" = "Darwin" ] ; then
		# Path of gtkwave for macOS is fixed.
		export GTKPATH=/Applications/gtkwave.app/Contents/Resources/bin/gtkwave
	elif [ "$OS" = "Linux" ] ; then
		# Find the path of gtkwave using the whereis utility.
		export GTKPATH=$SERVICE
	else
		# Terminate the script if the operating system is neither Darwin or Linux.
		echo "Operating system could not be determined."
		exit 1
	fi

	#TODO: Test if the vcd and gtkw files exist before starting gtkwave.
	#if [ ! test -f $WORK/$TOP.vcd ] && [ ! test -f $SIM/$TOP.gtkw ] ; then
		# Start gtkwave with the vcd and gtkw files.
		$GTKPATH $WORK/$TOP.vcd $SIM/$TOP.gtkw &

    #TODO: automatic reload waveform for Linux:
    #gconftool-2 --type string --set /com.geda.gtkwave/0/reload 0

  #else
	#	echo "$SERVICE input files are not found."
	#	exit 1
	#fi
fi

# TODO: make a clean script to delete the 'work' folder
# run todo.sh script for list of todos in source code
