@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg

:: Goto Basic
:: Goto Dialog
:: Goto Camp
:: Goto Map
Goto MapAsm
:: Goto Tuile
:: Goto Tuiles
Goto Ville2

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

:MapAsmDom
::
:: Same for MapAsmDom
::
CALL osdk_config_map_asm_dom.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_mapdom.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\map.tap BUILD\map.dom.tap
Goto End

:Tuile

::
:: Same for Tuile
::
CALL osdk_config_tuiles.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_tuiles.htm %OSDKNAME% %OSDK%\documentation\documentation.css


Goto End

:Tuiles

::
:: Same for Tuiles
::
CALL osdk_config_tuiles_asm.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_tuiles.htm %OSDKNAME% %OSDK%\documentation\documentation.css


Goto End

::
:: Same for CopyZeroPage
::
SET OSDKLINK=-B
CALL osdk_config_cpzerop.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe build\symbols build\map_cpzerop.htm %OSDKNAME% %OSDK%\documentation\documentation.css
SET OSDKLINK=

:Basic

echo "combat.tap"
%OSDK%\bin\bas2tap -b2t1 combat.bas BUILD\combat.tap

echo "creation.tap"
%OSDK%\bin\bas2tap -b2t1 creation.bas BUILD\creation.tap

:: %OSDK%\bin\bas2tap -b2t1 camp.bas BUILD\camp.tap

echo "ville.tap"
%OSDK%\bin\bas2tap -b2t1 ville.bas BUILD\ville.tap

echo "L1King.tap"
%OSDK%\bin\bas2tap -b2t1 L1King.txt BUILD\L1King.tap

echo "TXTPER1.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER1.txt BUILD\TXTPER1.tap

echo "L2Dorne.tap"
%OSDK%\bin\bas2tap -b2t1 L2Dorne.txt BUILD\L2Dorne.tap

echo "TXTPER2.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER2.txt BUILD\TXTPER2.tap

echo "L3Storm.tap"
%OSDK%\bin\bas2tap -b2t1 L3Storm.txt BUILD\L3Storm.tap

echo "TXTPER3.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER3.txt BUILD\TXTPER3.tap

echo "L4HighGa.tap"
%OSDK%\bin\bas2tap -b2t1 L4HighGa.txt BUILD\L4HighGa.tap

echo "TXTPER4.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER4.txt BUILD\TXTPER4.tap

echo "L5Pike.tap"
%OSDK%\bin\bas2tap -b2t1 L5Pike.txt BUILD\L5Pike.tap

echo "TXTPER5.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER5.txt BUILD\TXTPER5.tap

echo "L6Eyrie.tap"
%OSDK%\bin\bas2tap -b2t1 L6Eyrie.txt BUILD\L6Eyrie.tap

echo "TXTPER6.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER6.txt BUILD\TXTPER6.tap

echo "L7Caster.tap"
%OSDK%\bin\bas2tap -b2t1 L7Caster.txt BUILD\L7Caster.tap

echo "TXTPER7.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER7.txt BUILD\TXTPER7.tap

echo "L8River.tap"
%OSDK%\bin\bas2tap -b2t1 L8River.txt BUILD\L8River.tap

echo "TXTPER8.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER8.txt BUILD\TXTPER8.tap

echo "L9Winter.tap"
%OSDK%\bin\bas2tap -b2t1 L9Winter.txt BUILD\L9Winter.tap

echo "TXTPER9.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER9.txt BUILD\TXTPER9.tap

echo "TXTPER10.tap"
%OSDK%\bin\bas2tap -b2t1 TXTPER10.txt BUILD\TXTPER10.tap

:: %OSDK%\bin\header -a0 GoT.mid BUILD\Got.tap $0600

echo "TIMGPERSOS.tap"
%OSDK%\bin\bas2tap -b2t1 Timgpersos.bas BUILD\TIMGPERSOS.tap

echo "TITEMS.tap"
%OSDK%\bin\bas2tap -b2t1 TItems.bas BUILD\TITEMS.tap

echo "TPRIX.tap"
%OSDK%\bin\bas2tap -b2t1 TPrix.bas BUILD\TPRIX.tap

echo "monstres.tap"
%OSDK%\bin\bas2tap -b2t1 monstres.bas BUILD\monstres.tap

echo "editor.tap"
%OSDK%\bin\bas2tap -b2t1 editor.bas BUILD\editor.tap

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
