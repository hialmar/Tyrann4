;*********************************
;***       PLAN VILLE n°2      ***
;*********************************
; *********** VARIABLES PAGE ZERO  ***********
;
;	$00	:	repère 1/4 haut gauche tuile en cours
;	$01	:	repère 1/4 haut droit tuile en cours
;	$02	:	repère 1/4 bas gauche tuile en cours
;	$03	:	repère 1/4 bas droit tuile en cours
;	$04	:	n° tuile personnage affichée (pour animation droite gauche avant, bateau..)
;Deux oordonnées coin haut gauche partie table affichée	dans fenêtre
;	$05	:	N° ligne data MAp en haut gauche fenêtre,Mémorisée tant que pas de scroll
;	$06	:	Rang dans la ligne Data Map en haut gauche fenêtre, Mémorisée tant que pas de scroll
;Deux coordonnées variables dans table DataMap utilisées lors de l'affichage d'une fenêtre
;	$07	:	N° ligne data MAp
;	$08	:	Rang dans la ligne Data Map
;	$09	:	Rang tuile dans fenêtre, utilisé comme index de la table d'adresses écran de la fanêtre ( de 0 a $69)
;	$0A	:	N° identifiant quelle tuile en cours d'affichage
;	$0B	:	Direction scroll précedente( #$AC,$B4,$9C,$BC)
;	$0C	:	Direction scroll demandée( #$AC,$B4,$9C,$BC)
;	$0D	:	Drapeau 1 si on a un bateau , 0 si pas de bateau
;	$0E	:	valeur tuile position perso (attention, ce N'EST PAS la valeur de la tuile qui represente le perso)
;	$0F	:	ordonnée perso dans fenêtre Hires (varie de 1 à 7 , valeur initiale : 3)
;	$10	:	abscisse perso dans fenêtre Hires (varie de 1 à 15 , valeur initiale :7)
;	$11	:	drapeau déplacer perso horizontalement dans fenêtre hires : 0 non 1 oui
;	$12	:	Valeur variable index position perso dans table d'adresses ecran ( $00 à $69)
;	$13	:	drapeau déplacer perso verticalement dans fenêtre hires : 0 non 1 oui
;	$14	:	drapeau : 1 on est en mer, 0 on est à terre
;	$15	:	drapeau : 1 texte affiché , 0, pas de texte affiché
;	$16	:	drapeau : 1 scroll interdit , 0, scroll autorisé
;	$17	:	drapeau : 1 deplacement perso  interdit , 0, déplacement perso autorisé
;	$18	:	drapeau : on a clef_1
;	$19	: 	drapeau : on a clef_2
;	$1a	:	drapeau : on a mot de passe


main_routine
;	jsr impl_car			; Implante jeu de caractères redéfinis
	jsr hires_et_atributs	; spécifique à ce test passe en HIRES et installe 84 atributs de couleur (hauteur tuile)
	jsr impl_car			; Implante jeu de caractères redéfinis	(modif: maintenant après HIRES car plus de place pour nouveaux car redef...)
	jsr init_div_var		; initialise diverses variables dont coordonnées coin haut gauche de la  partie table affichée.
							; mais pas que...
	jsr cadre_plan			; dessine un cadre blanc autour du plan de ville						
main_loop
	jsr scrl_fenetre		; Affiche/ scrolle les 105 tuiles dans la fenetre
	jsr aff_hero			; affiche le hero.
	jsr	aff_text
	ldy $17
	bne fin_temporisation
	ldy #$7f
temporisation_2
	ldx #$ff	
temporisation_1
	dex
	bne temporisation_1
	dey
	bne temporisation_2
fin_temporisation	
;	jsr wait_key			; scanne les 4 touches flèchées pour scroll
	lda $0c
	cmp#$86
	beq sortie_main	
	jsr wait_key			; scanne les 4 touches flèchées pour scroll	
	lda $0c
	cmp#$86
	beq sortie_main
	jsr chck_around			; regarde valeur tuile sous et autour perso	pour validation (ou non) scroll
	jsr chck_bords			; regarde si un bord de la carte est à un bord de la fenêtre
	jsr chck_mvt_perso_fenetre
	jsr	eff_text
	jmp main_loop
sortie_main
	lda #$4c
	sta $1a
	jsr $ec21				; passe en mode TEXT (provisoire)
	rts						; sortie provisoire, rend la main au BASIC pour charger la FAKE ville et sortie
							; pour re-rentrer : CALL #2000
	
	
	
;-------------------------
;--- affiche hero   ------
;-------------------------
aff_hero
	lda $0c				; direction demandée
	cmp #$38			; a-t-on frappé une touche autre qu'une des 4 flêches
	beq fin_aff_perso
	lda $16
	beq chck_direction
	lda $17
	bne fin_aff_perso
chck_direction	
	lda $0c
	cmp $0b				; direction précédente
	beq anim_perso		; si identique animation perso
	sta $0b				; si non nouvelle direction
	
	jsr choix_perso		; et choix nouveau perso
	beq skip_anim		; saut inconditionnel
anim_perso

	lda $04				; $04 contient n° tuile perso affichée
	eor #$01			; force le bit 0 alternativement à  0 ou à 1
	sta $04				; et replace en  $04
skip_anim
	lda $0c
	sta $0b
	ldx $12				; 
	jsr maj_adr_scr_next_tuile			; en entrée x contient rang tuile dans  table adresses Hires
	ldx  $04
	jsr cherche_et_aff_tuile			; en entrée : X contient la reference de la tuile
fin_aff_perso

	rts

;------ Choix tuile perso en fonction direction demandée   -----
choix_perso
		lda $0c
		cmp #$9c
		beq vers_haut			; Si flêche vers le haut
		cmp #$b4
		beq vers_bas			; Si flêche vers le bas, mème pesro (vue de face)
		cmp #$ac
		beq vers_droite			; si flêche gauche perso regarde à gauche
		cmp #$bc
		beq vers_gauche			; si flêche droite, perso regarde vers droite
		bne fin_ch_perso		; Saut incontionnel
vers_haut
		lda #$26
		bne fin_ch_perso		; Saut incontionnel
vers_bas
		lda #$28
		bne fin_ch_perso		; Saut incontionnel		
vers_droite
		lda #$24				; n° tuile perso regarde à gauche
		bne fin_ch_perso		; Saut incontionnel
vers_gauche
		lda #$22				; n° tuile perso regarde à droite
fin_ch_perso
		sta $04					; mémoire tuile perso affichée
		rts

	
; -----------------------------------------------------------------------
; ----------  routine regarde autour du perso  pour détection mur  ------	
; -----------------------------------------------------------------------	
; en entrée :	
; en sortie : 	$0e contient valeur tuile sous perso
;				$0c contient #$38 si scroll impossible (perso en bord de carte ou en bord de mer (si a terre)

chck_around
; d'abord on regarde si une touche flêchée a été pressée sinon $0c contient #$38
		lda $0c
		cmp #$38
		beq sortie_scroll_direct		; inutile de regarder si autre touche que flêchée

; puis déterminons la position perso dans la carte
		lda $0f					; ordonnée perso dans fenête hires
		clc
		adc $05					; N° ligne ds table DataMAP en haut gauche fenêtre
		sta $07
		lda $10					; abscisse perso dans fenètre Hires
		clc
		adc $06					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
		sta $08
		
; que nous utilisons ensuite pour regarder autour du perso
		lda $0c					; mémoire touche pressée
		cmp #$ac				; recherche contenu tuile à gauche
		bne sens_2
		dec $08					; $08 contient rang perso dans ligne map
		bpl suite_chck_around_1	; bmi no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; le perso était en bord gauche map
suite_chck_around_1
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda $0a
		beq around_sortie		; si00 c'est un chemin,on peut soit scroller soit avancer		
		bne tuile_speciale			; sinon test situile spéciale		
sens_2
		cmp #$bc				; recherche contenu tuile à droite
		bne sens_3
		lda $08
		cmp #$1f				; rang tuile en bord droit de map
		bne suite_chck_around_2 ; Le beq no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; si perso en bord droit, pas de scroll
suite_chck_around_2		
		inc $08					; si non, on regarde ce qu'il y a à droite
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda $0a
		beq around_sortie		; si00 c'est un chemin			
		bne tuile_speciale			
sens_3
		cmp #$9c				; recherche contenu tuile au dessus
		bne sens_4
		dec $07
		bmi no_scroll
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda $0a
		beq around_sortie		; si00 c'est un chemin			
		bne tuile_speciale			
sens_4
		cmp #$b4				; recherche contenu tuile en dessous
		bne around_sortie
		lda $07
		cmp #$30
		beq no_scroll			
		inc $07
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda $0a
		beq around_sortie		; si  00 c'est un chemin
		bne tuile_speciale			
around_sortie
		lda #$00
		sta $16				; ré-autorise scroll (pour une boucle dans la direction demandée)
		sta $17				; ré-autorise mvt perso (pour une boucle dans la direction demandée)
sortie_scroll_direct
		rts
;-----------------------------------------------------------------------------
tuile_speciale
		cmp#$51
		bmi no_scroll
		cmp #$52	; have you the rigth key for gate 1?
;		bmi no_scroll
		bne chck_54
		lda $18
		bne around_sortie		; test: $18 =1 => on a la clef_1	=> scroll et/ou delplacement autorisés	
		jsr  why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
chck_54		; clef_1
		lda $0a					
		cmp #$54
		bne chck_58
		lda #$01
		sta $18					; met à 1 drapeau clef 1
		bne around_sortie		
chck_58		; a guard ask for pass word
		lda $0a
		cmp #$58				; 
		bne chck_57
		lda $1a
		bne around_sortie		; test:   $1a =1 => on a mot de passe	=> scroll et/ou delplacement autorisés
		jsr  why_no_scoll		
		beq no_scroll			; branchement forcé par sortie sp précédent		
chck_57		; patricienne donne mdp
		lda $0a
		cmp #$57
		bne chck_55
		lda #$01
		sta $1a					; met à 1 drapeau mote de passe
		bne around_sortie
chck_55		; clef_2
		lda $0a
		cmp #$55
		bne chck_53
		lda #$01
		sta $19					; met à 1 drapeau clef 2
		bne around_sortie
chck_53		; have you the rigth key for gate 2?
		lda $0a
		cmp #$53
		bne around_sortie
		lda $19
		bne around_sortie		; test: $19 =1 => on a la clef_2	=> scroll et/ou delplacement autorisés
		jsr  why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent

no_scroll		
		lda #$01			
		sta $16				;mets à 1 drapeau scroll interdit (pour une boucle, dans la direction demandée)
		sta $17				;mets à 1 drapeau mvt perso  interdit (pour une boucle, dans la direction demandée)
		rts 

; -------------------------------------------------------------------------
; ----------  routine teste si bords de carte en bord de fenêtre ----------	
; -----           et si le perso est au centre de la fenêtre         ------
; -------------------------------------------------------------------------
chck_bords
; en entrée :	$0c contient #38 si pas de touches flêchée pressée
;				$0c contient valeur touche fléchée pressée sinon
; en sortie :	idem 	
		lda $16						; si scroll déjà interdit par bord de mer
		bne sort_direct	
		lda $0c
		cmp #$38				 	; si 38, pas touche fléchée enfoncée
		beq sort_direct
;vers droite
		cmp #$BC					; touche flèche droite ==> tuile suivante
		bne autre_touche_1
		lda $06
		cmp #$0E   ;#$10					; au départ $06 = #$10 (rang tuile au bord gauche fénêtre) on ne peut atteindre la tuile suivante 
									; car le bord droit du plan est au bord droit de la fenêtre (largeur plan :#$10+#$0F = #$1f tuiles)
		beq end_chck_bords_nsc		; dans ce cas, scroll horizontal interdit il faut checker déplacement horizontal perso dans fenêtre
		lda $10						; rang (abscisse) perso dans fenètre
		cmp #$08					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre		
		inc $06						; Maj rang tuile DataMAP en bord gauche de fenêtre
		bne end_chck_bords			; saut inconditionnel
autre_touche_1			
		cmp #$AC					; touche flèche gauche ==> tuile précedente
		bne autre_touche_2
		lda $06
		bmi end_chck_bords_nsc   	;
		lda $10						; rang (abscisse) perso dans fenètre
		cmp #$08					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre
		dec $06
		bpl end_chck_bords	
autre_touche_2
		cmp #$B4					; touche flèche BAS ==> tuile ligne de dessous		
		bne autre_touche_3						
		lda $05
		cmp #$26   ;#$2A
		beq end_chck_bords_nsc
		lda $0f						; hauteur (ordonnée) perso dans fenètre
		cmp #$03					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre		
		inc $05
		bne end_chck_bords	
autre_touche_3
		cmp #$9C				; touche flèche haut ==> tuile ligne de dessus		
		bne end_chck_bords						
		lda $05
		beq end_chck_bords_nsc
		lda $0f						; hauteur (ordonnée) perso dans fenètre
		cmp #$03					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre			
		dec $05
end_chck_bords
		lda #$00
		sta $16					; ré-autorise scroll (pour une boucle, dans la direction demandée)
		lda #$01
		sta $17					; interdit deplacement perso (pour une boucle, dans la direstion demandée)
		rts
end_chck_bords_nsc
		lda #$01
		sta $16					; interdit scroll (pour une boucle, dans la direstion demandée)
;		lda #$00
;		sta $17					; autorise deplacement perso (pour une boucle, dans la direstion demandée)
sort_direct		
		rts

; ---------------------------------------------------------------------------------------------
; ---------   routine chck si deplacement perso possible (bord de carte )   ----------	
; ---------------------------------------------------------------------------------------------
		
chck_mvt_perso_fenetre
		lda $16
		beq sortie_perso			; si scrolling autorisé ==> deplacement perso interdit on sort direct
		lda $17
		bne sortie_perso			; si déplacement déjà interdit par bord de de mer => on ne traite pas deplacement perso
		
; on commence par afficher la tuile dont n° est sous le perso
		ldx $12						; contient le n° de tuile sous le perso
		jsr maj_adr_scr_next_tuile	; en entrée x contient rang tuile dans  table adresses Hires
		ldx  $0e
		jsr cherche_et_aff_tuile	; en entrée : X contient la reference de la tuile
; puis on checke le bord de la fenêtre hires et on modifie le contenu de $12 en fonction de la direction demandée

		lda $0c
		cmp #$38 
		beq sortie_perso			; pas de touche fléchée pressée  => on ne traite pas deplacement perso		

deplc_gauche
		cmp #$ac					; touche flèche gauche ==> deplacement vers la gauche
		bne deplac_droite
		lda $10
		cmp#$01
		beq no_depl
		dec $10
		dec $12
		jmp out_depl_perso
deplac_droite
		cmp #$bc					; touche flèche droite ==> deplacement vers la droite
		bne deplac_bas		
		lda $10
		cmp #$0f   ;cmp 15
		beq no_depl
		inc $10
		inc $12
		jmp out_depl_perso
deplac_bas		
		cmp #$b4				; touche flèche bas ==> deplacement vers le bas
		bne deplac_haut				
		lda $0f
		cmp #$06   
		beq no_depl
		inc $0f
		lda $12
		clc
		adc #$0f
		sta $12
		jmp out_depl_perso
deplac_haut
		cmp #$9c				; touche flèche haut ==> deplacement vers le haut
		bne sortie_perso	
		lda $0f
		beq no_depl
		dec $0f
		lda $12
		sec
		sbc #$0f
		sta $12		
out_depl_perso
; détermination n° tuile à la position perso
		lda $0f					; ordonnée perso dans fenête hires
		clc
		adc $05					; N° ligne ds table DataMAP en haut gauche fenêtre
		sta $07
		lda $10					; abscisse perso dans fenètre Hires
		clc
		adc $06					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
		sta $08
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda $0a
		sta $0e					; repère tuile dans $0e	
;		lda #$00
;		sta $17
		rts
no_depl
		lda #$01				; deplacement interdit
		sta $17
sortie_perso		
		rts

;********************************************************************************
;***                  routine  affiche 15 x 7 tuiles dans la                  ***
;***       fenêtre de l'écran HIRES définie par la table tab_adr_hires        *** 
;***              apres recherche dans la table DATA PLAN T4                  ***
;********************************************************************************
;en entrée : 	position coin fenetre dans la ligne des DATA MAP stockée dans $06
;				n°ligne DATA MAP stocké dans $05
;En sortie :	Les tuiles sont affichées dans la fenetre Hires

scrl_fenetre
	lda $16				; drapeau scroll (autorisé : 0 , interdit : 1)
	bne sortie_fenetre	; scroll interdit par bord de mer ou bord de carte
	lda $0c
	cmp #$38
	beq sortie_fenetre	; aucune touche fléchées pressée
	lda $05
	sta $07				; n° ligne datamap (variable)
	lda $06
	sta $08				; position dans ligne des datamap
	lda #$ff			; initialise  à $ff la
	sta $09				; Mémoire de rang  de la tuile ds fenetre ( $00 à $69 soit 7 x$0f tuiles)
	ldy #$00
lp_L7
	ldx #$00			; index nombre de colonnes de tuiles à afficher (15) 
lp_C15
	inc $08				; position ds la ligne des DATAMAP (première valeur : 0)
	inc $09				; Position dans la liste des adresses hires de la fenetre (première valeur : 0)
	inx					; (première valeur : x=1) puis colonne suivante
	jsr rech_tab_map	; en sortie $0A contient la reference de la tuile à afficher	
	cpx #$10			; on affiche 15 tuile par ligne
	beq autre_ligne
	txa 
	pha					;empile le rang de la tuile dans la ligne à afficher
	ldx $09
	jsr maj_adr_scr_next_tuile	; en entrée x contient rang tuile dans  table adresses Hires
	ldx $0A	;ldx $08
	jsr cherche_et_aff_tuile	; en entrée : X contient la reference de la tuile
	pla
	tax
	bne lp_C15
autre_ligne
	dec $09
	lda $06
	sta $08	
	inc $07
	iny
	cpy #$07
;	beq sortie_fenetre
	bne lp_L7

; détermination n° tuile à la position perso
	lda $0f					; ordonnée perso dans fenête hires
	clc
	adc $05					; N° ligne ds table DataMAP en haut gauche fenêtre
	sta $07
	lda $10					; abscisse perso dans fenètre Hires
	clc
	adc $06					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
	sta $08
	jsr rech_tab_map		; en sortie  repère tuile dans $0a
	lda $0a
	sta $0e					; repère tuile dans $0e	
	
sortie_fenetre
;	lda #$00
;	sta $16					; autorise scroll pour prochaine boucle, jusqu'aux différents checks
	rts	
	

;-----------------------------------------------------------------------------
; -----                initialise divers variables dont:                   ---
;	             coordonnées coin haut gauche partie table affichée      -----
;                     tuile perso affichée / index position perso
;-----------------------------------------------------------------------------		
init_div_var
	lda #$14		; coordonnées pour entrée ville au centre en bord gauche de fenetre (départ jeu)
	sta $05			; N° de ligne fixe tant que pas de scroll
	lda #$ff
	sta $06			; rang ds ligne fixe tant que pas de scroll
	lda #$22
	sta $04			; code tuile perso affichée (vers la gauche)
	lda #$2d
	sta $12			; valeur index perso dans table adresses hires fenêtre
	lda #$bC
	sta $0C			;  valeurs => ddirection scroll demandée
	lda #$03
	sta $0f			; ordonnée perso dans fenêtre Hires
	lda #$01
	sta $10			; abscisse perso dans fenêtre Hires
	lda #$00		; repère tuile entrée ville
	sta $0e			; sous position perso au départ
	lda #$00
	sta $11			; drapeau deplacement horizontal perso dans fenêtre : 0 => pas de déplacement
	sta $13			; drapeau deplacement vertical  perso dans fenêtre : 0 => pas de déplacement
	sta $0d			; drapeau bateau : 1 on a un bateau / 0 pas de bateau
	sta $15			; drapeau nom ville à l'écran 	1 : nom à l'ecran , 0 rien
	sta $16			; drapeau scroll autorisé/interdit 	1 : interdit , 0 autorisé
	sta $17			; drapeau déplacement perso autorisé/interdit 	1 : interdit , 0 autorisé
	sta $18			; drapeau on a clef 1	
	sta $19			; drapeau on a clef 2	
	sta $1a			; drapeau on a mot de passe
	rts	
;----------------------------------------------------------
;---   cherche n° de tuile en position X,Y dans carte   ---
;----------------------------------------------------------
;en entrée : 	position dans la ligne stockée dans $08,
;				n°ligne stocké dans $07
; en sortie : 	Le numéro de tuile est dans $0A

rech_tab_map
		txa
		pha
		tya
		pha
		ldx $07				; X contient le n° de ligne DataMap(en partant de 0)
		ldy $08				; y contient la position dans la ligne DataMap
		txa					; prépare pointeur
		asl					; vers table DATA PLAN T4
		tax					;
		lda ptr_Lignes,x	; Partie basse adresse table
		sta adr_ligne+1
		inx
		lda ptr_Lignes,x	; partie haute adresse table
		sta adr_ligne+2
adr_ligne	
		lda $1111,y
		sta $0A
		pla
		tay
		pla 
		tax
		rts			
		
;-----------------------------------------------------------
;---- Affiche une tuile dans la fenêtre de l'écran HIRES ---
;-----------------------------------------------------------
cherche_et_aff_tuile
; en entrée : X contient le n° de tuile
; En sortie : La tuile est à l'écran
		tya
		pha
		jsr find_compsants
		jsr aff__tuile			; côte à côte pour minimiser le Nn d'addition (adrsses écran)
		pla
		tay
		rts

;----------------------------------------------------------
;---            cherche  4 composants tuile             ---
;----------------------------------------------------------
; en entrée : X contient le n° de tuile
; en sortie : les 4 n° de sous tuiles sont stockées en $00,$01,$02,$03 

find_compsants
			txa
			asl					;vers table DATA PLAN T4
			tax					;
			lda ptr_t,x			;Partie basse adresse composants
			sta adr_compo+1
			inx
			lda ptr_t,x			;partie haute adresse composants
			sta adr_compo+2
			ldx #$03
adr_compo	
			lda $1111,x
			sta $00,x			; **** bien sûr, tu peux choisir un autre emplacement page 0  que  $00,01,02,03...
			dex
			bpl adr_compo
			rts	
;--------------------------------------------------
;---               affiche _tuile              ---- 
;--------------------------------------------------	
aff__tuile
			lda $09
			cmp $12					; n'affiche pas la tuile si c'est celle qui est sous le perso
			beq pas_daff
			ldx #$00				; 0 pour indexer le premier 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères supérieurs (dont n° d'ordre stocké en $00 et $01)
			ldx #$02				; 2 pour indexer le 3 ème 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères inférieurs (dont n° d'ordre stocké en $02 et $03)
pas_daff			
			rts	
;----------------------------------------------------
;--- maj adresses écran HIRES  dans aff_2_sextets----
;----------------------------------------------------
;en entrée:			x contient rang tuile dans  table adresses Hires
;en sortie:			les 2 adresses hires tuile en cours, renseignées dans routine aff_2_sextets
maj_adr_scr_next_tuile
;init_scr_hires
				txa						; X contient rang tuile dans  table adresses Hires
				asl						; prépare pour index
				tax						;
				pha						; sauve index rang partie basse adresse écran 1er 1/4 tuile	
				lda tab_adr_hires,x		; A contient partie basse adresse ecran	1er 1/4 tuile
				sta adr_screen_1+1		; dans partie basse 1er adresse écran 1er sextet de la routine aff_2_sextets
				tax						; passe partie basse adresse dans x pour incrément
				inx
				txa						; partie basse adresse écran second sextet
				sta adr_screen_2+1		; dans partie basse 2ème adresse écran de la routine aff_2_sextets
				pla 					; récupère index rang partie basse adresse écran 1er 1/4 tuile
				tax						; le passe dans x
				inx						; pour pointer sur la partie haute
				php						; sauve registre d'état (dont bit Z) Z=1 si partie basse =$00 ==> incrémenter partie haute
				lda tab_adr_hires,x		; A contient partie haute adresse écran 2ème  1/4 tuile 
				sta adr_screen_1+2		; dans partie haute 1ere adresse écran de la routine aff_2_sextets
				plp						; récupère P pour test Z
				bne skip_inc_ph			; si pas nul c'est que la partie basse n'est pas nulle après incrément ==> pas d'increment partie haute
				tax						; passe partie haute adresse dans X pour increment
				inx						; partie haute = partie haute +1
				txa						; dans pour
skip_inc_ph				
				sta adr_screen_2+2		; renseigner partie haute 2ème adresse écran de la routine aff_2_sextets
				rts
;--------------------------------------------------
;---               affiche demie tuile               
;--------------------------------------------------	
aff_demi_t	
				jsr rens_adr_car		; n° car issus de $00 et $01
				ldy #$00
lp_2_sextets	
				jsr aff_2_sextets		; 2 jeux de 6 octets  (partie haute tuile)
				jsr maj_scr_hires
				iny
				cpy #$06
				bne lp_2_sextets		
				rts	
				
;----------------------------------------------------------
;----           affiche deux sextets côte à côte      ----- 
;----------------------------------------------------------	
;pour faire seulement 10 additions par tuile  (2 x 5) au lieu de 20 (4 x 5)

aff_2_sextets	

adr_car_1	
					lda 1111,y
adr_screen_1	
					sta $1111
adr_car_2	
					lda 2222,y
adr_screen_2	
					sta $2222	
					rts				
;-------------------------------------------------
;--- MàJ adresses écran HIRES  dans une tuile ----
;-------------------------------------------------
maj_scr_hires
					clc
					lda adr_screen_1+1
					adc #$28
					sta adr_screen_1+1
					bcc skip_ret_1
					inc adr_screen_1+2
skip_ret_1
					clc
					lda adr_screen_2+1
					adc #$28
					sta adr_screen_2+1
					bcc end_maj_adr_ecr
					inc adr_screen_2+2
end_maj_adr_ecr	
					rts					
				
				
				
				
;------------------------------------------------------
;---     renseigne adresses caractères  tuile      ----
;------------------------------------------------------	
; En entrée : 	X contient l'index sur n° d'ordre (1,2,3 ou4) du 1/4 de tuile 
; 				(0,ou 2 car incrémenté dans cette routine pour les 1 et 3)
; en sortie : 	adr_car_1 et adr_car_2 de la routine aff_2_sextets sont renséignées
rens_adr_car
				txa					
				pha					; sauve le n° d'ordre du 1/4 de tuile haut gauche si X=0 bas gauche si x=2
				lda $00,x			; n° premier car stocké en $00
				asl					; vers table adresse car  1/4 tuiles
				tax					;
				lda sous_tuile,x		; Partie haute adresse caractère
				sta adr_car_1+2
				inx
				lda sous_tuile,x	; partie basse adresse caractère
				sta adr_car_1+1
				pla					; récupère n° d'ordre 1/4 de tuile 
				tax
				inx					; l'incremente pour	du 1/4 de tuile haut droit si X=2 bas droit si x=3
				lda $00,x			; n° deuxième car stocké en $01
				asl					; vers table adresse car  1/4 tuiles
				tax					;
				lda sous_tuile,x		; Partie haute adresse caractère
				sta adr_car_2+2
				inx
				lda sous_tuile,x	; partie basse adresse caractère
				sta adr_car_2+1
				rts


		
;------------------------------------------------------		
; -----  routine attend appui touche  ---
;------------------------------------------------------ spécifique pour mon test
wait_key
		lda $208
		cmp #$38
		beq wait_key
		cmp #$ac
		bne next_key_1
		beq end_key
next_key_1
		cmp #$bc
		bne next_key_2
		beq end_key
next_key_2
		cmp #$9c
		bne next_key_3
		beq end_key
next_key_3
		cmp #$b4
		bne next_key_4		
		beq end_key
next_key_4
		cmp #$86
		bne no_key
		beq end_key
no_key
		lda #$38	
end_key		
		sta $0c
		rts		
		
		
;************************************************
;***   implantation caractères redéfinis      ***
;************************************************ 	après être passé en HIRES
impl_car
	ldx #$00
lp1_impl	
	lda dta_car_redef_p1,x
	sta $9d00,x
	inx
	cpx #$FC
	bne lp1_impl
	ldx #$00
lp2_impl	
	lda dta_car_redef_p2,x
	sta	$9dfc,x
	inx
	cpx #$FC
	bne lp2_impl
	ldx #$00	
lp3_impl	
	lda dta_car_redef_p3,x
	sta	$9ef8,x
	inx
	cpx #$fc			;dernier car en $9ff4
	bne lp3_impl		
;	jsr hires_
	rts
;---------------------------------------------------------------------
;- passe en mode HIRES et installe 12x7 (84) atributs couleur jaune et cyan -
;---------------------------------------------------------------------	 routine spécifique l'emplacement choisie de la fenêtre
hires_et_atributs	
		jsr $EC33
		lda #$06
		sta $Aa01
		sta $Aa51
		sta $AaA1
		sta $AaF1	
		sta $Ab41
		sta $Ab91
		lda #$03
		sta $Aa29
		sta $Aa79
		sta $Aac9
		sta $Ab19
		sta $Ab69
		sta $Abb9
		
		lda #$06
		sta $Abe1
		sta $Ac31
		sta $Ac81
		sta $Acd1	
		sta $Ad21
		sta $Ad71
		lda #$03
		sta $Ac09
		sta $Ac59
		sta $Aca9
		sta $Acf9
		sta $Ad49
		sta $Ad99		
		
		lda #$06
		sta $Adc1
		sta $Ae11
		sta $Ae61
		sta $Aeb1	
		sta $Af01
		sta $Af51
		lda #$03
		sta $Ade9
		sta $Ae39
		sta $Ae89
		sta $Aed9
		sta $Af29
		sta $Af79		
		
		lda #$06
		sta $Afa1
		sta $Aff1
		sta $b041
		sta $b091	
		sta $b0e1
		sta $b131
		lda #$03
		sta $Afc9
		sta $b019
		sta $b069
		sta $b0b9
		sta $b109
		sta $b159		
		
		lda #$06
		sta $b181
		sta $b1d1
		sta $b221
		sta $b271	
		sta $b2c1
		sta $b311
		lda #$03
		sta $b1a9
		sta $b1f9
		sta $b249
		sta $b299
		sta $b2e9
		sta $b339		
		
		lda #$06
		sta $b361
		sta $b3b1
		sta $b401
		sta $b451	
		sta $b4a1
		sta $b4f1
		lda #$03
		sta $b389
		sta $b3d9
		sta $b429
		sta $b479
		sta $b4c9
		sta $b519		
		
		lda #$06
		sta $b541
		sta $b591
		sta $b5e1
		sta $b631	
		sta $b681
		sta $b6d1
		lda #$03
		sta $b569
		sta $b5b9
		sta $b609
		sta $b659
		sta $b6a9
		sta $b6f9		
										
		rts	
	
;************************************************
;******* Affiche différents textes   ************
;************************************************
aff_text
;--------------------------------------------------
	lda $0e
	cmp #$52				; valeur tuile portail traversable avec clef_1
	beq suite_portail
	cmp #$53				; valeur tuile portail traversable avec clef_2
	beq suite_portail	
	jmp key_1
suite_portail	
	ldx #$00
	lda t_portail_1,x
	sta adr_ecr_txt+1
	lda #<t_portail_1+1
	sta write_phrase+1
	lda #>t_portail_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #$00
	lda t_portail_2,x
	sta adr_ecr_txt+1
	lda #<t_portail_2+1
	sta write_phrase+1
	lda #>t_portail_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
;---------------------------------------------------
key_1	
	lda $0e
	cmp #$54				; valeur tuile clef_1 
	beq suite_clef
	cmp #$55				; valeur tuile clef_2
	beq suite_clef	
	jmp voleur_
suite_clef
	jsr eff_tuile_spe	
	ldx #$00
	lda t_key_1,x
	sta adr_ecr_txt+1
	lda #<t_key_1+1
	sta write_phrase+1
	lda #>t_key_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #$00
	lda t_key_2,x
	sta adr_ecr_txt+1
	lda #<t_key_2+1
	sta write_phrase+1
	lda #>t_key_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
	
	ldx #$00
	lda t_key_3,x
	sta adr_ecr_txt+1
	lda #<t_key_3+1
	sta write_phrase+1
	lda #>t_key_3+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
;-------------------------------------------------------------
voleur_

	lda $0e
	cmp #$56				; valeur tuile pour rencontre voleur
	beq suite_voleur
	jmp _mot_de_passe
suite_voleur	
	ldx #$00
	lda t_voleur_1,x
	sta adr_ecr_txt+1
	lda #<t_voleur_1+1
	sta write_phrase+1
	lda #>t_voleur_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #$00
	lda t_voleur_2,x
	sta adr_ecr_txt+1
	lda #<t_voleur_2+1
	sta write_phrase+1
	lda #>t_voleur_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
;-------------------------------------------------
_mot_de_passe
	lda $0e					
	cmp #$57				; valeur tuile pour patricienne donne mot de passe
	beq suite_mot_passe
	jmp garde_
suite_mot_passe
	jsr eff_tuile_spe
	ldx #$00
	lda t_m_de_passe_1,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_1+1
	sta write_phrase+1
	lda #>t_m_de_passe_1+1
	sta write_phrase+2
	jsr write_phrase	

	ldx #$00
	lda t_m_de_passe_2,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_2+1
	sta write_phrase+1
	lda #>t_m_de_passe_2+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_key
	jsr eff_text

	ldx #$00
	lda t_m_de_passe_3,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_3+1
	sta write_phrase+1
	lda #>t_m_de_passe_3+1
	sta write_phrase+2
	jsr write_phrase

	ldx #$00
	lda t_m_de_passe_4,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_4+1
	sta write_phrase+1
	lda #>t_m_de_passe_4+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	
	rts
;-------------------------------------------------
garde_
	lda $0e					
	cmp #$58				; valeur tuile pour garde (voit invitation)
	beq suite_garde
	jmp caius_
suite_garde
	jsr eff_tuile_spe
	ldx #$00
	lda t_garde_2,x
	sta adr_ecr_txt+1
	lda #<t_garde_2+1
	sta write_phrase+1
	lda #>t_garde_2+1
	sta write_phrase+2
	jsr write_phrase	

ldx #$00
	lda t_garde_3,x
	sta adr_ecr_txt+1
	lda #<t_garde_3+1
	sta write_phrase+1
	lda #>t_garde_3+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_key
	jsr eff_text	
	rts

;-------------------------------------------------
caius_
	lda $0e					
	cmp #$59				; valeur tuile pour legat qui donne bourse
	beq suite_caius
	jmp entrance_	
suite_caius
	jsr eff_tuile_spe	
	ldx #$00
	lda t_caius_1,x
	sta adr_ecr_txt+1
	lda #<t_caius_1+1
	sta write_phrase+1
	lda #>t_caius_1+1
	sta write_phrase+2
	jsr write_phrase	

	ldx #$00
	lda t_caius_2,x
	sta adr_ecr_txt+1
	lda #<t_caius_2+1
	sta write_phrase+1
	lda #>t_caius_2+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_key
	jsr eff_text

	ldx #$00
	lda t_caius_3,x
	sta adr_ecr_txt+1
	lda #<t_caius_3+1
	sta write_phrase+1
	lda #>t_caius_3+1
	sta write_phrase+2
	jsr write_phrase	
	
	ldx #$00
	lda t_caius_4,x
	sta adr_ecr_txt+1
	lda #<t_caius_4+1
	sta write_phrase+1
	lda #>t_caius_4+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_key
	jsr eff_text	
	
	rts
;-------------------------------------------------	
entrance_
	lda $0e
	cmp #$51				; valeur entrée ville
	beq suite_entrance
	jmp medicus_
suite_entrance	
	ldx #$00
	lda t_entrance_1,x
	sta adr_ecr_txt+1
	lda #<t_entrance_1+1
	sta write_phrase+1
	lda #>t_entrance_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #$00
	lda t_entrance_2,x
	sta adr_ecr_txt+1
	lda #<t_entrance_2+1
	sta write_phrase+1
	lda #>t_entrance_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
;-------------------------------------------------	
medicus_	
	lda $0e
	cmp #$5a				; valeur medicus
	bne armurerie_
	ldx #$00
	lda t_medicus_1,x
	sta adr_ecr_txt+1
	lda #<t_medicus_1+1
	sta write_phrase+1
	lda #>t_medicus_1+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr do_you_enter
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------------------
armurerie_
	lda $0e
	cmp #$5b				; valeur armurerie
	bne herboriste_
	ldx #$00
	lda t_armurerie_1,x
	sta adr_ecr_txt+1
	lda #<t_armurerie_1+1
	sta write_phrase+1
	lda #>t_armurerie_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------------------
herboriste_
	lda $0e
	cmp #$5c				; valeur herboriste
	bne animalerie_
	ldx #$00
	lda t_herboriste_1,x
	sta adr_ecr_txt+1
	lda #<t_herboriste_1+1
	sta write_phrase+1
	lda #>t_herboriste_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------------------
animalerie_
	lda $0e
	cmp #$5d				; valeur animalerie
	bne taberna_
	ldx #$00
	lda t_animalerie_1,x
	sta adr_ecr_txt+1
	lda #<t_animalerie_1+1
	sta write_phrase+1
	lda #>t_animalerie_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------------------	
taberna_
	lda $0e
	cmp #$5e				; valeur auberge
	bne fin_txt
	ldx #$00
	lda t_taberna_1,x
	sta adr_ecr_txt+1
	lda #<t_taberna_1+1
	sta write_phrase+1
	lda #>t_taberna_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr eff_text
;-------------------------------------------------	
fin_txt	
	rts
	
;****            routine modi fifie map retire tuile spéciale une fois découverte              ****	
eff_tuile_spe
		lda $0f
		clc
		adc $05
		tax				; n° ligne perso dans x
		lda $10
		clc
		adc $06
		tay				; rang perso sur ligne dans y
		txa
		asl
		tax
		lda ptr_Lignes,x
		sta adr_lign_eff+1
		inx
		lda ptr_Lignes,x
		sta adr_lign_eff+2
		lda #$00			; ref tuile chemin
adr_lign_eff
		sta $1111,y			; placée das la carte à l'emplacement de la tuile spéciale
		sta$0e				; rappel : $0e contient ref de tuile sous perso
		rts	
		
		
		
		

;********************************************************	
;****            routine why no scroll               ****
;********************************************************
why_no_scoll
		lda $0a					
		cmp #$52	;portail 1 vous n'avez pas clef_1
		bne chck_wns_4d
		jsr no_pasaran
		rts
chck_wns_4d		
		cmp #$58	; garde vousn 'avez pas mot de pass
		bne chck_wns_51
		jsr garde_nsc
		rts
chck_wns_51	
		cmp #$53	;portail 2 vous n'avez pas clef_2		
		bne fin_wns
		jsr no_pasaran
		rts
		
fin_wns
;-------------------------------------
garde_nsc
	ldx #$00
	lda t_garde_1,x
	sta adr_ecr_txt+1
	lda #<t_garde_1+1
	sta write_phrase+1
	lda #>t_garde_1+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------
no_pasaran
ldx #$00
	lda t_portail_3,x
	sta adr_ecr_txt+1
	lda #<t_portail_3+1
	sta write_phrase+1
	lda #>t_portail_3+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	rts
;-------------------------------------

do_you_enter
	ldx #$00
	lda t_do_you_1,x
	sta adr_ecr_txt+1
	lda #<t_do_you_1+1
	sta write_phrase+1
	lda #>t_do_you_1+1
	sta write_phrase+2	
	jsr write_phrase
	rts
;-------------------------------------

	
;********************************************************	
;**** routine ecrit une phrase sur ligne écran text  ****
;********************************************************
write_phrase
	lda $1111,x
	beq end_phrase
adr_ecr_txt
	sta $bf11,x
	inx	
	bne write_phrase
end_phrase
	lda #$01
	sta $15
	rts
;****************************************************	
;****  routine attend appui sur Espace et laché  ****
;****************************************************	
hit_key
	lda $208
	cmp #$38
	beq hit_key
	cmp #$86
	bne release_
	sta $0c
release_	
	lda $208
	cmp #$38
	bne release_
	rts
	
;************************************************
;*******       efface le texte       ************
;************************************************	
eff_text
	lda $15
	beq out_eff_text
	dec $15
	ldx #$27
	lda #$20
lp_efface	
	sta $BF90,x
	sta $bfb8,x
	dex
	bne lp_efface
out_eff_text
	rts	
;************************************************
;*******  dessine cadre carte ville   ***********
;************************************************
cadre_plan
	lda #$c0
; en premier, les 2 bords horizontaux	
	ldx #$15
	stx lp_30h+1	;bord horizontal, ici bord haut
	ldx #$a9
	stx lp_30h+2
	jsr draw_bord_h
	ldx #$25
	stx lp_30h+1	; bord horizontal, ici bord bas
	ldx #$b7
	stx lp_30h+2
	jsr draw_bord_h	
; puis les 2 bords verticaux
	ldx #$15
	stx lp_60_v+1	;bord vertical, ici gauche
	ldx #$a9
	stx lp_60_v+2
	jsr draw_bord_v
	ldx #$34
	stx lp_60_v+1	; bord vertical, ici droite
	ldx #$a9
	stx lp_60_v+2
	jsr draw_bord_v
	rts
; sous routine bords horizontaux	
draw_bord_h
	ldy #$6
lp_06v
	ldx #$1e
lp_30h	
	sta $1111,x
	dex
	bne lp_30h
	jsr maj_adr_h_dcm ; Mise à Jour ADResses Horizontales Draw Cadre Map	
	dey
	bne lp_06v
	rts
;-------------------------------------------	
maj_adr_h_dcm
	pha
	lda lp_30h+1
	clc
	adc #$28
	sta lp_30h+1
	bcc end_maj_h
	inc lp_30h+2
end_maj_h
	pla
	rts	
;-------------------------------------------
; sous routine bords verticaux	
draw_bord_v
	ldx #$60
lp_60_v	
	sta $2222
	dex
	beq out_lp_60
	jsr maj_adr_v_dcm 	; Mise à Jour ADResses Verticales Draw Cadre Map
	bne lp_60_v			; branchement forcé car on sort de maj par PLA C0 <> 0
out_lp_60
	rts
;-------------------------------------------	
maj_adr_v_dcm
	pha
	lda lp_60_v+1
	clc
	adc #$28
	sta lp_60_v+1
	bcc end_maj_v
	inc lp_60_v+2
end_maj_v
	pla
	rts		
				
;************************************************
;******* table adresses écran HIRES  ************
;************************************************				
tab_adr_hires				
	.byt $06,$aa,$08,$aa,$0a,$aa,$0c,$aa,$0e,$aa,$10,$aa,$12,$aa,$14,$aa,$16,$aa,$18,$aa,$1a,$aa,$1c,$aa,$1e,$aa,$20,$aa,$22,$aa
	.byt $e6,$ab,$e8,$ab,$ea,$ab,$ec,$ab,$ee,$ab,$f0,$ab,$f2,$ab,$f4,$ab,$f6,$ab,$f8,$ab,$fa,$ab,$fc,$ab,$fe,$ab,$00,$ac,$02,$ac
	.byt $c6,$ad,$c8,$ad,$ca,$ad,$cc,$ad,$ce,$ad,$d0,$ad,$d2,$ad,$d4,$ad,$d6,$ad,$d8,$ad,$da,$ad,$dc,$ad,$de,$ad,$e0,$ad,$e2,$ad				
	.byt $a6,$af,$a8,$af,$aa,$af,$ac,$af,$ae,$af,$b0,$af,$b2,$af,$b4,$af,$b6,$af,$b8,$af,$ba,$af,$bc,$af,$be,$af,$c0,$af,$c2,$af
	.byt $86,$b1,$88,$b1,$8a,$b1,$8c,$b1,$8e,$b1,$90,$b1,$92,$b1,$94,$b1,$96,$b1,$98,$b1,$9a,$b1,$9c,$b1,$9e,$b1,$a0,$b1,$a2,$b1
	.byt $66,$b3,$68,$b3,$6a,$b3,$6c,$b3,$6e,$b3,$70,$b3,$72,$b3,$74,$b3,$76,$b3,$78,$b3,$7a,$b3,$7c,$b3,$7e,$b3,$80,$b3,$82,$b3
	.byt $46,$b5,$48,$b5,$4a,$b5,$4c,$b5,$4e,$b5,$50,$b5,$52,$b5,$54,$b5,$56,$b5,$58,$b5,$5a,$b5,$5c,$b5,$5e,$b5,$60,$b5,$62,$b5
				
;*******************************************
;*******    DATA PLAN VILLE_1   ************
;*******************************************
_L00 
	.byt $02,$00,$00,$13,$03,$03,$03,$03,$03,$04,$00,$01,$03,$13,$45,$13,$03,$02,$00,$13,$03,$03,$03,$03,$03,$04,$00,$00,$01,$04
_L01 
	.byt $00,$00,$13,$11,$00,$00,$00,$00,$00,$01,$04,$00,$00,$12,$5E,$12,$00,$00,$13,$11,$00,$00,$00,$00,$00,$01,$04,$00,$00,$12
_L02 
	.byt $00,$13,$11,$00,$00,$13,$03,$04,$00,$00,$01,$04,$00,$05,$00,$05,$00,$13,$11,$00,$00,$13,$03,$04,$00,$00,$01,$04,$00,$05
_L03 
	.byt $00,$12,$00,$00,$13,$11,$00,$01,$04,$00,$00,$12,$00,$00,$00,$00,$00,$12,$00,$00,$13,$11,$00,$01,$04,$00,$00,$12,$00,$00
_L04 
	.byt $13,$11,$00,$01,$11,$00,$00,$00,$01,$04,$00,$01,$03,$02,$00,$01,$03,$11,$00,$13,$11,$00,$00,$00,$01,$02,$00,$01,$03,$04
_L05 
	.byt $12,$00,$00,$00,$00,$00,$14,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$14,$00,$00,$00,$00,$00,$00,$12
_L06 
	.byt $03,$04,$00,$01,$04,$00,$00,$00,$13,$11,$00,$13,$03,$02,$00,$01,$03,$04,$00,$01,$04,$00,$00,$00,$13,$02,$00,$13,$03,$12
_L07 
	.byt $00,$12,$00,$00,$01,$04,$00,$13,$11,$00,$00,$12,$00,$00,$00,$00,$00,$12,$00,$00,$01,$04,$00,$13,$11,$00,$00,$12,$00,$12
_L08 
	.byt $13,$03,$04,$00,$00,$01,$45,$11,$00,$00,$13,$11,$00,$12,$00,$12,$00,$01,$04,$00,$00,$01,$45,$11,$00,$00,$13,$11,$00,$12
_L09 
	.byt $12,$00,$01,$04,$00,$00,$5E,$00,$00,$13,$11,$00,$00,$12,$00,$12,$00,$00,$01,$04,$00,$00,$5E,$00,$00,$13,$11,$00,$00,$12
_L10 
	.byt $12,$00,$00,$01,$03,$03,$03,$03,$03,$11,$00,$00,$13,$11,$00,$01,$04,$00,$00,$01,$03,$03,$03,$03,$03,$11,$00,$00,$13,$11
_L11 
	.byt $01,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$11,$00,$00,$00,$01,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$11,$00
_L12 
	.byt $00,$12,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$00,$00,$00,$00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$04
_L13 	
	.byt $00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$03,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
_L14 
	.byt $13,$11,$00,$01,$03,$03,$03,$02,$00,$01,$03,$03,$03,$11,$00,$01,$03,$03,$03,$04,$00,$13,$03,$03,$03,$03,$03,$02,$00,$04
_L15 
	.byt $12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$05
_L16 
	.byt $12,$00,$04,$00,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$60,$12,$00,$00,$01,$01,$01,$01,$01,$04
_L17 
	.byt $01,$03,$03,$03,$03,$11,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$61,$01,$02,$00,$00,$00,$00,$00,$00,$05
_L18 
	.byt $1d,$1d,$1d,$1d,$50,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4f,$1d,$61,$39,$1d,$1d,$1d,$01,$03,$02,$00,$04
_L19 
	.byt $4c,$4c,$4c,$4c,$38,$13,$03,$03,$45,$03,$45,$03,$45,$03,$03,$03,$03,$36,$42,$1d,$61,$4c,$4c,$4c,$4f,$1d,$1d,$00,$00,$05
_L20 
	.byt $04,$00,$00,$00,$00,$12,$00,$00,$5a,$00,$5b,$00,$5c,$00,$00,$00,$00,$01,$03,$04,$5f,$13,$02,$00,$49,$1d,$1d,$00,$01,$04
_L21 
	.byt $12,$00,$04,$00,$13,$11,$00,$3f,$40,$40,$40,$40,$40,$37,$00,$04,$00,$00,$00,$05,$00,$12,$00,$00,$42,$4f,$1d,$00,$00,$05
_L22 
	.byt $01,$03,$11,$00,$05,$00,$0c,$37,$57,$00,$00,$00,$00,$37,$00,$13,$03,$04,$00,$00,$00,$01,$04,$00,$00,$49,$1d,$1d,$00,$04
_L23 
	.byt $51,$00,$00,$00,$00,$00,$43,$37,$00,$00,$00,$00,$00,$37,$00,$12,$00,$01,$03,$04,$00,$00,$01,$04,$00,$42,$4f,$1d,$00,$05
_L24 
	.byt $13,$03,$03,$03,$04,$00,$00,$40,$40,$40,$62,$40,$40,$3E,$00,$12,$00,$00,$00,$01,$04,$00,$00,$12,$00,$00,$49,$1d,$1d,$04
_L25 
	.byt $05,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$04,$00,$00,$01,$02,$00,$01,$02,$00,$42,$1d,$1d,$05
_L26 
	.byt $4d,$4a,$00,$00,$00,$00,$00,$00,$13,$03,$45,$03,$45,$03,$03,$11,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$49,$1d,$04
_L27 
	.byt $1d,$4d,$4b,$4b,$4b,$4a,$00,$00,$12,$00,$5b,$00,$5d,$00,$00,$00,$00,$00,$00,$00,$01,$03,$03,$03,$03,$04,$00,$42,$4f,$05
_L28 
	.byt $1d,$1d,$1d,$1d,$1d,$4d,$4a,$3d,$03,$02,$60,$3d,$03,$03,$03,$03,$03,$04,$00,$00,$00,$00,$00,$00,$00,$12,$00,$36,$49,$1d
_L29 
	.byt $13,$03,$03,$03,$3c,$1d,$4d,$4b,$4b,$4b,$61,$4b,$4b,$4b,$4b,$4b,$4a,$3d,$03,$03,$03,$03,$03,$04,$00,$12,$00,$12,$49,$1d
_L30 
	.byt $12,$00,$00,$00,$01,$3c,$1d,$1d,$1d,$1d,$61,$39,$1d,$1d,$1d,$1d,$4d,$4b,$4b,$4b,$4b,$4b,$4a,$3d,$03,$11,$00,$05,$49,$1d
_L31 
	.byt $13,$03,$02,$00,$00,$01,$03,$03,$03,$3b,$5f,$13,$03,$03,$3b,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$4d,$4b,$4b,$4b,$4b,$4b,$4E,$1d
_L32 
	.byt $12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d
_L33 
	.byt $12,$00,$00,$13,$03,$45,$03,$03,$03,$04,$00,$00,$01,$04,$00,$13,$03,$02,$00,$13,$03,$03,$45,$03,$03,$04,$00,$00,$01,$3c
_L34 
	.byt $05,$00,$13,$11,$00,$5E,$00,$00,$00,$01,$04,$00,$00,$12,$00,$12,$00,$00,$13,$11,$00,$00,$5a,$00,$00,$01,$04,$00,$00,$05
_L35 
	.byt $00,$13,$11,$00,$00,$13,$03,$04,$00,$00,$01,$04,$00,$05,$00,$05,$00,$13,$11,$00,$00,$14,$14,$14,$00,$00,$01,$02,$00,$04
_L36 
	.byt $00,$12,$00,$00,$13,$11,$00,$01,$04,$00,$00,$12,$00,$00,$00,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
_L37 
	.byt $13,$11,$00,$01,$11,$00,$00,$00,$01,$04,$00,$01,$03,$02,$00,$01,$03,$11,$00,$00,$00,$00,$15,$17,$00,$00,$0c,$46,$03,$04
_L38 
	.byt $12,$00,$00,$00,$00,$00,$14,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$58,$00,$00,$00,$00,$19,$1b,$00,$59,$0c,$08,$00,$12
_L39 
	.byt $03,$04,$00,$01,$04,$00,$00,$00,$13,$11,$00,$13,$03,$02,$00,$01,$03,$04,$00,$00,$00,$00,$00,$00,$00,$00,$43,$03,$03,$11
_L40 
	.byt $00,$12,$00,$00,$01,$04,$00,$13,$11,$00,$00,$12,$00,$00,$00,$00,$00,$12,$00,$00,$00,$14,$14,$14,$00,$00,$00,$00,$00,$04
_L41 
	.byt $13,$03,$04,$00,$00,$01,$03,$11,$00,$00,$13,$11,$00,$04,$00,$04,$00,$01,$04,$00,$00,$00,$00,$00,$00,$00,$13,$02,$00,$05
_L42 
	.byt $12,$00,$01,$04,$00,$00,$00,$00,$00,$13,$11,$00,$00,$12,$00,$12,$00,$00,$01,$04,$00,$00,$00,$00,$00,$13,$11,$00,$00,$04
_L43 
	.byt $12,$00,$00,$13,$03,$03,$03,$03,$03,$12,$00,$00,$13,$03,$03,$03,$04,$00,$00,$13,$03,$03,$03,$03,$03,$12,$00,$00,$13,$11
_L44 
	.byt $01,$03,$03,$11,$00,$00,$00,$00,$00,$01,$03,$03,$11,$00,$00,$00,$01,$03,$03,$11,$00,$00,$00,$00,$00,$01,$03,$03,$11,$00
ptr_Lignes

	.byt <_L00,>_L00,<_L01,>_L01,<_L02,>_L02,<_L03,>_L03,<_L04,>_L04,<_L05,>_L05,<_L06,>_L06,<_L07,>_L07,<_L08,>_L08,<_L09,>_L09
	.byt <_L10,>_L10,<_L11,>_L11,<_L12,>_L12,<_L13,>_L13,<_L14,>_L14,<_L15,>_L15,<_L16,>_L16,<_L17,>_L17,<_L18,>_L18,<_L19,>_L19
	.byt <_L20,>_L20,<_L21,>_L21,<_L22,>_L22,<_L23,>_L23,<_L24,>_L24,<_L25,>_L25,<_L26,>_L26,<_L27,>_L27,<_L28,>_L28,<_L29,>_L29
	.byt <_L30,>_L30,<_L31,>_L31,<_L32,>_L32,<_L33,>_L33,<_L34,>_L34,<_L35,>_L35,<_L36,>_L36,<_L37,>_L37,<_L38,>_L38,<_L39,>_L39
	.byt <_L40,>_L40,<_L41,>_L41,<_L42,>_L42,<_L43,>_L43,<_L44,>_L44
	
	
	
; -----------------------------------------------
;       Table redéfinition  2nd jeu de car 
; -----------------------------------------------

dta_car_redef_p1
;00 en $9d00
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;01 en $9d06
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0


;02 en $9d0c
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $49	;0,1,0,0,1,0,0,1
	.byt $f8	;1,1,1,1,1,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $fe	;1,1,1,1,1,1,1,0
	
;03 en $9d12
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $79	;0,1,1,1,1,0,0,1
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $c6	;1,1,0,0,0,1,1,0
	
;04 en $9d18
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	
;05 en $9d1e
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $da	;1,1,0,1,1,0,1,0
	.byt $72	;0,1,1,1,0,0,1,0
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	
;06 en $9d24
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $6c 	;0,1,1,0,1,1,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $7b 	;0,1,1,1,1,0,1,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	
;07  en $9d2a
	.byt $d5 	;1,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $d5 	;1,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $d5 	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	
;08  en $9d30
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	
;09  en $9d36
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	
;0A  en $9d3c
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0

;0B  en $9d42
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1

;0C  en $9d48
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $cc 	;1,1,0,0,1,1,0,0

;0D  en $9d4e
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $6c 	;0,1,1,0,1,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $6b 	;0,1,1,0,1,0,1,1
	.byt $eb 	;1,1,1,0,1,0,1,1
	
;0E  en $9d54
	.byt $d9 	;1,1,0,1,1,0,0,1
	.byt $e6 	;1,1,1,0,0,1,1,0
	.byt $d9 	;1,1,0,1,1,0,0,1
	.byt $e6 	;1,1,1,0,0,1,1,0
	.byt $d9 	;1,1,0,1,1,0,0,1
	.byt $e6 	;1,1,1,0,0,1,1,0
	
;0F  en $9d5a
	.byt $ec 	;1,1,1,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $ec 	;1,1,1,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $ec 	;1,1,1,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	
;10  en $9d60
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $6c 	;0,1,1,0,1,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $6b 	;0,1,1,0,1,0,1,1
	.byt $ea 	;1,1,1,0,1,0,1,0
	
;11  en $9d66
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $66 	;0,1,1,0,0,1,1,0
	.byt $43 	;0,1,0,0,0,0,1,1
	
;12  en $9d6c
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $50 	;0,1,0,1,0,0,0,0
	
;13  en $9d72
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	
;14  en $9d78
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $7d 	;0,1,1,1,1,1,0,1
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $7d 	;0,1,1,1,1,1,0,1
	
;15  en $9d7e
	.byt $77 	;0,1,1,1,0,1,1,1
	.byt $dc 	;1,1,0,1,1,1,0,0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $6e 	;0,1,1,0,1,1,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0
	
;16  en $9d84
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $fd 	;1,1,1,1,1,1,0,1
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $e7 	;1,1,1,0,0,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1

;17  en $9d8a
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $fb 	;1,1,1,1,1,0,1,1
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $f7 	;1,1,1,1,0,1,1,1
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $cf 	;1,1,0,0,1,1,1,1
	
;18  en $9d90
	.byt $40 	;0,1,0,0,0,0,0,0 
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $fd 	;1,1,1,1,1,1,0,1
	
;19  en $9d96
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $e1 	;1,1,1,0,0,0,0,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	
;1A  en $9d9c
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;1B  en $9da2
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $64 	;0,1,1,0,0,1,0,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $48 	;0,1,0,0,1,0,0,0
	
;1C  en $b9d8
	.byt $52 	;0,1,0,1,0,0,1,0
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $64 	;0,1,1,0,0,1,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;1D  en $9dae
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6b 	;0,1,1,0,1,0,1,1
	.byt $44 	;0,1,0,0,0,1,0,0
	
;1E  en $9db4
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	
;1F  en $9dba
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;20  en $9dc0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $ea 	;1,1,1,0,1,0,1,0
	
;21  en $9dc6
	.byt $4e 	;0,1,0,0,1,1,1,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $52 	;0,1,0,1,0,0,1,0
	.byt $4d 	;0,1,0,0,1,1,0,1
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $47 	;0,1,0,0,0,1,1,1
	
;22  en $9dcc
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,1,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $76 	;0,1,1,1,0,1,1,0

;23  en $9dd2
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0

;24  en $9dd8
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $65 	;0,1,1,0,0,1,0,1
	.byt $52 	;0,1,0,1,0,0,1,0
	.byt $4b 	;0,1,0,0,1,0,1,1
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $40 	;0,1,0,0,0,0,0,0

;25  en $9dde
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0

;26  en $9de4
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0

;27  en $9dea
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $6c 	;0,1,1,0,1,1,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $69 	;0,1,1,0,1,0,0,1
	.byt $56 	;0,1,0,1,0,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0

;28  en $9df0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1
	
;29  en $9df6
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0

dta_car_redef_p2	
;2A  en $9dfc
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1
	
;2B  en $9e02
	.byt $74 	;0,1,1,1,0,1,0,0
	.byt $6e 	;0,1,1,0,1,1,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $52 	;0,1,0,1,0,0,1,0
	.byt $60 	;0,1,1,0,0,0,0,0
	
;2C  en $9e08
	.byt $4e 	;0,1,0,0,1,1,1,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $49 	;0,1,0,0,1,0,0,1
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $47 	;0,1,0,0,0,1,1,1
	
;2D  en $9e0e
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $74 	;0,1,1,1,0,1,0,0
	.byt $7a 	;0,1,1,1,1,0,1,0
	
;2E  en $9e14
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0	
	
;2F  en $9e1a
	.byt $78 	;0,1,1,1,1,0,0,0	;0,1,1,1,1,0,0,0
	.byt $6c 	;0,1,1,0,1,1,0,0    ;0,1,1,0,1,1,1,1 
	.byt $4a 	;0,1,0,0,1,0,1,0    ;0,1,0,0,1,0,0,1
	.byt $6c 	;0,1,1,0,1,1,0,0    ;0,1,1,0,1,1,0,1
	.byt $48 	;0,1,0,0,1,0,0,0    ;0,1,0,0,1,0,1,0
	.byt $78 	;0,1,1,1,1,0,0,0    ;0,1,1,1,1,0,0,0

;30  en $9e20
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $4f 	;0,1,0,0,1,1,1,1

;31  en $9e26
	.byt $40 	;0,1,0,0,0,0,0,0	
	.byt $40 	;0,1,0,0,0,0,0,0	
	.byt $40 	;0,1,0,0,0,0,0,0	
	.byt $50 	;0,1,0,1,0,0,0,0	
	.byt $78 	;0,1,1,1,1,0,0,0	
	.byt $6b 	;0,1,1,0,1,0,1,1	

;32  en $9e2c
	.byt $4f 	;0,1,0,0,1,1,1,1 	
	.byt $4c 	;0,1,0,0,1,1,0,0 	
	.byt $46 	;0,1,0,0,0,1,1,0 	
	.byt $45 	;0,1,0,0,0,1,0,1 	
	.byt $41 	;0,1,0,0,0,0,0,1 	
	.byt $40 	;0,1,0,0,0,0,0,0 	

;33  en $9e32
	.byt $65 	;0,1,1,0,0,1,0,1 	
	.byt $53 	;0,1,0,1,0,0,1,1 	
	.byt $5c 	;0,1,0,1,1,1,0,0 	
	.byt $50 	;0,1,0,1,0,0,0,0 	
	.byt $48 	;0,1,0,0,1,0,0,0 	
	.byt $70 	;0,1,1,1,0,0,0,0 	
	
;34  en $9e38
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0	
	
;35  en $9e3e
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $41 	;0,1,0,0,0,0,0,1	
	
;36  en $9e44
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $69 	;0,1,1,0,1,0,0,1
	.byt $66 	;0,1,1,0,0,1,1,0
	.byt $48 	;0,1,0,0,1,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0	
	
;37  en $9e4a
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $7a 	;0,1,1,1,1,0,1,0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $47 	;0,1,0,0,0,1,1,1	

	
;38 en $9e50
	.byt $40	;0,1,0,0,0,0,0,0	
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $70	;0,1,1,1,0,0,0,0    
	.byt $78	;0,1,1,1,1,0,0,0    
	.byt $7c	;0,1,1,1,1,1,0,0    

;39 en $9e56
	.byt $4b	;0,1,0,0,1,0,1,1	
	.byt $45	;0,1,0,0,0,1,0,1    
	.byt $42	;0,1,0,0,0,0,1,0    
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $40	;0,1,0,0,0,0,0,0    


;3A en $9e5c
	.byt $7a	;0,1,1,1,1,0,1,0	
	.byt $6a	;0,1,1,0,1,0,1,0    
	.byt $7a	;0,1,1,1,1,0,1,0    
	.byt $43	;0,1,0,0,0,1,0,1    
	.byt $49	;0,1,0,0,1,0,0,1    
	.byt $46	;0,1,0,0,0,1,1,0    
	
;3B en $9e62
	.byt $40	;0,1,0,0,0,0,0,0		
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $40	;0,1,0,0,0,0,0,0    
	.byt $60	;0,1,1,0,0,0,0,0    
	.byt $76	;0,1,1,1,0,0,0,0    
	.byt $7d	;0,1,1,1,0,1,1,0    
	
;3C en $9e68
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0	
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	
;3D en $9e6e
	.byt $79	;0,1,1,1,1,1,0,1	
	.byt $6a	;0,1,0,1,1,0,1,0    
	.byt $5c	;0,1,1,0,1,1,0,0    
	.byt $4a 	;0,1,0,1,0,1,0,0    
	.byt $52	;0,1,1,0,0,1,0,0    
	.byt $4c 	;0,1,0,1,1,0,0,0    
	
;3E en $9e74
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $C0	;1,1,0,0,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $cf 	;1,1,0,0,1,1,1,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	
;3F  en $9e7a
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $7f 	;0,1,1,1,1,1,1,1
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $f8	;1,1,1,1,1,0,0,0
	
;40  en $9e80
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $7f 	;0,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $7f 	;0,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
	
;41  en $9e86
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $7f 	;0,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
	
;42  en $9e8c
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $4e 	;0,1,0,0,1,1,1,0
	.byt $f3	;1,1,1,1,0,0,1,1

;43  en $9e92
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1

;44  en $9e98
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;45  en $9e9e
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $f0 	;1,1,1,1,0,0,0,0
	
;46  en $9ea4
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	
;47  en $9eaa
	.byt $6e 	;0,1,1,0,1,1,1,0
	.byt $d1 	;1,1,0,1,0,0,0,1
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $d8 	;1,1,0,1,1,0,0,0
	.byt $77 	;0,1,1,1,0,1,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1
	
;48  en $9eb0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1
	
;49  en $9eb6
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $d9 	;1,1,0,1,1,0,0,1
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $d1 	;1,1,0,1,0,0,0,1
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $f1 	;1,1,1,1,0,0,0,1
	
;4A  en $9ebc
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	
;4B  en $9ec2
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $54 	;0,1,0,1,0,1,0,0
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $54 	;0,1,0,1,0,1,0,0
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	
;4C  en $9ec8
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	
;4D  en $9ece
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	
;4E  en $9ed4
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $54 	;0,1,0,1,0,1,0,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $54 	;0,1,0,1,0,1,0,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $54 	;0,1,0,1,0,1,0,0

;4F  en $9eda
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $50 	;0,1,0,1,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;50  en $9ee0
	.byt $c1 	;1,1,0,0,0,0,0,1 
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;51  en $9ee6
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $72 	;0,1,1,1,0,0,1,0
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	
;52  en $9eec
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $54 	;0,1,0,1,0,1,0,0
	
;53  en $9ef2
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
dta_car_redef_p3	

;54  en $9ef8
	.byt $4e 	;0,1,0,0,1,1,1,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $44 	;0,1,0,0,0,1,0,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1
	
;55  en $9efe
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $46 	;0,1,0,0,0,1,1,0
	.byt $50 	;0,1,0,1,0,0,0,0
	
;56  en $9f04
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $4a 	;0,1,0,0,1,0,1,0
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	
;57  en $9f0a
	.byt $7a 	;0,1,1,1,1,0,1,0
	.byt $e4 	;1,1,1,0,0,1,0,0
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $e4 	;1,1,1,0,0,1,0,0
	.byt $7a 	;0,1,1,1,1,0,1,0
	.byt $e4 	;1,1,1,0,0,1,0,0
	
;58  en $9f10
	.byt $fb 	;1,1,1,1,1,0,1,1
	.byt $66 	;0,1,1,0,0,1,1,0
	.byt $fd 	;1,1,1,1,1,1,0,1
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $cd 	;1,1,0,1,1,1,0,1
	.byt $73 	;0,1,1,1,0,0,1,1
	
;59  en $9f16
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $71 	;0,1,1,1,0,0,0,1
	.byt $40 	;0,1,0,0,0,0,0,0
	
;5A  en $9f1c
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $7e 	;0,1,1,1,1,1,1,0

;5B  en $9f22
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $4b 	;0,1,0,0,1,0,1,1
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $41 	;0,1,0,0,0,0,0,1

;5C  en $9f28
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $7b 	;0,1,1,1,1,0,1,1
	.byt $7d 	;0,1,1,1,1,1,0,1
	.byt $5e 	;0,1,0,1,1,1,1,0

;5D  en $9f2e
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1

;5E  en $9f34
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0

;5F  en $9f3a
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $77 	;0,1,1,1,0,1,1,1
	.byt $7b 	;0,1,1,1,1,0,1,1
	.byt $7d 	;0,1,1,1,1,1,0,1
	.byt $40 	;0,1,0,0,0,0,0,0

;60  en $9f40
	.byt $53 	;0,1,0,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $53 	;0,1,0,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $53 	;0,1,0,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	
;61  en $9f46
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $73 	;0,1,1,1,0,0,1,1

	
;62  en $9f4c
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $6b 	;0,1,1,0,1,0,1,1
	.byt $4d 	;0,1,0,0,1,1,0,1
	.byt $72 	;0,1,1,1,0,0,1,0
	.byt $4e 	;0,1,0,0,1,1,1,0
	
;63  en $9f52
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $6e 	;0,1,1,0,1,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $77 	;0,1,1,1,0,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $7b 	;0,1,1,1,1,0,1,1
	
;64  en $9f58
	.byt $5b 	;0,1,0,1,1,0,1,1
	.byt $4d 	;0,1,0,0,1,1,0,1
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $fd 	;1,1,1,1,1,1,0,1
	
;65  en $9f5e
	.byt $5b 	;0,1,0,1,1,0,1,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $5b 	;0,1,0,1,1,0,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	
;66  en $9f64
	.byt $5b 	;0,1,0,1,1,0,1,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $5b 	;0,1,0,1,1,0,1,1
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $42 	;0,1,0,0,0,0,1,0
	.byt $fd 	;1,1,1,1,1,1,0,1	
	
;67  en $9fa
	.byt $5a 	;0,1,0,1,1,0,1,0
	.byt $6c 	;0,1,1,0,1,1,0,0     
	.byt $5a 	;0,1,0,1,1,0,1,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1

;68  en $9f70
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $4f 	;0,1,0,0,1,1,1,1

;69  en $9f76
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	
;6a  en $9f7c
	.byt $7f 	;0,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $cf 	;1,1,0,0,1,1,1,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	
;6b  en $9f82
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $fc 	;1,1,1,1,1,1,0,0
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $ff 	;1,1,1,1,1,1,1,1
;6c  en $9f88
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $6f 	;0,1,1,0,1,1,1,1
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	
;6d  en $9f8e
	.byt $fd 	;1,1,1,1,1,1,0,1
	.byt $7d 	;0,1,1,1,1,1,0,1
	.byt $fd 	;1,1,1,1,1,1,0,1
	.byt $6d 	;0,1,1,0,1,1,0,1
	.byt $fd 	;1,1,1,1,1,1,0,1
	.byt $7d 	;0,1,1,1,1,1,0,1

;6e  en $9fb94
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $ef 	;1,1,1,0,1,1,1,1
	
;6f  en $9f9a
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $5e 	;0,1,0,1,1,1,1,0
	.byt $f3 	;1,1,1,1,0,0,1,1
	.byt $46 	;0,1,0,0,0,1,1,0
	.byt $fc 	;1,1,1,1,1,1,0,0	
	
;70  en $9fa0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $46 	;0,1,1,1,0,1,1,0
	.byt $e3 	;0,1,1,0,0,0,1,1

;71  en $9fa6
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $7c 	;0,1,1,1,1,1,0,0
	.byt $66 	;0,1,1,0,0,1,1,0
	.byt $63 	;0,1,1,0,0,0,1,1

;72  en $9fac
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $49 	;0,1,0,0,1,0,0,1
	.byt $67 	;0,1,1,0,0,1,1,1
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $5b 	;0,1,0,1,1,0,1,1	
	
;73  en $9fb2
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $ef 	;1,1,1,0,1,1,1,1
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $eb 	;1,1,1,0,1,0,1,1
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $ea 	;1,1,1,0,1,0,1,0

;74  en $9fb8
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $69 	;0,1,1,0,1,0,0,1
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $6b 	;0,1,1,0,1,0,1,1
	.byt $ea 	;1,1,1,0,1,0,1,0

;75  en $9fbe
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $ed 	;1,1,1,0,1,1,0,1
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $eb 	;1,1,1,0,1,0,1,1
	.byt $64 	;0,1,1,0,0,1,0,0
	.byt $e7 	;1,1,1,0,0,1,1,1
	
;76  en $9fc4
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $58 	;0,1,0,1,1,0,0,0
	.byt $4c 	;0,1,0,0,1,1,0,0
	.byt $46 	;0,1,0,0,0,1,1,0
	.byt $43 	;0,1,0,0,0,0,1,1

;77  en $9fca
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1

;78  en $9fd0
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0

;79  en $9fd6
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0

;7a  en $9fdc
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0

;7b  en $9fe2
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0

;7c  en $9fe8
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0

;7d  en $9fee
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0
	
;7e  en $9ff4
	.byt $61 	;0,1,0,0,0,0,0,0
	.byt $70 	;0,1,0,0,0,0,0,0
	.byt $58 	;0,1,0,0,0,0,0,0
	.byt $4a 	;0,1,0,0,0,0,0,0
	.byt $46 	;0,1,0,0,0,0,0,0
	.byt $43 	;0,1,0,0,0,0,0,0	
	
;7f  en $9ffa
;	.byt $61 	;0,1,0,0,0,0,0,0
;	.byt $70 	;0,1,0,0,0,0,0,0
;	.byt $58 	;0,1,0,0,0,0,0,0
;	.byt $4a 	;0,1,0,0,0,0,0,0
;	.byt $46 	;0,1,0,0,0,0,0,0
;	.byt $43 	;0,1,0,0,0,0,0,0	
	
	
; --------------------------------------------------------------------
;       Table redéfinition  des tuiles (N)d'ordre des 4 car redafinis 
; --------------------------------------------------------------------

; 1 tuile tuile chemin. On peut marcher dessus	
_t00 
		.byt $00,$00,$00,$00
		
; 70 tuiles : maisons, immeubles, monument arbres... (on ne peut pas les traverser )		
		
_t01 
		.byt $01,$01,$02,$03
_t02 
		.byt $01,$04,$03,$05
_t03 
		.byt $01,$01,$06,$03
_t04 
		.byt $07,$04,$07,$08
_t05 
		.byt $07,$08,$02,$05
_t06 
		.byt $09,$0a,$0b,$0c
_t07 
		.byt $04,$00,$08,$00
_t08 
		.byt $08,$00,$08,$00
_t09 
		.byt $03,$05,$00,$00	; finalement non utilisée	
_t0a 
		.byt $06,$03,$00,$00
_t0b 
		.byt $0d,$03,$08,$00
_t0c 
		.byt $0e,$0f,$0e,$0f
_t0d 
		.byt $02,$03,$00,$00		
_t0e 
		.byt $04,$00,$08,$04
_t0f 
		.byt $02,$03,$00,$02
_t10 
		.byt $05,$08,$03,$05
_t11 
		.byt $07,$08,$03,$05
_t12 
		.byt $07,$08,$07,$08
_t13 
		.byt $01,$01,$07,$10
_t14 
		.byt $11,$12,$13,$14
_t15 
		.byt $15,$15,$15,$16
_t16 
		.byt $15,$15,$17,$16
_t17 
		.byt $15,$15,$17,$15
_t18 
		.byt $15,$19,$15,$16
_t19 
		.byt $15,$19,$15,$15
_t1a 
		.byt $18,$19,$15,$15		
_t1b 
		.byt $18,$15,$15,$15
_t1c 
		.byt $18,$15,$17,$15
_t1d 
		.byt $18,$19,$17,$16
_t1e 
		.byt $00,$00,$1a,$00
_t1f 
		.byt $00,$1b,$00,$1c
_t20 
		.byt $1d,$1e,$1f,$20
_t21 
		.byt $40,$40,$41,$41
_t22 
		.byt $21,$22,$23,$24
_t23 
		.byt $21,$25,$26,$27
_t24 
		.byt $28,$29,$2a,$2b
_t25 
		.byt $2c,$2d,$2e,$2f
_t26 
		.byt $30,$31,$32,$33
_t27 
		.byt $30,$34,$35,$36
_t28 
		.byt $37,$38,$39,$3a
_t29 
		.byt $37,$3b,$3c,$3d
_t2a 
		.byt $42,$43,$08,$08		
_t2b 
		.byt $44,$44,$08,$08			
_t2c 
		.byt $45,$46,$08,$47		
_t2d 
		.byt $40,$48,$41,$49		
_t2e 
		.byt $4a,$00,$4b,$00		
_t2f 
		.byt $4c,$00,$4d,$00		
_t30 
		.byt $4e,$00,$4f,$00
_t31 
		.byt $50,$51,$08,$52		
_t32 
		.byt $53,$53,$08,$08		
_t33 
		.byt $54,$55,$00,$56		
_t34 
		.byt $57,$08,$58,$08		
_t35 
		.byt $0A,$5a,$5b,$5c		
_t36 
		.byt $07,$77,$07,$08		
_t37 
		.byt $07,$71,$07,$71		
_t38 
		.byt $16,$63,$63,$63		
_t39 
		.byt $6e,$19,$6e,$16		
_t3a 
		.byt $74,$03,$08,$00
_t3b 
		.byt $01,$73,$03,$05
_t3c 
		.byt $07,$73,$07,$08
_t3d 
		.byt $01,$01,$72,$03
_t3e 
		.byt $07,$71,$6f,$76
_t3f 
		.byt $01,$01,$07,$70
_t40 
		.byt $01,$01,$6f,$6f
_t41 
		.byt $63,$63,$75,$16
_t42 
		.byt $63,$16,$63,$63
_t43 
		.byt $0b,$0b,$02,$03	
_t44 
		.byt $08,$00,$05,$00			
_t45 
		.byt $01,$01,$6a,$6b	; Portail echoppes ex :47, 4a, 4c, 4e, 50
_t46
		.byt $01,$01,$74,$03	
_t47 
		.byt $00,$00,$00,$00	;libre	
_t48
		.byt $00,$00,$00,$00	;libre		
_t49 
		.byt $63,$19,$63,$16
_t4a
		.byt $63,$63,$16,$63
_t4b 
		.byt $63,$63,$17,$16
_t4c
		.byt $17,$16,$63,$63	
_t4d 
		.byt $18,$63,$17,$16
_t4e
		.byt $63,$19,$17,$16	
_t4f 
		.byt $18,$16,$63,$16	
_t50
		.byt $18,$16,$17,$63
		
;à partir de 51 , 18  tuiles spéciales , gébéralement elles apparaissent en  noir comme les chemins
; mais peuvent déclancher un évènement (rencontre, trouvaille ...)	et dans certains cas, on peut passer dessus ou à travers		
_t51 
		.byt $00,$00,$00,$00	; Entrée ville (ex 46)
_t52
		.byt $01,$01,$3e,$3f	; maison avec grand portail, on peut traverser si on a la clef_1	(ex 45)
_t53 
		.byt $01,$01,$3e,$3f	; maison avec grand portail, on peut traverser si on a la clef_2 (ex51)
_t54
		.byt $59,$00,$00,$00	; on trouve la clef_1	(ex 48)
_t55 
		.byt $00,$00,$00,$59	; on trouve la clef_2	(ex 4f)
_t56 
		.byt $00,$00,$00,$00	; un voleur vous détrousse 		(ex 49)
_t57 
		.byt $00,$00,$00,$00	; une Patricienne comprend votre situation et vous done un mot de passe		(ex 4b)
_t58 
		.byt $00,$00,$00,$00	; un garde vous demande le mot de passe		(ex 4d)
_t59 
		.byt $00,$00,$00,$00	; Le legat donne une bourse  (Ex 53)
_t5a 
		.byt $00,$00,$00,$00	; medicus		
_t5b 
		.byt $00,$00,$00,$00	; armurerie
_t5c 
		.byt $00,$00,$00,$00	; herboriste
_t5d 
		.byt $00,$00,$00,$00	; animalerie
_t5e 
		.byt $00,$00,$00,$00	; taberna , auberge
_t5f 
		.byt $6c,$6d,$00,$00	; pont
_t60 
		.byt $00,$00,$6d,$6c	; pont
_t61 
		.byt $6c,$6d,$6d,$6c	; pont
_t62 
		.byt $01,$01,$6f,$6f	; entrée forum
		
; -----------------------------------------------
;       Table des pointeurs adresse tuiles  
; ----------------------------------------------- 	évite d'additionner n fois 4 pour trouver la composition 
;													de la tuile n (rapidité scroll)
ptr_t ;(pointeurs t pour tuiles)	
	
	.byt <_t00,>_t00,<_t01,>_t01,<_t02,>_t02,<_t03,>_t03,<_t04,>_t04,<_t05,>_t05	
	.byt <_t06,>_t06,<_t07,>_t07,<_t08,>_t08,<_t09,>_t09,<_t0a,>_t0a,<_t0b,>_t0b	
	.byt <_t0c,>_t0c,<_t0d,>_t0d,<_t0e,>_t0e,<_t0f,>_t0f,<_t10,>_t10,<_t11,>_t11	
	.byt <_t12,>_t12,<_t13,>_t13,<_t14,>_t14,<_t15,>_t15,<_t16,>_t16,<_t17,>_t17
	.byt <_t18,>_t18,<_t19,>_t19,<_t1a,>_t1a,<_t1b,>_t1b,<_t1c,>_t1c,<_t1d,>_t1d
	.byt <_t1e,>_t1e,<_t1f,>_t1f,<_t20,>_t20,<_t21,>_t21,<_t22,>_t22,<_t23,>_t23
	.byt <_t24,>_t24,<_t25,>_t25,<_t26,>_t26,<_t27,>_t27,<_t28,>_t28,<_t29,>_t29
	.byt <_t2a,>_t2a,<_t2b,>_t2b,<_t2c,>_t2c,<_t2d,>_t2d,<_t2e,>_t2e,<_t2f,>_t2f	
	.byt <_t30,>_t30,<_t31,>_t31,<_t32,>_t32,<_t33,>_t33,<_t34,>_t34,<_t35,>_t35	
	.byt <_t36,>_t36,<_t37,>_t37,<_t38,>_t38,<_t39,>_t39,<_t3a,>_t3a,<_t3b,>_t3b
	.byt <_t3c,>_t3c,<_t3d,>_t3d,<_t3e,>_t3e,<_t3f,>_t3f,<_t40,>_t40,<_t41,>_t41
	.byt <_t42,>_t42,<_t43,>_t43,<_t44,>_t44,<_t45,>_t45,<_t46,>_t46,<_t47,>_t47
	.byt <_t48,>_t48,<_t49,>_t49,<_t4a,>_t4a,<_t4b,>_t4b,<_t4c,>_t4c,<_t4d,>_t4d
	.byt <_t4e,>_t4e,<_t4f,>_t4f,<_t50,>_t50,<_t51,>_t51,<_t52,>_t52,<_t53,>_t53
	.byt <_t54,>_t54,<_t55,>_t55,<_t56,>_t56,<_t57,>_t57,<_t58,>_t58,<_t59,>_t59
	.byt <_t5a,>_t5a,<_t5b,>_t5b,<_t5c,>_t5c,<_t5d,>_t5d,<_t5e,>_t5e,<_t5f,>_t5f
	.byt <_t60,>_t60,<_t61,>_t61,<_t62,>_t62	

; -----------------------------------------------------------------------------
;    Table adresses car modifiés dans 2nd jeu de car mode Hires (1/4 de tuile)
; ----------------------------------------------------------------------------- 
	   
sous_tuile
	.byt $9d,$00,$9d,$06,$9d,$0c,$9d,$12,$9d,$18,$9d,$1e,$9d,$24,$9d,$2a,$9d,$30,$9d,$36
	.byt $9d,$3c,$9d,$42,$9d,$48,$9d,$4e,$9d,$54,$9d,$5a,$9d,$60,$9d,$66,$9d,$6c,$9d,$72
	.byt $9d,$78,$9d,$7e,$9d,$84,$9d,$8a,$9d,$90,$9d,$96,$9d,$9c,$9d,$a2,$9d,$a8,$9d,$ae
	.byt $9d,$b4,$9d,$ba,$9d,$c0,$9d,$c6,$9d,$cc,$9d,$d2,$9d,$d8,$9d,$de,$9d,$e4,$9d,$ea
	.byt $9d,$f0,$9d,$f6,$9d,$fc,$9e,$02,$9e,$08,$9e,$0e,$9e,$14,$9e,$1a,$9e,$20,$9e,$26	
	.byt $9e,$2c,$9e,$32,$9e,$38,$9e,$3e,$9e,$44,$9e,$4a,$9e,$50,$9e,$56,$9e,$5c,$9e,$62
	.byt $9e,$68,$9e,$6e,$9e,$74,$9e,$7a,$9e,$80,$9e,$86,$9e,$8c,$9e,$92,$9e,$98,$9e,$9e
	.byt $9e,$a4,$9e,$aa,$9e,$b0,$9e,$b6,$9e,$bc,$9e,$c2,$9e,$c8,$9e,$ce,$9e,$d4,$9e,$da
	.byt $9e,$e0,$9e,$e6,$9e,$ec,$9e,$f2,$9e,$f8,$9e,$fe,$9f,$04,$9f,$0a,$9f,$10,$9f,$16
	.byt $9f,$1c,$9f,$22,$9f,$28,$9f,$2e,$9f,$34,$9f,$3a,$9f,$40,$9f,$46,$9f,$4c,$9f,$52
	.byt $9f,$58,$9f,$5e,$9f,$64,$9f,$6a,$9f,$70,$9f,$76,$9f,$7c,$9f,$82,$9f,$88,$9f,$8e,$9f,$94
	.byt $9f,$9a,$9f,$a0,$9f,$a6,$9f,$ac,$9f,$b2,$9f,$b8,$9f,$be,$9f,$c4,$9f,$ca,$9f,$d0
	.byt $9f,$d6,$9f,$dc,$9f,$e2,$9f,$e8,$9f,$ee,$9f,$f4	
	
	
; -----------------------------------------------------------------------------
;                   proposition de textes pour tuiles spéciales
; -----------------------------------------------------------------------------

t_portail_1
	.byt $97
	.asc "You've got the right key",0
t_portail_2	
	.byt $c4 
	.asc "You can cross.",0
t_portail_3
	.byt $95
	.asc "You don't have the right key.",0	

	
t_key_1
	.byt $9b
	.asc "You've found a key.",0 ;(key_1)
t_key_2	
	.byt $c1	
	.asc "Now all you have to do",0
t_key_3	
	.byt $98	
	.asc "is find the right door.",0
	
	
t_voleur_1
	.byt $9a
	.asc "A pickpocket skillfully;",0
t_voleur_2	
	.byt $c2	
	.asc "steals from Carpophorus.",0
	
t_m_de_passe_1
	.byt $98
	.asc "a friend of Kaeso warns you:",0
t_m_de_passe_2	
	.byt $be	
	.asc "'Caius Antoninus is in Lutecia.'",0
t_m_de_passe_3
	.byt $93
	.asc "'He stays in Legat's house and want",0
t_m_de_passe_4	
	.byt $bc	
	.asc "to see you. Password is Veni vidi.'",0	

t_garde_1
	.byt $96
	.asc "A guard is asking for password.",0
t_garde_2
	.byt $98
	.asc "Your password is correct",0
t_garde_3
	.byt $c2
	.asc "the guard lets you in.",0	

t_caius_1
	.byt $97
	.asc "Finally! I've been waiting",0
t_caius_2
	.byt $bf	
	.asc "for you for days! Take this",0
t_caius_3
	.byt $97	
	.asc "safe-conduct pass; it will",0
t_caius_4	
	.byt $bd	
	.asc"be useful to you in Gesoriacum.",0	
	
t_entrance_1
	.byt $9a	
	.asc "The entrance to the city,",0
t_entrance_2	
	.byt $c4	
	.asc "do you want to leave?",0
t_do_you_1
	.byt $c8	
	.asc "do you enter?",0	
t_medicus_1
	.byt $a3	
	.asc "MEDICUS",0
t_armurerie_1
	.byt $a0	
	.asc "FABER ARMORUM",0	
t_herboriste_1
	.byt $a2	
	.asc "HERBARIUS",0		
t_animalerie_1
	.byt $9f	
	.asc "OMNIA ANIMALIA",0	
t_taberna_1
	.byt $a3	
	.asc "TABERNA",0	
		