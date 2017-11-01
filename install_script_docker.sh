#! /bin/bash

#Docker _ DISC_VM-14.04_V5.0.1
#
echo "========================"
echo "===>>> Update System ..."
echo "========================"
sudo apt-get update
sudo apt-get -y upgrade

mkdir -p $HOME/sources
export WORK_DIR=$HOME/sources
export ROBOTPKG_DIR=$WORK_DIR/robotpkg

echo "================================="
echo "install some needed packages ..."
echo "================================="
sudo apt-get install -y cmake cmake-curses-gui cmake-qt-gui vim terminator libncurses5-dev pax tar blender python3-dev python3-numpy libeigen2-dev texlive-latex-extra python3-sphinx qtbase5-dev qtmultimedia5-dev qtdeclarative5-dev libsdl-net1.2-dev libgtkmm-2.4-dev libglademm-2.4-dev lua5.1 liblua5.1-0-dev sqlite3 freeglut3-dev libwxgtk2.8-dev doxygen assimp-utils libassimp-dev swig bison flex htop libudev-dev openjdk-[67]-jdk git meld

echo "================================="
echo "configure git (.gitconfig)"
echo "================================="
git config --global http.sslVerify False

echo "================================="
echo "configure and install ROS(indigo)"
echo "================================="
#Setup your sources.list
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
#Set up your keys
sudo -E apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
#update packages index:
sudo apt-get update
#install ros-indigo-desktop-full
sudo apt-get install -y ros-indigo-desktop-full
#Initialize rosdep
sudo -E rosdep init
rosdep update
#Environment setup
echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
. /opt/ros/indigo/setup.bash
#Getting rosinstall(rosws/rosinstall)
sudo apt-get install -y python-rosinstall


echo "================================="
echo "retreive Robotpkg"
echo "================================="
cd $WORK_DIR
#git clone git://git.openrobots.org/robots/robotpkg
git clone https://git.openrobots.org/robots/robotpkg.git
cd robotpkg
#git clone git://git.openrobots.org/robots/robotpkg/robotpkg-wip wip
git clone https://git.openrobots.org/robots/robotpkg/robotpkg-wip.git wip

sudo chmod -R 777 /opt/

cd bootstrap
./bootstrap

echo "export WORK_DIR=$HOME/sources" >> ~/.bashrc
echo "export ROBOTPKG_DIR=$WORK_DIR/robotpkg" >> ~/.bashrc
. ~/.bashrc
#ROBOTPKG_DIR=$HOME/sources/robotpkg

echo "================================="
echo "configure /opt/openrobots/etc/robotpkg.conf"
echo "================================="
echo "PREFER_ALTERNATIVE.python=python34"     >> /opt/openrobots/etc/robotpkg.conf
echo "PKG_OPTIONS.morse= -doc"                >> /opt/openrobots/etc/robotpkg.conf
echo "PREFER.opencv = robotpkg"               >> /opt/openrobots/etc/robotpkg.conf
echo "PKG_OPTIONS.orocos-yarp_transport=-doc" >> /opt/openrobots/etc/robotpkg.conf
echo "PKG_OPTIONS.certi=gui"                  >> /opt/openrobots/etc/robotpkg.conf
echo "================================="

echo "================================="
echo "configure and install morse"
echo "================================="
cd $ROBOTPKG_DIR/simulation/morse/
make update

echo "================================="
echo "configure and install opencv"
echo "================================="
cd $ROBOTPKG_DIR/image/opencv/
make update

echo "================================="
echo "configure and install yarp"
echo "================================="
cd $ROBOTPKG_DIR/middleware/yarp/
make update

echo "================================="
echo "install ORoCoS (ros rtt integration)"
echo "================================="
echo "configure and install ros rtt integration"
sudo apt-get install -y ros-indigo-rtt-ros-integration
sudo apt-get install -y ros-indigo-rtt-ros*

echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/openrobots/lib/pkgconfig" >> ~/.profile
echo "export PATH=$PATH:/opt/openrobots/bin:/opt/openrobots/sbin"            >> ~/.profile
echo "export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/openrobots/lib"       >> ~/.profile
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openrobots/lib/"          >> ~/.profile
echo "export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.4/dist-packages:" >> ~/.bashrc
. $HOME/.bashrc
. $HOME/.profile

echo "================================="
echo "configure and install orocos-yarp_transport"
echo "================================="
cd $ROBOTPKG_DIR/wip/orocos-yarp_transport
#cp /orocos-yarp-transport_with_rtt-ros-integration.patch .
cp /root/orocos-yarp-transport_with_rtt-ros-integration.patch .
#patch orocos-yarp_transport
patch -p0 Makefile orocos-yarp-transport_with_rtt-ros-integration.patch
make update

echo "================================="
echo "configure and install orocos-dot_service"
echo "================================="
cd $ROBOTPKG_DIR/wip/orocos-dot_service
#cp /orocos-dot-service_with_rtt-ros-integration.patch .
cp /root/orocos-dot-service_with_rtt-ros-integration.patch .
#patch orocos-dot_service
patch -p0 Makefile orocos-dot-service_with_rtt-ros-integration.patch
make update

