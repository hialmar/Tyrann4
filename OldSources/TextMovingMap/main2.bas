

600 ' Ajout de 30 a 50 lacs de 4x3 cases
610 O%=ASC("%")
620 FORI=1 TO 30+INT(RND(1)*21):XX%=INT(RND(1)*92)+1:YY%=INT(RND(1)*95)+1
630 MAP%(XX%,YY%)=O%:MAP%(XX%+1,YY%)=O%:MAP%(XX%+2,YY%)=O%:MAP%(XX%+3,YY%)=O%
640 MAP%(XX%+1,YY%+1)=O%:MAP%(XX%+2,YY%+1)=O%:MAP%(XX%+3,YY%+1)=O%:MAP%(XX%+4,YY%+1)=O%
650 MAP%(XX%+2,YY%+2)=O%:MAP%(XX%+3,YY%+2)=O%:MAP%(XX%+4,YY%+2)=O%:MAP%(XX%+5,YY%+2)=O%
660 NEXT
700 ' On n'oublie pas de mettre une case vide a la position du personnage dans la carte
710 MAP%(X%,Y%)=ASC(" ")
800 PING:CLS:PRINT"":PRINT"":PRINT""

810 PRINT "Initialisation terminee !":PRINT""
820 PRINT "Laisser le mode overclock 64MHz actif!"
825 PRINT "":PRINT""
830 PRINT "DEMONSTRATION DE CARTE DEROULANTE"
835 PRINT "================================="
837 :PRINT""
840 PRINT "Utiliser les fleches pour se deplacer"
850 PRINT "Appuyer sur ESC pour quitter"
855 PRINT ""
860 PRINT "Appuyer sur ESPACE pour commencer"
870 REPEAT
871   K$=KEY$:C=0
872   IFK$<>"" THEN C=ASC(K$)
873 UNTIL C=32
875 CLS

1000 ' == Init fenetre de visualisation a l'ecran
1002 ' taille de la fenetre visible de la carte a l'ecran
1010 XSIZE%=30:YSIZE%=15
1100 ' Affichage du cadre de la fenetre de visualisation de la carte 
1110 ' avec le caractere ASCII 126 (damier)
1120 ' WX% et WY% sont les coordonnees absolues du coin superieur gauche de la fenetre a l'ecran
1130 WX%=5:WY%=5
1140 FORI=WX% TO WX%+XSIZE%+1
1150 PLOT I, WY%, 126: PLOT I, WY%+YSIZE%+1,126
1160 NEXT
1170 FORI=WY% TO WY%+YSIZE%+1
1180 PLOT WX%, I, 126: PLOT WX%+XSIZE%+1, I,126
1190 NEXT
1195 PRINT @ 9, 22;"Deplacements: fleches"
1197 PRINT @ 9, 23;"    ESC = quitter"
1300 ' == BOUCLE PRINCIPALE
1305 ' -- Affichage de la partie de carte visible: XSIZE% x YSIZE% cases, centree sur le personnage
1306 '    (tant que celui-ci n'est pas dans un des "coins" de la carte)
1310 ' XV% et YV% representent le coin superieur gauche de la partie de la carte qui sera affichee
1315 ' Prise en compte cas "normal" + corrections pour affichage extremites gauche et superieure de la carte
1320 IF(X% <= XSIZE%/2) THEN XV%=0 ELSE XV%=X%-XSIZE%/2
1330 IF(Y% <= YSIZE%/2) THEN YV%=0 ELSE YV%=Y%-YSIZE%/2
1340 ' Corrections pour affichage extremites droite et inferieure de la carte
1350 IF(X% > XMAX%-XSIZE%/2) THEN XV%=XMAX%-XSIZE%+1
1350 IF(Y% > YMAX%-YSIZE%/2) THEN YV%=YMAX%-YSIZE%+1
1397 ' Affichage de la partie de la partie visible de la carte dans la fenetre
1500 FORI=XV% TO XV%+XSIZE%-1
1510 FORJ=YV% TO YV%+YSIZE%-1
1520 PLOT WX%+1+I-XV%,WY%+1+J-YV%,CHR$(MAP%(I,J))
1530 NEXT
1540 NEXT
1550 ' Affichage personnage: PX et PY sont les coordonnees relatives
1551 ' du personnage dans la fenetre d'affichage
1560 IF(X% >= XSIZE%/2) THEN PX%=X%-XV% ELSE PX%=X%
1570 IF(Y% >= YSIZE%/2) THEN PY%=Y%-YV% ELSE PY%=Y%
1574 PRINT @ 5,3;"X=";X%;", PX=";PX%;", Y=";Y%;",PY=";PY%
1575 PRINT @ 5,4;"XV=";XV%;", YV=";YV%
1580 PLOT WX%+1+PX%,WY%+1+PY%,"*"

1600 'Attente touche et retour a l'afffichae de la carte
1610 GOSUB 2000
1620 GOTO 1320
1999 ' == Gestion clavier
2000 REPEAT
2010   REPEAT:K$=KEY$: UNTIL K$<>""
2020   C=ASC(K$)
2023 ' On n'accepte que les touches flechees et la touche ESC
2027 ' Boucler tant qu'aucune touche valide n'a ete pressee
2030 UNTIL C=8 OR C=9 OR C=10 OR C=11 OR C=27
2032 ' Quitter si ESC a ete presse
2034 ' (apres avoir retabli l'affichage du curseur)
2040 IF C=27 THEN PRINT @ 2, 22;" ":GOSUB5200:END ' ESC=fin
2042 ' -- Gestion des deplacements:
2044 ' Le personage ne peut se deplacer que si la case cible est libre
2046 ' (NB: 32 = code du caractere espace = case libre)
2050 IF C=8  AND X% > 0  AND MAP%(X%-1, Y%)=32 THEN X%=X%-1
2060 IF C=9  AND X% < 99 AND MAP%(X%+1, Y%)=32 THEN X%=X%+1
2070 IF C=10 AND Y% < 99 AND MAP%(X%, Y%+1)=32 THEN Y%=Y%+1
2080 IF C=11 AND Y% > 0  AND MAP%(X%, Y%-1)=32 THEN Y%=Y%-1
2090 RETURN

25000 ' Key codes:
25010 ' UP=11
25020 ' DOWN=10
25030 ' LEFT=8
25040 ' RIGHT=9
25050 ' ESC=27
