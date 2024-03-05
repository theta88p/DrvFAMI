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
copy /y drv_*.bin %REL_DIR%
copy /y dsp_*.bin %REL_DIR%
move /y drv.bin %DBG_DIR%
move /y drv_*.bin %DBG_DIR%
move /y dsp_*.bin %DBG_DIR%
