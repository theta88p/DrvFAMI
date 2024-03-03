cd "%~dp0"

set MSYS_HOME=c:\msys64
set CC65_HOME=c:\cc65
set PATH=%CC65_HOME%\bin;%MSYS_HOME%\usr\bin
set DRV_DIR=..\DrvFAMICompiler\bin\Debug\bin

del buildlog.txt
del errlog.txt
del comlog.txt
make -k >buildlog.txt 2>&1
if %errorlevel% equ 0	goto end
start errlog.txt
:end
move /y drv.bin %DRV_DIR%
move /y drv_mmc5.bin %DRV_DIR%
move /y drv_vrc6.bin %DRV_DIR%
move /y dsp_code.bin %DRV_DIR%
move /y dsp_data.bin %DRV_DIR%
