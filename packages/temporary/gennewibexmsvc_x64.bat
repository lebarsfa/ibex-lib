@cd /d "%~dp0"

@echo off

rem choco install -y -r --no-progress wget zip winflexbison patch sed

rd /s /q "%ProgramFiles%\mathlib" "%ProgramFiles(x86)%\mathlib" "%ProgramFiles%\gaol" "%ProgramFiles(x86)%\gaol" "%ProgramFiles%\IBEX" "%ProgramFiles(x86)%\IBEX"
cd P:\devel\GitHub

rd /s /q mathlib_build_x64_vc15
md mathlib_build_x64_vc15
cd mathlib_build_x64_vc15
cmake -G "Visual Studio 15" -A x64 ..\mathlib
cmake --build . --config Release --target install
cd ..

rd /s /q gaol_build_x64_vc15
md gaol_build_x64_vc15
cd gaol_build_x64_vc15
cmake -G "Visual Studio 15" -A x64 ..\gaol
cmake --build . --config Release --target install
cd ..

rd /s /q ibex-lib_build_x64_vc15
md ibex-lib_build_x64_vc15
cd ibex-lib_build_x64_vc15
cmake -E env CXXFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" CFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" cmake -G "Visual Studio 15" -A x64 -D INTERVAL_LIB=gaol -D MATHLIB_DIR="%ProgramFiles%\\mathlib" -D GAOL_DIR="%ProgramFiles%\\gaol" ..\ibex-lib
cmake --build . --config Release --target install
cd ..

md "%ProgramFiles%\IBEX\include\ibex\3rd\gaol" "%ProgramFiles%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles%\mathlib\include\*" "%ProgramFiles%\IBEX\include\ibex\3rd"
copy "%ProgramFiles%\gaol\include\gaol" "%ProgramFiles%\IBEX\include\ibex\3rd\gaol"
copy "%ProgramFiles%\mathlib\lib\*" "%ProgramFiles%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles%\gaol\lib\*" "%ProgramFiles%\IBEX\lib\ibex\3rd"

rem echo Might need to run manually the rest...
rem pause

rem Due to sed error message mentionning cross-device link...
cd /d C:

sed -i "s/C:\/Program Files\/mathlib\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files\/mathlib\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files\/gaol\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"
sed -i "s/C:\/Program Files\/gaol\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"

cd "%ProgramFiles%"
zip -q -r ibex_x64_vc15.zip ibex

pause
