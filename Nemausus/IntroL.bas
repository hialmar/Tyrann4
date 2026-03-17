#define Space1 34
#define Space2 33
#define NbCultures 7
#define NbItemsInBag 6

#labels

 REM {++++ ORIC - NEMAUSUS RPG - April 2018 ++++}
 REM { Maximus (denis SOL)
 REM GOTO Intro ' saute l'intro pour tester la suite
 A=DEEK(#308):R=RND(-A)
 TEXT:CLS:PAPER0:INK3
 PRINT CHR$(17);CHR$(20)
 PRINTSPC(4);CHR$(4);CHR$(27);"JCEO GAMES STUDIOS ";CHR$(27)"BPRESENT"
 PRINT:PRINT:PRINT
 PRINTSPC(5);CHR$(27);"A";CHR$(27)"JA ROMAN RPG ADVENTURE";CHR$(4)
 PRINT:PRINT:PRINT
 PRINT "      "CHR$(27);"E";CHR$(96)" COLONIA NEMAUSENSIS":PRINT
 A$=CHR$(126):B$=CHR$(255)
 LP$=B$:FORI=1 TO Space1 :LP$=LP$+B$:NEXTI
 L$=B$:FORI=1 TO Space2 :L$=L$+B$:NEXTI:L$=L$+B$
 PRINT LP$
 PRINT B$;SPC(33);B$
 PRINT B$;"         AVE  HERO OF ROMA       ";B$
 PRINT B$;SPC(33);B$
 PRINT L$
 PRINT B$;SPC(33);B$
 PRINT B$;"    MAY  JUPITER    HELP  US     ";B$
 PRINT B$;SPC(33);B$
 PRINT B$;SPC(33);B$
 PRINT B$;"  NORTH   OF   HADRIAN'S  WALL   ";B$
 PRINT B$;SPC(33);B$
 PRINT LP$
 WAIT150:PLOT 29,24," SPACE >"
Loop1
    GETA$:IF A$<>" " THEN Loop1
 PRINT CHR$(17);CHR$(20)
 A$="":B$="":LP$=""

Intro
 REM MESSAGE D'INTRO DE L'EMPEREUR
 PAPER0:INK7:HIRES:POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
 PRINT:S$="<| EMPEROR LUCIUS VERUS OFFICE |>":GOSUB Blue
 T1=1:T2=1'temporisation affichage
 CL=10:LINE=6:NLIGNE=19
 FORI=1TONL:READS$
   FORJ=1TOLEN(S$):CURSET CL,LI,0:CHARASC(MID$(S$,J,1)),0,1
    CL=CL+6:WAIT T1
   NEXTJ
 CL=10:LI=LI+10:WAIT T2
 NEXTI
 FORI=1TO5:ZAP:WAIT6:NEXT:EXPLODE:PRINT


 REM ++++++++++ CREATION ++++++++++++
 NR=6:P=1:TRY=1' NR: nombre de Roles (carrières)
 DEF FNA(X)=INT(RND(1)*X)+1:D=10:REM dice (D10)
 FORI=1TONR:READ ROLE$(I):NEXTI:REM 6 roles
 FORI=1TO NbCultures:READ CULT$(I):NEXTI:REM 7 cultures (races)
 FORI=1TO NbCultures:READ CARAC$(I):NEXTI:REM 7 CARACTERISTICS
 FOR R=1TO NR: FOR C=1TO NbCultures
  READ BR(R,C)
 NEXT C, R:REM ++ Bonus des Roles 
 PRINTSPC(8);CHR$(148);" ! GO ! < Press G >"CHR$(144)
Loop2
    GETA$:IFA$<>"G" THEN Loop2

 REM creation du 1er héros (P)
 FORI=1TO NbItemsInBag:BAG(P,I)=0:NEXTI:REM INITIALIZE BAG

 TEXT:CLS:PRINT:PRINTSPC(12);CHR$(4);CHR$(27)"JCEO RPG";CHR$(4)
 PRINT
 PRINT:S$=" ****** CREATE your 1st Hero ***** ":GOSUB Blue:PRINT

Name
 PRINT:S$="HIS NAME (10 letters max)":GOSUB Blue
 INPUT NOM$(P)
 IF LEN(NOM$(P))< 2 THEN ZAP:GOTO Name
 IF LEN(NOM$(P))>10 THEN NOM$(P)=LEFT$(NOM$(P),10)
 GOSUB LowerCase:SS$=NOM$(P)

Culture
 TEST=0:GOSUB Display
 PRINT @10,17;"WHICH Culture ? ";
 GET CULT$:CULT=VAL(CULT$)
 IF CU<1 OR CU>7 THEN ZAP:GOTO Culture
 CP(1)=CU:PRINT CU$(CP(1))
 GOSUB Ok:IF OK$="N" THEN ZAP:GOTO Culture 
 TEST=1:BOOL=0:SS$=SS$+" the "+CULT$(CP(1))

Role
 GOSUB Display
 PRINT @10,16;"WHICH ROLE ? ";
 GET RO$:ROLE=VAL(RO$)
 IF RO<1 OR RO>NR THEN ZAP:GOTO Role
 IF RO<4 THEN RoleEnd
 IF RO=4 AND(CU=2ORCU=5ORCU=6)THENGOSUB ErrorPrint:GOTO Role
 IF RO=5 AND(CU<>2ANDCU<>5) THEN GOSUB ErrorPrint:GOTO Role
 IF RO=6 AND(CU<>3ANDCU<>6) THEN GOSUB ErrorPrint:GOTO Role

RoleEnd
 RP(1)=RO:PRINT RO$(RP(1)):GOSUB Fiches
 GOSUB Ok:IF OK$="N" THEN ZAP:TEXT:GOTO Role

 END' +++++++++++++++  Sous programmes et DATA ++++++++++++++++++++

ErrorPrint
 PRINT:PRINT:
 IF BOOL=1THEN ErrorKidding
 S$= "  HEY !! "+CULT$(CP(1))+" cannot do that !  "
 BOOL=1:GOTO ErrorPrintEnd
ErrorKidding
 S$= "         ARE YOU KIDDING ME ?     ":BOOL=0
ErrorPrintEnd
 GOSUB Red:ZAP:WAIT200:PING
 RETURN

Ok
 REM OK ?
 PING:WAIT 100
 PRINT SPC(10);CHR$(148)" < OK ? Y/N > "CHR$(144)
LoopOk
 OK$=KEY$:IF OK$="" THEN LoopOk
 IF OK$<>"N" AND OK$<>"Y" THEN LoopOk
 RETURN

LowerCase
 REM lowercase name
 S$=NOM$(P):NOM$(P)=LEFT$(S$,1)
 FORI=2TOLEN(S$)
 MI=ASC(MID$(S$,I,1))
 IF MI>64 AND MI<91 THEN MI=MI+32
 L$=CHR$(MI)
 NOM$(P)=NOM$(P)+L$
 NEXT 
 RETURN

Blue
 REM blue
 PRINTCHR$(148);S$;CHR$(144)
 RETURN

Red
 REM red
 PRINTCHR$(145);S$;CHR$(144)
 RETURN

Fiches
 'HIRES: REM FICHES DES Roles
 'CLOAD"FICH-GLA.HRS"
 RETURN

Display
 REM DISPLAY
 CLS:
 T=INT((37-LEN(SS$))/2)
 PRINT @ T,1;" ";CHR$(145);" ";SS$;"  ";CHR$(144)
 PRINT
 PRINT"        ***********************"
 PRINT"        *                     *"
 IFTEST=0THENXX=7ELSEXX=6
 FOR I=1TOXX:L=I+4
  IF TEST=0 THEN S$=CULT$(I)ELSE S$=ROLE$(I)
  PRINT @10,L;"*":PRINT @31,L;"*"
  PRINT @14,L;I;S$
 NEXT I
 PRINT"        *                     *"
 PRINT"        ***********************"
 RETURN

 REM ***************  TEXTE INTRO  **************
 DATA "   Ave !    Great Hero of Roma      "
 DATA "The Empire  needs you  one more time"
 DATA "Our north Frontier, Antoninus's Wall"
 DATA "is  under  pressure  by  the  pictus" 
 DATA "barbarians herds...."
 DATA "I want to increase the safety of the"
 DATA "civilized Britannia's people,   by a"
 DATA "strong offensive with the legions of"
 DATA "Nemausus.  "
 DATA "My father,  Antoninus Pius,  born in"
 DATA "this town, always said  they are the"
 DATA "most scary legions of all the Empire"
 DATA "You must explore the Caledonia land,"
 DATA "North of  Antoninus & Hadrian Walls,"
 DATA "Evaluate  enemy forces,  seek & find"
 DATA "their Chief .....and KILL HIM  !!!!!"
 DATA " . . . . "
 DATA "    * For the Glory of Roma *  "
 DATA "    ! Pray all the Gods now !  "

 DATA Legionary, Gladiator, Scout, Druid, Sem-Priest, Vestal
 DATA Celtic, Egyptian, Gallic, Goth, Persian, Roman, Viking
 DATA Melee Skill, Range Skill, Strength' Ml Rg St
 DATA Agility, Intelligence' Ag IQ
 DATA Mental Strength, Health Points' MS HP 

 REM   Ml Rg St  Ag IQ MS HP  les bonus de roles 
 DATA   6, 6, 6, 6, 5, 5, 3: REM Legionary
 DATA   8, 4, 8, 9, 3, 6, 5: REM Gladiator
 DATA   4, 8, 4,12, 8, 6, 3: REM Scout (Eclaireur)
 DATA   0, 6, 4, 6,10,10, 2: REM Druid
 DATA  -2,-2, 2, 8,12,10, 1: REM Sem-Priest
 DATA  -4,-4, 0,10,15,12, 0: REM Vestal

 REM MODIFS DUES AUX CULTURES
 REM A DEFINIR
















