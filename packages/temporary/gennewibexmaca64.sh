#!/bin/bash

mkdir -p ~/Downloads/newibex

sudo pip3 uninstall -y codac ; pip3 uninstall -y codac
sudo rm -Rf /usr/local/include/mathlib* /usr/local/include/MathLib* /usr/local/lib/libultim*
sudo rm -Rf /usr/local/include/gaol* /usr/local/lib/gaol* /usr/local/lib/libgaol*
sudo rm -Rf /usr/local/include/ibex* /usr/local/lib/ibex* /usr/local/lib/libibex* /usr/local/bin/ibex*
sudo rm -Rf /usr/local/include/codac* /usr/local/lib/libcodac*
cd ~/Downloads/newibex
rm -Rf ibex-lib*
git clone -b prerelease https://github.com/lebarsfa/ibex-lib
cd ibex-lib
export VERBOSE=1 ; mkdir build ; cd build && cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -D INTERVAL_LIB=gaol -D CMAKE_OSX_DEPLOYMENT_TARGET=11.0 -D CMAKE_INSTALL_PREFIX=../ibex .. && cmake --build . --config Release --target install && cd ..
sed -i "" "s/\\/Users\\/user\\/Downloads\\/newibex\\/ibex-lib\\/ibex/\${_IMPORT_PREFIX}/" ibex/share/ibex/cmake/*.cmake
zip -q -r ibex_arm64_bigsur.zip ibex
mv -f ./ibex_arm64_bigsur.zip ../
cd ..

sudo pip3 uninstall -y codac ; pip3 uninstall -y codac
sudo rm -Rf /usr/local/include/mathlib* /usr/local/include/MathLib* /usr/local/lib/libultim*
sudo rm -Rf /usr/local/include/gaol* /usr/local/lib/gaol* /usr/local/lib/libgaol*
sudo rm -Rf /usr/local/include/ibex* /usr/local/lib/ibex* /usr/local/lib/libibex* /usr/local/bin/ibex*
sudo rm -Rf /usr/local/include/codac* /usr/local/lib/libcodac*
cd ~/Downloads/newibex
rm -Rf ibex-lib*
git clone -b prerelease https://github.com/lebarsfa/ibex-lib
cd ibex-lib
export VERBOSE=1 ; mkdir build ; cd build && cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -D INTERVAL_LIB=gaol -D CMAKE_OSX_DEPLOYMENT_TARGET=12.0 -D CMAKE_INSTALL_PREFIX=../ibex .. && cmake --build . --config Release --target install && cd ..
sed -i "" "s/\\/Users\\/user\\/Downloads\\/newibex\\/ibex-lib\\/ibex/\${_IMPORT_PREFIX}/" ibex/share/ibex/cmake/*.cmake
zip -q -r ibex_arm64_monterey.zip ibex
mv -f ./ibex_arm64_monterey.zip ../
cd ..

sudo pip3 uninstall -y codac ; pip3 uninstall -y codac
sudo rm -Rf /usr/local/include/mathlib* /usr/local/include/MathLib* /usr/local/lib/libultim*
sudo rm -Rf /usr/local/include/gaol* /usr/local/lib/gaol* /usr/local/lib/libgaol*
sudo rm -Rf /usr/local/include/ibex* /usr/local/lib/ibex* /usr/local/lib/libibex* /usr/local/bin/ibex*
sudo rm -Rf /usr/local/include/codac* /usr/local/lib/libcodac*
cd ~/Downloads/newibex
rm -Rf ibex-lib*
git clone -b prerelease https://github.com/lebarsfa/ibex-lib
cd ibex-lib
export VERBOSE=1 ; mkdir build ; cd build && cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -D INTERVAL_LIB=gaol -D CMAKE_OSX_DEPLOYMENT_TARGET=13.0 -D CMAKE_INSTALL_PREFIX=../ibex .. && cmake --build . --config Release --target install && cd ..
sed -i "" "s/\\/Users\\/user\\/Downloads\\/newibex\\/ibex-lib\\/ibex/\${_IMPORT_PREFIX}/" ibex/share/ibex/cmake/*.cmake
zip -q -r ibex_arm64_ventura.zip ibex
mv -f ./ibex_arm64_ventura.zip ../
cd ..

sudo pip3 uninstall -y codac ; pip3 uninstall -y codac
sudo rm -Rf /usr/local/include/mathlib* /usr/local/include/MathLib* /usr/local/lib/libultim*
sudo rm -Rf /usr/local/include/gaol* /usr/local/lib/gaol* /usr/local/lib/libgaol*
sudo rm -Rf /usr/local/include/ibex* /usr/local/lib/ibex* /usr/local/lib/libibex* /usr/local/bin/ibex*
sudo rm -Rf /usr/local/include/codac* /usr/local/lib/libcodac*
cd ~/Downloads/newibex
rm -Rf ibex-lib*
git clone -b prerelease https://github.com/lebarsfa/ibex-lib
cd ibex-lib
export VERBOSE=1 ; mkdir build ; cd build && cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -D INTERVAL_LIB=gaol -D CMAKE_OSX_DEPLOYMENT_TARGET=14.0 -D CMAKE_INSTALL_PREFIX=../ibex .. && cmake --build . --config Release --target install && cd ..
sed -i "" "s/\\/Users\\/user\\/Downloads\\/newibex\\/ibex-lib\\/ibex/\${_IMPORT_PREFIX}/" ibex/share/ibex/cmake/*.cmake
zip -q -r ibex_arm64_sonoma.zip ibex
mv -f ./ibex_arm64_sonoma.zip ../
cd ..
