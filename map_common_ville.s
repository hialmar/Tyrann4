; insert 0s so that to move the specific code upwards of $2000
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
on_a_clef_1 .dsb 1
;	$19	: 	drapeau : on a clef_2
on_a_clef_2 .dsb 1
;	$1a	:	drapeau : on a mot de passe :1
mot_de_passe .dsb 1
;	$1b :	drapeau : on a laissez-passer :1 on n'a pas laissez-passer : 0
laisser_passer .dsb 1
;	$1c :	N° lieu (GALLIA :0 HISPANIA :1 LUSITANIA :2 BRITANIA:3 GERMANIA :4 CALEDONIA:5 HIBERNIA :6 MARE NOSTRUM: 7 MARE EXTERNUM 8 MARE GERMANICUM 9
numero_lieu .dsb 1
;	$1d :	Nombre de coffres ramassés et non ouverts
nb_coffres_non_ouverts .dsb 1
;	$1e :	Drapeau pass donné par legat Londinium  pour centurion fort (initialisé à 0 uniquement sur carte générale si nouvelle partie)
mot_de_passe_londinium .dsb 1
;	$1f :	Drapeau poudre de corne de taureau =1 pas de poudre =0
poudre_de_taureau .dsb 1
;	$20 :	drapeau mot de passe pour phare (Brigantium)
mot_de_passe_phare .dsb 1
;   $50 : drapeau sortie victorieuse de la carte = $80 sinon = $20
sortie_victorieuse .dsb 1 ; drapeau sortie victorieuse de la carte = $80 sinon = $20
;
;

;;; STOP : 27 octets utilisés en page 0

	.text

ProgCombat
	.asc "COMBAT.COM"
	.byt 0

ProgArmory
	.asc "ARM.COM"
	.byt 0

ProgMap
	.asc "MAP.COM"
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

;------------------------------------------------------
; -----  routine attend appui touche puis relacher ---
;------------------------------------------------------ spécifique pour mon test
wait_key
.(
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
		bne wait_key
		beq end_key
;no_key
;		lda #$38
end_key
		sta direction_scroll
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
	beq chck_direction
	lda depl_perso_est_interdit
	bne fin_aff_perso
chck_direction
	lda direction_scroll
	cmp direction_scroll_prec				; direction précédente
	beq anim_perso		; si identique animation perso
	sta direction_scroll_prec				; si non nouvelle direction
	jsr choix_perso		; et choix nouveau perso
	beq skip_anim		; saut inconditionnel
anim_perso
	lda tuile_perso_aff				; $04 contient n° tuile perso affichée
	eor #1				; force le bit 0 alternativement à  0 ou à 1
	sta tuile_perso_aff				; et replace en  $04
skip_anim
	lda direction_scroll
	sta direction_scroll_prec
	ldx index_perso				;
	jsr maj_adr_scr_next_tuile			; en entrée x contient rang tuile dans  table adresses Hires
	ldx tuile_perso_aff
	jsr cherche_et_aff_tuile			; en entrée : X contient la reference de la tuile
fin_aff_perso
;	lda #FALSE
;	sta depl_perso_est_interdit
	rts
.)

;------ Choix tuile perso en fonction direction demandée   -----
choix_perso
.(
		lda direction_scroll
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
		sta tuile_perso_aff					; mémoire tuile perso affichée
		rts
.)

;---------------------------------------------------------------------
;- passe en mode HIRES et installe 12 atributs couleur jaune et cyan -
;---------------------------------------------------------------------	 routine spécifique l'emplacement choisie de la fenêtre
hires_et_atributs
.(
		jsr $EC33
		lda #CYAN_INK
		sta $Aa01
		sta $Aa51
		sta $AaA1
		sta $AaF1
		sta $Ab41
		sta $Ab91
		lda #YELLOW_INK
		sta $Aa29
		sta $Aa79
		sta $Aac9
		sta $Ab19
		sta $Ab69
		sta $Abb9

		lda #CYAN_INK
		sta $Abe1
		sta $Ac31
		sta $Ac81
		sta $Acd1
		sta $Ad21
		sta $Ad71
		lda #YELLOW_INK
		sta $Ac09
		sta $Ac59
		sta $Aca9
		sta $Acf9
		sta $Ad49
		sta $Ad99

		lda #CYAN_INK
		sta $Adc1
		sta $Ae11
		sta $Ae61
		sta $Aeb1
		sta $Af01
		sta $Af51
		lda #YELLOW_INK
		sta $Ade9
		sta $Ae39
		sta $Ae89
		sta $Aed9
		sta $Af29
		sta $Af79

		lda #CYAN_INK
		sta $Afa1
		sta $Aff1
		sta $b041
		sta $b091
		sta $b0e1
		sta $b131
		lda #YELLOW_INK
		sta $Afc9
		sta $b019
		sta $b069
		sta $b0b9
		sta $b109
		sta $b159

		lda #CYAN_INK
		sta $b181
		sta $b1d1
		sta $b221
		sta $b271
		sta $b2c1
		sta $b311
		lda #YELLOW_INK
		sta $b1a9
		sta $b1f9
		sta $b249
		sta $b299
		sta $b2e9
		sta $b339

		lda #CYAN_INK
		sta $b361
		sta $b3b1
		sta $b401
		sta $b451
		sta $b4a1
		sta $b4f1
		lda #YELLOW_INK
		sta $b389
		sta $b3d9
		sta $b429
		sta $b479
		sta $b4c9
		sta $b519

		lda #CYAN_INK
		sta $b541
		sta $b591
		sta $b5e1
		sta $b631
		sta $b681
		sta $b6d1
		lda #YELLOW_INK
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

;****            routine modi fifie map retire tuile spéciale une fois découverte              ****	
eff_tuile_spe
.(
		lda ordo_perso_fen
		clc
		adc ligne_hg_map
		tax				; n° ligne perso dans x
		lda absc_perso_fen
		clc
		adc rang_hg_map
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
		sta tuile_sous_pos_perso				; rappel : $0e contient ref de tuile sous perso
		rts	
.)

;-------------------------------------
do_you_enter
.(
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
.)
	
;************************************************
;*******  dessine cadre carte ville   ***********
;************************************************
cadre_plan
.(
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
	jsr prt_nom_ville
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
;***            Ecrit nom  ville            *****
;************************************************	
prt_nom_ville	
.(
	jsr ini_adr_dta_nv
	ldy #$0c
prt_lign
	ldx #$10
ad_dta_nv
	lda $1111,x
ad_ec_nv
	sta $BA9F,x
	dex
	bpl ad_dta_nv
	jsr maj_adr_nv
	dey
	bpl prt_lign
	rts	
;------------------------------------------------
ini_adr_dta_nv
	lda #<dta_nom_ville
	sta ad_dta_nv+1
	lda #>dta_nom_ville
	sta ad_dta_nv+2
	lda #$c4
	sta ad_ec_nv+1
	lda #$ba
	sta ad_ec_nv+2
	rts	
;------------------------------------------------
maj_adr_nv
	lda ad_dta_nv+1
	clc
	adc #$11
	sta ad_dta_nv+1
	bcc sk_ret1
	inc ad_dta_nv+2
sk_ret1
	lda ad_ec_nv+1
	clc
	adc #$28
	sta ad_ec_nv+1
	bcc sk_ret2
	inc ad_ec_nv+2
sk_ret2
	rts	
.)

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

;7A en $9fdc 	coffre (1/4)
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $59	;0,1,0,1,1,0,0,1

;7B en $9fe2	coffre (2/4)
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $74	;0,1,1,1,0,1,0,0
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $6e	;0,1,1,0,1,1,1,0

;7C en $9fe8 	coffre (3/4)
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $e6	;1,1,1,0,0,1,1,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0

;7D en $9fee 	coffre (4/4)
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	
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


