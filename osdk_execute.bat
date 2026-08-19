@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated,
::
IF "%OSDK%"=="" GOTO ErCfg

SET OSDKGDBPORT=6502

cd c:\osdk_2_0\Oricutron\
CALL oricutron-sdl2.exe -t c:\Tyrann4\T4.dsk -s c:\Tyrann4\BUILD\symbols_map --gdb_port 6502
cd c:\Tyrann4
Goto End
::
:: Set the build paremeters
::
CALL osdk_config_tuiles_asm.bat

::
:: Run the emulator using the common batch
::
CALL %OSDK%\bin\execute.bat
GOTO End

::
:: Outputs an error message about configuration
::
:ErCfg
ECHO == ERROR ==
ECHO The Oric SDK was not configured properly
ECHO You should have a OSDK environment variable setted to the location of the SDK
ECHO ===========
IF "%OSDKBRIEF%"=="" PAUSE
GOTO End

:End
