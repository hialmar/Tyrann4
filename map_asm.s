#define FALSE 	0
#define TRUE 	1

#define CENTRE_ORDO 3
#define CENTRE_ABS  8

#define LARGEUR_FENETRE 	$0f
#define HAUTEUR_FENETRE		$07

#define YELLOW_INK 	3
#define CYAN_INK 	6

#define BLACK_PAPER $10

	.zero

	*= $a0
; *********** VARIABLES PAGE ZERO  ***********
;
;	$00	:	repère 1/4 haut gauche tuile en cours
tuile_en_cours_coin_hg	.dsb 1
;	$01	:	repère 1/4 haut droit tuile en cours
tuile_en_cours_coin_hd	.dsb 1
;	$02	:	repère 1/4 bas gauche tuile en cours
tuile_en_cours_coin_bg	.dsb 1
;	$03	:	repère 1/4 bas droit tuile en cours
tuile_en_cours_coin_bd	.dsb 1
;	$04	:	n° tuile personnage affichée (pour animation droite gauche avant, bateau..)
tuile_perso_aff .dsb 1
;Deux oordonnées coin haut gauche partie table affichée	dans fenêtre
;	$05	:	N° ligne data MAp en haut gauche fenêtre,Mémorisée tant que pas de scroll
ligne_hg_map .dsb 1
;	$06	:	Rang dans la ligne Data Map en haut gauche fenêtre, Mémorisée tant que pas de scroll
rang_hg_map .dsb 1
;Deux coordonnées variables dans table DataMap utilisées lors de l'affichage d'une fenêtre
;	$07	:	N° ligne data MAp
ligne_map .dsb 1
;	$08	:	Rang dans la ligne Data Map
rang_map .dsb 1
;	$09	:	Rang tuile dans fenêtre, utilisé comme index de la table d'adresses écran de la fanêtre ( de 0 a $69)
rang_fenetre .dsb 1
;	$0A	:	N° identifiant quelle tuile en cours d'affichage
tuile_courante .dsb 1
;	$0B	:	Direction scroll précedente( #$AC,$B4,$9C,$BC)
direction_scroll_prec .dsb 1
;	$0C	:	Direction scroll demandée( #$AC,$B4,$9C,$BC)
direction_scroll .dsb 1
;	$0D	:	Drapeau 1 si on a un bateau , 0 si pas de bateau
a_un_bateau .dsb 1
;	$0E	:	valeur tuile position perso (attention, ce N'EST PAS la valeur de la tuile qui represente le perso)
tuile_sous_pos_perso .dsb 1
;	$0F	:	ordonnée perso dans fenêtre Hires (varie de 1 à 7 , valeur initiale : 3)
ordo_perso_fen .dsb 1
;	$10	:	abscisse perso dans fenêtre Hires (varie de 1 à 15 , valeur initiale :7)
absc_perso_fen .dsb 1
;	$11	:	drapeau déplacer perso horizontalement dans fenêtre hires : 0 non 1 oui
peut_bouger_horiz .dsb 1
;	$12	:	Valeur variable index position perso dans table d'adresses ecran ( $00 à $69)
index_perso .dsb 1
;	$13	:	drapeau déplacer perso verticalement dans fenêtre hires : 0 non 1 oui
peut_bouger_vert .dsb 1
;	$14	:	drapeau : 1 on est en mer, 0 on est à terre
est_en_mer .dsb 1
;	$15	:	drapeau : 1 texte affiché , 0, pas de texte affiché
est_affiche_texte .dsb 1
;	$16	:	drapeau : 1 scroll interdit , 0, scroll autorisé
scroll_est_interdit .dsb 1
;	$17	:	drapeau : 1 deplacement perso  interdit , 0, déplacement perso autorisé
depl_perso_est_interdit .dsb 1
;	$18	:	drapeau : on a clef_1
;	$19	: 	drapeau : on a clef_2
;	$1a	:	drapeau : on a mot de passe :1
mot_de_passe .dsb 1
;	$1b :	drapeau : on a laissez-passer :1 on n'a pas laissez-passer : 0
laisser_passer .dsb 1
;	$1c :	N° lieu (GALLIA :0 HISPANIA :1 LUSITANIA :2 BRITANIA:3 GERMANIA :4 CALEDONIA:5 HIBERNIA :6 MARE NOSTRUM: 7 MARE EXTERNUM 8 MARE GERMANICUM 9
numero_lieu .dsb 1

;   $50 : drapeau sortie victorieuse de la carte = $80 sinon = $20
sortie_victorieuse .dsb 1 ; drapeau sortie victorieuse de la carte = $80 sinon = $20
;
;

;;; STOP : 27 octets utilisés en page 0

	.text

_main
.(
	jsr SaveZeroPage
	lda #4					; début de répétition touche après 4*30 = 120 ms
	sta $24E
	lda #1					; répétition d'une touche toutes les 30 ms
	sta $24F
	jsr hires_et_atributs	; spécifique à ce test passe en HIRES et installe 84 atributs de couleur (hauteur tuile)
	jsr impl_car			; Implante jeu de caractères redéfinis
	lda #10					; cache le curseur et vire le son des touches
	sta $26A
	jsr init_div_var		; initialise diverses variables dont coordonnées coin haut gauche de la  partie table affichée.
							; mais pas que...
	jsr bandeau				; dessine image au dessus du plan
main_loop
	; sei
	jsr scrl_fenetre		; Affiche/ scrolle les 105 tuiles dans la fenetre
	jsr prt_nom_lieu		; affiche lieu géographique (pays, mer...)
	jsr aff_hero			; affiche le hero au centre ... PROVISOIRE
	jsr	aff_text
	; cli

	ldy depl_perso_est_interdit
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
	; sei
	lda direction_scroll
	cmp#$86					; Y pour sortir
	beq sortie_main
	jsr wait_key			; scanne les 4 touches flèchées pour scroll
	jsr chck_around			; regarde valeur tuile sous et autour perso	pour validation (ou non) scroll
	jsr chck_bords			; regarde si un bord de la carte est à un bord de la fenêtre
	jsr chck_mvt_perso_fenetre
	;	jsr $fb2a				;son clavier contrôle
	jsr	eff_text
	; cli
	jmp main_loop
sortie_main
	lda #3					; ré-affiche le curseur et remet le son des touches
	sta $26A
	lda #32					; remet la répétition des touches normale
	sta $24E
	lda #4
	sta $24F
	jsr $ec21               ; back to text mode

    lda #$4c
	sta mot_de_passe
	lda #$b0
	sta laisser_passer
	lda #$cc
	sta numero_lieu
;	jsr $ec21

	jsr _get
	jsr RestoreZeroPage
	; test bascule combat
	ldy #$0         ; grab string pointer
	lda #<ProgCombat
	sta (sp),y
	iny
	lda #>ProgCombat
	sta (sp),y
	dey
	jsr _SwitchToCommand

	; rts						; sortie provisoire, rend la main au BASIC pour charger la FAKE ville et sortie
							; pour re-rentrer : CALL #2000
.)

ProgCombat
	.asc "COMBAT.COM"
	.byt 0

ZeroPageCopy
	.dsb $ff

SaveZeroPage
.(
    ldy #0
loop
    lda $00,y
    sta ZeroPageCopy,y
    iny
    bne loop
	rts
.)

RestoreZeroPage
.(
    ldy #0
loop
    lda ZeroPageCopy,y
	sta $00,y
    iny
    bne loop
	rts
.)

;-------------------------
;--- affiche hero   ------
;-------------------------
aff_hero
.(
	lda direction_scroll				; direction demandée
	cmp #$38			; a-t-on frappé une touche autre qu'une des 4 flêches
	beq fin_aff_perso
	lda scroll_est_interdit
	beq check_mer
	lda depl_perso_est_interdit
	bne fin_aff_perso
check_mer
	lda tuile_sous_pos_perso
	bne mer_01
	jsr choix_perso
	bne skip_anim
mer_01
	lda tuile_sous_pos_perso
	cmp #1
	bne chck_direction
	jsr choix_perso
	bne skip_anim
chck_direction	
	lda direction_scroll
	cmp direction_scroll_prec				; direction précédente
	beq anim_perso		; si identique animation perso
	sta direction_scroll_prec				; si non nouvelle direction
ratrappe_si_mer	
	jsr choix_perso		; et choix nouveau perso
	beq skip_anim		; saut inconditionnel
anim_perso
	lda est_en_mer
	bne ratrappe_si_mer	;retro action si en mer avant
	lda tuile_perso_aff				; $04 contient n° tuile perso affichée
	eor #1				; force le bit 0 alternativement à  0 ou à 1
	sta tuile_perso_aff				; et replace en  $04
skip_anim
	lda direction_scroll
	sta direction_scroll_prec
	ldx index_perso				; 
	jsr maj_adr_scr_next_tuile			; en entrée x contient rang tuile dans  table adresses Hires
	ldx  tuile_perso_aff
	jsr cherche_et_aff_tuile			; en entrée : X contient la reference de la tuile
fin_aff_perso
;	lda #FALSE
;	sta depl_perso_est_interdit	
	rts
.)	

;------ Choix tuile perso en fonction direction demandée   -----
choix_perso
.(
		lda tuile_sous_pos_perso
		beq mer_bateau
		cmp #TRUE
		beq mer_bateau
		lda #FALSE
		sta est_en_mer					; drapeau  à 0 : on n'est pas en mer
		lda direction_scroll
		cmp #$9c
		beq vers_haut			; Si flêche vers le haut
		cmp #$b4
		beq vers_haut			; Si flêche vers le bas, mème pesro (vue de face)
		cmp #$ac
		beq vers_droite			; si flêche gauche perso regarde à gauche
		cmp #$bc
		beq vers_gauche			; si flêche droite, perso regarde vers droite
		bne fin_ch_perso		; Saut incontionnel
vers_haut
		lda #$4c
		bne fin_ch_perso		; Saut incontionnel
vers_droite
		lda #$48				; n° tuile perso regarde à gauche
		bne fin_ch_perso		; Saut incontionnel
vers_gauche
		lda #$4a				; n° tuile perso regarde à droite
fin_ch_perso
		sta tuile_perso_aff					; mémoire tuile perso affichée
		rts
mer_bateau
		lda #TRUE
		sta est_en_mer					; drapeau à 1: on est en mer
		lda #$47
		sta tuile_perso_aff
		rts
.)	

; -----------------------------------------------------------------------
; ----------  routine regarde autour du perso  pour détection mer  ------	
; -----------------------------------------------------------------------	
; en entrée :	
; en sortie : 	tuile_sous_pos_perso contient valeur tuile sous perso
;				direction_scroll contient #$38 si scroll impossible (perso en bord de carte ou en bord de mer (si a terre)

chck_around
.(
; d'abord on regarde si une touche flêchée a été pressée sinon direction_scroll contient #$38
		lda direction_scroll
		cmp #$38
		beq sortie_scroll_direct		; inutile de regarder si autre touche que flêchée
; Ensuite on regarde si on est déjà en mer auquel cas, pas de contrainte de bord de mer
;
;		lda tuile_sous_pos_perso					; valeur tuile à la position du perso initialisée à #$50 (tuile NEMAUSUS)
;		beq around_sortie ; sortie_scroll_direct		; si on est en mer, pas de contrainte de proximité
;		cmp #$01
;		beq around_sortie ; sortie_scroll_direct		; deux valeurs de tuiles pour la mer : $00 et $01

; puis déterminons la position perso dans la carte
		lda ordo_perso_fen					; ordonnée perso dans fenête hires
		clc
		adc ligne_hg_map					; N° ligne ds table DataMAP en haut gauche fenêtre
		sta ligne_map
		lda absc_perso_fen					; abscisse perso dans fenètre Hires
		clc
		adc rang_hg_map					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
		sta rang_map
		
; que nous utilisons ensuite pour regarder autour du perso
sens_1
		lda direction_scroll					; mémoire touche pressée
		cmp #$ac				; recherche contenu tuile à gauche
		bne sens_2
		lda rang_map			; rang_map contient rang perso dans ligne map
		beq no_scroll			; le perso etait en bord gauche
		dec rang_map			; supprimer si retour
		bmi no_scroll			; le perso était en bord gauche map
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda tuile_courante
		beq check_ville_bateau	; si bord de mer à gauche, est-on dans ville portuaire		
		bne around_sortie		; saut inconditionnel			
sens_2
		cmp #$bc				; recherche contenu tuile à droite
		bne sens_3
		lda rang_map
		cmp #$1f				; rang tuile en bord droit de map
		beq no_scroll			; si perso en bord droit, pas de scroll
		inc rang_map					; si non, on regarde ce qu'il y a à droite
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq check_ville_bateau			
		bne around_sortie			
sens_3
		cmp #$9c				; recherche contenu tuile au dessus
		bne sens_4
		lda ligne_map
		beq no_scroll
		dec ligne_map			; a supprimer si retour
		bmi no_scroll
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq check_ville_bateau			
		bne around_sortie			
sens_4
		cmp #$b4				; recherche contenu tuile en dessous
		bne around_sortie
		lda ligne_map
		cmp #$30
		beq no_scroll
		inc ligne_map
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq check_ville_bateau		
around_sortie
		lda #FALSE
		sta scroll_est_interdit				; ré-autorise scroll (pour une boucle dans la direction demandée)
		sta depl_perso_est_interdit				; ré-autorise mvt perso (pour une boucle dans la direction demandée)
sortie_scroll_direct		
		rts
check_ville_bateau		
		lda tuile_sous_pos_perso				; valeur tuile à la position du perso
		beq around_sortie
		cmp #TRUE
		beq around_sortie
		cmp #$5e			; villes portuaires codées entre #$5e et #$63
		bmi ret_7_8 ; no_scroll		; si pas port
		lda a_un_bateau				; si port check bateau
		beq no_scroll		; si pas bateau
		bne around_sortie 	; Saut inconditionnel
ret_7_8
		lda direction_scroll
		cmp #$ac
		bne chk_bc
		inc rang_map
chk_bc
		cmp #$bc
		bne chk_9c
		dec rang_map
chk_9c
		cmp #$9c
		bne chk_b4
		inc ligne_map
chk_b4
		cmp #$b4
		bne no_scroll
		dec ligne_map
no_scroll		
		lda #TRUE			
		sta scroll_est_interdit				;mets à 1 drapeau scroll interdit (pour une boucle, dans la direction demandée)
		sta depl_perso_est_interdit				;mets à 1 drapeau mvt perso  interdit (pour une boucle, dans la direction demandée)
		rts 
.)	

; -------------------------------------------------------------------------
; ----------  routine teste si bords de carte en bord de fenêtre ----------	
; -----           et si le perso est au centre de la fenêtre         ------
; -------------------------------------------------------------------------
chck_bords
.(
; en entrée :	direction_scroll contient #38 si pas de touches flêchée pressée
;				direction_scroll contient valeur touche fléchée pressée sinon
; en sortie :	idem 	
		lda scroll_est_interdit						; si scroll déjà interdit par bord de mer
		bne sort_direct	
		lda direction_scroll
		cmp #$38				 	; si 38, pas touche fléchée enfoncée
		beq sort_direct
;vers droite
		cmp #$BC					; touche flèche droite ==> tuile suivante
		bne autre_touche_1
		lda rang_hg_map
		cmp #$10					; au départ rang_hg_map = #$10 (rang tuile au bord gauche fénêtre) on ne peut atteindre la tuile suivante 
									; car le bord droit du plan est au bord droit de la fenêtre (largeur plan :#$10+#$0F = #$1f tuiles)
		beq end_chck_bords_nsc		; dans ce cas, scroll horizontal interdit il faut checker déplacement horizontal perso dans fenêtre
		lda absc_perso_fen						; rang (abscisse) perso dans fenètre
		cmp #CENTRE_ABS					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre		
		inc rang_hg_map						; Maj rang tuile DataMAP en bord gauche de fenêtre
		bne end_chck_bords			; saut inconditionnel
autre_touche_1			
		cmp #$AC					; touche flèche gauche ==> tuile précedente
		bne autre_touche_2
		lda rang_hg_map
		bmi end_chck_bords_nsc   	;
		lda absc_perso_fen						; rang (abscisse) perso dans fenètre
		cmp #CENTRE_ABS					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre
		dec rang_hg_map
		bpl end_chck_bords	
autre_touche_2
		cmp #$B4					; touche flèche BAS ==> tuile ligne de dessous		
		bne autre_touche_3						
		lda ligne_hg_map
		cmp #$2A
		beq end_chck_bords_nsc
		lda ordo_perso_fen						; hauteur (ordonnée) perso dans fenètre
		cmp #CENTRE_ORDO					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre		
		inc ligne_hg_map
		bne end_chck_bords	
autre_touche_3
		cmp #$9C				; touche flèche haut ==> tuile ligne de dessus		
		bne end_chck_bords						
		lda ligne_hg_map
		beq end_chck_bords_nsc
		lda ordo_perso_fen						; hauteur (ordonnée) perso dans fenètre
		cmp #CENTRE_ORDO					; si perso pas au centre
		bne end_chck_bords_nsc		; pas de scroll fenètre			
		dec ligne_hg_map
end_chck_bords
		lda #FALSE
		sta scroll_est_interdit					; ré-autorise scroll (pour une boucle, dans la direction demandée)
		lda #TRUE
		sta depl_perso_est_interdit					; interdit deplacement perso (pour une boucle, dans la direstion demandée)
		rts
end_chck_bords_nsc
		lda #TRUE
		sta scroll_est_interdit					; interdit scroll (pour une boucle, dans la direstion demandée)
;		lda #FALSE
;		sta depl_perso_est_interdit					; autorise deplacement perso (pour une boucle, dans la direstion demandée)
;		lda #$38				; pour simuler aucune touche enfoncée donc interdire scroll carte
;		sta direction_scroll
sort_direct		
		rts
.)	

; ---------------------------------------------------------------------------------------------
; ---------   routine chck si deplacement perso possible (bord de carte )   ----------	
; ---------------------------------------------------------------------------------------------
		
chck_mvt_perso_fenetre
.(
		lda scroll_est_interdit
		beq sortie_perso			; si scrolling autorisé ==> deplacement perso ok
		lda depl_perso_est_interdit
		bne sortie_perso			; si déplacement déjà interdit par bord de de mer => on ne traite pas deplacement perso
		
; on commence par afficher la tuile dont n° est sous le perso
		ldx index_perso						; contient le n° de tuile sous le perso
		jsr maj_adr_scr_next_tuile	; en entrée x contient rang tuile dans  table adresses Hires
		ldx tuile_sous_pos_perso
		jsr cherche_et_aff_tuile	; en entrée : X contient la reference de la tuile
; puis on checke le bord de la fenêtre hires et on modifie le contenu de index_perso en fonction de la direction demandée

		lda direction_scroll
		cmp #$38 
		beq sortie_perso			; pas de touche fléchée pressée  => on ne traite pas deplacement perso		

deplc_gauche
		cmp #$ac					; touche flèche gauche ==> deplacement vers la gauche
		bne deplac_droite
		lda absc_perso_fen
		cmp#$01
		beq no_depl
		dec absc_perso_fen
		dec index_perso
		jmp out_depl_perso
deplac_droite
		cmp #$bc					; touche flèche droite ==> deplacement vers la droite
		bne deplac_bas		
		lda absc_perso_fen
		cmp #LARGEUR_FENETRE   ;cmp #15
		beq no_depl
		inc absc_perso_fen
		inc index_perso
		jmp out_depl_perso
deplac_bas		
		cmp #$b4				; touche flèche bas ==> deplacement vers le bas
		bne deplac_haut				
		lda ordo_perso_fen
		cmp #$06   ;cmp #$07
		beq no_depl
		inc ordo_perso_fen
		lda index_perso
		clc
		adc #LARGEUR_FENETRE
		sta index_perso
		jmp out_depl_perso
deplac_haut
		cmp #$9c				; touche flèche haut ==> deplacement vers le haut
		bne sortie_perso	
		lda ordo_perso_fen
		beq no_depl
		dec ordo_perso_fen
		lda index_perso
		sec
		sbc #LARGEUR_FENETRE
		sta index_perso		
out_depl_perso
; détermination n° tuile à la position perso
		lda ordo_perso_fen					; ordonnée perso dans fenête hires
		clc
		adc ligne_hg_map					; N° ligne ds table DataMAP en haut gauche fenêtre
		sta ligne_map
		lda absc_perso_fen					; abscisse perso dans fenètre Hires
		clc
		adc rang_hg_map					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
		sta rang_map
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		sta tuile_sous_pos_perso					; repère tuile dans tuile_sous_pos_perso	
;		lda #FALSE
;		sta depl_perso_est_interdit
		rts
no_depl
		lda #TRUE				; deplacement interdit
		sta depl_perso_est_interdit
sortie_perso		
		rts
.)	

;********************************************************************************
;***                  routine  affiche 15 x 7 tuiles dans la                  ***
;***       fenêtre de l'écran HIRES définie par la table tab_adr_hires        *** 
;***              apres recherche dans la table DATA PLAN T4                  ***
;********************************************************************************
;en entrée : 	position coin fenetre dans la ligne des DATA MAP stockée dans rang_hg_map
;				n°ligne DATA MAP stocké dans ligne_hg_map
;En sortie :	Les tuiles sont affichées dans la fenetre Hires

scrl_fenetre
.(
	lda scroll_est_interdit				; drapeau scroll (autorisé : 0 , interdit : 1)
	bne sortie_fenetre	; scroll interdit par bord de mer ou bord de carte
	lda direction_scroll
	cmp #$38
	beq sortie_fenetre	; aucune touche fléchées pressée
	lda ligne_hg_map
	sta ligne_map				; n° ligne datamap (variable)
	lda rang_hg_map
	sta rang_map				; position dans ligne des datamap
	lda #$ff			; initialise  à $ff la
	sta rang_fenetre				; Mémoire de rang  de la tuile ds fenetre ( $00 à $69 soit 7 x$0f tuiles)
	ldy #0
lp_L7
	ldx #0			; index nombre de colonnes de tuiles à afficher (15) 
lp_C15
	inc rang_map				; position ds la ligne des DATAMAP (première valeur : 0)
	inc rang_fenetre				; Position dans la liste des adresses hires de la fenetre (première valeur : 0)
	inx					; (première valeur : x=1) puis colonne suivante
	jsr rech_tab_map	; en sortie tuile_courante contient la reference de la tuile à afficher	
	cpx #$10			; on affiche 15 tuile par ligne
	beq autre_ligne
	txa 
	pha					;empile le rang de la tuile dans la ligne à afficher
	ldx rang_fenetre
	jsr maj_adr_scr_next_tuile	; en entrée x contient rang tuile dans  table adresses Hires
	ldx tuile_courante	;ldx rang_map
	jsr cherche_et_aff_tuile	; en entrée : X contient la reference de la tuile
	pla
	tax
	bne lp_C15
autre_ligne
	dec rang_fenetre
	lda rang_hg_map
	sta rang_map	
	inc ligne_map
	iny
	cpy #HAUTEUR_FENETRE
;	beq sortie_fenetre
	bne lp_L7

; détermination n° tuile à la position perso
	lda ordo_perso_fen					; ordonnée perso dans fenête hires
	clc
	adc ligne_hg_map					; N° ligne ds table DataMAP en haut gauche fenêtre
	sta ligne_map
	lda absc_perso_fen					; abscisse perso dans fenètre Hires
	clc
	adc rang_hg_map					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
	sta rang_map
	jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
	lda tuile_courante
	sta tuile_sous_pos_perso					; repère tuile dans tuile_sous_pos_perso	
	
sortie_fenetre
	; lda #FALSE
	; sta scroll_est_interdit					; autorise scroll pour prochaine boucle, jusqu'aux différents checks
	rts	
.)	

;-----------------------------------------------------------------------------
; -----                initialise divers variables dont:                   ---
;	             coordonnées coin haut gauche partie table affichée      -----
;                     tuile perso affichée / index position perso
;-----------------------------------------------------------------------------		
init_div_var
.(
	lda #$1B		; coordonnées pour avoir Némausus au centre fénêtre (départ jeu)
	sta ligne_hg_map			; N° de ligne fixe tant que pas de scroll
	lda #$10
	sta rang_hg_map			; rang ds ligne fixe tant que pas de scroll
	lda #$4C
	sta tuile_perso_aff			; code tuile perso affichée
	lda #$34
	sta index_perso			; valeur index perso dans table adresses hires fenêtre
	lda #$9C
	sta direction_scroll			;  valeurs => ddirection scroll demandée
	lda #CENTRE_ORDO
	sta ordo_perso_fen			; Abscisse perso dans fenêtre Hires
	lda #CENTRE_ABS
	sta absc_perso_fen			; Ordonnée perso dans fenêtre Hires
	lda #$55		; repère tuile Nemausus
	sta tuile_sous_pos_perso			; sous position perso au départ
	lda #FALSE
	sta peut_bouger_horiz			; drapeau deplacement horizontal perso dans fenêtre : 0 => pas de déplacement
	sta peut_bouger_vert			; drapeau deplacement vertical  perso dans fenêtre : 0 => pas de déplacement
	sta a_un_bateau			; drapeau bateau : 1 on a un bateau / 0 pas de bateau
	sta est_affiche_texte			; drapeau nom ville à l'écran 	1 : nom à l'ecran , 0 rien
	sta scroll_est_interdit			; drapeau scroll autorisé/interdit 	1 : interdit , 0 autorisé
	sta depl_perso_est_interdit			; drapeau déplacement perso autorisé/interdit 	1 : interdit , 0 autorisé
	lda #TRUE	        ; TEMPO
	sta a_un_bateau			; drapeau bateau : 1 on a un bateau / 0 pas de bateau
	sta numero_lieu         ; indique lieu <> Gallia (0)
	lda #$20
	sta sortie_victorieuse ; drapeau sortie victorieuse de la carte = $80 sinon = $20
	rts
.)	

;----------------------------------------------------------
;---   cherche n° de tuile en position X,Y dans carte   ---
;----------------------------------------------------------
;en entrée : 	position dans la ligne stockée dans rang_map,
;				n°ligne stocké dans ligne_map
; en sortie : 	Le numéro de tuile est dans tuile_courante

rech_tab_map
.(
		txa
		pha
		tya
		pha
		ldx ligne_map				; X contient le n° de ligne DataMap(en partant de 0)
		ldy rang_map				; y contient la position dans la ligne DataMap
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
		sta tuile_courante
		pla
		tay
		pla 
		tax
		rts			
.)

;-----------------------------------------------------------
;---- Affiche une tuile dans la fenêtre de l'écran HIRES ---
;-----------------------------------------------------------
cherche_et_aff_tuile
.(
; en entrée : X contient le n° de tuile
; En sortie : La tuile est à l'écran
		tya
		pha
		jsr find_compsants
		jsr aff__tuile			; côte à côte pour minimiser le Nn d'addition (adrsses écran)
		pla
		tay
		rts
.)	

;----------------------------------------------------------
;---            cherche  4 composants tuile             ---
;----------------------------------------------------------
; en entrée : X contient le n° de tuile
; en sortie : les 4 n° de sous tuiles sont stockées en tuile_en_cours_coin_hg=$00,tuile_en_cours_coin_hg=$01,tuile_en_cours_coin_bg=$02,tuile_en_cours_coin_bd=$03 

find_compsants
.(
			txa
			asl					;vers table DATA PLAN T4
			tax					;
			lda ptr_t,x			;Partie basse adresse composants
			sta adr_compo+1
			inx
			lda ptr_t,x			;partie haute adresse composants
			sta adr_compo+2
			ldx #3
adr_compo	
			lda $1111,x
			sta tuile_en_cours_coin_hg,x			; **** bien sûr, tu peux choisir un autre emplacement page 0  que  $00,01,02,03...
			dex
			bpl adr_compo
			rts	
.)

;--------------------------------------------------
;---               affiche _tuile              ---- 
;--------------------------------------------------	
aff__tuile
.(
			lda index_perso
			cmp rang_fenetre					; n'affiche pas la tuile si c'est celle qui est sous le perso
			beq chck_68; beq pas_daff
aff_t
			ldx #0				; 0 pour indexer le premier 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères supérieurs (dont n° d'ordre stocké en $00 et $01)
			ldx #2				; 2 pour indexer le 3 ème 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères inférieurs (dont n° d'ordre stocké en $02 et $03)
pas_daff			
			rts
chck_68
			cmp #$68
			beq aff_t
			bne pas_daff
.)	

;----------------------------------------------------
;--- maj adresses écran HIRES  dans aff_2_sextets----
;----------------------------------------------------
;en entrée:			x contient rang tuile dans  table adresses Hires
;en sortie:			les 2 adresses hires tuile en cours, renseignées dans routine aff_2_sextets
maj_adr_scr_next_tuile
.(
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
.)	

;--------------------------------------------------
;---               affiche demie tuile               
;--------------------------------------------------	
aff_demi_t	
.(
				jsr rens_adr_car		; n° car issus de $00 et $01
				ldy #0
lp_2_sextets	
				jsr aff_2_sextets		; 2 jeux de 6 octets  (partie haute tuile)
				jsr maj_scr_hires
				iny
				cpy #$06
				bne lp_2_sextets		
				rts	
.)	

;----------------------------------------------------------
;----           affiche deux sextets côte à côte      ----- 
;----------------------------------------------------------	
;pour faire seulement 10 additions par tuile  (2 x 5) au lieu de 20 (4 x 5)

aff_2_sextets	
.(
+adr_car_1	
					lda 1111,y
+adr_screen_1	
					sta $1111
+adr_car_2	
					lda 2222,y
+adr_screen_2	
					sta $2222	
					rts
.)
				
;-------------------------------------------------
;--- MàJ adresses écran HIRES  dans une tuile ----
;-------------------------------------------------
maj_scr_hires
.(
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
.)					
				
				
				
;------------------------------------------------------
;---     renseigne adresses caractères  tuile      ----
;------------------------------------------------------	
; En entrée : 	X contient l'index sur n° d'ordre (1,2,3 ou4) du 1/4 de tuile 
; 				(0,ou 2 car incrémenté dans cette routine pour les 1 et 3)
; en sortie : 	adr_car_1 et adr_car_2 de la routine aff_2_sextets sont renséignées
rens_adr_car
.(
				txa					
				pha					; sauve le n° d'ordre du 1/4 de tuile haut gauche si X=0 bas gauche si x=2
				lda tuile_en_cours_coin_hg,x			; n° premier car stocké en $00
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
				lda tuile_en_cours_coin_hg,x			; n° deuxième car stocké en $01
				asl					; vers table adresse car  1/4 tuiles
				tax					;
				lda sous_tuile,x		; Partie haute adresse caractère
				sta adr_car_2+2
				inx
				lda sous_tuile,x	; partie basse adresse caractère
				sta adr_car_2+1
				rts
.)	

		
;------------------------------------------------------		
; -----  routine attend appui touche puis relacher ---
;------------------------------------------------------ spécifique pour mon test
wait_key
.(
;		lda direction_scroll			;pour test
;		cmp #$86		;sortie victorieuse
;		beq end_key		;sur ecran 'Episode II' (sera a supprimer)
;
;		lda $208
;		cmp #$38
;		beq wait_key
;		cmp #$ac
;		bne next_key_1
;		beq end_key
;next_key_1
;		cmp #$bc
;		bne next_key_2
;		beq end_key
;next_key_2
;		cmp #$9c
;		bne next_key_3
;		beq end_key
;next_key_3
;		cmp #$b4
;		bne next_key_4
;		beq end_key
;next_key_4
;		cmp #$86
;		bne no_key
;		beq end_key
;no_key
;		lda #$38
;end_key
;		sta direction_scroll
;		rts


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
;		bne next_key_4
		bne wait_key
		beq end_key
;next_key_4
;		cmp #$86
;		bne no_key
;		beq end_key
;no_key
;		lda #$38
end_key
		sta direction_scroll
		rts
.)			
		
;************************************************
;***   implantation caractères redéfinis      ***
;************************************************ 	peut être lancé séparément pour ne charger dans le jeu
;													que la zone des caractères  une fois rédéfinie
impl_car
.(
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
	cpx #$5a
	bne lp2_impl	
	rts
.)	

;---------------------------------------------------------------------
;- passe en mode HIRES et installe 12 atributs couleur jaune et cyan -
;---------------------------------------------------------------------	 routine spécifique l'emplacement choisie de la fenêtre
hires_et_atributs	
.(
		jsr $EC33
		lda #YELLOW_INK
		sta $Aa01
		sta $Aa51
		sta $AaA1
		sta $AaF1	
		sta $Ab41
		sta $Ab91
		lda #CYAN_INK
		sta $Aa29
		sta $Aa79
		sta $Aac9
		sta $Ab19
		sta $Ab69
		sta $Abb9
		
		lda #YELLOW_INK
		sta $Abe1
		sta $Ac31
		sta $Ac81
		sta $Acd1	
		sta $Ad21
		sta $Ad71
		lda #CYAN_INK
		sta $Ac09
		sta $Ac59
		sta $Aca9
		sta $Acf9
		sta $Ad49
		sta $Ad99		
		
		lda #YELLOW_INK
		sta $Adc1
		sta $Ae11
		sta $Ae61
		sta $Aeb1	
		sta $Af01
		sta $Af51
		lda #CYAN_INK
		sta $Ade9
		sta $Ae39
		sta $Ae89
		sta $Aed9
		sta $Af29
		sta $Af79		
		
		lda #YELLOW_INK
		sta $Afa1
		sta $Aff1
		sta $b041
		sta $b091	
		sta $b0e1
		sta $b131
		lda #CYAN_INK
		sta $Afc9
		sta $b019
		sta $b069
		sta $b0b9
		sta $b109
		sta $b159		
		
		lda #YELLOW_INK
		sta $b181
		sta $b1d1
		sta $b221
		sta $b271	
		sta $b2c1
		sta $b311
		lda #CYAN_INK
		sta $b1a9
		sta $b1f9
		sta $b249
		sta $b299
		sta $b2e9
		sta $b339		
		
		lda #YELLOW_INK
		sta $b361
		sta $b3b1
		sta $b401
		sta $b451	
		sta $b4a1
		sta $b4f1
		lda #CYAN_INK
		sta $b389
		sta $b3d9
		sta $b429
		sta $b479
		sta $b4c9
		sta $b519		
		
		lda #YELLOW_INK
		sta $b541
		sta $b591
		sta $b5e1
		sta $b631	
		sta $b681
		sta $b6d1
		lda #CYAN_INK
		sta $b569
		sta $b5b9
		sta $b609
		sta $b659
		sta $b6a9
		sta $b6f9		

		;;; paper 0 sur les 3 lignes texte
		lda #BLACK_PAPER
		sta $bf68
		sta $bf90
		sta $bfb8
										
		rts	
.)	

	; insert 0s so that to move the specific code upwards of $2000
	.dsb $2000-*

;************************************************
;******* Affiche différents textes   ************
;************************************************
aff_text
.(
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	sec				; prépare retenue pour soustraction
	sbc #$55		; la première ville est numéroté #$50 (la dernière : #$64)
	bmi hadrian_wall	; si pas sur ville, test suivant
	asl				; prépare index
	tax				; 
	lda ptr_v,x			; Partie basse adresse premier byte chaine nom (ie: $a0,"narbone",0) 
	sta adr_nom_1+1
	sta lp_nom_v+1			
	inx
	lda ptr_v,x			; Partie haute premier byte chaine nom (ie :$a0,"narbone",0) 
	sta adr_nom_1+2
	sta lp_nom_v+2			
	ldx #0
+adr_nom_1	
	lda $1111,x			;partie basse aadresse écran pour ecriture nom
	sta adr_ecr_nom+1			
	inx
+lp_nom_v			
	lda $3333 ,x		; lit lettre des noms jusqu'à  rencontrer 0
	beq ask_enter
adr_ecr_nom
	sta $bf44,x			; erit nom sur Avant dernière ligne texte de l'écran Hires
	inx
	bne lp_nom_v
ask_enter	
	ldx #0
lp_ask	
	lda quest_enter,x
	bne suite_ask
	inc est_affiche_texte		;flag indiquant que quelquechose est ecrit en bas écran (pour que la routine Eff_texte le teste et agisse ou pas)
	jsr hit_key
	rts
;	jmp fin_txt
suite_ask	
	sta $bfbe,x
	inx
	bne lp_ask
	rts
quest_enter	
	.asc "Do you wish to enter the city?",0
hadrian_wall
	lda tuile_sous_pos_perso
	cmp #$44				; valeur tuile mur Hadrien ouest
	beq suite_hw
	jmp druid_hut
suite_hw	
	ldx #0
	lda t_h_wall_1,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_1+1
	sta write_phrase+1
	lda #>t_h_wall_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_h_wall_2,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_2+1
	sta write_phrase+1
	lda #>t_h_wall_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
	
	
	ldx #0
	lda t_h_wall_3,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_3+1
	sta write_phrase+1
	lda #>t_h_wall_3+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_h_wall_4,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_4+1
	sta write_phrase+1
	lda #>t_h_wall_4+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	
	ldx #0
	lda t_h_wall_5,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_5+1
	sta write_phrase+1
	lda #>t_h_wall_5+1
	sta write_phrase+2	
	jsr write_phrase		
	
	ldx #0
	lda t_h_wall_6,x
	sta adr_ecr_txt+1
	lda #<t_h_wall_6+1
	sta write_phrase+1
	lda #>t_h_wall_6+1
	sta write_phrase+2	
	jsr write_phrase		
	jsr hit_key
	jsr eff_text
;sortie vers ecran HIRES ;-)
	lda #$80
	sta sortie_victorieuse				;drapeau mur atteint
	lda #$86
	sta direction_scroll				; simule appui sur 'Y' pour sortie carte
	rts
;-----------------------------------------------------

druid_hut	
	lda tuile_sous_pos_perso
	cmp #$53				; valeur tuile camp Druides
	beq suite_dh
	jmp herb_
suite_dh	
	ldx #0
	lda t_druid_hut_1,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_1+1
	sta write_phrase+1
	lda #>t_druid_hut_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_druid_hut_2,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_2+1
	sta write_phrase+1
	lda #>t_druid_hut_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
	
	ldx #0
	lda t_druid_hut_3,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_3+1
	sta write_phrase+1
	lda #>t_druid_hut_3+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_druid_hut_4,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_4+1
	sta write_phrase+1
	lda #>t_druid_hut_4+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	
	ldx #$00
	lda t_druid_hut_5,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_5+1
	sta write_phrase+1
	lda #>t_druid_hut_5+1
	sta write_phrase+2	
	jsr write_phrase		
	
	ldx #0
	lda t_druid_hut_6,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_6+1
	sta write_phrase+1
	lda #>t_druid_hut_6+1
	sta write_phrase+2	
	jsr write_phrase		
	jsr hit_key
	jsr eff_text	
	
	ldx #0
	lda t_druid_hut_7,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_7+1
	sta write_phrase+1
	lda #>t_druid_hut_7+1
	sta write_phrase+2	
	jsr write_phrase		
	
	ldx #0
	lda t_druid_hut_8,x
	sta adr_ecr_txt+1
	lda #<t_druid_hut_8+1
	sta write_phrase+1
	lda #>t_druid_hut_8+1
	sta write_phrase+2	
	jsr write_phrase		
	jsr hit_key
	jsr eff_text	
	rts
herb_

	lda tuile_sous_pos_perso
	cmp #$54				; valeur tuile montagne et plante mortelle
	bne _kraken
	ldx #0
	lda t_herb_1,x
	sta adr_ecr_txt+1
	lda #<t_herb_1+1
	sta write_phrase+1
	lda #>t_herb_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_herb_2,x
	sta adr_ecr_txt+1
	lda #<t_herb_2+1
	sta write_phrase+1
	lda #>t_herb_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text
	rts

_kraken
	lda tuile_sous_pos_perso					; il faut être en mer
	beq	test_nord
	cmp #TRUE
	bne fin_txt
test_nord	
	lda ligne_hg_map
	cmp #$10				; et tenter de passer au nord de la ligne 16 de la carte
	bne fin_txt     ;  remettre bpl en fin de beta
	
	ldx #0
	lda t_kraken_1,x
	sta adr_ecr_txt+1
	lda #<t_kraken_1+1
	sta write_phrase+1
	lda #>t_kraken_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_kraken_2,x
	sta adr_ecr_txt+1
	lda #<t_kraken_2+1
	sta write_phrase+1
	lda #>t_kraken_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text	
	
	ldx #0
	lda t_kraken_3,x
	sta adr_ecr_txt+1
	lda #<t_kraken_3+1
	sta write_phrase+1
	lda #>t_kraken_3+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #0
	lda t_kraken_4,x
	sta adr_ecr_txt+1
	lda #<t_kraken_4+1
	sta write_phrase+1
	lda #>t_kraken_4+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr eff_text	
fin_txt	
	rts
.)

write_phrase
.(
	lda $1111,x
	beq end_phrase
+adr_ecr_txt
	sta $bf11,x
	inx	
	bne write_phrase
end_phrase
	lda #TRUE
	sta est_affiche_texte
	rts
.)

hit_key
.(
	lda $208
	cmp #$38
	bne hit_key  ;beq hit_key
ld_208
	lda $208
	cmp #$38
	beq ld_208
	cmp #$86
	bne release_
	sta direction_scroll
release_
	rts
.)	

;************************************************
;******* efface le texte   ************
;************************************************
eff_text
.(
	lda est_affiche_texte
	beq out_eff_text
	dec est_affiche_texte
	ldx #$27
	lda #$20
lp_efface
	sta $BF90,x
	sta $bfb8,x
	dex
	bne lp_efface
out_eff_text
	rts
.)


;******************************************************************
;***  dessine image au dessus carte ville et ecrit nom ville  *****
;******************************************************************
bandeau
.(
	jsr ini_adr_dta_bd
	ldx #$00
ad_dta_bandeau
	lda $1111,x
	cmp #$0a
	beq end_af_bd
ad_ec_bd
	sta $A000,x
	inx
	bne ad_dta_bandeau
	jsr maj_adr_bd
	jmp ad_dta_bandeau
end_af_bd
	rts

;--------------------------------------------------
ini_adr_dta_bd
	lda #<dta_bandeau
	sta ad_dta_bandeau+1
	lda #>dta_bandeau
	sta ad_dta_bandeau+2
	lda #$00
	sta ad_ec_bd+1
	lda #$A0
	sta ad_ec_bd+2
	rts
;--------------------------------------------------
maj_adr_bd
	inc	ad_dta_bandeau+2
	inc ad_ec_bd+2
	rts
.)

;************************************************
;***    Cherche et  Ecrit nom  lieux       *****
;************************************************
prt_nom_lieu
.(
	jsr det_index
	cpx numero_lieu
	beq fin_ptr_nl		; on est toujours dans le meme lieu => pas de changement de nom
	stx numero_lieu				; mémoire lieu actuel
	jsr ini_adr_dta_nl
	jsr eff_nom
nb_ligne
	ldy #$00			; nb delignes moins 1, renseigné par routine ini_adr_dta_nl par
prt_lign
	ldx #$0A			; nb colonnes moins 1, renseigné par routine ini_adr_dta_nl par
ad_dta_nl
	lda $1111,x
ad_ec_nl
	sta $B960,x
	dex
	bpl ad_dta_nl
	jsr maj_adr_nl
	dey
	bpl prt_lign
fin_ptr_nl
	rts

;------------------------------------------------
maj_adr_nl
	lda ad_dta_nl+1
	clc
	adc #$33			; nb de colonnes lieu, renseigné par routine ini_adr_dta_nl
	sta ad_dta_nl+1
	bcc sk_ret1
	inc ad_dta_nl+2
sk_ret1
	lda ad_ec_nl+1
	clc
	adc #$28
	sta ad_ec_nl+1
	bcc sk_ret2
	inc ad_ec_nl+2
sk_ret2
	rts
;------------------------------------------------
ini_adr_dta_nl
	txa
	asl
	tax
	lda ptr_dta_lieux,x			; partie basse adresse data lieu
	sta get_value+1
	inx
	lda ptr_dta_lieux,x			; partie haute adresse data lieu
	sta get_value+2
	ldx #$00
	jsr get_value				; 1ere data: partie basse adresse affichage écran
	sta ad_ec_nl+1
	inx
	jsr get_value				; 2ème data nb de lignes écran du nom
	sec
	sbc#$01
	sta nb_ligne+1
	inx
	jsr get_value				; Nb de colonnes écran du nom
	sta maj_adr_nl+5
	sec
	sbc#$01
	sta prt_lign+1
	lda get_value +1
	clc
	adc #$3
	sta ad_dta_nl+1
	lda get_value+2
	sta ad_dta_nl+2
	bcc fin_ini_adnl
	inc ad_dta_nl+2
fin_ini_adnl
	lda #$B9
	sta ad_ec_nl+2
	rts
get_value
	lda $1111,x
	rts

;------------------------------------------------

det_index
	lda tuile_sous_pos_perso
	beq traite_mer
	cmp #$01
	beq traite_mer
	bne traite_terre
traite_mer
	lda ligne_map
	cmp #$1d
	bmi test_mare_germa
	lda rang_map
	cmp #$11
	bmi test_m_nostrum_2
	ldx #$07
	rts
test_m_nostrum_2
	lda ligne_map
	cmp #$2d
	bmi test_mare_germa
	lda rang_map
	cmp #$07
	bmi test_mare_germa
	ldx #$07
	rts
test_mare_germa
	cmp #$09
	bpl test_mare_exter
	lda rang_map
	cmp #$13
	bmi test_mare_exter
	ldx #$09
	rts
test_mare_exter
	ldx #$08
	rts
;-----------------
traite_terre
	lda ligne_map
test_germania
	cmp #$11			; limite sud de Germania, Hibernia, Calédonia
	bpl test_gallia
	lda rang_map
	cmp #$18
	bmi test_hibernia
	ldx #$04			; Germania
	rts
test_hibernia
	lda rang_map
	cmp #$0a
	bpl test_caledonia
	lda ligne_map
	cmp #$0e
	bpl test_caledonia
	ldx #$06			; Hibernia
	rts
test_caledonia
	lda ligne_map
	cmp #$02
	bpl test_britania
	ldx #$05			; Caledonia
	rts
test_britania			; au nord de #$11 si on n'est ni en Germania, ni en Hibernia, ni en Caledonia
	lda ligne_map				; alors on est soit en Britania, soit dans le Pas de Calais
	cmp #$0f
	bmi test_brit_2
	lda rang_map
	cmp #$15
	bmi test_brit_2
	ldx #$00			; cas particulier "Pas de Callais"
	rts
	test_brit_2
	ldx #$03			; Britania
	rts
test_gallia
	cmp #$21
	bpl test_lusitania
	lda rang_map
	cmp #$0a
	bmi test_lusitania
	cmp #$0f
	bpl case_gallia
	lda ligne_map
	cmp #$1d
	bmi case_gallia
	ldx #$01			; hispania galice et côte nord
	rts
case_gallia
	ldx #$00
	rts
test_lusitania
	lda ligne_map
	cmp #$22
	bmi test_hispania
	lda rang_map
	cmp #$06
	bpl test_hispania
	ldx #$02			; Lusitania
	rts
test_hispania
	lda ligne_map
	cmp #$12
	bmi last_case_b
	cmp #$1d
	bmi last_case_g
	ldx #$01
	rts
last_case_b
	ldx #$03			; britania (extremite cornouailles)
	rts
last_case_g
	ldx #$00			; Gallia (bretagne ouest et cotentin)
	rts
;------------------------------------------------
eff_nom
	jsr ini_ad_v
	lda #$40
	ldy #$16
nb_l_vide
	ldx #$1E
nb_c_vide
	sta $b906,x
	dex
	bpl nb_c_vide
	dey
	bmi end_vide
	jsr maj_ad_vide
	bpl nb_l_vide
end_vide
	rts
maj_ad_vide
	pha
	clc
	lda nb_c_vide+1
	adc #$28
	sta nb_c_vide+1
	bcc end_maj_vide
	inc nb_c_vide+2
end_maj_vide
	pla
	rts
ini_ad_v
	lda #$06
	sta nb_c_vide+1
	lda #$b9
	sta nb_c_vide+2
	rts
.)

; insert 0s so that to move the data upwards of $3000
	.dsb $3000-*

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
				
;**********************************
;******* DATA PLAN T4  ************
;**********************************
_L00
	.byt $00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$0F,$10,$10,$10,$10,$10,$08,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00
_L01
	.byt $00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$09,$10,$10,$10,$10,$10,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00
_L02
	.byt $01,$00,$01,$00,$00,$09,$10,$09,$00,$00,$0F,$0F,$0C,$41,$41,$43,$44,$3C,$09,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01
_L03
	.byt $01,$00,$01,$00,$0E,$10,$10,$10,$10,$02,$00,$00,$00,$10,$15,$15,$15,$2A,$10,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01
_L04
	.byt $00,$01,$00,$00,$03,$15,$10,$10,$10,$08,$00,$00,$07,$10,$0F,$15,$15,$32,$40,$08,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00
_L05
	.byt $00,$00,$0F,$10,$15,$15,$15,$10,$0C,$00,$00,$01,$00,$00,$00,$10,$15,$15,$1F,$10,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01
_L06
	.byt $01,$00,$0E,$15,$15,$10,$10,$10,$02,$00,$01,$00,$01,$00,$00,$04,$10,$15,$16,$0B,$05,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00
_L07
	.byt $00,$00,$04,$0B,$10,$10,$10,$10,$08,$00,$00,$00,$00,$00,$10,$15,$15,$4f,$34,$08,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00
_L08
	.byt $01,$00,$00,$0A,$10,$10,$15,$15,$64,$00,$00,$02,$00,$0A,$10,$15,$15,$4e,$38,$08,$00,$00,$01,$00,$01,$00,$01,$00,$00,$00,$03,$09
_L09
	.byt $00,$01,$00,$0E,$15,$15,$15,$10,$08,$00,$00,$10,$0D,$15,$15,$15,$36,$2C,$16,$10,$00,$01,$00,$01,$00,$01,$00,$00,$03,$0E,$15,$15
_L0a
	.byt $01,$00,$03,$15,$15,$10,$10,$08,$00,$00,$00,$04,$15,$15,$15,$36,$3A,$15,$1E,$0D,$09,$00,$01,$00,$01,$00,$00,$09,$10,$10,$15,$10
_L0b
	.byt $00,$03,$15,$15,$10,$0B,$05,$00,$01,$00,$00,$03,$15,$15,$36,$3A,$15,$15,$17,$15,$10,$10,$00,$00,$01,$00,$0A,$10,$10,$15,$15,$10
_L0c
	.byt $00,$04,$10,$0B,$05,$00,$00,$01,$00,$00,$09,$10,$10,$10,$1F,$15,$15,$15,$1F,$15,$10,$08,$00,$01,$00,$00,$10,$10,$15,$15,$15,$10
_L0d
	.byt $01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$00,$04,$0B,$36,$2c,$15,$36,$39,$5D,$39,$0C,$00,$00,$01,$00,$03,$10,$15,$15,$10,$10,$10
_L0e
	.byt $00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$09,$09,$1F,$10,$36,$3A,$17,$10,$32,$3B,$00,$00,$00,$03,$10,$15,$15,$10,$10,$10,$15
_L0f
	.byt $00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$0A,$10,$4f,$34,$10,$0B,$0B,$00,$0B,$00,$00,$00,$09,$0E,$10,$10,$15,$15,$10,$10,$15,$15
_L10
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$00,$03,$10,$10,$63,$00,$00,$00,$00,$00,$00,$00,$00,$60,$10,$10,$10,$10,$10,$10,$59,$15,$15,$15
_L11
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$00,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$17,$10,$10,$10,$10,$10,$15,$16,$15,$10,$10
_L12
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$04,$10,$02,$00,$09,$10,$15,$17,$10,$15,$10,$10,$10,$10,$16,$15,$10,$10
_L13
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$0F,$10,$09,$0E,$15,$15,$17,$10,$15,$15,$10,$10,$10,$16,$10,$10,$15
_L14
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$09,$0E,$10,$09,$09,$15,$15,$15,$15,$15,$10,$25,$58,$10,$15,$10,$26,$24,$34,$10,$15,$15
_L15
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$0F,$10,$10,$15,$15,$53,$15,$15,$15,$10,$10,$15,$32,$50,$32,$1B,$19,$10,$10,$15,$15,$15
_L16
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$0B,$0F,$15,$15,$15,$15,$15,$10,$10,$10,$15,$28,$39,$10,$16,$10,$15,$15,$11,$12
_L17
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$0B,$15,$15,$15,$15,$15,$10,$10,$10,$15,$32,$24,$18,$15,$11,$12,$12,$12
_L18
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$0F,$10,$15,$10,$15,$10,$10,$10,$10,$10,$4f,$34,$11,$12,$12,$12,$12
_L19
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$5F,$30,$30,$30,$30,$38,$10,$36,$30,$57,$10,$12,$37,$30,$38,$12
_L1a
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$10,$10,$10,$10,$10,$33,$24,$35,$11,$2E,$30,$30,$2C,$12,$11,$12
_L1b
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$04,$10,$15,$15,$10,$14,$12,$11,$12,$17,$10,$12,$12,$12,$12,$12
_L1c
	.byt $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$0D,$0A,$10,$15,$10,$10,$14,$12,$12,$17,$12,$12,$12,$54,$14,$15
_L1d
	.byt $01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$36,$56,$39,$10,$15,$15,$11,$12,$12,$17,$12,$12,$12,$12,$12,$15
_L1e
	.byt $01,$00,$01,$00,$03,$0E,$0D,$00,$00,$00,$00,$00,$01,$00,$00,$0A,$20,$10,$32,$50,$10,$11,$12,$12,$55,$2E,$38,$12,$36,$1D,$3D,$3D
_L1f
	.byt $01,$00,$00,$0A,$5C,$38,$15,$15,$15,$0D,$09,$00,$00,$00,$00,$0E,$16,$10,$10,$3F,$30,$38,$36,$30,$2B,$35,$2A,$36,$31,$05,$00,$00
_L20
	.byt $01,$00,$00,$0A,$10,$3F,$38,$15,$11,$14,$10,$37,$39,$0D,$09,$26,$12,$11,$10,$10,$10,$3F,$5E,$0B,$00,$00,$32,$35,$05,$00,$01,$00
_L21
	.byt $01,$00,$00,$15,$10,$10,$3F,$38,$10,$37,$1A,$34,$32,$24,$24,$34,$14,$12,$12,$11,$10,$1F,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
_L22
	.byt $01,$00,$00,$15,$10,$10,$10,$23,$24,$34,$10,$10,$10,$10,$10,$10,$15,$15,$14,$14,$42,$52,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00
_L23
	.byt $01,$00,$00,$15,$10,$36,$2B,$34,$10,$10,$10,$14,$11,$11,$10,$10,$10,$10,$10,$10,$17,$10,$0D,$00,$00,$01,$00,$01,$01,$00,$01,$00
_L24
	.byt $01,$00,$03,$10,$26,$35,$10,$10,$10,$10,$10,$10,$10,$12,$12,$11,$10,$12,$10,$36,$31,$0C,$05,$00,$00,$01,$00,$01,$01,$00,$01,$00
_L25
	.byt $01,$00,$0E,$10,$16,$10,$10,$10,$11,$10,$10,$11,$12,$10,$14,$12,$11,$36,$5a,$31,$0B,$00,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L26
	.byt $00,$03,$10,$26,$34,$10,$10,$10,$10,$10,$14,$10,$10,$10,$10,$10,$36,$31,$05,$00,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L27
	.byt $00,$0E,$26,$34,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$36,$31,$0C,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L28
	.byt $00,$62,$19,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$17,$0C,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L29
	.byt $00,$04,$33,$24,$1B,$30,$38,$10,$10,$10,$10,$10,$10,$10,$10,$17,$08,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2a
	.byt $01,$00,$10,$10,$10,$10,$2A,$10,$10,$10,$26,$24,$1C,$38,$4f,$35,$15,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2b
	.byt $00,$0A,$10,$10,$10,$10,$32,$50,$10,$26,$34,$10,$10,$28,$31,$61,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2c
	.byt $00,$04,$0B,$0B,$0F,$10,$10,$2F,$1A,$34,$10,$10,$10,$11,$14,$08,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2d
	.byt $01,$00,$00,$00,$00,$0F,$5B,$51,$10,$10,$10,$10,$14,$15,$0B,$05,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2e
	.byt $01,$00,$01,$00,$00,$04,$10,$10,$0C,$0B,$0B,$0F,$10,$05,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L2f
	.byt $01,$00,$01,$00,$01,$00,$04,$05,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00
_L30
	.byt $01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00

ptr_Lignes

	.byt <_L00,>_L00,<_L01,>_L01,<_L02,>_L02,<_L03,>_L03,<_L04,>_L04,<_L05,>_L05,<_L06,>_L06,<_L07,>_L07,<_L08,>_L08,<_L09,>_L09
	.byt <_L0a,>_L0a,<_L0b,>_L0b,<_L0c,>_L0c,<_L0d,>_L0d,<_L0e,>_L0e,<_L0f,>_L0f,<_L10,>_L10,<_L11,>_L11,<_L12,>_L12,<_L13,>_L13
	.byt <_L14,>_L14,<_L15,>_L15,<_L16,>_L16,<_L17,>_L17,<_L18,>_L18,<_L19,>_L19,<_L1a,>_L1a,<_L1b,>_L1b,<_L1c,>_L1c,<_L1d,>_L1d
	.byt <_L1e,>_L1e,<_L1f,>_L1f,<_L20,>_L20,<_L21,>_L21,<_L22,>_L22,<_L23,>_L23,<_L24,>_L24,<_L25,>_L25,<_L26,>_L26,<_L27,>_L27
	.byt <_L28,>_L28,<_L29,>_L29,<_L2a,>_L2a,<_L2b,>_L2b,<_L2c,>_L2c,<_L2d,>_L2d,<_L2e,>_L2e,<_L2f,>_L2f,<_L30,>_L30



; -----------------------------------------------------------------------------
;    Table adresses car modifiés dans 2nd jeu de car mode Hires (1/4 de tuile)
; ----------------------------------------------------------------------------- ici, pas besoin de pointeurs d'adresses car pas d'addition
;																				pour trouver l'adresse du car n, il suffit de décaler à gauche
;																				le registre contenant le n° du car pour trouver l'adresse.
sous_tuile
	.byt $9d,$00,$9d,$06,$9d,$0c,$9d,$12,$9d,$18,$9d,$1e,$9d,$24,$9d,$2a,$9d,$30,$9d,$36,
	.byt $9d,$3c,$9d,$42,$9d,$48,$9d,$4e,$9d,$54,$9d,$5a,$9d,$60,$9d,$66,$9d,$6c,$9d,$72,
	.byt $9d,$78,$9d,$7e,$9d,$84,$9d,$8a,$9d,$90,$9d,$96,$9d,$9c,$9d,$a2,$9d,$a8,$9d,$ae,
	.byt $9d,$b4,$9d,$ba,$9d,$c0,$9d,$c6,$9d,$cc,$9d,$d2,$9d,$d8,$9d,$de,$9d,$e4,$9d,$ea,
	.byt $9d,$f0,$9d,$f6,$9d,$fc,$9e,$02,$9e,$08,$9e,$0e,$9e,$14,$9e,$1a,$9e,$20,$9e,$26,
	.byt $9e,$2c,$9e,$32,$9e,$38,$9e,$3e,$9e,$44,$9e,$4a,$9e,$50



; --------------------------------------------------------------------
;       Table redéfinition  des tuiles (N)d'ordre des 4 car redafinis
; --------------------------------------------------------------------


_t00
		.byt $03,$01,$00,$01
_t01
		.byt $00,$01,$00,$02
_t02
		.byt $00,$01,$04,$02
_t03
		.byt $00,$01,$00,$04
_t04
		.byt $00,$04,$00,$02
_t05
		.byt $04,$01,$00,$02
_t06
		.byt $04,$01,$00,$04
_t07
		.byt $00,$04,$04,$02
_t08
		.byt $04,$01,$04,$02
_t09
		.byt $00,$01,$04,$04
_t0A
		.byt $00,$04,$00,$04
_t0B
		.byt $04,$04,$00,$02
_t0C
		.byt $04,$04,$04,$02
_t0D
		.byt $04,$01,$04,$04
_t0E
		.byt $00,$04,$04,$04
_t0F
		.byt $04,$04,$00,$04
_t10
		.byt $04,$04,$04,$04
_t11
		.byt $04,$04,$0B,$0C
_t12
		.byt $0B,$0C,$0B,$0C
_t13
		.byt $04,$04,$04,$0B
_t14
		.byt $0B,$0C,$04,$04
_t15
		.byt $0D,$0E,$0F,$10
_t16
		.byt $11,$04,$11,$04
_t17
		.byt $04,$11,$04,$11
_t18
		.byt $12,$04,$11,$04
_t19
		.byt $11,$04,$12,$04
_t1A
		.byt $04,$17,$14,$16
_t1B
		.byt $18,$04,$15,$14
_t1C
		.byt $14,$18,$04,$15
_t1D
		.byt $17,$14,$16,$04
_t1E
		.byt $11,$04,$15,$18
_t1F
		.byt $04,$11,$17,$16
_t20
		.byt $17,$16,$11,$04
_t21
		.byt $14,$12,$04,$11
_t22
		.byt $04,$13,$04,$11
_t23
		.byt $13,$14,$11,$04
_t24
		.byt $14,$14,$04,$04
_t25
		.byt $04,$11,$04,$15
_t26
		.byt $17,$14,$11,$04
_t27
		.byt $15,$18,$04,$13
_t28
		.byt $11,$04,$15,$14
_t29
		.byt $11,$04,$16,$04
_t2A
		.byt $15,$18,$04,$11
_t2B
		.byt $04,$17,$14,$16
_t2C
		.byt $11,$04,$16,$04
_t2D
		.byt $04,$11,$14,$12
_t2E
		.byt $04,$11,$04,$13
_t2F
		.byt $11,$04,$13,$14
_t30
		.byt $04,$04,$14,$14
_t31
		.byt $04,$11,$14,$16
_t32
		.byt $04,$15,$04,$04
_t33
		.byt $15,$14,$04,$04
_t34
		.byt $16,$04,$04,$04
_t35
		.byt $14,$16,$04,$04
_t36
		.byt $04,$04,$04,$17
_t37
		.byt $04,$04,$17,$14
_t38
		.byt $04,$04,$18,$04
_t39
		.byt $04,$04,$14,$18
_t3A
		.byt $17,$16,$16,$04
_t3B
		.byt $14,$01,$04,$04
_t3C
		.byt $00,$01,$18,$04
_t3D
		.byt $14,$14,$00,$02
_t3E
		.byt $11,$01,$16,$02
_t3F
		.byt $15,$18,$04,$15
_t40
		.byt $18,$04,$15,$18
_t41
		.byt $21,$21,$04,$04
_t42
		.byt $0B,$0C,$04,$17
_t43
		.byt $22,$22,$04,$04
_t44
		.byt $22,$23,$04,$15
_t45
		.byt $05,$06,$07,$08
_t46
		.byt $05,$06,$09,$0A
_t47
		.byt $34,$35,$36,$37
_t48
		.byt $19,$1A,$1B,$1C
_t49
		.byt $1D,$1E,$1F,$20
_t4A
		.byt $24,$25,$26,$27
_t4B
		.byt $28,$29,$2A,$2B
_t4C
		.byt $2C,$2D,$2E,$2F
_t4D
		.byt $30,$31,$32,$33
_t4E							; 5 nouvelles tuiles
		.byt $04,$11,$17,$38
_t4F
		.byt $04,$17,$04,$11
_t50
		.byt $18,$04,$11,$04
_t51
		.byt $11,$04,$16,$04
_t52
		.byt $11,$01,$16,$02


; A partir d'ici, tuiles "Spéciales"

_t53
		.byt $0D,$0E,$0F,$10	; forêt spéciale proposition camps de druides
_t54
		.byt $0B,$0C,$0B,$0C	; Pleine montagne spéciale proposition: plante pour druide
_t55
		.byt $05,$06,$07,$08	; NEMAUSUS	(Nîmes)

; SI   #$55 < code < #$5E  ==> villes 	sans possibilite achat bateau


_t56
		.byt $05,$06,$07,$08	; BURDIGALA (Bordeaux)
_t57
		.byt $05,$06,$07,$08	; LUGDUNUM (Lyon)
_t58
		.byt $05,$06,$07,$08	; LUTECIA (Paris)
_t59
		.byt $05,$06,$07,$08	; AGRIPPINA (Köln))
_t5A
		.byt $05,$06,$07,$08	; BACINO (Barcelone)
_t5B
		.byt $05,$06,$07,$08	; GASES (Cadiz)
_t5C
		.byt $05,$06,$07,$08	; BRIGANTIUM ( A Coruña)
_t5D
		.byt $05,$06,$07,$08	; LONDINIUM (London)
_t5E
		.byt $05,$06,$09,$0A	; NARBO MARTIUS (Narbone)
_t5F
		.byt $05,$06,$09,$0A	; MEDIOLANUM SANTONUM (Saintes)
_t60
		.byt $05,$06,$09,$0A	; GESORIACUM ( Boulogne)
_t61
		.byt $05,$06,$09,$0A	; CATHAGO NOVA (Cartagena)
_t62
		.byt $05,$06,$09,$0A	; OLISIPA (Lisboa)
_t63
		.byt $05,$06,$09,$0A	; ISCA DUMNONIORUM (Exeter)
_t64
		.byt $05,$06,$09,$0A	; EBLANA POLIS (Dublin)



ptr_t ;(pointeurs t pour tuiles)

	.byt <_t00,>_t00,<_t01,>_t01,<_t02,>_t02,<_t03,>_t03,<_t04,>_t04,<_t05,>_t05
	.byt <_t06,>_t06,<_t07,>_t07,<_t08,>_t08,<_t09,>_t09,<_t0A,>_t0A,<_t0B,>_t0B
	.byt <_t0C,>_t0C,<_t0D,>_t0D,<_t0E,>_t0E,<_t0F,>_t0F,<_t10,>_t10,<_t11,>_t11
	.byt <_t12,>_t12,<_t13,>_t13,<_t14,>_t14,<_t15,>_t15,<_t16,>_t16,<_t17,>_t17
	.byt <_t18,>_t18,<_t19,>_t19,<_t1A,>_t1A,<_t1B,>_t1B,<_t1C,>_t1C,<_t1D,>_t1D
	.byt <_t1E,>_t1E,<_t1F,>_t1F,<_t20,>_t20,<_t21,>_t21,<_t22,>_t22,<_t23,>_t23
	.byt <_t24,>_t24,<_t25,>_t25,<_t26,>_t26,<_t27,>_t27,<_t28,>_t28,<_t29,>_t29
	.byt <_t2A,>_t2A,<_t2B,>_t2B,<_t2C,>_t2C,<_t2D,>_t2D,<_t2E,>_t2E,<_t2F,>_t2F
	.byt <_t30,>_t30,<_t31,>_t31,<_t32,>_t32,<_t33,>_t33,<_t34,>_t34,<_t35,>_t35
	.byt <_t36,>_t36,<_t37,>_t37,<_t38,>_t38,<_t39,>_t39,<_t3A,>_t3A,<_t3B,>_t3B
	.byt <_t3C,>_t3C,<_t3D,>_t3D,<_t3E,>_t3E,<_t3F,>_t3F,<_t40,>_t40,<_t41,>_t41
	.byt <_t42,>_t42,<_t43,>_t43,<_t44,>_t44,<_t45,>_t45,<_t46,>_t46,<_t47,>_t47
	.byt <_t48,>_t48,<_t49,>_t49,<_t4A,>_t4A,<_t4B,>_t4B,<_t4C,>_t4C,<_t4D,>_t4D
	.byt <_t4E,>_t4E,<_t4F,>_t4F,<_t50,>_t50,<_t51,>_t51,<_t52,>_t52,<_t53,>_t53
	.byt <_t54,>_t54,<_t55,>_t55,<_t56,>_t56,<_t57,>_t57,<_t58,>_t58,<_t59,>_t59
	.byt <_t5A,>_t5A,<_t5B,>_t5B,<_t5C,>_t5C,<_t5D,>_t5D,<_t5E,>_t5E,<_t5F,>_t5F
	.byt <_t60,>_t60,<_t61,>_t61,<_t62,>_t62,<_t63,>_t63,<_t64,>_t64


; *************  DATA NOMS des Villes  *************

v_00
	.byt $9f					; longeur $08 lettres
	.asc 3,"NEMAUSUS",0			; Nîmes
v_01
	.byt $9e					; $09
	.asc 3,"BURDIGALA",0 		; Bordeaux
v_02
	.byt $9f					; $08
	.asc 3,"LUGDUNUM",0 		; Lyon
v_03
	.byt $9f					; $07
	.asc 3,"LUTETIA",0 			; Paris
v_04
	.byt $9e					; $09
	.asc 3,"AGRIPPINA",0 		; Köln
v_05
	.byt $9f					; $06
	.asc 3,"BACINO",0 			; Barcelone
v_06
	.byt $a1					; $05
	.asc 3,"GADES",0 			; Cadiz
v_07
	.byt $9e					; $0a
	.asc 3,"BRIGANTIUM",0 		; A Coruña
v_08
	.byt $9e					; $09
	.asc 3,"LONDINIUM",0 		; London
v_09
	.byt $9c					; $0d
	.asc 3,"NARBO MARTIUS",0 	; Narbone
v_0A
	.byt $9a					; $13
	.asc 3,"MEDIOLANUM SANTONUM",0 ; Saintes
v_0B
	.byt $9e					; $0a
	.asc 3,"GESORIACUM",0 		; Boulogne
v_0C
	.byt $9c					; $0d
	.asc 3,"CARTHAGO NOVA",0 	; Cartagena
v_0D
	.byt $9f					; $07
	.asc 3,"OLISIPO",0 			; Lisboa
v_0E
	.byt $9b					; $10
	.asc 3,"ISCA DUMNONIORUM",0 ; Exeter
v_0F
	.byt $a1					; $6
	.asc 3,"EBLANA",0 			; Dublin

ptr_v ;(pointeurs v pour villes)

	.byt <v_00,>v_00,<v_01,>v_01,<v_02,>v_02,<v_03,>v_03,<v_04,>v_04,<v_05,>v_05
	.byt <v_06,>v_06,<v_07,>v_07,<v_08,>v_08,<v_09,>v_09,<v_0A,>v_0A,<v_0B,>v_0B
	.byt <v_0C,>v_0C,<v_0D,>v_0D,<v_0E,>v_0E,<v_0F,>v_0F

;--------------------------------------------------------------
t_h_wall_1
	.byt $9c
	.asc "Congratulations!",0
t_h_wall_2
	.byt $bc
	.asc "You have reached fort Borcovicus",0
t_h_wall_3
	.byt $94
	.asc "and completed the first part of",0
t_h_wall_4
	.byt $c6
	.asc "your mission!",0
t_h_wall_5
	.byt $96
	.asc "See you soon for episode two:",0
t_h_wall_6
	.byt $c0
	.asc "MISSIO: Beyond the Wall",0
;--------------------------------------------------------------
t_druid_hut_1
	.byt $93
	.asc "You are in front of a druid's hut.",0
t_druid_hut_2
	.byt $bf
	.asc "Do you knock on the door?",0
t_druid_hut_3
	.byt $96
	.asc "Your magical skill is too low.",0
t_druid_hut_4
	.byt $c3
	.asc "He refuses to open.",0
t_druid_hut_5
	.byt $93
	.asc "He asks you for Aconitum napellus",0
t_druid_hut_6
	.byt $bc
	.asc "in exchange for his best spell.",0
t_druid_hut_7
	.byt $91
	.asc "He thanks you for the Aconitum napellus",0
t_druid_hut_8
	.byt $ba
	.asc "and teaches you the KRAKENSLEEP spell",0
;--------------------------------------------------------------

t_herb_1
	.byt $97
	.asc "You find Aconitum napellus;",0
t_herb_2
	.byt $c5
	.asc "do you pick it?",0
;--------------------------------------------------------------
t_kraken_1
	.byt $94
	.asc "A raging kraken is preventing you",0
t_kraken_2
	.byt $be
	.asc "from going any further north.",0
t_kraken_3
	.byt $95
	.asc "The spell appeases the kraken.",0
t_kraken_4
	.byt $c4
	.asc "It lets you pass.",0


; -----------------------------------------------
;       Table redéfinition  2nd jeu de car
; -----------------------------------------------

dta_car_redef_p1
;00 en $9d00
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $fe	;1,1,1,1,1,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;01 en $9d06
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0


;02 en $9d0c
	.byt $fb	;1,1,1,1,1,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;03 en $9d12
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;04 en $9d18
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1

;05 en $9d1e
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $f3 	;1,1,1,1,0,0,1,1

;06 en $9d24
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $7a 	;0,1,1,1,1,0,1,0
	.byt $dc 	;1,1,0,1,1,1,0,0
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $cd 	;1,1,0,0,1,1,0,1

;07  en $9d2a
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $55	;0,1,0,1,0,1,0,1

;08  en $9d30
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $55	;0,1,0,1,0,1,0,1

;09  en $9d36
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $55	;0,1,0,1,0,1,0,1

;0A  en $9d3c
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1

;0B  en $9d42
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $7f 	;0,1,1,1,1,1,1,1

;0C  en $9d48
	.byt $cf 	;1,1,0,0,1,1,1,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $7f 	;0,1,1,1,1,1,1,1

;0D  en $9d4e
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $63 	;0,1,1,0,0,0,1,1
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $47 	;0,1,0,0,0,1,1,1

;0E  en $9d54
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $71 	;0,1,1,1,0,0,0,1
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $71 	;0,1,1,1,0,0,0,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $54 	;0,1,0,1,0,1,0,0

;0F  en $9d5a
	.byt $63 	;0,1,1,0,0,0,1,1
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1

;10  en $9d60
	.byt $69 	;0,1,1,0,1,0,0,1
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $72 	;0,1,1,1,0,0,1,0
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $72 	;0,1,1,1,0,0,1,0

;11  en $9d66
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;12  en $9d6c
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;13  en $9d72
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;14  en $9d78
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1

;15  en $9d7e
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1

;16  en $9d84
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1

;17  en $9d8a
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;18  en $9d90
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;19  en $9d96
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1

;1A  en $9d9c
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0

;1B  en $9da2
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;1C  en $9da8
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $dc 	;1,1,0,1,1,1,0,0

;1D  en $9dae
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1

;1E  en $9db4
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $ec 	;1,1,1,0,1,1,0,0

;1F  en $9dba
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $d1 	;1,1,0,1,0,0,0,1
	.byt $c1	;1,1,0,0,0,0,0,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;20  en $9dc0
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0

;21  en $9dc6
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $76 	;0,1,1,1,0,1,1,0

;22  en $9dcc
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1

;23  en $9dd2
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;24  en $9dd8
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0

;25  en $9dde
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0

;26  en $9de4
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $ce 	;1,1,0,0,1,1,1,0

;27  en $9dea
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;28  en $9df0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c7 	;1,1,0,0,0,1,1,1
	.byt $cd 	;1,1,0,0,1,1,0,1

;29  en $9df6
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0

dta_car_redef_p2
;2A  en $9dfc
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $c7 	;1,1,0,0,0,1,1,1

;2B  en $9e02
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e2 	;1,1,1,0,0,0,1,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;2C  en $9e08
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1

;2D  en $9e0e
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0

;2E  en $9e14
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c6 	;1,1,0,0,0,1,1,0

;2F  en $9e1a
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e4 	;1,1,1,0,0,1,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0

;30  en $9e20
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1

;31  en $9e26
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0

;32  en $9e2c
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0

;33  en $9e32
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0

;34  en $9e38
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $5f 	;0,1,0,1,1,1,1,1

;35  en $9e3e
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $7c 	;0,1,1,1,1,1,0,0

;36  en $9e44
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0

;37  en $9e4a
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;38  en $9e50
	.byt $DE	;1,1,0,1,1,1,1,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1

; ------------------------------------
dta_bandeau
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$40,$02,$7F,$47,$78,$00,$02,$40,$58,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$03,$40,$41,$7F,$43,$7C,$00,$03,$40,$7C,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$02,$40,$47,$7E,$41,$12,$10,$40,$41,$7E,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$03,$40,$4F,$7E,$41,$13,$10,$40,$47,$7C,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$02,$40,$41,$7E,$4F,$7F,$60,$40,$7F,$7C,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$03,$40,$43,$7E,$4F,$7F,$78,$41,$7F,$7E,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$02,$40,$4F,$7C,$47,$7F,$7C,$41,$7F,$7E,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$03,$40,$47,$78,$4F,$7F,$7C,$41,$7F,$7E,$00,$04,$01,$41,$7F,$70,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$01,$40,$4F,$7F,$70,$00,$04,$00,$04,$40,$40,$40,$02,$43,$7F,$78,$47,$7F,$7E,$00,$01,$40,$4F,$7F,$11,$10,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
.byt $00,$04,$00,$04,$01,$40,$7C,$47,$70,$43,$7F,$7F,$7E,$40,$40,$40,$03,$47,$7F,$60,$47,$7F,$7E,$00,$7F,$01,$7F,$60,$7F,$70,$40,$41,$7F,$7F,$7E,$00,$04,$00,$04,$0
.byt $00,$04,$00,$04,$01,$41,$70,$41,$70,$40,$5F,$7F,$7F,$60,$40,$40,$02,$5E,$78,$40,$4F,$7F,$7E,$00,$01,$43,$78,$40,$43,$7C,$40,$40,$4F,$7F,$7F,$70,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$43,$60,$40,$70,$40,$4F,$60,$4F,$70,$40,$03,$41,$78,$40,$04,$13,$00,$41,$10,$01,$4F,$60,$40,$00,$11,$7F,$7F,$78,$4F,$78,$47,$10,$04,$00,$4
.byt $00,$04,$00,$01,$40,$47,$60,$40,$70,$40,$4F,$60,$47,$78,$40,$40,$40,$40,$02,$43,$7F,$7F,$7C,$00,$01,$5F,$40,$40,$40,$5F,$60,$40,$47,$70,$41,$7C,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$47,$40,$40,$50,$40,$4F,$60,$43,$7C,$40,$40,$40,$40,$03,$4F,$7F,$7F,$78,$00,$01,$7E,$40,$40,$40,$4F,$70,$40,$47,$70,$40,$7E,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$47,$60,$40,$00,$01,$4F,$60,$41,$7C,$40,$40,$40,$02,$4C,$7F,$7F,$7F,$78,$01,$41,$7C,$40,$40,$40,$47,$78,$40,$47,$70,$40,$7E,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$47,$60,$40,$00,$01,$4F,$60,$41,$7C,$40,$40,$40,$03,$47,$7F,$7F,$7F,$78,$40,$01,$78,$40,$40,$40,$43,$78,$40,$47,$70,$40,$5F,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$47,$70,$40,$40,$40,$4F,$60,$40,$7C,$40,$40,$02,$5F,$7F,$7F,$7F,$7F,$78,$01,$43,$78,$40,$40,$40,$43,$7C,$40,$47,$70,$40,$5F,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$43,$78,$40,$40,$40,$4F,$60,$40,$7C,$40,$40,$03,$47,$7F,$7F,$7F,$7F,$78,$01,$43,$70,$40,$40,$40,$41,$7C,$40,$47,$70,$40,$5F,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$43,$7C,$40,$40,$40,$4F,$60,$40,$7C,$40,$40,$40,$02,$5F,$7F,$7F,$7F,$7C,$01,$47,$70,$40,$40,$40,$41,$7E,$40,$47,$70,$40,$5E,$00,$04,$00,$4
.byt $00,$04,$00,$01,$40,$41,$7F,$40,$40,$40,$4F,$60,$41,$78,$40,$40,$40,$03,$4F,$7F,$7F,$7F,$7C,$01,$47,$70,$40,$40,$40,$41,$7E,$40,$47,$70,$40,$5E,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$01,$7F,$60,$40,$40,$4F,$60,$41,$78,$40,$40,$40,$02,$47,$7F,$7F,$7F,$7E,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$70,$40,$5C,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$01,$5F,$78,$40,$40,$4F,$60,$43,$70,$40,$40,$40,$03,$43,$7F,$7F,$7F,$7E,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$70,$40,$5C,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$01,$47,$7C,$40,$40,$4F,$60,$47,$60,$40,$40,$40,$02,$41,$7F,$7F,$7F,$7F,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$70,$40,$78,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$01,$43,$7F,$40,$40,$4F,$60,$5E,$40,$00,$7F,$7F,$03,$43,$7F,$7F,$7F,$7F,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$70,$41,$70,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$11,$5F,$7F,$70,$58,$47,$7F,$10,$7F,$7F,$02,$41,$7F,$7F,$7F,$7F,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$7F,$7F,$60,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$01,$5F,$60,$40,$4F,$60,$40,$40,$00,$7F,$7F,$03,$42,$7F,$7F,$7F,$7F,$01,$47,$70,$40,$40,$40,$40,$7E,$40,$47,$7F,$7F,$60,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$01,$4F,$70,$40,$4F,$60,$40,$40,$00,$7F,$7F,$02,$43,$7F,$7F,$7F,$4E,$01,$47,$78,$40,$40,$40,$41,$7C,$40,$47,$70,$47,$70,$00,$04,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$01,$47,$70,$40,$4F,$60,$40,$40,$00,$7F,$7F,$03,$47,$7F,$7C,$7E,$40,$01,$43,$78,$40,$40,$40,$41,$7C,$40,$47,$70,$47,$78,$40,$00,$04,$0
.byt $00,$04,$00,$04,$40,$40,$01,$43,$78,$40,$4F,$60,$40,$40,$02,$46,$4F,$60,$5F,$7F,$70,$4C,$40,$01,$43,$78,$40,$40,$40,$41,$78,$40,$47,$70,$43,$7C,$40,$00,$04,$0
.byt $00,$04,$00,$04,$40,$40,$01,$41,$78,$40,$4F,$60,$40,$40,$03,$4F,$7F,$7F,$7F,$7F,$60,$40,$40,$01,$43,$7C,$40,$40,$40,$43,$78,$40,$47,$70,$41,$7E,$40,$00,$04,$0
.byt $00,$04,$00,$04,$40,$40,$01,$41,$78,$40,$4F,$60,$40,$40,$02,$4F,$7F,$7F,$7F,$7F,$60,$40,$40,$01,$41,$7E,$40,$40,$40,$43,$70,$40,$47,$70,$40,$7F,$40,$00,$04,$0
.byt $00,$04,$00,$04,$01,$48,$40,$41,$70,$40,$4F,$60,$40,$40,$03,$4F,$7F,$7F,$7F,$7F,$60,$40,$40,$40,$01,$7F,$40,$40,$40,$47,$60,$40,$47,$70,$40,$5F,$40,$00,$04,$0
.byt $00,$04,$00,$01,$40,$48,$40,$41,$70,$40,$4F,$60,$40,$40,$02,$4F,$7F,$7F,$7F,$7E,$40,$40,$40,$40,$01,$5F,$60,$40,$40,$4F,$40,$40,$47,$70,$40,$4F,$70,$00,$04,$0
.byt $00,$04,$00,$01,$40,$4C,$40,$43,$60,$40,$4F,$60,$40,$40,$03,$4F,$7F,$7F,$7F,$70,$40,$40,$40,$40,$01,$4F,$70,$40,$40,$5E,$40,$40,$47,$70,$40,$47,$78,$00,$04,$0
.byt $00,$04,$00,$01,$40,$4E,$40,$47,$40,$40,$4F,$60,$40,$40,$02,$4F,$7F,$7F,$7F,$60,$40,$40,$40,$40,$01,$47,$7C,$40,$41,$7C,$40,$40,$47,$70,$40,$43,$7C,$00,$04,$0
.byt $00,$04,$00,$01,$40,$4F,$40,$4E,$40,$40,$4F,$60,$40,$40,$03,$4F,$7F,$7F,$7F,$40,$40,$40,$40,$40,$01,$41,$7F,$70,$5F,$7E,$40,$40,$47,$70,$40,$41,$7E,$00,$04,$0
.byt $00,$04,$00,$01,$40,$4F,$7F,$7C,$40,$40,$5F,$60,$40,$40,$02,$4F,$7F,$7F,$7E,$40,$40,$40,$40,$40,$40,$01,$5F,$7F,$7F,$7F,$60,$40,$47,$70,$40,$40,$7F,$60,$00,$4
.byt $00,$04,$00,$7F,$7F,$01,$5F,$40,$40,$41,$7F,$7E,$40,$40,$03,$5F,$7F,$7F,$7E,$40,$40,$40,$40,$40,$40,$40,$01,$7F,$70,$5F,$7C,$40,$7F,$7F,$40,$40,$4F,$7E,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$02,$5F,$7F,$7F,$7F,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$43,$7F,$40,$40,$40,$40,$40,$40,$00,$04,$0
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$03,$5F,$7F,$7F,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$7F,$78,$40,$40,$40,$40,$40,$00,$04,$0
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$02,$4F,$7F,$7F,$70,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$4F,$7E,$40,$40,$40,$40,$40,$00,$04,$0
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$03,$5F,$7F,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$41,$7F,$78,$40,$40,$40,$40,$00,$04,$0
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$02,$4E,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$4F,$7F,$60,$40,$4F,$40,$40,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$03,$44,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$41,$7F,$7F,$7F,$78,$40,$40,$00,$4
.byt $00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$01,$47,$7F,$7E,$40,$40,$40,$00,$04,$0a


ptr_dta_lieux

.byt <d_gallia,>d_gallia
.byt <d_hispania,>d_hispania
.byt <d_lusitania,>d_lusitania
.byt <d_britania,>d_britania
.byt <d_Germania,>d_Germania
.byt <d_caledonia,>d_caledonia
.byt <d_hibernia,>d_hibernia
.byt <d_Mare_n,>d_Mare_n
.byt <d_Mare_e,>d_Mare_e
.byt <d_Mare_g,>d_Mare_g

;--------------------------------------------------
d_gallia

	.byt $60,$0e,$09							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$40,$79,$73,$60,$40
	.byt $2,$41,$7E,$40,$40,$79,$73,$60,$40
	.byt $3,$47,$7F,$40,$40,$79,$73,$60,$40
	.byt $2,$4F,$41,$40,$40,$79,$70,$40,$40
	.byt $3,$4E,$40,$47,$78,$79,$73,$63,$7C
	.byt $2,$5C,$40,$4F,$7C,$79,$73,$67,$7E
	.byt $3,$5C,$40,$48,$5C,$79,$73,$64,$4E
	.byt $2,$5C,$5F,$40,$5C,$79,$73,$60,$4E
	.byt $3,$5C,$5F,$47,$7C,$79,$73,$63,$7E
	.byt $2,$5C,$47,$4F,$7C,$79,$73,$67,$7E
	.byt $3,$4E,$47,$4E,$5C,$79,$73,$67,$4E
	.byt $2,$4F,$47,$4E,$5C,$79,$73,$67,$4E
	.byt $3,$47,$7F,$4F,$7C,$79,$73,$67,$7E
	.byt $2,$41,$7E,$47,$7C,$79,$73,$63,$7E

;--------------------------------------------------
d_hispania

	.byt $5d,$12,$0e							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$4E,$40,$40,$40,$40,$40,$40,$41,$70,$40
	.byt $2,$40,$5C,$4E,$4E,$40,$40,$40,$40,$40,$40,$41,$70,$40
	.byt $3,$40,$5C,$4E,$4E,$40,$40,$40,$40,$40,$40,$41,$70,$40
	.byt $2,$40,$5C,$4E,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$40,$5C,$4E,$4E,$4F,$47,$5C,$47,$78,$7B,$71,$71,$7E
	.byt $2,$40,$5C,$4E,$4E,$5F,$67,$7E,$4F,$7C,$7F,$79,$73,$7F
	.byt $3,$40,$5F,$7E,$4E,$58,$67,$6F,$48,$5C,$7C,$79,$72,$47
	.byt $2,$40,$5F,$7E,$4E,$5C,$47,$47,$40,$5C,$78,$79,$70,$47
	.byt $3,$40,$5C,$4E,$4E,$5F,$47,$47,$47,$7C,$78,$79,$71,$7F
	.byt $2,$40,$5C,$4E,$4E,$47,$77,$47,$4F,$7C,$78,$79,$73,$7F
	.byt $3,$40,$5C,$4E,$4E,$41,$77,$47,$4E,$5C,$78,$79,$73,$67
	.byt $2,$40,$5C,$4E,$4E,$51,$77,$6F,$4E,$5C,$78,$79,$73,$67
	.byt $3,$40,$5C,$4E,$4E,$5F,$77,$7E,$4F,$7C,$78,$79,$73,$7F
	.byt $2,$40,$5C,$4E,$4E,$4F,$47,$5C,$47,$7C,$78,$79,$71,$7F
	.byt $3,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $2,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $2,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40

;--------------------------------------------------
d_lusitania

	.byt $5d,$0e,$0f							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$78,$40,$40
	.byt $2,$41,$70,$40,$40,$40,$47,$40,$40,$40,$40,$40,$78,$40,$40
	.byt $3,$41,$70,$40,$40,$40,$47,$47,$40,$40,$40,$40,$78,$40,$40
	.byt $2,$41,$70,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$41,$70,$4E,$4E,$4F,$47,$5F,$73,$7C,$5D,$78,$78,$7F,$40
	.byt $2,$41,$70,$4E,$4E,$5F,$67,$5F,$77,$7E,$5F,$7C,$79,$7F,$60
	.byt $3,$41,$70,$4E,$4E,$58,$67,$47,$44,$4E,$5E,$5C,$79,$43,$60
	.byt $2,$41,$70,$4E,$4E,$5C,$47,$47,$40,$4E,$5C,$5C,$78,$43,$60
	.byt $3,$41,$70,$4E,$4E,$5F,$47,$47,$43,$7E,$5C,$5C,$78,$7F,$60
	.byt $2,$41,$70,$4E,$4E,$47,$77,$47,$47,$7E,$5C,$5C,$79,$7F,$60
	.byt $3,$41,$70,$4E,$4E,$41,$77,$47,$47,$4E,$5C,$5C,$79,$73,$60
	.byt $2,$41,$70,$4E,$5E,$51,$77,$47,$47,$4E,$5C,$5C,$79,$73,$60
	.byt $3,$41,$7F,$4F,$7E,$5F,$77,$47,$77,$7E,$5C,$5C,$79,$7F,$60
	.byt $2,$41,$7F,$47,$6E,$4F,$47,$43,$73,$7E,$5C,$5C,$78,$7F,$60

;--------------------------------------------------
d_britania

	.byt $5e,$0e,$0d							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$41,$70,$40,$40,$40,$40,$4E,$40,$40
	.byt $2,$43,$7E,$40,$41,$70,$40,$40,$40,$40,$4E,$40,$40
	.byt $3,$43,$7F,$60,$41,$71,$70,$40,$40,$40,$4E,$40,$40
	.byt $2,$43,$63,$60,$40,$41,$70,$40,$40,$40,$40,$40,$40
	.byt $3,$43,$63,$63,$6D,$77,$7C,$7F,$47,$5E,$4E,$4F,$70
	.byt $2,$43,$63,$63,$7D,$77,$7D,$7F,$67,$7F,$4E,$5F,$78
	.byt $3,$43,$7E,$43,$71,$71,$71,$43,$67,$67,$4E,$50,$78
	.byt $2,$43,$7F,$63,$61,$71,$70,$43,$67,$47,$4E,$40,$78
	.byt $3,$43,$63,$73,$61,$71,$70,$7F,$67,$47,$4E,$4F,$78
	.byt $2,$43,$61,$73,$61,$71,$71,$7F,$67,$47,$4E,$5F,$78
	.byt $3,$43,$61,$73,$61,$71,$71,$73,$67,$47,$4E,$5C,$78
	.byt $2,$43,$63,$73,$61,$71,$71,$73,$67,$47,$4E,$5C,$78
	.byt $3,$43,$7F,$63,$61,$71,$7D,$7F,$67,$47,$4E,$5F,$78
	.byt $2,$43,$7F,$43,$61,$70,$7C,$7F,$67,$47,$4E,$4F,$78


;--------------------------------------------------
d_Germania

	.byt $5d,$0e,$0f							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$47,$40,$40
	.byt $2,$43,$7C,$40,$40,$40,$40,$40,$40,$40,$40,$40,$47,$40,$40
	.byt $3,$4F,$7E,$40,$40,$40,$40,$40,$40,$40,$40,$40,$47,$40,$40
	.byt $2,$5E,$42,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$5C,$40,$47,$70,$7B,$5D,$79,$78,$5F,$63,$6F,$47,$47,$78
	.byt $2,$78,$40,$4F,$78,$7F,$5F,$7F,$7C,$7F,$73,$7F,$67,$4F,$7C
	.byt $3,$78,$40,$4C,$5C,$7C,$5E,$5E,$5C,$61,$73,$73,$67,$48,$5C
	.byt $2,$78,$7E,$5C,$5C,$78,$5C,$5C,$5C,$41,$73,$63,$67,$40,$5C
	.byt $3,$78,$7E,$5F,$7C,$78,$5C,$5C,$5C,$5F,$73,$63,$67,$47,$7C
	.byt $2,$78,$4E,$5F,$7C,$78,$5C,$5C,$5C,$7F,$73,$63,$67,$4F,$7C
	.byt $3,$5C,$4E,$5C,$40,$78,$5C,$5C,$5C,$79,$73,$63,$67,$4E,$5C
	.byt $2,$5E,$4E,$5E,$44,$78,$5C,$5C,$5C,$79,$73,$63,$67,$4E,$5C
	.byt $3,$4F,$7E,$4F,$7C,$78,$5C,$5C,$5C,$7F,$73,$63,$67,$4F,$7C
	.byt $2,$43,$7C,$47,$78,$78,$5C,$5C,$5C,$5F,$73,$63,$67,$47,$7C

;--------------------------------------------------
d_caledonia

	.byt $5e,$0e,$0f							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$40,$40,$40,$47,$40,$40,$40,$5C,$40,$40,$40,$43,$60,$40
	.byt $2,$43,$78,$40,$47,$40,$40,$40,$5C,$40,$40,$40,$43,$60,$40
	.byt $3,$4F,$7C,$40,$47,$40,$40,$40,$5C,$40,$40,$40,$43,$60,$40
	.byt $2,$5E,$44,$40,$47,$40,$40,$40,$5C,$40,$40,$40,$40,$40,$40
	.byt $3,$5C,$40,$7F,$47,$43,$78,$47,$5C,$47,$71,$77,$63,$63,$7C
	.byt $2,$78,$41,$7F,$67,$47,$7C,$4F,$7C,$5F,$79,$7F,$73,$67,$7E
	.byt $3,$78,$41,$43,$67,$46,$4E,$5E,$7C,$5C,$7D,$79,$73,$64,$4E
	.byt $2,$78,$40,$43,$67,$4E,$4E,$5C,$5C,$78,$5D,$71,$73,$60,$4E
	.byt $3,$78,$40,$7F,$67,$4F,$7E,$5C,$5C,$78,$5D,$71,$73,$63,$7E
	.byt $2,$78,$41,$7F,$67,$4F,$7E,$5C,$5C,$78,$5D,$71,$73,$67,$7E
	.byt $3,$7C,$41,$73,$67,$4E,$40,$5C,$5C,$78,$5D,$71,$73,$67,$4E
	.byt $2,$5E,$45,$73,$67,$4F,$42,$5E,$7C,$7C,$79,$71,$73,$67,$4E
	.byt $3,$4F,$7D,$7F,$67,$47,$7E,$4F,$7C,$5F,$79,$71,$73,$67,$7E
	.byt $2,$47,$78,$7F,$67,$43,$7C,$47,$5C,$4F,$61,$71,$73,$63,$7E

;--------------------------------------------------
d_hibernia

	.byt $5f,$0d,$0d							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $3,$78,$5C,$5C,$78,$40,$40,$40,$40,$40,$43,$60,$40
	.byt $2,$78,$5C,$5C,$78,$40,$40,$40,$40,$40,$43,$60,$40
	.byt $3,$78,$5C,$40,$78,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $2,$78,$5C,$5C,$7B,$60,$5F,$43,$6D,$77,$63,$63,$7C
	.byt $3,$78,$5C,$5C,$7F,$70,$7F,$63,$7D,$7F,$73,$67,$7E
	.byt $2,$7F,$7C,$5C,$7D,$78,$71,$73,$71,$79,$73,$64,$4E
	.byt $3,$7F,$7C,$5C,$78,$79,$71,$73,$61,$71,$73,$60,$4E
	.byt $2,$78,$5C,$5C,$78,$79,$7F,$73,$61,$71,$73,$63,$7E
	.byt $3,$78,$5C,$5C,$78,$79,$7F,$73,$61,$71,$73,$67,$7E
	.byt $2,$78,$5C,$5C,$78,$79,$70,$43,$61,$71,$73,$67,$4E
	.byt $3,$78,$5C,$5C,$7D,$79,$78,$53,$61,$71,$73,$67,$4E
	.byt $2,$78,$5C,$5C,$7F,$70,$7F,$73,$61,$71,$73,$67,$7E
	.byt $3,$78,$5C,$5C,$7B,$60,$5F,$63,$61,$71,$73,$63,$7E

;--------------------------------------------------
d_Mare_n

	.byt $aa,$0d,$16							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $4,$7E,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$7E,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$43,$60,$40,$40,$40,$40,$40,$40
	.byt $4,$7F,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$43,$60,$40,$40,$40,$40,$40,$40
	.byt $6,$7F,$47,$78,$5F,$63,$6C,$5F,$40,$47,$5E,$41,$7C,$4F,$4F,$7B,$6D,$71,$73,$6F,$4F,$40
	.byt $4,$7B,$46,$78,$7F,$73,$7C,$7F,$60,$47,$7F,$47,$7E,$5F,$6F,$7B,$7D,$71,$73,$7F,$7F,$60
	.byt $6,$7B,$46,$78,$61,$73,$70,$71,$70,$47,$67,$47,$4F,$58,$63,$63,$71,$71,$73,$73,$73,$60
	.byt $4,$7B,$6E,$78,$41,$73,$61,$71,$70,$47,$47,$4E,$47,$5C,$43,$63,$61,$71,$73,$63,$63,$60
	.byt $6,$79,$6C,$78,$5F,$73,$61,$7F,$70,$47,$47,$4E,$47,$5F,$43,$63,$61,$71,$73,$63,$63,$60
	.byt $4,$79,$6C,$78,$7F,$73,$61,$7F,$70,$47,$47,$4E,$47,$47,$73,$63,$61,$71,$73,$63,$63,$60
	.byt $6,$79,$7C,$78,$79,$73,$61,$70,$40,$47,$47,$4E,$47,$41,$73,$63,$61,$71,$73,$63,$63,$60
	.byt $4,$79,$78,$78,$79,$73,$61,$78,$50,$47,$47,$4F,$4E,$51,$73,$63,$61,$73,$73,$63,$63,$60
	.byt $6,$78,$78,$78,$7F,$73,$60,$7F,$70,$47,$47,$47,$7E,$5F,$73,$7B,$61,$7F,$73,$63,$63,$60
	.byt $4,$78,$78,$78,$5F,$73,$60,$5F,$60,$47,$47,$43,$78,$4F,$41,$7B,$60,$7D,$73,$63,$63,$60
;--------------------------------------------------
d_Mare_e

	.byt $a8,$0d,$19							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $4,$41,$7C,$47,$70,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$41,$7C,$47,$70,$40,$40,$40,$40,$40,$40,$40,$40,$40,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $4,$41,$7E,$47,$70,$40,$40,$40,$40,$40,$40,$40,$40,$40,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$41,$7E,$4F,$70,$7F,$47,$58,$7E,$40,$43,$78,$5C,$5B,$7E,$4F,$61,$76,$7B,$71,$71,$73,$6F,$4F,$40
	.byt $4,$41,$76,$4D,$71,$7F,$67,$79,$7F,$40,$47,$7C,$5C,$73,$7E,$5F,$71,$7E,$7F,$79,$71,$73,$7F,$7F,$60
	.byt $6,$41,$76,$4D,$71,$43,$67,$61,$63,$60,$46,$4E,$4D,$70,$78,$58,$79,$78,$7C,$79,$71,$73,$73,$73,$60
	.byt $4,$41,$77,$5D,$70,$43,$67,$43,$63,$60,$4E,$4E,$4F,$60,$78,$78,$79,$70,$78,$79,$71,$73,$63,$63,$60
	.byt $6,$41,$73,$59,$70,$7F,$67,$43,$7F,$60,$4F,$7E,$47,$60,$78,$7F,$79,$70,$78,$79,$71,$73,$63,$63,$60
	.byt $4,$41,$73,$59,$71,$7F,$67,$43,$7F,$60,$4F,$7E,$47,$60,$78,$7F,$79,$70,$78,$79,$71,$73,$63,$63,$60
	.byt $6,$41,$73,$79,$71,$73,$67,$43,$60,$40,$4E,$40,$4D,$70,$78,$78,$41,$70,$78,$79,$71,$73,$63,$63,$60
	.byt $4,$41,$73,$71,$71,$73,$67,$43,$70,$60,$4F,$42,$5D,$70,$78,$7C,$49,$70,$78,$79,$73,$73,$63,$63,$60
	.byt $6,$41,$71,$71,$71,$7F,$67,$41,$7F,$60,$47,$7E,$5C,$78,$7E,$5F,$79,$70,$78,$79,$7F,$73,$63,$63,$60
	.byt $4,$41,$71,$71,$70,$7F,$67,$40,$7F,$40,$43,$7C,$7C,$7C,$5E,$4F,$71,$70,$78,$78,$7D,$73,$63,$63,$60

;--------------------------------------------------
d_Mare_g

	.byt $a7,$11,$1c							; Partie basse adresse début 1ere ligne (partie haute = $b9),Nb de lignes , Nb de colonnes
	.byt $4,$7E,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$7E,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$47,$40,$40,$40,$40,$40,$40,$40
	.byt $4,$7F,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$7F,$47,$78,$5F,$63,$6C,$5F,$40,$41,$7F,$47,$70,$7B,$5D,$79,$78,$5F,$63,$6F,$47,$43,$71,$71,$73,$6F,$4F,$40
	.byt $4,$7B,$46,$78,$7F,$73,$7C,$7F,$60,$47,$7E,$4F,$78,$7F,$5F,$7F,$7C,$7F,$73,$7F,$67,$47,$79,$71,$73,$7F,$7F,$60
	.byt $6,$7B,$46,$78,$61,$73,$70,$71,$70,$46,$4C,$4C,$5C,$7C,$5E,$5E,$5C,$61,$73,$73,$67,$4F,$49,$71,$73,$73,$73,$60
	.byt $4,$7B,$6E,$78,$41,$73,$61,$71,$70,$46,$4C,$5C,$5C,$78,$5C,$5C,$5C,$41,$73,$63,$67,$4E,$41,$71,$73,$63,$63,$60
	.byt $6,$79,$6C,$78,$5F,$73,$61,$7F,$70,$46,$4C,$5F,$7C,$78,$5C,$5C,$5C,$5F,$73,$63,$67,$4E,$41,$71,$73,$63,$63,$60
	.byt $4,$79,$6C,$78,$7F,$73,$61,$7F,$70,$47,$7C,$5F,$7C,$78,$5C,$5C,$5C,$7F,$73,$63,$67,$4E,$41,$71,$73,$63,$63,$60
	.byt $6,$79,$7C,$78,$79,$73,$61,$70,$40,$47,$78,$5C,$40,$78,$5C,$5C,$5C,$79,$73,$63,$67,$4E,$41,$71,$73,$63,$63,$60
	.byt $4,$79,$78,$78,$79,$73,$61,$78,$50,$46,$40,$5E,$44,$78,$5C,$5C,$5C,$79,$73,$63,$67,$4F,$49,$73,$73,$63,$63,$60
	.byt $6,$78,$78,$78,$7F,$73,$60,$7F,$70,$47,$7C,$4F,$7C,$78,$5C,$5C,$5C,$7F,$73,$63,$67,$47,$79,$7F,$73,$63,$63,$60
	.byt $4,$78,$78,$78,$5F,$73,$60,$5F,$60,$47,$7E,$47,$78,$78,$5C,$5C,$5C,$5F,$73,$63,$67,$43,$70,$7D,$73,$63,$63,$60
	.byt $6,$40,$40,$40,$40,$40,$40,$40,$40,$4E,$46,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $4,$40,$40,$40,$40,$40,$40,$40,$40,$4E,$46,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $6,$40,$40,$40,$40,$40,$40,$40,$40,$47,$7E,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $4,$40,$40,$40,$40,$40,$40,$40,$40,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40

;--------------------------------------------------

