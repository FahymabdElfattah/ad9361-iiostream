#Share folder bteween the host machine and VMWare:
sudo apt install open-vm-tools open-vm-tools-desktop
sudo vmhgfs-fuse .host:/shared_folder_vmware /mnt/shared -o subtype=vmhgfs-fuse,allow_other

#Install the required 32-bit libraries:
sudo apt-get install lib32stdc++6
sudo apt-get install libgtk2.0-0:i386 libfontconfig1:i386 libx11-6:i386 libxext6:i386 libxrender1:i386 libsm6:i386 libqtgui4:i386

#Install all the dependencies needed by Yocto:
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python-pip libsdl1.2-dev xterm
