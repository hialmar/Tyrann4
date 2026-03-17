 5 REM {++++ ORIC - NEMAUSUS RPG - April 2018 ++++}
 10 REM { Maximus (denis SOL)
 15 REM GOTO Intro ' saute l'intro pour tester la suite
 20 A=DEEK(#308):R=RND(-A)
 25 TEXT:CLS:PAPER0:INK3
 30 PRINT CHR$(17);CHR$(20)
 35 PRINTSPC(4);CHR$(4);CHR$(27);"JCEO GAMES STUDIOS ";CHR$(27)"BPRESENT"
 40 PRINT:PRINT:PRINT
 45 PRINTSPC(5);CHR$(27);"A";CHR$(27)"JA ROMAN RPG ADVENTURE";CHR$(4)
 50 PRINT:PRINT:PRINT
 55 PRINT "      "CHR$(27);"E";CHR$(96)" COLONIA NEMAUSENSIS":PRINT
 60 A$=CHR$(126):B$=CHR$(255)
 65 LP$=B$:FORI=1 TO 34 :LP$=LP$+B$:NEXTI
 70 L$=B$:FORI=1 TO 33 :L$=L$+B$:NEXTI:L$=L$+B$
 75 PRINT LP$
 80 PRINT B$;SPC(33);B$
 85 PRINT B$;"         AVE  HERO OF ROMA       ";B$
 90 PRINT B$;SPC(33);B$
 95 PRINT L$
 100 PRINT B$;SPC(33);B$
 105 PRINT B$;"    MAY  JUPITER    HELP  US     ";B$
 110 PRINT B$;SPC(33);B$
 115 PRINT B$;SPC(33);B$
 120 PRINT B$;"  NORTH   OF   HADRIAN'S  WALL   ";B$
 125 PRINT B$;SPC(33);B$
 130 PRINT LP$
 135 WAIT150:PLOT 29,24," SPACE >"
 140 GETA$:IF A$<>" " THEN 140
 145 PRINT CHR$(17);CHR$(20)
 150 A$="":B$="":LP$=""
 155 REM MESSAGE D'INTRO DE L'EMPEREUR
 160 PAPER0:INK7:HIRES:POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
 165 PRINT:S$="<| EMPEROR LUCIUS VERUS OFFICE |>":GOSUB 520
 170 T1=1:T2=1'temporisation affichage
 175 CL=10:LINE=6:NLIGNE=19
 180 FORI=1TONL:READS$
 185 FORJ=1TOLEN(S$):CURSET CL,LI,0:CHARASC(MID$(S$,J,1)),0,1
 190 CL=CL+6:WAIT T1
 195 NEXTJ
 200 CL=10:LI=LI+10:WAIT T2
 205 NEXTI
 210 FORI=1TO5:ZAP:WAIT6:NEXT:EXPLODE:PRINT
 215 REM ++++++++++ CREATION ++++++++++++
 220 NR=6:P=1:TRY=1' NR: nombre de Roles (carriTOMUSICres)
 225 DEF FNA(X)=INT(RND(1)*X)+1:D=10:REM dice (D10)
 230 FORI=1TONR:READ ROLE$(I):NEXTI:REM 6 roles
 235 FORI=1TO 7:READ CULT$(I):NEXTI:REM 7 cultures (races)
 240 FORI=1TO 7:READ CARAC$(I):NEXTI:REM 7 CARACTERISTICS
 245 FOR R=1TO NR: FOR C=1TO 7
 250 READ BR(R,C)
 255 NEXT C, R:REM ++ Bonus des Roles
 260 PRINTSPC(8);CHR$(148);" ! GO ! < Press G >"CHR$(144)
 265 GETA$:IFA$<>"G" THEN 265
 270 REM creation du 1er hTOPLAYros (P)
 275 FORI=1TO 6:BAG(P,I)=0:NEXTI:REM INITIALIZE BAG
 280 TEXT:CLS:PRINT:PRINTSPC(12);CHR$(4);CHR$(27)"JCEO RPG";CHR$(4)
 285 PRINT
 290 PRINT:S$=" ****** CREATE your 1st Hero ***** ":GOSUB 520:PRINT
 295 PRINT:S$="HIS NAME (10 letters max)":GOSUB 520
 300 INPUT NOM$(P)
 305 IF LEN(NOM$(P))< 2 THEN ZAP:GOTO 295
 310 IF LEN(NOM$(P))>10 THEN NOM$(P)=LEFT$(NOM$(P),10)
 315 GOSUB 475:SS$=NOM$(P)
 320 TEST=0:GOSUB 555
 325 PRINT @10,17;"WHICH Culture ? ";
 330 GET CULT$:CULT=VAL(CULT$)
 335 IF CU<1 OR CU>7 THEN ZAP:GOTO 320
 340 CP(1)=CU:PRINT CU$(CP(1))
 345 GOSUB 445:IF OK$="N" THEN ZAP:GOTO 320
 350 TEST=1:BOOL=0:SS$=SS$+" the "+CULT$(CP(1))
 355 GOSUB 555
 360 PRINT @10,16;"WHICH ROLE ? ";
 365 GET RO$:ROLE=VAL(RO$)
 370 IF RO<1 OR RO>NR THEN ZAP:GOTO 355
 375 IF RO<4 THEN 395
 380 IF RO=4 AND(CU=2ORCU=5ORCU=6)THENGOSUB 410:GOTO 355
 385 IF RO=5 AND(CU<>2ANDCU<>5) THEN GOSUB 410:GOTO 355
 390 IF RO=6 AND(CU<>3ANDCU<>6) THEN GOSUB 410:GOTO 355
 395 RP(1)=RO:PRINT RO$(RP(1)):GOSUB 550
 400 GOSUB 445:IF OK$="N" THEN ZAP:TEXT:GOTO 355
 405 END' +++++++++++++++  Sous programmes et DATA ++++++++++++++++++++
 410 PRINT:PRINT:
 415 IF BOOL=1THEN 430
 420 S$= "  HEY !! "+CULT$(CP(1))+" cannot do that !  "
 425 BOOL=1:GOTO 435
 430 S$= "         ARE YOU KIDDING ME ?     ":BOOL=0
 435 GOSUB 535:ZAP:WAIT200:PING
 440 RETURN
 445 REM OK ?
 450 PING:WAIT 100
 455 PRINT SPC(10);CHR$(148)" < OK ? Y/N > "CHR$(144)
 460 OK$=KEY$:IF OK$="" THEN 460
 465 IF OK$<>"N" AND OK$<>"Y" THEN 460
 470 RETURN
 475 REM lowercase name
 480 S$=NOM$(P):NOM$(P)=LEFT$(S$,1)
 485 FORI=2TOLEN(S$)
 490 MI=ASC(MID$(S$,I,1))
 495 IF MI>64 AND MI<91 THEN MI=MI+32
 500 L$=CHR$(MI)
 505 NOM$(P)=NOM$(P)+L$
 510 NEXT
 515 RETURN
 520 REM blue
 525 PRINTCHR$(148);S$;CHR$(144)
 530 RETURN
 535 REM red
 540 PRINTCHR$(145);S$;CHR$(144)
 545 RETURN
 550 RETURN
 555 REM DISPLAY
 560 CLS:
 565 T=INT((37-LEN(SS$))/2)
 570 PRINT @ T,1;" ";CHR$(145);" ";SS$;"  ";CHR$(144)
 575 PRINT
 580 PRINT"        ***********************"
 585 PRINT"        *                     *"
 590 IFTEST=0THENXX=7ELSEXX=6
 595 FOR I=1TOXX:L=I+4
 600 IF TEST=0 THEN S$=CULT$(I)ELSE S$=ROLE$(I)
 605 PRINT @10,L;"*":PRINT @31,L;"*"
 610 PRINT @14,L;I;S$
 615 NEXT I
 620 PRINT"        *                     *"
 625 PRINT"        ***********************"
 630 RETURN
 635 REM ***************  TEXTE INTRO  **************
 640 DATA "   Ave !    Great Hero of Roma      "
 645 DATA "The Empire  needs you  one more time"
 650 DATA "Our north Frontier, Antoninus's Wall"
 655 DATA "is  under  pressure  by  the  pictus"
 660 DATA "barbarians herds...."
 665 DATA "I want to increase the safety of the"
 670 DATA "civilized Britannia's people,   by a"
 675 DATA "strong offensive with the legions of"
 680 DATA "Nemausus.  "
 685 DATA "My father,  Antoninus Pius,  born in"
 690 DATA "this town, always said  they are the"
 695 DATA "most scary legions of all the Empire"
 700 DATA "You must explore the Caledonia land,"
 705 DATA "North of  Antoninus & Hadrian Walls,"
 710 DATA "Evaluate  enemy forces,  seek & find"
 715 DATA "their Chief .....and KILL HIM  !!!!!"
 720 DATA " . . . . "
 725 DATA "    * For the Glory of Roma *  "
 730 DATA "    ! Pray all the Gods now !  "
 735 DATA Legionary, Gladiator, Scout, Druid, Sem-Priest, Vestal
 740 DATA Celtic, Egyptian, Gallic, Goth, Persian, Roman, Viking
 745 DATA Melee Skill, Range Skill, Strength' Ml Rg St
 750 DATA Agility, Intelligence' Ag IQ
 755 DATA Mental Strength, Health Points' MS HP
 760 REM   Ml Rg St  Ag IQ MS HP  les bonus de roles
 765 DATA   6, 6, 6, 6, 5, 5, 3: REM Legionary
 770 DATA   8, 4, 8, 9, 3, 6, 5: REM Gladiator
 775 DATA   4, 8, 4,12, 8, 6, 3: REM Scout (Eclaireur)
 780 DATA   0, 6, 4, 6,10,10, 2: REM Druid
 785 DATA  -2,-2, 2, 8,12,10, 1: REM Sem-Priest
 790 DATA  -4,-4, 0,10,15,12, 0: REM Vestal
 795 REM MODIFS DUES AUX CULTURES
 800 REM A DEFINIR