echo "================================="
echo "configure and install morse-ros"
echo "================================="
##################################################
#Sometimes problems with proxy, instal like this:
#sudo apt-get install python3-dateutil
#sudo -E pip3 install argparse
##################################################
sudo apt-get install -y python3-dev python3-yaml python3-pip
sudo pip3 install pyyaml
sudo apt-get install -y python3-dateutil
sudo -E pip3 install argparse
cd $HOME/sources
git clone git://github.com/ros-infrastructure/catkin_pkg.git
cd catkin_pkg
sudo python3 setup.py install
cd $HOME/sources
git clone git://github.com/ros/catkin.git
cd catkin
sudo python3 setup.py install
cd $HOME/sources
git clone git://github.com/ros/rospkg.git
cd rospkg
sudo python3 setup.py install
cd $ROBOTPKG_DIR/sysutils/py-catkin-pkg
make update
#===> Installing for py34-catkin-pkg-0.2.4
#=> Compiling python files
#=> Please note the following:
#======================================================================
#
#To use ros, the following environment variables must contain those values:
#
#  ROS_MASTER_URI    http://localhost:11311
#  ROS_PACKAGE_PATH  /opt/openrobots/share
#  PYTHONPATH        /opt/openrobots/lib/python3.4/site-packages
#  PATH              /opt/openrobots/bin#
#
#As an alternative to the above configuration, commands can be executed by
#using the `env.sh' wrapper. For instance, roscore can be started like so:
#  /opt/openrobots/etc/ros/env.sh roscore
#
#In Bourne shell scripts, the following file can be sourced instead:
#  /opt/openrobots/etc/ros/setup.sh
#
#=> Registering installation for py34-catkin-pkg-0.2.4
#===> Done install for py34-catkin-pkg-0.2.4
#===> Cleaning temporary files for py34-catkin-pkg-0.2.4
#===> Done update for py34-catkin-pkg-0.2.4
#======================================================================

cd $ROBOTPKG_DIR/wip/morse-ros
make update
#=== PYTHONPATH look like this:
#etdisc@etdisc-virtual-machine:~/sources/rospkg$ env | grep PYTHONPATH
#PYTHONPATH=/opt/ros/indigo/lib/python2.7/dist-packages:/usr/local/lib/python3.4/dist-packages:
#===

echo "================================="
echo "configure and install mrpt"
echo "================================="
cd $ROBOTPKG_DIR/wip/mrpt/
make update

echo "================================="
echo "configure and install mavlink"
echo "================================="
cd $ROBOTPKG_DIR/wip/mavlink/
make update

echo "================================="
echo "configure and install urg"
echo "================================="
cd $ROBOTPKG_DIR/wip/urg/
make update

echo "================================="
echo "configure and install lua-rfsm"
echo "================================="
cd $ROBOTPKG_DIR/wip/lua-rfsm/
make update

echo "================================="
echo "configure and install lua-completion"
echo "================================="
cd $WORK_DIR
git clone https://github.com/orocos-toolchain/rttlua_completion.git
cd rttlua_completion
make

echo "export LUA_PATH=\";\$LUA_PATH;/opt/openrobots/share/lua/5.1/?.lua;/opt/openrobots/bin/?.lua;/opt/openrobots/lib/lua/rfsm/?.lua;/usr/local/share/lua/?.lua;\"" >> ~/.profile
echo "export LUA_CPATH=\";\$LUA_CPATH;/opt/openrobots/lib/?.so;\"" >> ~/.profile
. ~/.profile

echo "export LUA_PATH=\";;;\$WORK_DIR/rttlua_completion/?.lua;\$LUA_PATH\"" >> $HOME/.bashrc
echo "export LUA_CPATH=\";;;\$WORK_DIR/rttlua_completion/?.so;\$LUA_CPATH\"" >> $HOME/.bashrc


echo "================================="
echo "configure and install morse-yarp"
echo "================================="
cd $ROBOTPKG_DIR/simulation/morse-yarp/
make update

echo "================================="
echo "configure and install certi"
echo "================================="
cd $ROBOTPKG_DIR/wip/certi/
make update
echo "CERTI_HTTP_PROXY="       >> $HOME/.bashrc
echo "export CERTI_HTTP_PROXY" >> $HOME/.bashrc

echo "================================="
echo "configure and install morse-hla"
echo "================================="
cd $ROBOTPKG_DIR/wip/morse-hla/
make update

echo "================================="
echo "configure and install morse-mavlink"
echo "================================="
cd $ROBOTPKG_DIR/wip/morse-mavlink/
make update

echo "================================="
echo "configure and install openni2"
echo "================================="
#cd $ROBOTPKG_DIR/middleware/openni2/
#make update
sudo apt-get install -y libopenni2-dev

echo "================================="
echo "configure and install qtcreator for ros"
echo "================================="
#!!!sources from https://pricklytech.wordpress.com/2014/05/16/ubuntu-server-14-4-trusty-add-apt-repository-command-not-found/
sudo apt-get install -y python-software-properties
sudo apt-get install -y apt-file
apt-file update
sudo apt-get install -y software-properties-common
#!!! sources from https://pricklytech.wordpress.com/2014/05/16/ubuntu-server-14-4-trusty-add-apt-repository-command-not-found/
sudo -E add-apt-repository ppa:beineri/opt-qt571-trusty  
sudo -E add-apt-repository ppa:levi-armstrong/ppa  
sudo apt-get update && sudo apt-get install -y qt57creator-plugin-ros

echo "============================================"
echo "configure catkin workspace (R.O.S.)"
echo "============================================"
#!/bin/sh
echo "create catkin workspace ..."
cd $HOME
mkdir -p catkin_ws/src
CATKIN_WORKSPACE=$HOME/catkin_ws
cd catkin_ws/src
catkin_init_workspace
cd .. #cd CATKIN_WORKSPACE
catkin_make
echo ". $CATKIN_WORKSPACE/devel/setup.bash" >> $HOME/.bashrc
echo "catkin workspace created!"



echo "================================="
echo "All the tools are installed!"
echo "You can work now! ;-)"
echo "================================="
