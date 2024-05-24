#!/bin/bash

# Check if running as root and warn if not
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0"
    exit 1
fi

# Step to compile the program
gcc -o ad9361-iiostream ad9361-iiostream.c iiostream-common.c -liio -lfftw3 -lm

# Run the compiled program
./ad9361-iiostream

