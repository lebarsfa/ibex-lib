#!/bin/bash

# Usage : 
#sh ./genlibibex-dev.sh ubuntu bionic amd64 2.8.9 0 0

OS=$1
DIST=$2
ARCH=$3
VER=$4
DREV=$5
REV=$6

#sudo apt-get -y install dpkg-dev

mkdir -p $DIST/$ARCH
cd $DIST/$ARCH
mkdir -p libibex-dev/usr
cp -Rf ../../../ibex/* libibex-dev/usr/
mkdir -p libibex-dev/DEBIAN
cp -Rf ../../deb/control libibex-dev/DEBIAN/control
sed_param=s/Version:\ .*/Version:\ ${VER}/  
sed -i "$sed_param" libibex-dev/DEBIAN/control
sed_param=s/Architecture:\ .*/Architecture:\ ${ARCH}/
sed -i "$sed_param" libibex-dev/DEBIAN/control
if [ "$DIST" = "xenial" ] || [ "$DIST" = "bionic" ] || [ "$DIST" = "buster" ]; then
    sed_param=s/libgcc-s1/libgcc1/  
    sed -i "$sed_param" libibex-dev/DEBIAN/control
fi
chmod 775 libibex-dev/DEBIAN
dpkg-deb --build libibex-dev
mv libibex-dev.deb ../../../libibex-dev-$VER-$DREV$DIST$REV\_$ARCH.deb
cd ../..
