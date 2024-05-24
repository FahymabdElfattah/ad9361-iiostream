#!/bin/bash

# This script is created by Fahym Abdelfattah
# It automates the installation of libiio on Linux systems.

# Ensures the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update

# Install dependencies
echo "Installing required packages..."
apt-get install -y libzstd-dev cmake libxml2-dev libusb-1.0-0-dev libcdk5-dev

# Clone the libiio repository
echo "Cloning libiio repository..."
git clone https://github.com/analogdevicesinc/libiio.git

# Build libiio from source
echo "Building libiio..."
cd libiio
mkdir build && cd build
cmake ..
make

# Install libiio
echo "Installing libiio..."
sudo make install
sudo ldconfig

# Exiting the build directory and then the libiio directory
cd ../..

# Remove the libiio directory
echo "Removing the libiio directory..."
rm -rf libiio

echo "Installation complete."

# Error handling advice
echo "If you encounter an error that 'libiio.so.0 is not a symbolic link',"
echo "run the command 'sudo find / -name libiio.so.0' to find the 'libiio.so.0' file, can be found in </usr/lib/arm-linux-gnueabihf>"
echo "then remove 'libiio.so.0' using the command 'sudo rm -r libiio.so.0'."
echo "then the command 'sudo ldconfig'."
echo "We can check the libiio version and more details by running the command 'iio_info'"
