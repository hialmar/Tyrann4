#labels
 REM {++++ ORIC - NEMAUSUS RPG - April 2018 ++++}
 REM { Maximus (denis SOL)
 GOSUB  dices_0
 PRINT "PRESS S TO SKIP THE INTRO"
 GETA$:IF A$="S" THEN Dices ' saute l'intro pour tester la suite
 GOSUB Intro
Dices
 REM DICES TESTS
 CLS:D=10:PAPER0:INK 3
 INPUT "DICE ROLL SPEED (1=FAST-3=SLOW)";VT
 FOR P=1TO6
 TRY=1
 GOSUB IntroCreation
 POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
 DEF FN A(X)=INT(RND(1)*X)+1
dices_14
 CLS:TT=0
 S$=" "+NOM$(P)+" the "+CULT$(CULT(P))+" "
 T=INT((40-LEN(S$))/2)
 PRINT @T,1;CHR$(148);S$;CHR$(144)
 S$=" > "+ROLE$(ROLE(P))+" < "
 T=INT((40-LEN(S$))/2)
 PRINT @T,2;CHR$(148);S$;CHR$(144)
 S$=" <  ROLL 2x10 DICES > - TRY:"+CHR$(144)
 PRINT@ 6,4;CHR$(148);S$;TRY
 PRINT@ 5,12;CHR$(148);"Ml - Rg - St - Ag - IQ - MS - HP ";CHR$(144)
 PRINT@ 1,11;"2D:"
 FOR C=1TO7
 GOSUB  dices_1 
 PRINT @12,5;" >                      "
 PRINT @12,5;" > ";CA$(C)
dices_2
 GETA$:IFA$<>" " THEN  dices_2
 PING:PRINT @13,20;"                "
 IF C<7 THEN GOSUB  dices_3 :PRINT@ C*5,11;DD
 ON C GOTO  dices_4 , dices_5 , dices_6 , dices_7 , dices_8 , dices_9 , dices_10 
dices_4
 ML(P)=DD+15:CARAC(C)=ML(P)
 PRINT@ 5,13;ML(P):GOTO  dices_11 
dices_5
 RG(P)=DD+15:CARAC(C)=RG(P)
 PRINT@10,13;RG(P):GOTO  dices_11 
dices_6
 ST(P)=DD+15:CARAC(C)=ST(P)
 PRINT@15,13;ST(P):GOTO  dices_11 
dices_7
 AG(P)=DD+15:CARAC(C)=AG(P)
 PRINT@20,13;AG(P):GOTO  dices_11 
dices_8
 IQ(P)=DD+15:CARAC(C)=IQ(P)
 PRINT@25,13;IQ(P):GOTO  dices_11 
dices_9
 MS(P)=DD+15:CARAC(C)=MS(P)
 PRINT@30,13;MS(P):GOTO  dices_11 
dices_10
 HP(P)=6+FNA(4)+INT(ST(P)/10)
 ZAP:WAIT50:CARAC(7)=HP(P):PRINT@35,13;HP(P)
dices_11
 NEXT C
 PRINT@ 34,11;"=";TT
 PRINT@13,20;CHR$(145);" IS IT OK (Y/N) ";CHR$(144)
dices_12
 GETA$:IFA$="" THEN  dices_12 
 IF TRY=3 THEN TRY=1:GOTO dices_13 
 IF A$= "Y" THEN  dices_13 
 IF A$<>"N" THEN  dices_12 
 ZAP:TRY=TRY+1:GOTO dices_14 
dices_13
 PRINT@12,20;CHR$(145);"^  CULTURE BONUS  ^ ";CHR$(144)
 FORI=1TO7
 PRINT@ I*5+1,14;BC(CULT(P),I):WAITVT*40:PING
 PRINT@ I*5,15;CARAC(I)+BC(CULT(P),I):WAITVT*40:PING
 NEXT I
 
 PRINT@12,20;CHR$(148);"^   ROLE  BONUS  ^ ";CHR$(144)
 FORI=1TO7
 PRINT@ I*5+1,16;BR(ROLE(P),I):WAITVT*40:PING
 PRINT@ I*5,17;CARAC(I)+BR(ROLE(P),I):WAITVT*40:PING
 NEXT I
 ET(P)=HP(P)
 RI(P)=FNA(150)+200
 NEXT P
 GOSUB Sauvegarde
 END:REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++
dices_1
 REM ++  DICES ROLL  ++++++++
 PRINT @13,7;CHR$(138);"                   "
 PRINT @13,8;CHR$(138);"                   "
 PRINT @14,20;"< Press Space>"
 RETURN
dices_3
 FOR I=1TO15
 WAIT VT*3
 D1=FN A(D):D2=FN A(D)
 PRINT @14,7;CHR$(138);D1
 PRINT @14,8;CHR$(138);D1
 PRINT @19,7;CHR$(138);D2
 PRINT @19,8;CHR$(138);D2
 NEXT
 DD=D1+D2:TT=TT+DD
 PRINT @24,7;CHR$(138);"=";DD
 PRINT @24,8;CHR$(138);"=";DD
 WAIT VT*25
 RETURN
dices_0
 FORI=1TO6:READ ROLE$(I):NEXTI:REM 6 roles
 FORI=1TO7:READ CULT$(I):NEXTI:REM 7 cultures (races)
 FORI=1TO7:READ CARAC$(I):NEXTI:REM 7 CARACTERISTICS
 FOR R=1TO6: FOR C=1TO7:REM ++ Bonus des Roles
 READ BR(R,C)
 NEXT C, R
 FOR R=1TO7: FOR C=1TO7:REM ++ Bonus des Cultures
 READ BC(R,C)
 NEXT C, R
 RETURN

Intro
  A=DEEK(#308):R=RND(-A)
  TEXT:CLS:PAPER0:INK3
  PRINT CHR$(17);CHR$(20)
  PRINTSPC(4);CHR$(4);CHR$(27);"JCEO GAMES STUDIOS ";CHR$(27)"BPRESENT"
  PRINT:PRINT:PRINT
  PRINTSPC(5);CHR$(27);"A";CHR$(27)"JA ROMAN RPG ADVENTURE";CHR$(4)
  PRINT:PRINT:PRINT
  PRINT "      "CHR$(27);"E";CHR$(96)" COLONIA NEMAUSENSIS":PRINT
  A$=CHR$(126):B$=CHR$(255)
  LP$=B$:FORI=1TO34:LP$=LP$+B$:NEXTI
  L$=B$:FORI=1TO33:L$=L$+B$:NEXTI:L$=L$+B$
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
  GETA$:IF A$<>" " THEN  Intro_0
Intro_0
  PRINT CHR$(17);CHR$(20)
  A$="":B$="":LP$=""
  REM MESSAGE D'INTRO DE L'EMPEREUR
  PAPER0:INK7:HIRES:POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
  PRINT:S$="<| EMPEROR LUCIUS VERUS OFFICE |>":GOSUB Intro_1
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
  PRINTSPC(8);CHR$(148);" ! GO ! < Press G >"CHR$(144)
Intro_2
  GETA$:IFA$<>"G" THEN  Intro_2
  RETURN

IntroCreation
  REM creation du 1er héros (P)
  FORI=1TO6:BAG(P,I)=0:NEXTI:REM INITIALIZE BAG
Intro_3
  TEXT:CLS:PRINT:PRINTSPC(12);CHR$(4);CHR$(27)"JCEO RPG";CHR$(4)
  PRINT
  PRINT:S$=" ****** CREATE your Hero # "+STR$(P)+" ***** ":GOSUB  Intro_1 :PRINT
  PRINT:S$="HIS FIRSTNAME (10 letters max)":GOSUB  Intro_1
  INPUT NOM$(P)
  IF LEN(NOM$(P))< 2 THEN ZAP:GOTO  Intro_3
  IF LEN(NOM$(P))>10 THEN NOM$(P)=LEFT$(NOM$(P),10)
  GOSUB  Intro_4 :SS$=NOM$(P)
Intro_6
  TEST=0:GOSUB  Intro_5
  PRINT @10,17;"WHICH Culture ? ";
  GET CULT$:CU=VAL(CULT$)
  IF CU<1 OR CU(P)>7 THEN ZAP:GOTO  Intro_6
  CULT(P)=CU:PRINT CU$(CULT(P))
  GOSUB  Intro_7 :IF OK$="N" THEN ZAP:GOTO  Intro_6
  TEST=1:BOOL=0:SS$=SS$+" the "+CULT$(CULT(P))
Intro_8
  GOSUB  Intro_5
  PRINT @10,16;"WHICH ROLE ? ";
  GET RO$:RO=VAL(RO$)
  IF RO<1 OR RO>6 THEN ZAP:GOTO Intro_8
  IF RO<4 THEN  Intro_9
  IF RO=4 AND(CU=2ORCU=5ORCU=6)THENGOSUB Intro_10 :GOTO Intro_8
  IF RO=5 AND(CU<>2ANDCU<>5) THEN GOSUB  Intro_10 :GOTO Intro_8
  IF RO=6 AND(CU<>3ANDCU<>6) THEN GOSUB  Intro_10 :GOTO Intro_8
Intro_9
  ROLE(P)=RO:PRINT RO$(ROLE(P)):GOSUB  Intro_11
  GOSUB  Intro_7 :IF OK$="N" THEN ZAP:TEXT:GOTO Intro_8
  RETURN ' +++++++++++++++  Sous programmes et DATA ++++++++++++++++++++
Intro_10
  PRINT:PRINT:
  IF BOOL=1THEN Intro_12
  S$= "  HEY !! "+CULT$(CULT(P))+" cannot do that !  "
  BOOL=1:GOTO  Intro_13
Intro_12
  S$= "         ARE YOU KIDDING ME ?     ":BOOL=0
Intro_13
  GOSUB Intro_14 :ZAP:WAIT200:PING
  RETURN
Intro_7
  REM OK ?
  PING:WAIT 100
  PRINT SPC(10);CHR$(148)" < OK ? Y/N > "CHR$(144)
Intro_15
  OK$=KEY$:IF OK$="" THEN  Intro_15
  IF OK$<>"N" AND OK$<>"Y" THEN  Intro_15
  RETURN
Intro_4
  REM lowercase forename
  S$=NOM$(P):NOM$(P)=LEFT$(S$,1)
  FORI=2TOLEN(S$)
  MI=ASC(MID$(S$,I,1))
  IF MI>64 AND MI<91 THEN MI=MI+32
  L$=CHR$(MI)
  NOM$(P)=NOM$(P)+L$
  NEXT
  RETURN
Intro_1
  REM blue
  PRINTCHR$(148);S$;CHR$(144)
  RETURN
Intro_14
  REM red
  PRINTCHR$(145);S$;CHR$(144)
  RETURN
Intro_11
  'HIRES: REM FICHES DES Roles
  'CLOAD"FICH-GLA.HRS"
  RETURN
Intro_5
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
  PRINT @10,L;"*":PRINT @32,L;"*"
  PRINT @14,L;I;S$
  NEXT I
  PRINT"        *                     *"
  PRINT"        ***********************"
  RETURN

Sauvegarde
 S$="   SAUVEGARDES EN COURS - PATIENCE  ":GOSUB  Intro_1
 VIL=1:TL=1:BS=0:FIL=0:SD=0:NP=0:PM=0' ni boussole, ni Filet, ni Selle
 O1=#A000:POKE O1,0
 O1=O1+1:POKEO1,1 'numero de version
 O1=O1+1:POKEO1,85'X
 O1=O1+1:POKEO1,2'Y
 O1=O1+1:POKEO1,S
 O1=O1+1:POKEO1,CA
 O1=O1+1:POKEO1,VIL
 FOR P=1TO6
 O1=O1+1:POKEO1,LEN(NOM$(P))'Longueur du prenom
 FORJ=1TOLEN(NOM$(P))
 O1=O1+1:POKEO1,ASC(MID$(NOM$(P),J,1))'stockage du prenom
 NEXTJ
 O1=O1+1:DOKEO1,INT(RI(P)/10)' argent sur 2 octets
 O1=O1+2:POKEO1,ROLE(P):REM + Role du Personnage
 O1=O1+1:POKEO1,CULT(P):REM + Culture du Personnage
 O1=O1+1:POKEO1,ML(P):REM + Capacite de Combat
 O1=O1+1:POKEO1,RG(P):REM + Capacite de Tir
 O1=O1+1:POKEO1,ST(P):REM + Force
 O1=O1+1:POKEO1,AG(P):REM + Agilite
 O1=O1+1:POKEO1,IQ(P):REM + Intelligence
 O1=O1+1:POKEO1,MS(P):REM + Force Mentale
 O1=O1+1:POKEO1,HP(P):REM > Points de Vie ou de Blessures
 O1=O1+1:POKEO1,ET(P):REM > Etat des PV
 O1=O1+1:OK(P)=1:POKEO1,OK(P):REM > Sante
 O1=O1+1:NI(P)=1:POKEO1,NI(P):REM > Niveau du perso
 O1=O1+1:XP(P)=0:DOKEO1,XP(P):REM > Experience
 O1=O1+2:WR(P)=0:POKEO1,WR(P):REM > ARME DROITE (WEAPON RIGHT)
 O1=O1+1:WL(P)=0:POKEO1,WL(P):REM > ARME G (WEAPON LEFT)
 O1=O1+1:PT(P)=0:POKEO1,PT(P):REM > PROTECTION
 O1=O1+1:CA(P)=0:POKEO1,CA(P):REM > Classe d'armure
 O1=O1+1:BT(P)=0:POKEO1,BT(P):REM > BETE (ANIMAL)
 FORI=1TO6:O1=O1+1:POKEO1,BAG(P,I):NEXTI:REM Sac a Dos
 IF ROLE(P)>3 THEN FORI=1TO8:O1=O1+1:POKEO1,SN(P,I):NEXT'SORTS
 NEXT P
 O1=O1+1:POKEO1,BS'Boussole
 O1=O1+1:POKEO1,FI'Filet
 O1=O1+1:POKEO1,SD'Selle de Dragon: maitre des dragons (1 a 6)
 FOR L=1TO9:FOR C=1TO4:O1=O1+1:CLEF(L,C)=0:POKEO1,CLEF(L,C):NEXT C,L:REM Trousseau de clefs
 FORI=1TO6:O1=O1+1:POKEO1,IG(I):NEXT' tableau des 6 ingr�dients de la potion
 FOR V=1TO9:FORM=1TO5:O1=O1+1:POKEO1,0:NEXT M,V' tableau coffres et combats � 0
 O1=O1+1:POKEO1,0'DEdans (portes speciales franchies ou pas - bits 0-3) + Potion Magique (bit 6) + Wall (bit 7)
 O1=O1+1:POKEO1,1'TL = Team Level
 O1=O1+1:POKEO1,0'NP = Nombre d'ingredients de la Potion (NI utilise pour Items)
 O1=O1+1:POKEO1,0'NF = Nombre de fuites
 O1=O1+1:POKEO1,0'PM = Potion faite
 PING
 SAVEU "TEAM.BIN",A#A000,EO1
 SAVEU "TEAM2.BIN",A#A000,EO1:REM Copie secours
 RETURN


 DATA Legionary, Gladiator, Scout, Druid, Sem-Priest, Vestal
 DATA Celtic, Egyptian, Gallic, Goth, Persian, Roman, Viking
 DATA Melee Skill, Range Skill, Strength
 DATA Agility, Intelligence
 DATA Mental Strength, Health Points
 REM   Ml Rg St  Ag IQ MS HP  les 7 bonus de roles
 DATA   8, 4, 6, 3, 0, 5, 5: REM Legionary
 DATA   9, 2, 5, 5, 0, 6, 4: REM Gladiator
 DATA   4, 8, 4, 8, 2, 6, 3: REM Scout (Eclaireur)
 DATA   0, 4, 4, 6, 6, 6, 2: REM Druid
 DATA  -2,-2, 2, 8, 4, 6, 1: REM Sem-Priest
 DATA  -4,-4, 0, 9, 9, 9,-1: REM Vestal
 REM   Ml Rg St  Ag IQ MS HP  les 7 bonus de culture
 DATA   2, 0, 0, 1, 1, 1, 1: REM Celtic
 DATA  -1, 2, 0, 2, 1, 1, 0: REM Egyptian
 DATA   3, 0, 2, 2,-2, 1, 1: REM Gallic
 DATA   4,-2, 4, 0,-4, 0, 2: REM Goth
 DATA  -2, 4, 0, 3, 0, 0,-1: REM Perse
 DATA   3, 0, 0, 0, 3, 0, 0: REM Roman
 DATA   3, 0, 4, 0,-3, 5, 3: REM Viking
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