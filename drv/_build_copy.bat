cd "%~dp0"

set MSYS_HOME=c:\msys64
set CC65_HOME=c:\cc65
set PATH=%CC65_HOME%\bin;%MSYS_HOME%\usr\bin
set DBG_DIR=..\DrvFAMICompiler\bin\Debug\bin
set REL_DIR=..\DrvFAMICompiler\bin\Release\bin

del buildlog.txt
del errlog.txt
del comlog.txt
make -k >buildlog.txt 2>&1
if %errorlevel% equ 0	goto end
start errlog.txt
:end
copy /y drv.bin %REL_DIR%
copy /y drv_mmc5.bin %REL_DIR%
copy /y drv_vrc6.bin %REL_DIR%
copy /y dsp_code.bin %REL_DIR%
copy /y dsp_data.bin %REL_DIR%
move /y drv.bin %DBG_DIR%
move /y drv_mmc5.bin %DBG_DIR%
move /y drv_vrc6.bin %DBG_DIR%
move /y dsp_code.bin %DBG_DIR%
move /y dsp_data.bin %DBG_DIR%
