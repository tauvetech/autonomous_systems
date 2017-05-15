#!/bin/bash

echo "script update_vm_01.sh"

mv $HOME/sources/Firmware $HOME/catkin_ws/src
rm -Rf $HOME/catkin_ws/src/Firmware/build_posix_sitl_default
cd $HOME/catkin_ws/src
ln -s Firmware/Tools/sitl_gazebo sitl_gazebo_link

sudo mv $HOME/sources/cmake-3.8.0-rc2-Linux-x86_64/bin/* /usr/local/bin/
sudo mv $HOME/sources/cmake-3.8.0-rc2-Linux-x86_64/doc/* /usr/local/doc/
sudo mv $HOME/sources/cmake-3.8.0-rc2-Linux-x86_64/man/* /usr/local/man/
sudo mv $HOME/sources/cmake-3.8.0-rc2-Linux-x86_64/share/* /usr/local/share/

rm -Rf $HOME/.ros
rm -Rf $HOME/sources/cmake-3.8.0-rc2-Linux-x86_64

sed -i '/PX4/Id' $HOME/.bashrc

cd $HOME/catkin_ws

echo " - Now, close your terminal"
echo " - open a new terminal"
echo " - go to catkin workspace ($HOME/catkin_ws)"
echo " - and execute catkin_make"
