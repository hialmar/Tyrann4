@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg

:Ville_11

CALL osdk_config_Ville_11.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_11.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_11

::Goto GestionSymbols
:Ville_15

CALL osdk_config_Ville_15.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_15.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_15

::Goto GestionSymbols
:Ville_7

CALL osdk_config_Ville_7.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_7.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_7

::Goto GestionSymbols
:Ville_9

CALL osdk_config_Ville_9.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_9.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_9

::Goto GestionSymbols
:Ville_3

CALL osdk_config_Ville_3.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_3.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_3

::Goto GestionSymbols
:map

CALL osdk_config_map.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map

::Goto GestionSymbols
:Ville_12

CALL osdk_config_Ville_12.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_12.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_12

::Goto GestionSymbols
:Ville_16

CALL osdk_config_Ville_16.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_16.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_16

::Goto GestionSymbols
:Ville_4

CALL osdk_config_Ville_4.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_4.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_4

::Goto GestionSymbols
:Ville_13

CALL osdk_config_Ville_13.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_13.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_13

::Goto GestionSymbols
:ville_5

CALL osdk_config_ville_5.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\ville_5.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville_5

::Goto GestionSymbols
:Ville_1

CALL osdk_config_Ville_1.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_1.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_1

::Goto GestionSymbols
:Ville_10

CALL osdk_config_Ville_10.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_10.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_10

::Goto GestionSymbols
:Ville_14

CALL osdk_config_Ville_14.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_14.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_14

::Goto GestionSymbols
:ville_6

CALL osdk_config_ville_6.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\ville_6.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville_6

::Goto GestionSymbols
:Ville_2

CALL osdk_config_Ville_2.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_2.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_2

::Goto GestionSymbols
:Ville_8

CALL osdk_config_Ville_8.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\Ville_8.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_Ville_8

::Goto GestionSymbols

:GestionSymbols
Call sed -i.bak s/\\/\//g BUILD\symbols_ext
Call sed -i.bak s/c:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext
Call sed -i.bak s/C:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext


Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe 
Copy asedoric_io.s sedoric_io.s 

Goto Tap2dsk
:Tap2dsk

pause

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\Ville_11.tap BUILD\Ville_15.tap BUILD\Ville_7.tap BUILD\Ville_9.tap BUILD\Ville_3.tap BUILD\map.tap BUILD\Ville_12.tap BUILD\Ville_16.tap BUILD\Ville_4.tap BUILD\Ville_13.tap BUILD\ville_5.tap BUILD\Ville_1.tap BUILD\Ville_10.tap BUILD\Ville_14.tap BUILD\ville_6.tap BUILD\Ville_2.tap t4_prog.dsk

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\Ville_8.tap  t4_1_prog.dsk


pause

%OSDK%\bin\old2mfm t4_prog.dsk

%OSDK%\bin\old2mfm t4_1_prog.dsk

GOTO End

::
:: Outputs an error message
::
:ErCfg
ECHO == ERROR ==
ECHO The Oric SDK was not configured properly
ECHO You should have a OSDK environment variable setted to the location of the SDK
IF "%OSDKBRIEF%"=="" PAUSE
GOTO End


:End
pause
