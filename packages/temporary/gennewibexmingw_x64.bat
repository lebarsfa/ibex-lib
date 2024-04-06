@cd /d "%~dp0"

@echo off

rem choco install -y -r --no-progress wget zip winflexbison patch sed

for %%v in (11) do (

rd /s /q "%ProgramFiles%\mathlib" "%ProgramFiles(x86)%\mathlib" "%ProgramFiles%\gaol" "%ProgramFiles(x86)%\gaol" "%ProgramFiles%\IBEX" "%ProgramFiles(x86)%\IBEX"
cd /d P:\devel\GitHub

rd /s /q mathlib_build_x64_mingw%%v
md mathlib_build_x64_mingw%%v
cd mathlib_build_x64_mingw%%v
cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX="%ProgramFiles%\mathlib" ..\mathlib
cmake --build . -j 4 --config Release --target install
cd ..

rd /s /q gaol_build_x64_mingw%%v
md gaol_build_x64_mingw%%v
cd gaol_build_x64_mingw%%v
rem Temporary gaol_configuration.h, gaol_double_op.h, "-I .."...
cmake -E env CXXFLAGS=" -I .. -fPIC" CFLAGS=" -I .. -fPIC" cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX="%ProgramFiles%\gaol" ..\gaol
copy /Y /B ..\gaol\gaol\gaol_version_mingw.h+..\gaol\gaol\gaol_config_mingw.h gaol\gaol_configuration.h
copy /Y ..\gaol\gaol\gaol_double_op_apmathlib.h gaol\gaol_double_op.h
cmake --build . -j 4 --config Release --target install
copy /Y gaol\gaol_configuration.h "%ProgramFiles%\gaol\include\gaol\"
copy /Y gaol\gaol_double_op.h "%ProgramFiles%\gaol\include\gaol\"
cd ..

rd /s /q ibex-lib_build_x64_mingw%%v
md ibex-lib_build_x64_mingw%%v
cd ibex-lib_build_x64_mingw%%v
cmake -E env CXXFLAGS="-fPIC" CFLAGS="-fPIC" cmake -G "MinGW Makefiles" -D INTERVAL_LIB=gaol -D MATHLIB_DIR="%ProgramFiles%\\mathlib" -D GAOL_DIR="%ProgramFiles%\\gaol" -D CMAKE_INSTALL_PREFIX="%ProgramFiles%\IBEX" ..\ibex-lib
cmake --build . -j 4 --config Release --target install
cd ..

md "%ProgramFiles%\IBEX\include\ibex\3rd\gaol" "%ProgramFiles%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles%\mathlib\include\*" "%ProgramFiles%\IBEX\include\ibex\3rd"
copy "%ProgramFiles%\gaol\include\gaol" "%ProgramFiles%\IBEX\include\ibex\3rd\gaol"
copy "%ProgramFiles%\mathlib\lib\*" "%ProgramFiles%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles%\gaol\lib\*" "%ProgramFiles%\IBEX\lib\ibex\3rd"

rem echo Might need to run manually the rest...
rem pause

rem Due to sed error message mentioning cross-device link...
cd /d C:

sed -i "s/C:\/Program Files\/mathlib\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files\/mathlib\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files\/gaol\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"
sed -i "s/C:\/Program Files\/gaol\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"

cd "%ProgramFiles%"
del /f /q ibex_x64_mingw%%v.zip
zip -q -r ibex_x64_mingw%%v.zip ibex

)

pause
