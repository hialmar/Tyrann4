@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg

:: Goto Camp
:: Goto MapAsm
:: Goto Ville1
:: Goto Ville2
:: Goto Ville3
:: Goto Ville4
:: Goto Ville5
:: Goto Ville6
:: Goto Ville7
Goto Ville8
:: Goto Ville9
:: Goto Ville10
:: Goto Ville11
:: Goto Ville12
:: Goto Ville13
:: Goto Ville14
:: Goto Ville15
:: Goto Ville16
:: Goto PMap
:: Goto PVille1
:: Goto PVille2
:: Goto PVille3
:: Goto PVille4
:: Goto PVille5
:: Goto PVille6
:: Goto PVille7
:: Goto PVille8
:: Goto PVille9
:: Goto PVille10
:: Goto PVille11
:: Goto PVille12
:: Goto PVille13
:: Goto PVille14
:: Goto PVille15
:: Goto PVille16

::
:: Set the build parameters : Laby
:: Launch the compilation of files : Laby
::

:Camp

::
:: Same for Camp
::

SET OSDK=C:\OSDK

echo "1.23"

:: SET OSDK=C:\OSDK_2_0

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

SET OSDK=C:\OSDK_2_0

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
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_map.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\map.tap BUILD\map_init.tap
Copy BUILD\symbols BUILD\symbols_map

Goto GestionSymbols

:Ville1

CALL osdk_config_map_ville1.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville1.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville1

Goto GestionSymbols

:Ville2

CALL osdk_config_map_ville2.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville2.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville2

Goto GestionSymbols

:Ville3

CALL osdk_config_map_ville3.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville3.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville3

Goto GestionSymbols

:Ville4

CALL osdk_config_map_ville4.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville4.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville4

Goto GestionSymbols

:Ville5

CALL osdk_config_map_ville5.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville5.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville5

Goto GestionSymbols

:Ville6

CALL osdk_config_map_ville6.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville6.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_ville6

Goto GestionSymbols

:Ville7

CALL osdk_config_map_ville7.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville7.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville7

Goto GestionSymbols

:Ville8

CALL osdk_config_map_ville8.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville8.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville8

Goto GestionSymbols

:Ville9

CALL osdk_config_map_ville9.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville9.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville9

Goto GestionSymbols

:Ville10

CALL osdk_config_map_ville10.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville10.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville10

Goto GestionSymbols

:Ville11

CALL osdk_config_map_ville11.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville11.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville11

Goto GestionSymbols

:Ville12

CALL osdk_config_map_ville12.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville12.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville12

Goto GestionSymbols

:Ville13

CALL osdk_config_map_ville13.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville13.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville13

Goto GestionSymbols

:Ville14

CALL osdk_config_map_ville14.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville14.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville14

Goto GestionSymbols

:Ville15

CALL osdk_config_map_ville15.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville15.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville15

Goto GestionSymbols

:Ville16

CALL osdk_config_map_ville16.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_ville16.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_map_ville16

Goto GestionSymbols

:PMap
CALL osdk_config_map_asm.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map.comp Compressed\cmap.s dta_map
Copy /b pbase.s Compressed\cmap.s pmap.s
CALL osdk_config_pmap.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap

Goto GestionSymbols

:PVille1
CALL osdk_config_map_ville1.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\ville1.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\ville1.comp Compressed\cville1.s dta_map
Type pbase.s Compressed\cville1.s > pville1.s
CALL osdk_config_pville1.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pville1.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pville1

Goto GestionSymbols

:PVille2
CALL osdk_config_map_ville2.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\Ville_2.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\Ville_2.comp Compressed\cVille_2.s dta_map
Type pbase.s Compressed\cVille_2.s > pville2.s
CALL osdk_config_pmap_ville2.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pville2.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pville2

Goto GestionSymbols

:PVille3
CALL osdk_config_map_ville3.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville3.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville3.comp Compressed\cmap_ville3.s dta_map
Type pbase.s Compressed\cmap_ville3.s > pville3.s
CALL osdk_config_pmap_ville3.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville3.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville3

Goto GestionSymbols

:PVille4
CALL osdk_config_map_ville4.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville4.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville4.comp Compressed\cmap_ville4.s dta_map
Type pbase.s Compressed\cmap_ville4.s > pville4.s
CALL osdk_config_pmap_ville4.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville4.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville4

Goto GestionSymbols

:PVille5
CALL osdk_config_map_ville5.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville5.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville4.comp Compressed\cmap_ville5.s dta_map
Type pbase.s Compressed\cmap_ville5.s > pville5.s
CALL osdk_config_pmap_ville5.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville5.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville5

