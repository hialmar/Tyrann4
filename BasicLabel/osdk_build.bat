@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg

echo "combat.tap"
%OSDK%\bin\bas2tap -b2t1 combatL.bas BUILD\combat.tap

echo "dicesL.tap"
%OSDK%\bin\bas2tap -b2t1 dicesL.bas BUILD\dices.tap

:: echo "genteam.tap"
:: %OSDK%\bin\bas2tap -b2t1 genteamL.bas BUILD\genteam.tap

echo "cop.tap"
%OSDK%\bin\bas2tap -b2t1 copL.bas BUILD\cop.tap

:: %OSDK%\bin\bas2tap -b2t1 camp.bas BUILD\camp.tap

:: echo "ville.tap"
:: %OSDK%\bin\bas2tap -b2t1 villeL.bas BUILD\ville.tap

echo "armory.tap"
%OSDK%\bin\bas2tap -b2t1 armoryL.bas BUILD\armory.tap

echo "medicus.tap"
%OSDK%\bin\bas2tap -b2t1 medicL.bas BUILD\medicus.tap

echo "herborist.tap"
%OSDK%\bin\bas2tap -b2t1 herboL.bas BUILD\herborist.tap

echo "animalia.tap"
%OSDK%\bin\bas2tap -b2t1 animalsL.bas BUILD\animalia.tap

echo "bazar.tap"
%OSDK%\bin\bas2tap -b2t1 bazarL.bas BUILD\bazar.tap

echo "taberna.tap"
%OSDK%\bin\bas2tap -b2t1 tabernaL.bas BUILD\taberna.tap

echo "TITEMS.tap"
%OSDK%\bin\bas2tap -b2t1 TItemsL.bas BUILD\TITEMS.tap

echo "TPRIX.tap"
%OSDK%\bin\bas2tap -b2t1 TPrixL.bas BUILD\TPRIX.tap

echo "monstres.tap"
%OSDK%\bin\bas2tap -b2t1 monstresL.bas BUILD\monstres.tap

echo "editor.tap"
%OSDK%\bin\bas2tap -b2t1 editorL.bas BUILD\editor.tap

echo "dices.tap"
%OSDK%\bin\bas2tap -b2t1 dicesL.bas BUILD\dices.tap

:: echo "intro.tap"
:: %OSDK%\bin\bas2tap -b2t1 IntroL.bas BUILD\intro.tap


:Tap2dsk

pause

:: %OSDK%\bin\tap2dsk -c19:1 -n"   Tyrann III" -i"DIR" BUILD/Z-LUWIN.tap BUILD/Z-WINT.tap BUILD/Z-MORMON.tap BUILD/Z-WINTER.tap BUILD/Z-NED.tap BUILD/Z-RODRIC.tap BUILD/creation.tap BUILD/Z-CASTRA.tap BUILD/Z-SHOP.tap BUILD/laby.tap BUILD/Z-CATELI.tap BUILD/Z-SORC.tap BUILD/Z-DWOLF.tap BUILD/Z-TYRION.tap BUILD/labyMaximus.tap BUILD/Z-Dragon.tap BUILD/Z-TYWIN.tap BUILD/Z-HIGHGA.tap BUILD/Z-WALL1.tap BUILD/Z-INTRO.tap BUILD/Z-WALL2.tap BUILD/Z-JAIME.tap BUILD/Z-WALL3.tap BUILD/T-IMG-P.TAP BUILD/TEAM.TAP BUILD/COMBAT.TAP BUILD\L4-Conflans.tap tyrann3.dsk

:: %OSDK%\bin\tap2dsk -n"   Tyrann III" -i"DIR" BUILD/Z-LUWIN.tap BUILD/Z-WINT.tap BUILD/Z-MORMON.tap BUILD/Z-WINTER.tap BUILD/Z-NED.tap BUILD/Z-RODRIC.tap BUILD/Z-CASTRA.tap BUILD/Z-SHOP.tap BUILD/Z-CATELI.tap BUILD/Z-SORC.tap BUILD/Z-DWOLF.tap BUILD/Z-TYRION.tap BUILD/Z-Dragon.tap BUILD/Z-TYWIN.tap BUILD/Z-HIGHGA.tap BUILD/Z-WALL1.tap BUILD/Z-INTRO.tap BUILD/Z-WALL2.tap BUILD/Z-JAIME.tap BUILD/Z-WALL3.tap t3_img.dsk

:: %OSDK%\bin\tap2dsk -n"   Tyrann III" -i"DIR" BUILD\TIMGPERSOS.tap BUILD\TITEMS.tap  BUILD\L1King.tap BUILD\TXTPER1.tap BUILD\L2Dorne.tap BUILD\TXTPER2.tap BUILD\L3Storm.tap BUILD\TXTPER3.tap BUILD\L4HighGa.tap BUILD\TXTPER4.tap BUILD\L5Pike.tap BUILD\TXTPER5.tap BUILD\L6Eyrie.tap BUILD\TXTPER6.tap BUILD\L7Caster.tap BUILD\TXTPER7.tap BUILD\L8River.tap BUILD\TXTPER8.tap BUILD\L9Winter.tap BUILD\TXTPER9.tap BUILD\TXTPER10.tap BUILD\TPRIX.tap BUILD\monstres.tap t3_data.dsk

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\combat.tap BUILD\cop.tap BUILD\taberna.tap BUILD\bazar.tap BUILD\animalia.tap BUILD\medicus.tap BUILD\herborist.tap BUILD\editor.tap BUILD\monstres.tap BUILD\TPRIX.tap BUILD\TITEMS.tap BUILD\dices.tap BUILD\armory.tap t4_bas_prog.dsk

pause

:: %OSDK%\bin\old2mfm t3_img.dsk
:: copy t3_img.dsk c:\Euphoric\disks
:: %OSDK%\bin\old2mfm t3_data.dsk
:: copy t3_data.dsk c:\Euphoric\disks
%OSDK%\bin\old2mfm t4_bas_prog.dsk
:: copy t4_bas_prog.dsk c:\Euphoric\disks

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
