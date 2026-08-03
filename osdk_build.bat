@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg

:: Goto Camp
:: Goto MapAsm
Goto Ville1
:: Goto Ville2

::
:: Set the build parameters : Laby
:: Launch the compilation of files : Laby
::

:Camp

::
:: Same for Camp
::

:: SET OSDK=C:\OSDK
SET OSDK=C:\OSDK_2_0

CALL osdk_config_camp.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_camp.htm %OSDKNAME% %OSDK%\documentation\documentation.css

Call sed -i.bak s/\\/\//g BUILD\symbols_ext
Call sed -i.bak s/c:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext
Call sed -i.bak s/C:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext

Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe 
Copy asedoric_io.s sedoric_io.s 

:: SET OSDK=C:\OSDK_2_0

Goto Tap2dsk


:Dialog

::
:: Same for Dialog
::
:: CALL osdk_config_dialog.bat
:: CALL %OSDK%\bin\make.bat %OSDKFILE%
:: %OSDK%\bin\MemMap.exe build\symbols build\map_dialog.htm %OSDKNAME% %OSDK%\documentation\documentation.css


:MapAsm

::
:: Same for MapAsm
::
SET OSDKLINK=
SET OSDKHEAD=
CALL osdk_config_map_asm.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_map.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\map.tap BUILD\map.pat.tap
Copy BUILD\symbols BUILD\symbols_map

Call sed -i.bak s/\\/\//g BUILD\symbols_ext
Call sed -i.bak s/c:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext
Call sed -i.bak s/C:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext


Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe 
Copy asedoric_io.s sedoric_io.s 

Goto Tap2dsk

:Ville1

CALL osdk_config_map_ville1.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_ville1.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville1

Call sed -i.bak s/\\/\//g BUILD\symbols_ext
Call sed -i.bak s/c:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext
Call sed -i.bak s/C:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext


Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe 
Copy asedoric_io.s sedoric_io.s 

Goto Tap2dsk


:Ville2

CALL osdk_config_map_ville2.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_ville2.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville2

Call sed -i.bak s/\\/\//g BUILD\symbols_ext
Call sed -i.bak s/c:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext
Call sed -i.bak s/C:\//\/Users\/torguet\/.wine\/drive_c\//g BUILD\symbols_ext


Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe 
Copy asedoric_io.s sedoric_io.s 

Goto Tap2dsk

::
:: Same for TestT4Team
::
CALL osdk_config_test_t4_team.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_test_t4_team.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_t4team

Goto Tap2dsk

:Tap2dsk

pause

:: %OSDK%\bin\tap2dsk -c19:1 -n"   Tyrann IV" -i"DIR" BUILD/Z-LUWIN.tap BUILD/Z-WINT.tap BUILD/Z-MORMON.tap BUILD/Z-WINTER.tap BUILD/Z-NED.tap BUILD/Z-RODRIC.tap BUILD/creation.tap BUILD/Z-CASTRA.tap BUILD/Z-SHOP.tap BUILD/laby.tap BUILD/Z-CATELI.tap BUILD/Z-SORC.tap BUILD/Z-DWOLF.tap BUILD/Z-TYRION.tap BUILD/labyMaximus.tap BUILD/Z-Dragon.tap BUILD/Z-TYWIN.tap BUILD/Z-HIGHGA.tap BUILD/Z-WALL1.tap BUILD/Z-INTRO.tap BUILD/Z-WALL2.tap BUILD/Z-JAIME.tap BUILD/Z-WALL3.tap BUILD/T-IMG-P.TAP BUILD/TEAM.TAP BUILD/COMBAT.TAP BUILD\L4-Conflans.tap tyrann4.dsk

:: %OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD/Z-LUWIN.tap BUILD/Z-WINT.tap BUILD/Z-MORMON.tap BUILD/Z-WINTER.tap BUILD/Z-NED.tap BUILD/Z-RODRIC.tap BUILD/Z-CASTRA.tap BUILD/Z-SHOP.tap BUILD/Z-CATELI.tap BUILD/Z-SORC.tap BUILD/Z-DWOLF.tap BUILD/Z-TYRION.tap BUILD/Z-Dragon.tap BUILD/Z-TYWIN.tap BUILD/Z-HIGHGA.tap BUILD/Z-WALL1.tap BUILD/Z-INTRO.tap BUILD/Z-WALL2.tap BUILD/Z-JAIME.tap BUILD/Z-WALL3.tap t4_img.dsk

:: %OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\TIMGPERSOS.tap BUILD\TITEMS.tap  BUILD\L1King.tap BUILD\TXTPER1.tap BUILD\L2Dorne.tap BUILD\TXTPER2.tap BUILD\L3Storm.tap BUILD\TXTPER3.tap BUILD\L4HighGa.tap BUILD\TXTPER4.tap BUILD\L5Pike.tap BUILD\TXTPER5.tap BUILD\L6Eyrie.tap BUILD\TXTPER6.tap BUILD\L7Caster.tap BUILD\TXTPER7.tap BUILD\L8River.tap BUILD\TXTPER8.tap BUILD\L9Winter.tap BUILD\TXTPER9.tap BUILD\TXTPER10.tap BUILD\TPRIX.tap BUILD\monstres.tap t4_data.dsk

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BasicLabel\BUILD\combat.tap BUILD\camp.tap BUILD\map.tap BUILD\ville1.tap BUILD\ville2.tap  BUILD\t4team.tap t4_prog.dsk

pause

:: %OSDK%\bin\old2mfm t4_img.dsk
:: copy t4_img.dsk c:\Euphoric\disks
:: %OSDK%\bin\old2mfm t4_data.dsk
:: copy t4_data.dsk c:\Euphoric\disks
%OSDK%\bin\old2mfm t4_prog.dsk
:: copy t4_prog.dsk c:\Euphoric\disks

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
