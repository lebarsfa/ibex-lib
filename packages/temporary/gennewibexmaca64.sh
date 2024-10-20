#!/bin/bash

mkdir -p ~/Downloads/newibex

sudo pip3 uninstall --break-system-packages -y codac ; sudo pip3 uninstall -y codac ; pip3 uninstall -y codac
sudo rm -Rf /usr/local/include/mathlib* /usr/local/include/MathLib* /usr/local/lib/libultim* /usr/local/share/mathlib*
sudo rm -Rf /usr/local/include/gaol* /usr/local/lib/gaol* /usr/local/lib/libgaol* /usr/local/share/gaol*
sudo rm -Rf /usr/local/include/ibex* /usr/local/lib/ibex* /usr/local/lib/libibex* /usr/local/bin/ibex* /usr/local/share/ibex*
sudo rm -Rf /usr/local/include/codac* /usr/local/lib/libcodac* /usr/local/share/codac*
cd ~/Downloads/newibex
rm -Rf ibex-lib*
git clone -b prerelease https://github.com/lebarsfa/ibex-lib
cd ibex-lib
export VERBOSE=1 ; mkdir build ; cd build && cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -D INTERVAL_LIB=gaol -D CMAKE_OSX_DEPLOYMENT_TARGET=13.0 -D CMAKE_INSTALL_PREFIX=../ibex .. && cmake --build . -j 4 --config Release --target install && cd ..
sed -i "" "s/\\/Users\\/user\\/Downloads\\/newibex\\/ibex-lib\\/ibex/\${_IMPORT_PREFIX}/" ibex/share/ibex/cmake/*.cmake
zip -q -r ibex_arm64_ventura.zip ibex
mv -f ./ibex_arm64_ventura.zip ../
cd ..