Goto GestionSymbols

:PVille6
CALL osdk_config_map_ville6.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville6.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville6.comp Compressed\cmap_ville6.s dta_map
Type pbase.s Compressed\cmap_ville6.s > pville6.s
CALL osdk_config_pmap_ville6.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville6.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville6

Goto GestionSymbols

:PVille7
CALL osdk_config_map_ville7.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville7.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville7.comp Compressed\cmap_ville7.s dta_map
Type pbase.s Compressed\cmap_ville7.s > pville7.s
CALL osdk_config_pmap_ville7.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville7.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville7

Goto GestionSymbols

:PVille8
CALL osdk_config_map_ville8.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville8.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville8.comp Compressed\cmap_ville8.s dta_map
Type pbase.s Compressed\cmap_ville8.s > pville8.s
CALL osdk_config_pmap_ville8.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville8.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville8

Goto GestionSymbols

:PVille9
CALL osdk_config_map_ville9.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville9.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville9.comp Compressed\cmap_ville9.s dta_map
Type pbase.s Compressed\cmap_ville9.s > pville9.s
CALL osdk_config_pmap_ville9.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville9.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville9

Goto GestionSymbols

:PVille10
CALL osdk_config_map_ville10.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville10.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville10.comp Compressed\cmap_ville10.s dta_map
Type pbase.s Compressed\cmap_ville10.s > pville10.s
CALL osdk_config_pmap_ville10.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville10.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville10

Goto GestionSymbols

:PVille11
CALL osdk_config_map_ville11.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville11.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville11.comp Compressed\cmap_ville11.s dta_map
Type pbase.s Compressed\cmap_ville11.s > pville11.s
CALL osdk_config_pmap_ville11.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville11.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville11

Goto GestionSymbols

:PVille12
CALL osdk_config_map_ville12.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville12.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville12.comp Compressed\cmap_ville12.s dta_map
Type pbase.s Compressed\cmap_ville12.s > pville12.s
CALL osdk_config_pmap_ville12.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville12.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville12

Goto GestionSymbols

:PVille13
CALL osdk_config_map_ville13.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville13.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville13.comp Compressed\cmap_ville13.s dta_map
Type pbase.s Compressed\cmap_ville13.s > pville13.s
CALL osdk_config_pmap_ville13.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville13.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville13

Goto GestionSymbols

:PVille14
CALL osdk_config_map_ville14.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville14.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville14.comp Compressed\cmap_ville14.s dta_map
Type pbase.s Compressed\cmap_ville14.s > pville14.s
CALL osdk_config_pmap_ville14.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville14.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville14

Goto GestionSymbols

:PVille15
CALL osdk_config_map_ville15.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville15.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville15.comp Compressed\cmap_ville15.s dta_map
Type pbase.s Compressed\cmap_ville15.s > pville15.s
CALL osdk_config_pmap_ville15.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville15.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville15

Goto GestionSymbols

:PVille16
CALL osdk_config_map_ville16.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
CALL %OSDK%\bin\FilePack.exe -p0 BUILD\final.out Compressed\map_ville16.comp
CALL %OSDK%\bin\bin2txt.exe -s1 -f2 Compressed\map_ville16.comp Compressed\cmap_ville16.s dta_map
Type pbase.s Compressed\cmap_ville16.s > pville16.s
CALL osdk_config_pmap_ville16.bat
CALL %OSDK%\bin\make.bat %OSDKFILE%
%OSDK%\bin\MemMap.exe -s30 build\symbols build\map_pmap_ville16.htm %OSDKNAME% %OSDK%\documentation\documentation.css
Copy BUILD\symbols BUILD\symbols_pmap_ville16

Goto GestionSymbols


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

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\camp.tap BUILD\map.tap BUILD\pmap.tap BUILD\ville1.tap BUILD\pville1.tap BUILD\ville2.tap BUILD\ville3.tap BUILD\ville4.tap BUILD\ville5.tap BUILD\ville6.tap BUILD\ville7.tap BUILD\ville8.tap t4_prog.dsk

%OSDK%\bin\tap2dsk -n"   Tyrann IV" -i"DIR" BUILD\ville8.tap t4_prog1.dsk

pause

:: %OSDK%\bin\old2mfm t4_img.dsk
:: copy t4_img.dsk c:\Euphoric\disks
:: %OSDK%\bin\old2mfm t4_data.dsk
:: copy t4_data.dsk c:\Euphoric\disks
%OSDK%\bin\old2mfm t4_prog.dsk
%OSDK%\bin\old2mfm t4_prog1.dsk
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
