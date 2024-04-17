@cd /d "%~dp0"

@echo off

rem choco install -y -r --no-progress wget zip winflexbison patch sed

for %%v in (15 16 17) do (

rd /s /q "%ProgramFiles%\mathlib" "%ProgramFiles(x86)%\mathlib" "%ProgramFiles%\gaol" "%ProgramFiles(x86)%\gaol" "%ProgramFiles%\IBEX" "%ProgramFiles(x86)%\IBEX"
cd /d P:\devel\GitHub

rd /s /q mathlib_build_x86_vc%%v
md mathlib_build_x86_vc%%v
cd mathlib_build_x86_vc%%v
cmake -G "Visual Studio %%v" -A Win32 ..\mathlib
cmake --build . -j 4 --config Release --target install
cd ..

rd /s /q gaol_build_x86_vc%%v
md gaol_build_x86_vc%%v
cd gaol_build_x86_vc%%v
cmake -G "Visual Studio %%v" -A Win32 ..\gaol
cmake --build . -j 4 --config Release --target install
cd ..

rd /s /q ibex-lib_build_x86_vc%%v
md ibex-lib_build_x86_vc%%v
cd ibex-lib_build_x86_vc%%v
cmake -E env CXXFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" CFLAGS=" /wd4267 /wd4244 /wd4305 /wd4996" cmake -G "Visual Studio %%v" -A Win32 -D INTERVAL_LIB=gaol -D MATHLIB_DIR="%ProgramFiles(x86)%\\mathlib" -D GAOL_DIR="%ProgramFiles(x86)%\\gaol" ..\ibex-lib
cmake --build . -j 4 --config Release --target install
cd ..

md "%ProgramFiles(x86)%\IBEX\include\ibex\3rd\gaol" "%ProgramFiles(x86)%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles(x86)%\mathlib\include\*" "%ProgramFiles(x86)%\IBEX\include\ibex\3rd"
copy "%ProgramFiles(x86)%\gaol\include\gaol" "%ProgramFiles(x86)%\IBEX\include\ibex\3rd\gaol"
copy "%ProgramFiles(x86)%\mathlib\lib\*" "%ProgramFiles(x86)%\IBEX\lib\ibex\3rd"
copy "%ProgramFiles(x86)%\gaol\lib\*" "%ProgramFiles(x86)%\IBEX\lib\ibex\3rd"

rem echo Might need to run manually the rest...
rem pause

rem Due to sed error message mentioning cross-device link...
cd /d C:

sed -i "s/C:\/Program Files (x86)\/mathlib\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles(x86)%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files (x86)\/mathlib\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles(x86)%\IBEX\share\ibex\cmake\ibex-config-ultim.cmake"
sed -i "s/C:\/Program Files (x86)\/gaol\/lib/\${_IMPORT_PREFIX}\/lib\/ibex\/3rd/" "%ProgramFiles(x86)%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"
sed -i "s/C:\/Program Files (x86)\/gaol\/include/\${_IMPORT_PREFIX}\/include\/ibex\/3rd/" "%ProgramFiles(x86)%\IBEX\share\ibex\cmake\ibex-config-gaol.cmake"

cd "%ProgramFiles(x86)%"
del /f /q ibex_x86_vc%%v.zip
zip -q -r ibex_x86_vc%%v.zip ibex

)

pause
