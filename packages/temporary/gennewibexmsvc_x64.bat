@cd /d "%~dp0"

@echo off

rem choco install -y -r --no-progress wget zip winflexbison patch sed

for %%v in (15 16 17) do (

rd /s /q "%ProgramFiles%\mathlib" "%ProgramFiles(x86)%\mathlib" "%ProgramFiles%\gaol" "%ProgramFiles(x86)%\gaol" "%ProgramFiles%\IBEX" "%ProgramFiles(x86)%\IBEX"
cd /d P:\devel\GitHub

rd /s /q mathlib_build_x64_vc%%v
md mathlib_build_x64_vc%%v
cd mathlib_build_x64_vc%%v
cmake -G "Visual Studio %%v" -A x64 ..\mathlib
cmake --build . -j 4 --config Release --target install
cd ..

rd /s /q gaol_build_x64_vc%%v
md gaol_build_x64_vc%%v
cd gaol_build_x64_vc%%v
cmake -G "Visual Studio %%v" -A x64 ..\gaol
cmake --build . -j 4 --config Release --target install
cd ..

rd /s /q ibex-lib_build_x64_vc%%v
md ibex-lib_build_x64_vc%%v
cd ibex-lib_build_x64_vc%%v
cmake -E env CXXFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" CFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" cmake -G "Visual Studio %%v" -A x64 -D INTERVAL_LIB=gaol -D MATHLIB_DIR="%ProgramFiles%\\mathlib" -D GAOL_DIR="%ProgramFiles%\\gaol" ..\ibex-lib
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
del /f /q ibex_x64_vc%%v.zip
zip -q -r ibex_x64_vc%%v.zip ibex

)

pause
