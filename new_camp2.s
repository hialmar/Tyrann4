;**********************************************
;**********  liste variables page 0  **********
;**********************************************

; $21 contient partie basse adresse texte
; $22 contient partie haute adresse texte
; $23 contient partie basse adresse ecranhire pour texte (1er car au début puis caar siuvant jusqu'à 0)
; $24 contient partie haute adresse ecranhire pour texte (1er car au début puis caar siuvant jusqu'à 0)
; $25 contient partie basse adresse ecranhire pour octet caractère puis evolue ($24 au debut puis 8 fois +#$28 pour afficher car complet)
; $26 contient partie haute adresse ecranhire pour octet caractère puis evolue ($24 au debut puis 8 fois +#$28 pour afficher car complet)
; $27 utilisé pour partie basse adresse masque Yeme ligne carractère
; $28 utilisé pour partie haute adresse masque Yeme ligne carractère
; $29 compteur d'octet pour aff_acarr (affiche un carractère)
; $2a longueur nom héro en cours (peut varier dans une boucle de 1 à 6) sert aussi d'index 
; $2b Longueur totale data extraites de TEAM.BIN  
; $2c index début data 1er perso (#$00) 
; $2d index début data 2ème perso (= $2c + $2a +(#$24 ou #$1c))
; $2e index début data 3ème perso (= $2d + $2a +(#$24 ou #$1c))
; $2f index début data 4ème perso (= $2e + $2a +(#$24 ou #$1c))
; $30 index début data 5ème perso (= $2f + $2a +(#$24 ou #$1c))
; $31 index début data 5ème perso (= $2f + $2a +(#$24 ou #$1c))

; $32 dizaines millers et centaines milliers pour calcul arithmétique BCD
; $33 millers et centaines pour calcul arithmétique BCD
; $34 unités et dizaines pour calcul arithmétique BCD
; $35 LL valeur Hexa pour calcul aritmétique BCD
; $36 hh valeur Hexa pour calcul aritmétique BCD
; $37 ll adresse debut data perso | ( adresse indexée par Y pour lires les data: lda ($36),Y )
; $38 hh adresse début data perso |
; $39 mémoire carrière (utilisée pour les sorts)
; $3a mémoire n° perso inspecté
; $3b mémoire n° perso receuveur (argent/objet ou soins)
;----
; $3c partie basse montant argent donné
; $3d partie haute montant argent donné
; $3e partie basse montant bourse perso inspecté
; $3f partie haute montant bourse perso inspecté
; $40 partie basse montant bourse perso receuveur
; $41 partie haute montant bourse perso receuveur




;---------------------------
;deb_all		;	Pour mémoire, génère un NB "pseudo aléatoire' entre 0 et 7
;	jsr get_key
;	lda $304
;	and #$07	; masque les bits b7,b6,b5,b4,b3	
;	sta $00		; nb stocké en $00
;	jmp deb_all ; pour faire autant d'essais que l'on veut
;----------------------------


;***********************************************
;***  simule CAMP (affichage 1er écran TXT)  ***
;***********************************************
new_camp
	jsr $ec33				; passe en HIRES ****** provisoire à supprimer  ****
	jsr eff_hires_complet
	jsr swap_0p_97p			; sauve variables Page 0 en page 97
	jsr $EC21				; Passe en mode TEXT (atmos)
	jsr swap_97p_0p			; restaure variables page 0
	jsr Main_dta_camp_hero	; Charge TEAM.BIN et ransfère data hero dans code new camp
lp_new_camp	
	jsr choix_option		; on n'en sort que sur appuis <espace> avec X=0, 1,2, 3 ou 4 mode TEXT
;--------------------
choix_1		; Examine a hero
	cpx #$01
	bne choix_2
	jsr menu_choix_hero
	stx $3a					;mémoire n° perso inspecté
mnu_bgmgo
	jsr insp_hero
	jsr mnu_back_spells_give
	cpx#$01					; cas "back" sélectionné	
	beq out_choix
	cpx #$02				; cas "spells" selctionné
	bne ch_give_money
	jsr spells_				;prévoir sous sous prog  aff_spells, mnu soin + traitement
	jmp out_choix
ch_give_money
	cpx #$03				; cas "give money" sélectionné
	bne ch_give_object
	jsr give_money			; prévoir ssp mnu_a_qui et combien + traitement
	ldx $3a
	bcc mnu_bgmgo				; cas d'un don nul,retour au choix spell don argent don objet
	jmp out_choix	
ch_give_object
	jsr give_object			; prévoir ssp mnu_a_qui et quoi + traitement
;	jmp out_choix_1	
out_choix
	jsr swap_0p_97p			; sauve variables Page 0 en page 97
	jsr $EC21				; passe en mode TEXT
	jsr swap_97p_0p			; restaure variables page 0	
	jmp lp_new_camp
;--------------------		
choix_2		; View the team en MODE TEXT
	cpx #$02
	bne choix_3	
	jsr view_team
	jmp lp_new_camp		
;--------------------		
choix_3		; Open a chest EN MODE HIRES
	cpx #$03
	bne choix_4	
	jsr open_chest
	jmp out_choix		
;--------------------		
choix_4		; have a rest en mode TEXT
	cpx #$04
	bne choix_5	
	jsr have_rest
	jmp lp_new_camp		
;--------------------
choix_5		; break camp 
						; dernier choix, donc sortie camp et retour ville
	jsr main_sav_team	; Sauve TEAM.BIN après transfert data depuis code camp  vers $A007 et sort de camp
;--------------------	
;fin_choix
	rts
;-------------------- efface écran HIRES complet avant  passage en TXT pour éviter GLitch --------------
eff_hires_complet
	
	ldy #$00			; partie basse adresse depart effaçage
	sty adr_h+1
	lda #$a0			; partie haute adresse départ effaçage
	sta adr_h+2
	lda #$37			; partie basse nb d'octets écran HIRES à éffaçer
	sta lp_y+1
	lda #$1f			; partie haute nb d'octets écran HIRES à éffaçer
	sta lp_y+5
	jsr eff_hires
	rts
;----------------     efface moitié inferieure  écran HIRES pour afficher liste hero     -----------------	
eff_demi_hires
	ldy #$18			; partie basse adresse depart effaçage
	sty adr_h+1
	lda #$b0			; partie haute adresse départ effaçage
	sta adr_h+2
	lda #$27			; partie basse nb d'octets écran HIRES à éffaçer
	sta lp_y+1
	lda #$0f			; partie haute nb d'octets écran HIRES à éffaçer
	sta lp_y+5	
	jsr eff_hires
	rts

;----------------     efface ecran hires selon données spécifiques  ----------------
eff_hires
	ldx #$00	
lp_y
	cpy #$37			; Partie basse nB octets écran HIRES a éffaçer
	bne ld_byt
	cpx #$1F			; Partie haute  nb octets écran HIRES à éffaçer
	beq out_eH			; on continue jusqu'à Y= partie basse et X = Partie haute
ld_byt	
	lda #$00
adr_h	
	sta $A000,y
	iny
	bne lp_y
	inc adr_h+2			; increment partie haute adresse écran HIRES
	inx					; page suivante
	jmp lp_y
out_eH
	rts
;-------------------- efface écran TXT avant  retour menu camp --------------

eff_TXT

	ldx #$00
	ldy #$00
	lda #$a8
	sta adr_h_t+1
	lda #$bb
	sta adr_h_t+2
lp_y_t
	cpy #$37				; Partie basse nB octets écran HIRES
	bne ld_byt_t
	cpx #$04				; Partie haute  nb octets écran HIRES
	beq out_eH_t			; on continue jusqu'à Y= partie basse et X = Partie haute
ld_byt_t	
	lda #$20
adr_h_t	
	sta $BBA8,y
	iny
	bne lp_y
	inc adr_h_t+2			; increment partie haute adresse écran HIRES
	inx						; page suivante
	jmp lp_y_t
out_eH_t
	rts

;-------------------- construit écran options menu deroulant option --------------	
choix_option
	lda #$00
	sta $bba3				; encre noire sur CAPS
	jsr aff_options
	jsr menu_deroul_ch_act
	rts
;--------------------
aff_options
		ldx #$00
lp_aff_op	
		jsr ini_adr_mnu_camp
		jsr ini_adr_ecr_mnu_camp
		jsr Ecr_LT_mnu
		inx
		cpx #$1a
		bne lp_aff_op
; --- ajout pour intégrer noms héros issus de team.bin (et plus noms fixes en dur)
			ldx #$00		
lp_nm_hero			
			jsr nm_hero_team	; transfère un nom de data issues de team.bin
			inx					; nom suivant
			cpx #$06			; nb de noms à transférer
			bne lp_nm_hero
; --- fin ajout	---			
	
		rts
;--------------------
;Routine init adress message dans $21-$22		
ini_adr_mnu_camp
			txa
			pha
			lda ptr_dta_mnu,X
			sta $21			;$21 contient partie basse adresse texte
			inx
			lda ptr_dta_mnu,X
			sta $22			;$22 contient partie haute adresse texte
			pla
			tax
		rts
;--------------------
LL_adr_scr_nm_hero
	.byt $34,$84,$d4,$3e,$8e,$de
;--------------------
nm_hero_team
	txa
	pha							; sauve sur la pile le nb de nom restant à tranférer
	ldy #$00					; compteur de lettre des noms
	lda LL_adr_scr_nm_hero,x	; partie basse adresse ecran nom hero pour menu
	sta adr_ecr_nm_p+1		   	; placée dans code à la place de 11	
	lda $2c,x					; longueur totale data "devant" nom héro en cours
	tax							; en index
	lda dta_kaeso,x				; longeur nom en cours
	sta $2a						; sauvée dans $2a
	inx							; carractère suivant
lp_tr_nm	
	lda dta_kaeso,x				; prends carractère nom
adr_ecr_nm_p	
	sta $be11,y					; la place à l'écran TEXT
	inx							; carrac suivant dans data 
	iny							; compteru nb Carrac pour boucle
	cpy $2a						; fin du nom?
	bne lp_tr_nm				; Non, alors on boucle
	pla							; Oui alors on récupère sur la pile
	tax							; le N° du nom qui vient d'être transféré
	rts

;--------------------
;Sous Routine init adresse écran dans $23-$24
ini_adr_ecr_mnu_camp
			lda dta_adr_mnu,x
			sta $23			;$23-24 contient  adresse
			inx
			lda dta_adr_mnu,x	;début ligne HIRES des texte	
			sta $24
			rts
;--------------------	
; sous routine ecrit une ligne texte du menu camp	
Ecr_LT_mnu
loop_2_mnu  
			jsr Pr_ltr		;A=0 si fin ligne texte
			beq out_2_mnu
			sta($23),y
			inc $23
			bne skip_2_mnu
			inc $24
skip_2_mnu
			jmp loop_2_mnu
out_2_mnu
			rts	
;------------ menu déroulant choix action -----
; sortie X pointe sur option choisie : 0 Inspect hero, 1 View team....
menu_deroul_ch_act
	ldx #$01
chk_kbd
	lda $208
	cmp #$38
	beq chk_kbd
y_208	
	ldy $208
	cpy #$38
	bne y_208
	cmp #$B4			; touche flêche vers le bas
	bne ckh_9c			; vers chk Arrow Up
	inx
	cpx #$06
	bne suite_mnu
	ldx #$01
	jmp suite_mnu
ckh_9c
	cmp #$9c			; touche flêche vers le haut
	bne chk_84m
	dex
	bne suite_mnu  
	ldx #$05			; on pointe le ligne 0 (camp)  alors ligne 5 (break camp)
	jmp suite_mnu
chk_84m	
	cmp #$84		
	bne chk_kbd
	JMP fin_mnu_a
suite_mnu
	cmp #$b4			;Sens vers le Bas (test 1ère touche autorisée)
	bne sens_vh
	lda #$10			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$01
	bne chk_x02b
	sta $bd43
	sty $bc03
	jmp chk_kbd
chk_x02b
	cpx #$02
	bne chk_x03b
	sta $bc03
	sty $bc53
	jmp chk_kbd
chk_x03b
	cpx #$03
	bne chk_x04b
	sta $bc53
	sty $bca3
	jmp chk_kbd
chk_x04b
	cpx #$04
	bne chk_x05b
	sta $bca3
	sty $bcf3
	jmp chk_kbd
chk_x05b
	sta $bcf3
	sty $bd43
	jmp chk_kbd
;----	
sens_vh
;	pla
	cmp #$9c			;Sens vers le haut (test 2 ème touche autorisée)
	bne chk_84			;aller tester 3 ème touche autorisée (espace)
	lda #$10			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$01
	bne chk_x02h
	sta $bc53
	sty $bc03
	jmp chk_kbd
chk_x02h
	cpx #$02
	bne chk_x03h
	sta $bca3
	sty $bc53
	jmp chk_kbd
chk_x03h
	cpx #$03
	bne chk_x04h
	sta $bcf3
	sty $bca3
	jmp chk_kbd
chk_x04h	
	cpx #$04
	bne chk_x05h
	sta $bd43
	sty $bcf3
	jmp chk_kbd	
chk_x05h
	sta $bc03
	sty $bd43
	jmp chk_kbd
chk_84
	cmp #$84
	beq fin_mnu_a
	jmp chk_kbd
fin_mnu_a	
	rts
;*************************************************************
;*************************************************************
;------------ menu déroulant choix hero  -----
; sortie X pointe sur option choisie : #$00 (01)  Kaeso, #$01 (02) Elancia....
menu_choix_hero
	ldx #$1a
	jsr ini_adr_mnu_camp
	jsr ini_adr_ecr_mnu_camp
	jsr Ecr_LT_mnu
	lda #$14
	sta $be33
	ldx #$00	;#$01

chk_kbd_h
	lda $208
	cmp #$38
	beq chk_kbd_h
y_208_h	
	ldy $208
	cpy #$38
	bne y_208_h
	cmp #$B4			; touche flêche vers le bas
	bne ckh_9c_h			; vers chk Arrow Up
	inx
	cpx #$06	;#$07
	bne suite_mnu_h
	ldx #$00	;#$01
	jmp suite_mnu_h
ckh_9c_h
	cmp #$9c			; touche flêche vers le haut
	bne chk_84m_h
	dex
	cpx #$ff
	bne suite_mnu_h  	;bne
	ldx #$05	;#$06			; 
	jmp suite_mnu_h
chk_84m_h
	cmp #$84		
	bne chk_kbd_h
	JMP fin_mnu_h
;---------------------------------------------------------------------	
suite_mnu_h
	cmp #$b4			;Sens vers le Bas (test 1ère touche autorisée)
	bne sens_vh_h
	lda #$10			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$00	;#$01
	bne chk_x02b_h
	sta $bedd
	sty $be33
	jmp chk_kbd_h
chk_x02b_h
	cpx #$01	;#$02
	bne chk_x03b_h
	sta $be33
	sty $be83
	jmp chk_kbd_h
chk_x03b_h
	cpx #$02	;#$03
	bne chk_x04b_h
	sta $be83
	sty $bed3
	jmp chk_kbd_h
chk_x04b_h
	cpx #$03	;#$04
	bne chk_x05b_h
	sta $bed3
	sty $be3d
	jmp chk_kbd_h
chk_x05b_h
	cpx #$04	;#$05
	bne chk_x06b_h
	sta $be3d
	sty $be8d
	jmp chk_kbd_h
chk_x06b_h
	sta $be8d
	sty $bedd
	jmp chk_kbd_h	
;----	
sens_vh_h
;	pla
	cmp #$9c			;Sens vers le haut (test 2 ème touche autorisée)
	bne chk_84_h			;aller tester 3 ème touche autorisée (espace)
	lda #$10			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$00	;#$01
	bne chk_x02h_h
	sta $be83
	sty $be33
	jmp chk_kbd_h
chk_x02h_h
	cpx #$01	;#$02
	bne chk_x03h_h
	sta $bed3
	sty $be83
	jmp chk_kbd_h
chk_x03h_h
	cpx #$02	;#$03
	bne chk_x04h_h
	sta $be3d
	sty $bed3
	jmp chk_kbd_h
chk_x04h_h	
	cpx #$03	;#$04
	bne chk_x05h_h
	sta $be8d
	sty $be3d
	jmp chk_kbd_h	
chk_x05h_h
	cpx #$04	;#$05
	bne chk_x06h_h
	sta $bedd
	sty $be8d
	jmp chk_kbd_h
chk_x06h_h
	sta $be33
	sty $bedd
	jmp chk_kbd_h	
chk_84_h
	cmp #$84
	beq fin_mnu_h
	jmp chk_kbd_h
fin_mnu_h	
	rts


;--------------------------------------------------------------------------
;--------------           affiche data individuelles  hero	     ----------
;--------------------------------------------------------------------------
insp_hero
;	dex
	txa
	pha
	JSR swap_0p_97p 			;Sauve la page 0 (variables T4) en $9700-$97ff 	
	jsr load_
	jsr $EC33					; passe en mode HIRES (ATMOS)
	JSR swap_97p_0p 			; Restaure la page 0 (Variables T4) pour continuer partie en cours	
	jsr main_affiche			; affiche portrait
	ldx #$00					
	jsr aff_text				;  affiche texte fixe (commun à tous perso)
	pla							;| récupère n° hero
	tax							;| dans X
	jsr ecr_dta_perso			; 
	rts		
;---------------------------------	
mnu_back_spells_give	
	lda$39
	cmp #$04
	bpl sort_ok
	ldx #$30		; 48		; Pointe "Back     Give money ....
	bne sk_sort_ok
sort_ok	
	ldx #$2e		; 46		; Pointe "Spells   Give money .... 	
sk_sort_ok	
	jsr ini_adr_txt
	jsr ini_adr_ecr	
	jsr Ecr_LT					; Sp écrit sur ligne TEXT
	jsr anim_mnu_bsg
	cpx #$02
	bne sk_dex
	lda$39
	cmp #$4
	bpl sk_dex
	dex
sk_dex
	rts
;----------------------------------------	
anim_mnu_bsg					;animation menu choix sort/back ou give M give O
	ldx #$02
chk_kbd_dr
	lda $208
	cmp #$38
	beq chk_kbd_dr
y_208_dr	
	ldy $208
	cpy #$38
	bne y_208_dr
	cmp #$Bc			; touche flêche vers la droite
	bne ckh_ac_dr			; vers chk flêche gauche
	inx
	cpx #$05
	bne suite_mnu_droite
	ldx #$02
	jmp suite_mnu_droite
ckh_ac_dr
	cmp #$ac			; touche flêche vers la gauche
	bne chk_84m_dr
	dex
	cpx #$01
	bne suite_mnu_gauche  
	ldx #$04			; on pointe le ligne 0 (camp)  alors ligne 5 (break camp)
	jmp suite_mnu_gauche
chk_84m_dr
	cmp #$84		
	bne chk_kbd_dr
	JMP fin_mnu_dr
;---------------------------------------------------------------------	
suite_mnu_droite
	lda #$11			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$02
	bne chk_x02b_dr
	sta $bfaa
	sty $bf91
	jmp chk_kbd_dr
chk_x02b_dr
	cpx #$03
	bne chk_x03b_dr
	sta $bf91
	sty $bf9b
	jmp chk_kbd_dr
chk_x03b_dr
	cpx #$04
	sta $bf9b
	sty $bfaa
	jmp chk_kbd_dr
;----	
suite_mnu_gauche
	lda #$11			;attribut fond noir
	ldy #$14			;attribut fond bleu
	cpx #$02
	bne chk_x02h_dr
	sta $bf9b
	sty $bf91
	jmp chk_kbd_dr
chk_x02h_dr
	cpx #$03
	bne chk_x03h_dr
	sta $bfaa
	sty $bf9b
	jmp chk_kbd_dr
chk_x03h_dr
	cpx #$04
	sta $bf91
	sty $bfaa
	jmp chk_kbd_dr
fin_mnu_dr	
	rts	

;----------------------------------------
spells_
	jsr aff_spells
	jsr mnu_back_soins
	lda$39
	cmp #$05				; Mestre ?
	bne no_anim				; si pas mestre, juste back
	jsr anim_mnu_h_spell	; si mestre choix back ou cast healing spell
	jsr cast_h_spell
no_anim	
	jsr get_key
	rts	

;----------------------------------------
aff_spells
	jsr aff_text_2				; affiche sorts (649)
	jsr ecr_dta_sorts
rts
;----------------------------------------
mnu_back_soins
	lda$39
	cmp #$05
	bne no_healing
	ldx #$32		; 50		Pointe vers "Back   Cast healing spell .... 	
	jmp _healing
no_healing
	ldx #$34		; 52		pointe vers "Back" seul
_healing
	jsr ini_adr_txt
	jsr ini_adr_ecr	
	jsr Ecr_LT		; 			Sp écrit sur ligne TEXT
	rts
;------------------------------------------------
 
anim_mnu_h_spell
	ldx #$01
chk_kbd_mbs
	lda $208
	cmp #$38
	beq chk_kbd_mbs
y_208_mbs	
	ldy $208
	cpy #$38
	bne y_208_mbs
	cmp #$Bc			; touche flêche vers la droite
	bne ckh_ac_mbs			; vers chk flêche gauche
	inx
	cpx #$03
	bne suite_mnu_mbs
	ldx #$01
	jmp suite_mnu_mbs
ckh_ac_mbs
	cmp #$ac			; touche flêche vers la gauche
	bne chk_84m_mbs
	dex
	cpx #$00
	bne suite_mnu_mbs  
	ldx #$02			; on pointe le ligne 0 (camp)  alors ligne 5 (break camp)
	jmp suite_mnu_mbs
chk_84m_mbs
	cmp #$84		
	bne chk_kbd_mbs
	JMP fin_mnu_mbs
;---------	
suite_mnu_mbs	
	cmp #$bc			; Sens vers la droite (test 1ère touche autorisée)
	bne sens_dr_mbs
	lda #$11			; attribut fond noir
	ldy #$14			; attribut fond bleu
	cpx #$01
	bne chk_x02_mbs
	sta $bf9b
	sty $bf91
	jmp chk_kbd_mbs
chk_x02_mbs
	cpx #$02
	sta $bf91
	sty $bf9b
	jmp chk_kbd_mbs
;----	
sens_dr_mbs
	cmp #$ac			; Sens vers la gauche (test 2 ème touche autorisée)
	bne chk_84_mbs		; aller tester 3 ème touche autorisée (espace)
	lda #$11			; attribut fond noir
	ldy #$14			; attribut fond bleu
	cpx #$01
	bne chk_x02h_mbs
	sta $bf9b
	sty $bf91
	jmp chk_kbd_mbs
chk_x02h_mbs
	cpx #$02
	sta $bf91
	sty $bf9b
	jmp chk_kbd_mbs
chk_84_mbs
	cmp #$84
	beq fin_mnu_mbs
	jmp chk_kbd_mbs	
fin_mnu_mbs
	cpx #$01
	bne fin_k_healing
	pla				;| dépile adresse dernier appel SP pour retour direct camp
	pla				;|
fin_k_healing	
	rts
;----------------------------------------
	
cast_h_spell	
	
	
	
	
;*************************************************************
; *******                 Choix GIVE MONEY             *******
;*************************************************************		
give_money
	jsr eff_demi_hires
other_try	
	jsr aff_give_to
	jsr choose_hero
;	inx
	cpx $3a
	bne cont_gm
	jsr aff_give_oneself	; affiche texte One can't give to oneself et option unique "back"
	jsr get_space_release
	jsr erase_back
	jmp other_try
cont_gm	
	jsr aff_choose_amount
	jsr choose_amount
	jsr transf_don_2_hex
	jsr chk_don_nul
	beq out_gv				;on sort avec C=0
	jsr chk_inf_don_max
	bcs cont_gm
	jsr calc_bourse_1_et_2
	jsr affich_res
;	jsr get_key
	sec	
	rts
out_gv
	clc
	rts
	
;---------
get_space_release
	lda $208
	cmp #$84
	bne get_space_release
lp_release	
	lda $208
	cmp #$38		; touche relachée
	bne lp_release
	rts
;----------------------------------------
aff_give_to
; aff bande rouge en haut 1/2 ecran
	lda #$40 
	sta $25
	lda #$b0
	sta $26
	lda #$11
	jsr Aff_att
; aff "select hero to give to"	
	lda #$00
	sta $23
	lda #$be
	sta $24
	lda #<message_shtgt
	sta $21
	lda #>message_shtgt
	sta $22
	jsr Ecr_LH
	rts
;-----	
bande_rouge
	.asc $11	
message_shtgt
	.asc $11,$0c,"      Select a hero to give to  ",0  

;----------------------------------------
choose_hero
	jsr aff_fond_bourse_perso 
	jsr aff_perso_hires
	jsr menu_ch_perso_hires
	stx $3b

rts
;-----
aff_fond_bourse_perso
		lda #$a3
		sta $23
		lda #$b2
		sta $24
		lda #<chiffres_1ere_jaune
		sta $21
		lda #>chiffres_1ere_jaune
		sta $22
		jsr Ecr_LH
		rts
;-----		
chiffres_1ere_jaune
	.asc $13,$01,"   000000 Se    ",$10,0		;Deb en $B2A3, 1er zéro en $B2A8		
;-----
aff_perso_hires
		ldx #$00
lp_mnu_perso_hire	
		lda #<dta__mnu_perso_h
		sta $21
		lda #>dta__mnu_perso_h
		sta $22	
		lda adr_ecr_hi_mnu_ph,x
		sta $23
		inx
		lda adr_ecr_hi_mnu_ph,x
		sta $24
		jsr Ecr_LH
		inx
		cpx #$06
		bne lp_mnu_perso_hire
		ldx #$00		
lp_nm_hero_hi			
		jsr nm_hero_team_hi	; transfère un nom des data issues de team.bin
		inx					; nom suivant
		cpx #$06			; nb de noms à transférer
		bne lp_nm_hero_hi
		rts
;--------
dta__mnu_perso_h
		.asc $07,$10,"       ",$10," ",$10,"       ",$10,0
adr_ecr_hi_mnu_ph
		.byt $4a,$b5,$ca,$b7,$4a,$ba			
		
;--------------------
nm_hero_team_hi
			txa
			pha							; sauve sur la pile le nb de nom restant à tranférer
			asl
			tax
			lda adr_hire_nm_hero,x		; partie basse adresse ecran nom hero pour menu
			sta $23
			inx
			lda adr_hire_nm_hero,x		; partie basse adresse ecran nom hero pour menu
			sta $24	
			pla
			tax
			tay
			lda $2c,y					; longueur totale data "devant" nom héro en cours
			tay							; en index
			txa
			pha
			lda dta_kaeso,y				; longeur nom en cours
			sta $2a						; sauvée dans $2a
			iny							; carractère suivant
			ldx #$00
lp_tr_nm_hi
			lda $23
			sta $25
			lda $24
			sta $26	
			tya
			pha							; empile Y car utilisé par Aff_Car
			lda dta_kaeso,y				; prends carractère nom
			jsr Aff_Car					; l'affiche à l'adresse contebue en $25-26
			pla
			tay
			clc
			inc $23						; mise à jour adresse écran Hires
			bcc suite_nm_hi
			inc $24
suite_nm_hi	
			iny
			inx	
			cpx $2a						; fin du nom?
			beq sk_tr_nm_hi				; Non, alors on boucle
			jmp lp_tr_nm_hi
sk_tr_nm_hi	
			pla							; Oui alors on récupère sur la pile
			tax							; le N° du nom qui vient d'être transféré
			rts	
;--------
adr_hire_nm_hero
	.byt $4c,$b5,$cc,$b7,$4c,$ba,$56,$b5,$d6,$b7,$56,$ba	
		
;--------------------
menu_ch_perso_hires
		lda #$4b 
		sta $25
		lda #$b5
		sta $26
		lda #$14
		jsr Aff_att		;"allume Kaeso en bleu
		ldx #$00
		jsr aff_bourse_perso	

chk_kbd_anim
		lda $208
		cmp #$38
		beq chk_kbd_anim
w_208_h	
		ldy $208
		cpy #$38
		bne w_208_h
		cmp #$B4			; touche flêche vers le bas
		bne ckh_9c_anim_h			; vers chk Arrow Up
		inx
		jmp suite_anim_mnu_b
ckh_9c_anim_h
		cmp #$9c			; touche flêche vers le haut
		bne chk_84m_anim
		dex
		jmp suite_anim_mnu_h
chk_84m_anim
		cmp #$84		
		bne chk_kbd_anim
		JMP fin_mnu_anim
;--	
suite_anim_mnu_b
		cpx #$06
		bne sk_ldx_00
		dex
		jsr rens_25_26
		lda #$10
		jsr Aff_att
		ldx #$00
		jsr rens_25_26	
		lda #$14
		jsr Aff_att
		jsr aff_bourse_perso
		jmp chk_kbd_anim	
sk_ldx_00
		dex
		jsr rens_25_26	
		lda #$10
		jsr Aff_att
		inx
		jsr rens_25_26	
		lda #$14
		jsr Aff_att
		jsr aff_bourse_perso	
		jmp chk_kbd_anim
;--	
suite_anim_mnu_h	
		bmi x0_vers_x5
		inx
		jsr rens_25_26	
		lda #$10
		jsr Aff_att
		dex
		jsr rens_25_26	
		lda #$14
		jsr Aff_att
		jsr aff_bourse_perso	
		jmp chk_kbd_anim	
x0_vers_x5
		ldx #$00
		jsr rens_25_26	
		lda #$10
		jsr Aff_att	
		ldx #$05
		jsr rens_25_26	
		lda #$14
		jsr Aff_att
		jsr aff_bourse_perso	
		jmp chk_kbd_anim
fin_mnu_anim	
		rts
;--------	
rens_25_26
			txa
			pha
			asl
			tax
			lda adr_anim_14_h,x
			sta $25
			inx
			lda adr_anim_14_h,x
			sta $26
			pla
			tax
			rts
;-------			
adr_anim_14_h
		.byt $4b,$b5,$cb,$b7,$4b,$ba,$55,$b5,$d5,$b7,$55,$ba				
;------	
aff_bourse_perso
			txa
			pha
			lda $2c,x
			tax
			lda dta_kaeso,x
			sta $2a
			txa
			clc
			adc $2a
			tax
			inx
			lda dta_kaeso,x
			sta $35
			inx
			lda dta_kaeso,x
			sta $36
			jsr hex_2_asc
			jsr init_adr_bourse_p
			jsr bourse_g
			pla
			tax
			rts
;---	
init_adr_bourse_p
				lda #<adr_scr_UDCM_gv
				sta adr_UDCM_0+1
				sta adr_UDCM_1+1
				sta lp_UDCM+1
				sta adr_UDCM_2+1
				sta adr_UDCM_3+1
				sta adr_UDCM_4+1
				lda #>adr_scr_UDCM_gv
				sta adr_UDCM_0+2
				sta adr_UDCM_1+2	
				sta lp_UDCM+2
				sta adr_UDCM_2+2
				sta adr_UDCM_3+2
				sta adr_UDCM_4+2
				lda #$32
				sta byte_1+1
				sta byte_2+1
				rts

;------
adr_scr_UDCM_gv
	.asc $ad,$b2,$ac,$b2,$ab,$b2,$aa,$b2,$a9,$b2,$a8,$b2	
;---------------------	
aff_give_oneself
	lda #$00
	sta $23
	lda #$be
	sta $24
	lda #<to_oneself
	sta $21
	lda #>to_oneself
	sta $22
	jsr Ecr_LH
aff_back	
	lda #<t_ip_27
	sta $21
	lda #>t_ip_27
	sta $22
	lda #$91
	sta $23
	lda #$bf
	sta $24
	jsr Ecr_LT
	rts
;-----
to_oneself
	.asc $11,$0c,"      One can't give to oneself",0 		
;--------------------
erase_back
	lda #<dta_erase_back
	sta $21
	lda #>dta_erase_back
	sta $22
	lda #$90
	sta $23
	lda #$bf
	sta $24
	jsr Ecr_LT
	rts
;----
dta_erase_back
	.asc "                                ",0	  
;----
;----------------------------------------
aff_choose_amount
; aff "Enter the amount"	
	lda #$00
	sta $23
	lda #$be
	sta $24
	lda #<message_aa
	sta $21
	lda #>message_aa
	sta $22
	jsr Ecr_LH
; aff_fond_bourse_donneur
	lda #$90
	sta $23
	lda #$bf
	sta $24
	lda #<chiffres_2eme_jaune
	sta $21
	lda #>chiffres_2eme_jaune
	sta $22
	jsr Ecr_LT
	rts
;-----
message_aa	
	.asc $11,$0c,"           Enter the amount   ",0 
chiffres_2eme_jaune
	.asc "           ",$13,$01,"   0",$b0,"0000 Se    ",$10,"          ",0		;Deb en $BF9B, 1er zéro en $BFA0
;----------------------------------------

choose_amount 	;animation menu choix montant à donner

	ldx #$02
chk_kbd_m
	lda $208
	cmp #$38
	beq chk_kbd_m
y_208_m	
	ldy $208
	cpy #$38
	bne y_208_m
chk_bc	
	cmp #$Bc			; touche flêche vers la droite
	bne chk_ac			; vers chk flêche gauche
	cpx #$05
	beq chk_kbd_m
	lda $bf9f,x
	eor #$80
	sta $bf9f,x
	inx
	lda $bf9f,x
	eor #$80
	sta $bf9f,x	
	jmp chk_kbd_m
chk_ac
	cmp #$ac			; touche flêche vers la gauche
	bne chk_b4
	cpx #$1
	beq chk_kbd_m  
	lda $bf9f,x
	eor #$80
	sta $bf9f,x
	dex
	lda $bf9f,x
	eor #$80
	sta $bf9f,x	
	jmp chk_kbd_m
	
chk_b4
	cmp #$b4			; touche flêche vers le bas
	bne chk_9c
	lda $bf9f,x
	eor #$b0
	beq chk_kbd_m
	dec $bf9f,x
	jmp chk_kbd_m
chk_9c
	cmp #$9c			; touche flêche vers le haut
	bne chk_84_m
	lda $bf9f,x
	eor #$b0
	cmp #$09
	beq chk_kbd_m
	inc $bf9f,x
	jmp chk_kbd_m
chk_84_m
	cmp #$84		
	bne chk_kbd_m
fin_mnu
	lda $bf9f,x
	eor #$80
	sta $bf9f,x
	jsr erase_choose
	rts	
;-----	
erase_choose
		lda #$00
		sta $23
		lda #$be
		sta $24
		lda #<dta_erase_cham
		sta $21
		lda #>dta_erase_cham
		sta $22
		jsr Ecr_LH
		rts
;-----
dta_erase_cham
	.asc $11,"                                ",0

;----------------------------------------

;---------------
transf_don_2_hex
	lda #$00
	sta $3c
	sta $3d
	ldx #$04
	jsr chk_digit
	beq digit_d
	jsr unites
digit_d	
	dex	;3
	jsr chk_digit
	beq digit_c
	jsr dizaines
digit_c	
	dex	;2
	jsr chk_digit
	beq digit_m	
	jsr centaines
digit_m	
	dex	;1
	jsr chk_digit
	beq digit_dm		
	jsr milliers
digit_dm
	dex
	jsr chk_digit
	beq out_td2h
	dex	;0
	jsr d_milliers
out_td2h	
	rts
;------	
chk_digit
		lda $bfa0,x
		And #$0f
		rts
;------		
unites
	lda $bfa0,x
	and #$0f
	tay
lp_unites	
	inc $3c
	bne suite_u
	inc $3d
suite_u	
	dey
	bne lp_unites
	rts
;------			
dizaines
	ldy #$0a
lp_dizaines	
	tya
	pha
	jsr unites
	pla
	tay
	dey
	bne lp_dizaines
	rts
;------			
centaines
	ldy #$0a
lp_centaines	
	tya
	pha
	jsr dizaines
	pla
	tay
	dey
	bne lp_centaines
	rts
;------			
milliers
	ldy #$0a
lp_milliers	
	tya
	pha
	jsr centaines
	pla
	tay
	dey
	bne lp_milliers
	rts
;------			
d_milliers
	ldy #$0a
lp_d_milliers	
	tya
	pha
	jsr milliers
	pla
	tay
	dey
out_d_milliers	
	rts
;---------------
chk_don_nul
	lda $3c			; partie basse valeur don
	bne sk_chk_3c	; si non nul, on sort avec Z=0
	lda $3d			; si nul on check partie haute
sk_chk_3c	
	rts				; on sort ace Z=0 si don non nul et Z+1 si nul
;---------------
chk_inf_don_max 
	ldx $3a
	jsr index_1ere_data_perso_x
	lda dta_kaeso,x
	sta $3e					; partie basse valeur bourse perso inspecté
	inx
	lda dta_kaeso,x
	sta $3f					; partie haute valeur bourse perso inspecté
;-- soustraction sur 2 octes pour check signe (débordement) 
	cld
	sec
	lda $3e
	sbc $3c
;	sta $40
	lda $3f
	sbc $3d
;	sta $41
	bmi pas_assez_riche		
	jsr maj_bourse_perso_donneur
	jsr maj_bourse_perso_receveur
	clc
	rts
pas_assez_riche	
	jsr aff_cant_give_more
	jsr aff_back
	jsr get_key
	sec
	rts
;----	
aff_cant_give_more	
	lda #$00
	sta $23
	lda #$be
	sta $24
	lda #<give_more
	sta $21
	lda #>give_more
	sta $22
	jsr Ecr_LH	
	rts
;---- 	
give_more
	.asc $11,$0c,"  You can't give more than you have",0 	
;---- 
maj_bourse_perso_donneur
	ldx $3a
	jsr index_1ere_data_perso_x
	lda dta_kaeso,x
	sec
	sbc $3c
	sta dta_kaeso,x
	inx
	lda dta_kaeso,x
	sbc $3d	
	sta dta_kaeso,x
	rts
;---- 	
maj_bourse_perso_receveur	
	ldx $3b
	jsr index_1ere_data_perso_x
	lda dta_kaeso,x
	clc
	adc $3c
	sta dta_kaeso,x
	inx
	lda dta_kaeso,x
	adc $3d	
	sta dta_kaeso,x
	rts	
;----------------------------
;entée X:N° êrso Sortie: X indexe Première data en partant de dta_Kaeso
index_1ere_data_perso_x
	txa
	pha
	lda $2c,x
	tax
	lda dta_kaeso,x
	sta $2a
	pla 
	tax
	lda $2a
	clc
	adc $2c,x
	tax
	inx	
	rts	
;---- 		
		
		
;---------------
calc_bourse_1_et_2


		rts
;---------------
affich_res


		rts









;----------------------------------------



;*************************************************************
; *******              Choix GIVE object               *******
;*************************************************************	
	
give_object
		rts
;----------------------------------------	
	
;----------------------------------------
view_team
		rts
;             reste à programmer		
;----------------------------------------
open_chest
	ldx #$1c
	jsr ini_adr_mnu_camp
	jsr ini_adr_ecr_mnu_camp	; "Who is going to try?"
	jsr Ecr_LT_mnu
;-------------				| à compléter ----------
;-------------	            |             ----------	
	rts
;----------------------------------------		
have_rest
	ldx #$1e
	jsr ini_adr_mnu_camp
	jsr ini_adr_ecr_mnu_camp	; "You regain yours spells"
	jsr Ecr_LT_mnu
	ldx #$20
	jsr ini_adr_mnu_camp
	jsr ini_adr_ecr_mnu_camp	; "<   >"
	jsr Ecr_LT_mnu	
;-------------				| à compléter ----------
;-------------	            |             ----------
	rts
;----------------------------------------
		
;****************************************
;****     attend appuis sur espace    ***
;****************************************	
get_key
	lda $208
	cmp #$38
	bne get_key
w_esp	
	lda $208
	cmp #$84		; code espace
	bne w_esp
	rts

;*************************************
;  Routine swp $97 page to zero_page 
;     ($9700-$97FF ==> $00-$FF)
;*************************************
swap_97p_0p
	ldy #$FF
loop_97p
	lda$9700,y
	sta $00,Y
	dey
	bne loop_97p
	lda $9700
	sta $00
	rts	
;*************************************
;  Routine swp zero_page to $97 page 
;c   ($00-$FF ==> $9700-$97FF)
;*************************************
swap_0p_97p
	ldy #$FF
loop_zp
	lda$00,y
	sta $9700,Y
	dey
	bne loop_zp
	lda $00
	sta $9700
	rts
;***************************************
;  		Routine LOAD  image perso
;***************************************

load_
    jsr $477 
	lda #<dta_image	; partie basse ll adresse chargement image
	sta $c052		; dans adresse chargement (normalement après ,A#hhll)
	lda #>dta_image	; partie haute hh adresse chargement image
	sta $c053		; dans adresse chargement (normalement après ,A#hhll)
	lda #$40		; 0100 0000  code b6=1
	sta $c04e		; pour simuler ,A#xxxx dans commande load
	LDA $C009		; N° drive par défaut
	STA $C028		; dans préfixe deBUFFNOM (N° du drive)
	LDA #$00		; code pour ni ",V" ni ",N"
	STA $C04D		; dans VASALO0
;	STA $C04E		; dans VSALO1 (ni ",A" ni ",J")
	JSR nom_ds_buff	; Recopie le nom du portrait perso dans BUFFNOM
	JSR $E0E5		; Appel routine LOAD de SEDORIC
	jsr $477
	RTS

;------------- charge et affiche portrait perso  ---------------
nom_ds_buff 
	
;	dex				; X : n° perso (de 1 à 6) ramené de 0à 5
	txa				; X dans A pour pointer la bonne adresse
	asl				; grace à cet ASL
	tax
	lda ptr_p_perso,x
	sta loop_ndb+1
	inx
	lda ptr_p_perso,x
	sta loop_ndb+2
	LDX #$0B		;Nombre de lettres à transférer
loop_ndb	
	LDA ptr_p_perso,X	;Début boucle de transfert
	STA $C029,X		;Vers BUFFNOM en $C029
	DEX				;Décrémente le compteur de boucle
	BPL loop_ndb	;Boucle si pas fini
	RTS 		
;-----------------------------------------------------		
main_affiche
	jsr init_adr_ecr
	jsr init_adr_data
	ldy #$63
main_loop		
	jsr trans_1_ligne
	jsr mise_a_jour_ard_ecr
	jsr mise_a_jour_ard_data
	dey
	bne main_loop
	rts

;******** initialisation adresse HIRES   ********

init_adr_ecr
	lda #$00		;lda $00
	sta adr_ecr+1
	lda #$a0		;lda $01 $00_01 contiendra variable début adresse ecran fournie avant appel routine main_affiche
	sta adr_ecr+2
	rts
;********   mise à jour  adresse HIRES   ********	
mise_a_jour_ard_ecr
	clc
	lda adr_ecr+1
	adc #$28
	sta adr_ecr+1
	bcc fin_maj
	inc adr_ecr+2
fin_maj
	rts
	
;******** initialisation adresse données image    ********
init_adr_data	
	lda #<dta_image
	sta adr_dta+1
	lda #>dta_image
	sta adr_dta+2
	rts
;******** mise à jour adresse données image    ********	
mise_a_jour_ard_data
	clc
	lda adr_dta+1
	adc #$13
	sta adr_dta+1
	bcc fin_maj_data
	inc adr_dta+2
fin_maj_data
	rts

;********  transfert écran d une ligne image   ********	
trans_1_ligne
	ldx #$12
adr_dta	
	lda 1111,x
adr_ecr	
	sta 1111,x
	dex
	bpl adr_dta
	rts

;***************************************************
;*** Routine affiche texte sur HIRES (une ligne) ***
;***     1ere partie (avant les sorts)    ***
;***************************************************
aff_text

lp_aff_txt		
	jsr ini_adr_txt
	jsr ini_adr_ecr
	JSR Ecr_LH		;SP écrit sur une ligne HIRES
	inx
	cpx #$2e		; 46
	bne lp_aff_txt
lp_aff_txt_2		;on boucle pour ecriture partie hires de l'écran
		
	rts
;***************************************************
;*** Routine affiche texte sur HIRES (une ligne) ***  
;***          2eme partie affiche sorts          ***
;***************************************************
aff_text_2
	ldx	#$00
lp_aff_text_2	
	jsr ini_adr_txt_2
	jsr ini_adr_ecr_2
	JSR Ecr_LH		;EcrLH écrit sur une ligne HIRES
	inx
	cpx #$14		; 20
	bne lp_aff_text_2
	rts

;Routine init adress message dans $21-$22		
ini_adr_txt
	txa
	pha
	lda ind_tip,X
	sta $21			;$21 contient partie basse adresse texte
	inx
	lda ind_tip,X
	sta $22			;$22 contient partie haute adresse texte
	pla
	tax
	rts

; Sous Routine init adresse écran dans $23-$24
ini_adr_ecr
	LDA adr_txt_hi,x
	STA $23			;$23-24 contient  adresse
	inx
	LDA adr_txt_hi,x	;début ligne HIRES des texte	
	STA $24
	rts
;---------------------------------------
;Routine init adress message dans $21-$22		
ini_adr_txt_2
	txa
	pha
	lda ind_tips,x
	sta $21			;$21 contient partie basse adresse texte
	inx
	lda ind_tips,x
	sta $22			;$22 contient partie haute adresse texte
	pla
	tax
	rts

; Sous Routine init adresse écran dans $23-$24
ini_adr_ecr_2
	LDA adr_txt_hi_s,x
	STA $23			;$23-24 contient  adresse
	inx
	LDA adr_txt_hi_s,x	;début ligne HIRES des texte	
	STA $24
	rts	
;---------------------------------------	
; Sous routine ecrit ligne de texte sur Hires
; Entrée :	$23-$24 contient adresse ecran début ligne (transférée en $25-26 en début routine)
Ecr_LH	
	txa
	pha
	LDX #$00
    STX $02E3	; n° jeu de caractères
loop_2  
	LDA $23
   	STA $25
    LDA $24
   	STA $26
    JSR Pr_ltr	;A=0 si fin ligne texte
   	BEQ out_2
	cmp #$20
	bpl j_Aff_Car
	jsr Aff_att
	jmp sk_Aff_Car
j_Aff_Car	
    JSR Aff_Car
sk_Aff_Car	
    INC $23
    BNE skip_2
    INC $24
skip_2
	JMP loop_2
out_2
	pla
	tax
	RTS

;------------------------------------------------
;Sous Routine prend lettre dans message
;Entrée :
;		$21-22 Contient  Adresse début message 
;Sortie : 	Code ASCII lettre dans A
;		$21-22 mis à jour
;		A contient #$00 si fin de ligne
;-----------------------------------------------
Pr_ltr
	LDY #$00
	LDA($21),Y
	Pha
	INC $21
	BNE out_1 	
	INC $22
out_1
	Pla
 	RTS 		;sortie avec A=0 si fin ligne
;------------------------------------------
;Sous Routine Affiche un caractère en HIRES
;Entrée:
;	A contient le code ascii du caractère
;	$25-$26 contient adresse octet écran
;	$2E3 n° jeu de caractères
;-------------------------------------------
Aff_Car	
	JSR Adr_car_tabl	;$F17E Adr car ds tab placé en $27-$28
	LDY#$00	 			;init compteur octets ( lignes masque graphique)
loop1
	STY $29	 			;sauvé en $29
	LDA($27),Y			;masque d’Yème ligne ->A
	ORA #$40			;force bit 6 à 1
	LDY #$00	
	STA($25),Y			;écrit Yè ligne à l’écran
	JSR adc_28 			;$F089 (+#28 à adresse écran)
	LDY $29				;récup valeur compteur
	INY					;masque suivant
	CPY #$08				;est-ce le 8éme ?
	BNE  loop1 			;sinon on continue
	RTS					;si oui, caractère affiché

;Sous routine cherche adresse carractère dans table		
Adr_car_tabl
		sta $27
		lda #$00
		sta $28
		txa
		pha
		ldx #$03
loop_car
		asl $27
		rol $28
		dex
		bne loop_car
		lda $2E3
		asl
		asl
		clc
		adc #$98
		clc
		adc $28
		sta $28
		pla
		tax
		rts
; sous routine calcule adresse et masque du point au dessous du point courant

adc_28	
	clc
	lda $25
	adc #$28
	sta $25
	bcc no_ret
	inc $26
no_ret
	rts			

;---------------------------------------------	
;Sous Routine Affiche un attribut en HIRES
;Entrée:
;	A contient le code ascii de l'attribut
;	$25-$26 contient adresse octet écran
;---------------------------------------------
Aff_att
	LDY #$00	 			;init compteur octets ( lignes masque graphique)
loop_at
	STY $29	 			;sauvé en $29
	LDY #$00	
	STA($25),Y			;écrit Yè ligne à l’écran
	pha
	JSR adc_28 			;$F089 (+#28 à adresse écran)
	pla
	LDY$29				;récup valeur compteur
	INY					;masque suivant
	CPY #$08				;est-ce le 8éme ?
	BNE  loop_at 			;sinon on continue
	RTS					;si oui, caractère affiché

;-----------------------------------------
Ecr_LT
	txa
	pha
	cpx #$52
	bpl out_2_lt
loop_2_lt  
    JSR Pr_ltr		;A=0 si fin ligne texte
   	BEQ out_2_lt
    sta($23),y
    INC $23
    BNE skip_2_lt
    INC $24
skip_2_lt
	JMP loop_2_lt
out_2_lt
	pla
	tax
	RTS

;******************************************************************************
;*** ecriture sur Hires des données spécifiques à chaque perso (hors sorts) ***
;******************************************************************************

;------------- nom du perso ------------------------
;entrée : X contient le rang du perso dans la liste : 0 kaeso, 1  Elantia, 2 Carpo,...
ecr_dta_perso
;-- init $23-$24 avec adresse écran
	lda adr_scr_nm,x		; LL partie basse adesse écran hires pour nom perso
	sta $23
	lda #$a0				; soit $a0LL
	sta $24

	jsr init_adr_dta_perso_x ;-- init $21-$22 avec adresse nom perso	
	jsr ecr_nom_perso
	jsr bourse_ip
	jsr carriere_
	rts

init_adr_dta_perso_x
	lda #<dta_kaeso
	clc
	adc $2c,x
	sta $21
	sta $37
	lda #>dta_kaeso
	adc #$00
	sta $22
	sta$38
	ldy #$00
	LDA ($37),y	
	sta $2a			 ;longueur du nom
	rts
;--- 	ecrit nom perso -----
ecr_nom_perso	
	inc $21
	inc $37
	txa
	pha
	LDX #$00
    STX $02E3		; n° jeu de caractères
loop_2_nm  
	LDA $23
   	STA $25
    LDA $24
   	STA $26
    JSR Pr_ltr		;A=0 si fin ligne texte
	inx
	cmp #$20				; check si attribut
	bpl j_Aff_Car_nm		;
	jsr Aff_att				;affiche un attribut
	jmp sk_Aff_Car_nm
j_Aff_Car_nm	
    JSR Aff_Car
sk_Aff_Car_nm	
    INC $23
    BNE skip_2_nm
    INC $24
skip_2_nm
	cpx $2a
	bne loop_2_nm
	pla
	tax
	rts
	
;------------- Bourse perso ------------------------
bourse_ip
	jsr calc_bourse
	jsr init_adr_scr_ip
	jsr bourse_g
	rts
;---	
calc_bourse	
	ldy $2a				; 2 octets bourse aux rangs L+1 et L+2 des data perso
	inc $2a
	lda ($37),y
	sta $35
	iny
	inc $2a
	lda ($37),y
	sta $36
	jsr hex_2_asc
	rts	
;----	
init_adr_scr_ip
	lda #<adr_scr_UDCM_bh
	sta adr_UDCM_0+1
	sta adr_UDCM_1+1
	sta lp_UDCM+1
	sta adr_UDCM_2+1
	sta adr_UDCM_3+1
	sta adr_UDCM_4+1
	lda #>adr_scr_UDCM_bh
	sta adr_UDCM_0+2
	sta adr_UDCM_1+2	
	sta lp_UDCM+2
	sta adr_UDCM_2+2
	sta adr_UDCM_3+2
	sta adr_UDCM_4+2
	lda #$32
	sta byte_1+1
	sta byte_2+1
	rts
;----
bourse_g
	ldx #$00
adr_UDCM_0	
	lda $1111,x
	sta $25
	inx
adr_UDCM_1	
	lda $1111,x
	sta $26
	lda #$30
	jsr Aff_Car
	inx
lp_UDCM
	lda $1111,x
	sta $25
	inx
adr_UDCM_2	
	lda $1111,x
	sta $26	
byte_1
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car
	inx
	cpx #$0c
	beq out_bourse
adr_UDCM_3
	lda $1111,x
	sta $25
	inx
adr_UDCM_4
	lda $1111,x
	sta $26
byte_2
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car
	inx
	inc byte_1+1
	inc byte_2+1
	bne lp_UDCM
out_bourse	
	rts

adr_scr_UDCM_bh
	.asc $a3,$ac,$a2,$ac,$a1,$ac,$a0,$ac,$9f,$ac,$9e,$ac
;---------------
;	lda #$a3    				;| 
;	sta $25					;| $25-$26 adresse Hires
;	lda #$ac				;|
;	sta $26					;|
;	lda #$30	
;	jsr Aff_Car				; unités (toujours nulles)
;---------------		
;	lda #$a2    ;#$a3				;| 
;	sta $25					;| $25-$26 adresse Hires
;	lda #$ac				;|
;	sta $26					;|
;	lda $31
;	and #$0f
;	ora #$31
;	jsr Aff_Car				; unités affichées dans dizaines (x10)
;---------------	
;	lda #$a1   ;#$a2
;	sta $25
;	lda #$ac
;	sta $26	
;	lda $31
;	lsr
;	lsr
;	lsr
;	lsr
;	ora #$30
;	jsr Aff_Car		; dizaines affichées dans centaines (x10)
;---------------
;	lda #$a0   ; #$a1
;	sta $25
;	lda #$ac
;	sta $26		
;	lda $32
;	and #$0f
;	ora #$30
;	jsr Aff_Car	; centaines affichées dans milliers (x10)
;---------------	
;	lda #$9f   ;#$a0
;	sta $25
;	lda #$ac
;	sta $26		
;	lda $32
;	lsr
;	lsr
;	lsr
;	lsr
;	ora #$30
;	jsr Aff_Car	; milliers affichés dans dizaines de milliers (x10)	
;---------------	
;	lda #$9e   ;#$9f
;	sta $25
;	lda #$ac
;	sta $26		
;	lda $33
;	and #$0f
;	ora #$30
;	jsr Aff_Car	; dizaines de milliers affuchées dans centaines de milliers (x10)

;	rts
;------------- carrière ------------------------
carriere_		
	ldy $2a			; N° carrière en position L+3 sur ligne data perso
	inc $2a
	lda ($37),y
	sta$39
	tax					; n° carrière
	dex
	bmi capacite_combat
	txa
	asl
	tax
	lda ptr_carr,x
	sta $21
	inx
	lda ptr_carr,x
	sta $22				; $21-$22 initialisé avec adre texte carrière
	lda #$9c
	sta $23
	lda #$a2
	sta $24				; $23
	jsr Ecr_LH

;------------- CC Capacité Combat ------------------------	
capacite_combat
	inc $2a			; on saute l'item "maison"
	ldy $2a			; CC en position L+5 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$c2				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$b4				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$c1
	sta $25
	lda #$b4
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines

;------------- CT Capacité Tir ------------------------	
capa_tir
	ldy $2a			; CT en position L+5 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$c6				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$b4				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$C5
	sta $25
	lda #$b4
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;------------- Fo Force ------------------------	
forc_
	ldy $2a			; Fo en position L+6 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$82				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$b8				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$81
	sta $25
	lda #$b8
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines	
;------------- Ag agilité ------------------------	
Agili_
	ldy $2a			; Ag en position L+7 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$86				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$b8				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$85
	sta $25
	lda #$b8
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;------------- In Intelligence ------------------------	
int_
	ldy $2a			; In en position L+8 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$1a				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$bc				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$19
	sta $25
	lda #$bc
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines	
;------------- FM Force  Morale ------------------------	
fo_mo_
	ldy $2a			; FM en position L+9 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$1e				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$bc				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$1d
	sta $25
	lda #$bc
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;------------- PV Points de Vie ------------------------	
po_vi_
	ldy $2a			; PV en position L+10 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$1e				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$aa				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$1d
	sta $25
	lda #$aa
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;---------------	
	lda #$1c				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$aa				;|
	sta $26					;|
	lda $33
	and #$0f
	ora #$30
	jsr Aff_Car		; centaines	
;------------- ET Etat ------------------------	
et_at
	ldy $2a			; ET en position L+11 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$24				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$aa				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$23
	sta $25
	lda #$aa
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;---------------	
	lda #$22				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$aa				;|
	sta $26					;|
	lda $33
	and #$0f
	ora #$30
	jsr Aff_Car		; centaines
	
;------------- Santé ------------------------
sante_		
	ldy $2a			; Santé est  en position L+12 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° carrière
	dex
	bmi niv_
	txa
	asl
	tax
	lda ptr_etats,x
	sta $21
	inx
	lda ptr_etats,x
	sta $22				; $21-$22 initialisé avec adre texte carrière
	lda #$9d
	sta $23
	lda #$a7
	sta $24				; $23
	jsr Ecr_LH	

;------------- Ni  Niveau ------------------------	
niv_
	ldy $2a			; NI  en position L+13 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$1c				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$a5				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$1b
	sta $25
	lda #$a5
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
	
;------------- Expérience ------------------------
expe_	
	ldy $2a				; 2 octets expérience aux rangs L+14 et L+15 des data perso
	inc $2a
	lda ($37),y
	sta $35
	iny
	inc $2a	
	lda ($37),y
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$26				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$a5				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$25
	sta $25
	lda #$a5
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;---------------
	lda #$24
	sta $25
	lda #$a5
	sta $26		
	lda $33
	and #$0f
	ora #$30
	jsr Aff_Car	; centaines
;---------------	
	lda #$23
	sta $25
	lda #$a5
	sta $26		
	lda $33
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car	; milliers	

;------------- WR ARme main droite ------------------------
wr_		
	ldy $2a			; WR en position L+16 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° carrière
	dex
	bmi wl_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte carrière
	lda #$d8
	sta $23
	lda #$b1
	sta $24				; $23
	jsr Ecr_LH	
;------------- WL ARme main gauche ------------------------
wl_		
	ldy $2a			; WL en position L+17 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° carrière
	dex
	bmi pt_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte carrière
	lda #$90
	sta $23
	lda #$b3
	sta $24				; $23
	jsr Ecr_LH
;------------- PT  Armure ------------------------	
pt_
	ldy $2a			; PT  en position L+18 sur ligne data perso
	inc $2a
	lda ($37),y	
	tax					; n° armure
	dex
	bmi ca_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte armure
	lda #$70
	sta $23
	lda #$b5
	sta $24				; $23
	jsr Ecr_LH	
	
;------------- CA  Classe d'armure ------------------------	
ca_
	ldy $2a			; CA  en position L+19 sur ligne data perso
	inc $2a
	lda ($37),y	
	sta $35
	lda #$00
	sta $36
	jsr hex_2_asc
;---------------	
	lda #$1b				;| 
	sta $25					;| $25-$26 adresse Hires
	lda #$af				;|
	sta $26					;|
	lda$32
	and #$0f
	ora #$30
	jsr Aff_Car				; unités
;---------------	
	lda #$1a
	sta $25
	lda #$af
	sta $26	
	lda$32
	lsr
	lsr
	lsr
	lsr
	ora #$30
	jsr Aff_Car		; dizaines
;------------- BT Animal ------------------------
bt_		
	ldy $2a			; WL en position L+20 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° carrière
	dex
	bmi it1_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte animal
	lda #$48 ;#$f8
	sta $23
	lda #$b0 ;#$af
	sta $24				; $23
	jsr Ecr_LH		
;------------- Item n°1 ------------------------
it1_		
	ldy $2a			; Item n°1 en position L+21 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 1
	dex
	bmi it2_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 1
	lda #$9b
	sta $23
	lda #$b7
	sta $24				
	jsr Ecr_LH		
;------------- Item n°2 ------------------------
it2_		
	ldy $2a			; Item n°2 en position L+22 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 2
	dex
	bmi it3_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 2
	lda #$db
	sta $23
	lda #$b8
	sta $24				
	jsr Ecr_LH	
;------------- Item n°3 ------------------------
it3_		
	ldy $2a			; Item n°3 en position L+23 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 3
	dex
	bmi it4_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 3
	lda #$1b
	sta $23
	lda #$ba
	sta $24				
	jsr Ecr_LH	
;------------- Item n°4 ------------------------
it4_		
	ldy $2a			; Item n°4 en position L+24 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 4
	dex
	bmi it5_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 4
	lda #$5b
	sta $23
	lda #$bb
	sta $24				
	jsr Ecr_LH	
;------------- Item n°5 ------------------------
it5_		
	ldy $2a			; Item n°5 en position L+25 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 5
	dex
	bmi it6_
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 5
	lda #$9b
	sta $23
	lda #$bc
	sta $24				
	jsr Ecr_LH
;------------- Item n°6 ------------------------
it6_		
	ldy $2a			; Item n°6 en position L+26 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° item 6
	dex
	bmi out_it
	txa
	asl
	tax
	lda ptr_data_echopes,x
	sta $21
	inx
	lda ptr_data_echopes,x
	sta $22				; $21-$22 initialisé avec adre texte item 6
	lda #$bb
	sta $23
	lda #$bd
	sta $24				
	jsr Ecr_LH
out_it
	rts
;******************************************************************************
;***       écriture sur Hires des sorts spécifiques à chaque  perso         ***
;******************************************************************************	
ecr_dta_sorts
	jsr init_adr_sorts
	jsr prnt_dta_sorts
	rts
;-------------------------	
init_adr_sorts	
	lda$39				; mémoire carrière 1: Chevalier, 2: Mercenaire, 3: Ranger, 4: Sorcier, 5: Mestre, 6: Septon
	sec
	sbc#$03
	bne test_bmi		;|
	jmp out_srt			;| tout ça car jump out of range avec bmi et beq
test_bmi				;|
	bpl suite_sorts		;|
	jmp out_srt			;|
suite_sorts	
;	bmi out_srt			;| on sort si la carrière est chevalier, mercenaire ou ranger (CP<4)
;	beq out_srt			;| 
	tax					; X=1 ou 2 ou 3
	dex					; index catégorie de sorts en fonction de la carrière X= 0 ou 1 ou 2
	txa
	asl
	tax					; index catégorie de sorts en fonction de la carrière X= 0 ou 2 ou 4
	lda ptr_ptr_sorts,x		; partie basse adresse des adresses de l'une des 3 séries de 8 sorts
	sta sort_carr_1+1
	sta sort_carr_2+1	
	inx
	lda ptr_ptr_sorts,x		; partie haute adresse des adressse de l'une des 3 séries de 8 sorts
	sta	sort_carr_1+2
	sta sort_carr_2+2		
	ldx #$00
sort_carr_1	
	lda $1111,x			; lda $2d66 ;adresses des pointeurs de nomns de sorts; 3 adresse différentes en fonction de la carrière
	sta $21		
	inx
sort_carr_2		
	lda $1111,x	
	sta $22
;adr_sort
;	lda $2222,x			;adresses data des nomns de sorts; 3 adresse différentes en fonction de la carrière
	rts
;sort_carr	
;	.byt $00,$00	
	
;------------------------	
prnt_dta_sorts
;------------- sort n°1 ------------------------
srt1_		
	ldy $2a			; sort n°1 en position L+27 sur ligne data perso
	inc $2a
	lda ($37),y			; nb de sorts
	tax					; 
	dex
	bmi srt2_
	ora #$30			;
	pha
	lda #$c7
	sta $25
	lda #$b4
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 1
	ldx #$00
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort1
	lda #$be
	sta $23
	lda #$b4
	sta $24				
	jsr Ecr_LH
;------------- sort n°2 ------------------------
srt2_		
	ldy $2a			; sort n°2 en position L+28 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 2
	dex
	bmi srt3_
	ora #$30			;
	pha
	lda #$2f
	sta $25
	lda #$b6
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 2	
	ldx #$02
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort2
	lda #$26
	sta $23
	lda #$b6
	sta $24				
	jsr Ecr_LH	
;------------- sort n°3 ------------------------
srt3_		
	ldy $2a			; sort n°3 en position L+29 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 3
	dex
	bmi srt4_
	ora #$30			; 
	pha
	lda #$6f
	sta $25
	lda #$b7
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 3	
	ldx #$04
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort3
	lda #$66
	sta $23
	lda #$b7
	sta $24				
	jsr Ecr_LH		
;------------- sort n°4 ------------------------
srt4_		
	ldy $2a			; sort n°4 en position L+30 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 4
	dex
	bmi srt5_
	ora #$30			;
	pha
	lda #$af
	sta $25
	lda #$b8
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 4	
	ldx #$06
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort4
	lda #$a6
	sta $23
	lda #$b8
	sta $24				
	jsr Ecr_LH			
;------------- sort n°5 ------------------------
srt5_		
	ldy $2a			; sort n°5 en position L+31 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 5
	dex
	bmi srt6_
	ora #$30			;
	pha
	lda #$ef
	sta $25
	lda #$b9
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 5	
	ldx #$08
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort5
	lda #$e6
	sta $23
	lda #$b9
	sta $24				
	jsr Ecr_LH			
;------------- sort n°6 ------------------------
srt6_		
	ldy $2a			; sort n°6 en position L+32 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 6
	dex
	bmi srt7_
	ora #$30			;
	pha
	lda #$2f
	sta $25
	lda #$bb
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 6		
	ldx #$0a
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort6
	lda #$26
	sta $23
	lda #$bb
	sta $24				
	jsr Ecr_LH	
;------------- sort n°7 ------------------------
srt7_		
	ldy $2a			; sort n°7 en position L+33 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 7
	dex
	bmi srt8_
	ora #$30			;
	pha
	lda #$6f
	sta $25
	lda #$bc
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 7	
	ldx #$0c
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort7
	lda #$66
	sta $23
	lda #$bc
	sta $24				
	jsr Ecr_LH	
;------------- sort n°8 ------------------------
srt8_		
	ldy $2a			; sort n°8 en position L+34 sur ligne data perso
	inc $2a
	lda ($37),y
	tax					; n° sort 8
	dex
	bmi out_srt
	ora #$30			;
	pha
	lda #$af
	sta $25
	lda #$bd
	sta $26
	pla
	jsr Aff_Car			; affiche nb de sorts de type 8		
	ldx #$0e
	jsr sort_carr_1		; $21-$22 initialisé avec adre texte sort8
	lda #$a6
	sta $23
	lda #$bd
	sta $24				
	jsr Ecr_LH	
out_srt
	rts

	
	
;******************************************************
;****  Transforme en nb Hexa stocké sur 2 octets   ****
;****            en carractère ASCII               ****	
;******************************************************
;En enrée : A contient le nombre en hexa
; en sortie: A contient le nombre en décimal

hex_2_asc
	sed         ; Switch to decimal mode
	lda #$00    ; Ensure the result is clear
	sta$32
	sta $33
	sta $34
	ldx #$10	; 16 The number of source bits
        
nextBIT
	asl $35		; Shift out one bit (b7 ==> C  0 ==> b0)
	rol $36		; C ==> B0 puis  b7 ==> C 	
	lda$32		; And add into result
	adc$32
	sta$32
	lda $33		; propagating any carry
	adc $33
	sta $33
	lda $34		; ... thru whole result
	adc $34
	sta $34
	dex			; And repeat for next bit
	bne nextBIT
	cld 		; Back to binary
	rts
	
;*************************************************************	
;*******                 ZONE DATA                     *******
;;************************************************************

;-----------    Data ecran  camp (menu choix)     ------------

; dta textes choix actions
dta_BR1
	.asc $11,0
dta_camp
	.asc $07,"CAMP  ",0
dta_insp
	.asc $14,$07,"Inspect a hero  ",$10,0
dta_view_t
	.asc $10,$07,"View the  team  ",$10,0
dta_open_c
	.asc $10,$07," Open a chest   ",$10,0
dta_have_r
	.asc $10,$07," have  a rest   ",$10,0
dta_brk_c
	.asc $10,$07,"  Break camp    ",$10,0
dta_BR2
	.asc $11,0
; dta textes choix perso	
dta_k_m
;	.asc $10," Kaeso  ",$10,$10," Maelle ",$10,0
	.asc $10,"        ",$10,$10,"        ",$10,0
dta_e_v	
;	.asc $10," Elantia",$10,$10," Viggo  ",$10,0
	.asc $10,"        ",$10,$10,"        ",$10,0
dta_c_a
;	.asc $10," Carpo  ",$10,$10," Astrid ",$10,0
	.asc $10,"        ",$10,$10,"        ",$10,0
dta_BR3
	.asc $11,$0c,$07,0	
; data textes réponses programme
dat_sel_op1
	.asc "  Select an option     ",0
dat_sel_op2	
	.asc " Inspect which hero?   ",0
dat_sel_op3	
	.asc " Who is going to try?  ",0
dat_sel_op4	
	.asc "You regain yours spells",0
dat_sel_op5		
	.asc $01,$0c,"<  >",0
dat_sel_op6
	.asc "  Select a spell        ",0
dat_sel_op7
	.asc "  Select a hero to heal ",0	
;-----------------------------	
ptr_dta_mnu
	.byt <dta_BR1,>dta_BR1,<dta_camp,>dta_camp,<dta_insp,>dta_insp,<dta_view_t,>dta_view_t,<dta_open_c,>dta_open_c
	.byt <dta_have_r,>dta_have_r,<dta_brk_c,>dta_brk_c,<dta_BR2,>dta_BR2,<dta_k_m,>dta_k_m,<dta_e_v,>dta_e_v,<dta_c_a,>dta_c_a
	.byt <dta_BR3,>dta_BR3,<dat_sel_op1,>dat_sel_op1,<dat_sel_op2,>dat_sel_op2,<dat_sel_op3,>dat_sel_op3,<dat_sel_op4,>dat_sel_op4
	.byt <dat_sel_op5,>dat_sel_op5,<dat_sel_op6,>dat_sel_op6,<dat_sel_op7,>dat_sel_op7
	
;-----------    Adresses écran  dta camp (menu choix action)     ------------	
	
dta_adr_mnu
	.byt $a8,$bb										 ; Première bande rouge (BR1)
	.byt $b9,$bb,$03,$bc,$53,$bc,$a3,$bc,$f3,$bc,$43,$bd ; adresses textes  choix actions
	.byt $88,$bd 										 ; Deuxième bande rouge (BR2)
	.byt $33,$be,$82,$be,$d2,$be						 ; adresses textes  choix perso + "select an otion"
	.byt $40,$bf	
	.byt $4a,$bf,$4a,$bf,$4a,$bf,$4a,$bf,$b1,$bf

;-----------    Adresses écran  dta camp (menu choix perso (exam perso ou qui ouvre))     ------------		

;dta_adr_ch_perso
;	.byt $0b,$be,$5b,$be,$ab,$be,$15,$be,$65,$be,$b5,$be		
		
;-----------    Adresses écran  dta reponses programme     ------------			
dta_adr_txp
	.byt $48,$bf,$4c,$bf,$4a,$bf,$4a,$bf,$49,$bf,$af,$bf

;-----------    Adresses écran  dta camp (menu choix perso)     ------------
		

;---   adresses  des textes  sur écran HIRES  inspecter un perso ---
adr_txt_hi
;From #$00 to #$2d
	.byt $15,$A0,$95,$A2,$15,$A5,$1D,$A5,$95,$A7,$15,$AA,$1F,$AA
	.byt $95,$AC,$A4,$AC,$15,$AF,$68,$B0,$D0,$B1,$88,$B3,$68,$B5 ; 7ème place, $68 était $18
	.byt $98,$B7,$D8,$B8,$18,$BA,$58,$BB,$98,$BC,$D8,$BD,$DF,$B2
	.byt $9f,$B6,$5f,$BA
	
;From #$2e	to #$37 attribut couleur rouge et bleue
;	.byt $9A,$BF,$AF,$BF,$BC,$BF,$C8,$BF,$DC,$BF
;From #$2e	to #$33  3textes
	.byt $91,$BF,$91,$BF,$91,$BF,$91,$BF 
;	.byt $9d,$BF,$BF,$BF,$CB,$BF 	
;From #$34 to #$47 	
;---   adresses  des textes 2 (sorts)  sur écran HIRES inspecter un perso   ---
adr_txt_hi_s
	.byt $Db,$B2,$De,$B2,$bb,$B4,$23,$B6,$63,$B7,$a3,$B8,$e3,$B9
	.byt $23,$BB,$63,$BC,$a3,$Bd
	

;---  adresses  des textes 1  en mémoire  (perso) ----	
ind_tip
	.byt <t_ip_01,>t_ip_01,<t_ip_02,>t_ip_02,<t_ip_03,>t_ip_03,<t_ip_04,>t_ip_04,<t_ip_05,>t_ip_05
	.byt <t_ip_06,>t_ip_06,<t_ip_07,>t_ip_07,<t_ip_08,>t_ip_08,<t_ip_09,>t_ip_09,<t_ip_10,>t_ip_10
	.byt <t_ip_11,>t_ip_11,<t_ip_12,>t_ip_12,<t_ip_13,>t_ip_13,<t_ip_14,>t_ip_14,<t_ip_15,>t_ip_15
	.byt <t_ip_16,>t_ip_16,<t_ip_17,>t_ip_17,<t_ip_18,>t_ip_18,<t_ip_19,>t_ip_19,<t_ip_20,>t_ip_20	
	.byt <t_ip_21,>t_ip_21,<t_ip_22,>t_ip_22,<t_ip_23,>t_ip_23
;	.byt <t_ip_24,>t_ip_24,<t_ip_25,>t_ip_25,<t_ip_26,>t_ip_26,<t_ip_27,>t_ip_27,<t_ip_28,>t_ip_28
	.byt <t_ip_24,>t_ip_24,<t_ip_25,>t_ip_25,<t_ip_26,>t_ip_26,<t_ip_27,>t_ip_27
;---  adresses  des textes 2  en mémoire (perso sorts)  ----
ind_tips	
	.byt <t_ips_01,>t_ips_01,<t_ips_02,>t_ips_02
	.byt <t_ips_03,>t_ips_03,<t_ips_04,>t_ips_04
	.byt <t_ips_05,>t_ips_05,<t_ips_06,>t_ips_06
	.byt <t_ips_07,>t_ips_07,<t_ips_08,>t_ips_08
	.byt <t_ips_09,>t_ips_09,<t_ips_10,>t_ips_10	

;---  Textes 1 ecran inspection personnage   ---
t_ip_01
	.asc $07,$11,"                ",$10,0
t_ip_02
	.asc $01,"Carr:",$07,0
t_ip_03	
	.asc $03,"Niv:",$07,0
t_ip_04	
	.asc $03,"EXP:",$07,0
t_ip_05	
	.asc $01,"Sante:",$07,0
t_ip_06	
	.asc $03,"PV:",$07,0
t_ip_07	
	.asc $03,"/",$07,0
	
t_ip_08	
	.asc $01,"Bourse:",$07,0
t_ip_09	
	.asc $01,"CA",0
t_ip_10	
	.asc $03,"CA:",$07,0
t_ip_11	
	.asc $03,"Animal",$07,0
t_ip_12	
	.asc $01,"Arme D",$07,0
t_ip_13	
	.asc $03,"Arme G",$07,0
	
t_ip_14	
	.asc $01,"Armure",$07,0
	
; 6 item possibles dans le sac à dos
t_ip_15	
	.asc $03,"1",$07,"..................",0
t_ip_16	
	.asc $01,"2",$07,"..................",0
t_ip_17	
	.asc $03,"3",$07,"..................",0
t_ip_18	
	.asc $01,"4",$07,"..................",0
t_ip_19	
	.asc $03,"5",$07,"..................",0
t_ip_20	
	.asc $01,"6",$07,"..................",0
	
; capacité combat , tir,
t_ip_21
	.asc $11,$03,"CC  CT ",0
; force, agilité,
t_ip_22
	.asc $11,$03,"Fo  Ag ",0
; intelligence,force morale
t_ip_23	
	.asc $11,$03,"In  Fm ",0	
; -----------   1 ligne TEXT  fonction de carrière ( >3 on a des sorts , <4 on n'zn a pas )-------------
;t_ip_24	
;	.asc $11,0
;t_ip_25	
;	.asc $10,0
;t_ip_26	
;	.asc $14,0
;t_ip_27	
;	.asc $11,0
;t_ip_28	
;	.asc $10,0
t_ip_24	
	.asc $14," Spell ",$10," ",$11," Give money ",$10," ",$11," Give object ",$10,0
t_ip_25	
	.asc $14," Back  ",$10," ",$11," Give money ",$10," ",$11," Give object ",$10,0
t_ip_26	
	.asc $14," Back  ",$10," ",$11," Cast healing spell ",$10,"          ",0
t_ip_27
	.asc $14," Back  ",$10,"                                ",0	
	
;-----------  Textes 2 ecran sorts   ------------
t_ips_01
	.asc $11,"            ",0
t_ips_02
	.asc $03,"SORTS",0
t_ips_03	
	.asc $03,"1",$07,"........",$06,0
t_ips_04	
	.asc $01,"2",$07,"........",$06,0
t_ips_05	
	.asc $03,"3",$07,"........",$06,0
t_ips_06	
	.asc $01,"4",$07,"........",$06,0
t_ips_07	
	.asc $03,"5",$07,"........",$06,0
t_ips_08	
	.asc $01,"6",$07,"........",$06,0
t_ips_09	
	.asc $03,"7",$07,"........",$06,0
t_ips_10	
	.asc $01,"8",$07,"........",$06,0	
	
;---   Adresses des textes issus du prg BASIC et situé en $732F  dans le code de "camp" ---
	
tab_adr_data	; cette table se trouve entre $06BD et $071C dans le code de "CAMP" (mais commence par la fin ???)
	.byt $2F,$73,$3E,$73,$4B,$73,$57,$73,$67,$73,$74,$73,$83,$73,$8A,$73,$8F,$73,$98,$73,$9E,$73,$A5,$73,$AC,$73,$B2,$73,$BB,$73,$C0,$73
	.byt $C4,$73,$CA,$73,$D1,$73,$DA,$73,$E1,$73,$E7,$73,$EB,$73,$F2,$73,$F7,$73,$FE,$73,$03,$74,$09,$74,$10,$74,$14,$74,$1C,$74,$22,$74
	.byt $28,$74,$32,$74,$38,$74,$40,$74,$47,$74,$51,$74,$59,$74,$62,$74,$6C,$74,$76,$74,$79,$74,$80,$74,$87,$74,$8F,$74,$96,$74,$A1,$74

	
;---   Adresses des textes contenus echoppes ----

tab_adr_echoppes	;table se trouve entre $6A34 - $6A93 dans le code de "camp" ( et est dans le "bon" sens )
	.byt $A2,$6A,$B4,$6A,$C4,$6A,$D2,$6A,$E3,$6A,$EC,$6A,$FB,$6A,$08,$6B,$18,$6B,$2C,$6B,$38,$6B,$46,$6B,$4E,$6B,$5D,$6B,$62,$6B,$6B,$6B
	.byt $75,$6B,$7C,$6B,$82,$6B,$8B,$6B,$93,$6B,$9E,$6B,$AB,$6B,$BA,$6B,$C8,$6B,$D5,$6B,$E5,$6B,$EB,$6B,$F9,$6B,$02,$6C,$0E,$6C,$21,$6C
	.byt $2E,$6C,$3B,$6C,$49,$6C,$52,$6C,$62,$6C,$6B,$6C,$74,$6C,$7C,$6C,$82,$6C,$89,$6C,$8F,$6C,$9C,$6C,$A5,$6C,$AF,$6C,$BE,$6C,$D0,$6C	
;----------------------------------------
adr_scr_nm
	.byt $1c,$1b,$1c,$1c,$1c,$1c

;----------------------------------------	

;-----------  DATA TEAM ----------------
dta_kaeso
;   	Long  K   a   e   s   o  ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI  ExpExp
	.byt $05,$4B,$61,$65,$73,$6F,$24,$09,$01,$01,$25,$1A,$26,$24,$1D,$1E,$0C,$00,$04,$04,$01,$09   	; Kaeso  Legionnaire (1)
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	
;     	  Wr  Wl  Ar  CA  BT  6 items
	.byt $08,$09,$04,$25,$2B,$22,$00,$00,$00,$00,$00
	
;dta_elantia	
;   	 Long E   l   a   n   t   i   a  ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI 
	.byt $07,$45,$6C,$61,$6E,$74,$69,$61,$05,$08,$04,$02,$13,$1C,$1B,$21,$28,$28,$0B,$0B,$01,$02 	; Elantia  Priestess (4)
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;   	 ExpExp  Wr  Wl  Ar  CA  BT  6 items	             8 sorts
	.byt $FD,$01,$0E,$00,$06,$02,$00,$14,$16,$1A,$17,$19,$00,$04,$03,$04,$04,$03,$02,$02,$01
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	
;dta_carpo
;  	    Long  C   a   r   p   o  ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI  ExpExp 
	.byt $05,$43,$61,$72,$70,$6F,$DB,$07,$02,$01,$22,$23,$21,$26,$1D,$25,$0C,$0E,$01,$0F,$CF,$00    ; Carpo  Gladiator (2)
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;     	  Wr  Wl  Ar  CA  BT  6 items 
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	
;dta_maelle
;  	     Long M   a   e   l   l   e  ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI  Exp
	.byt $06,$4D,$61,$65,$6C,$6C,$65,$DC,$07,$03,$01,$1A,$1F,$18,$1B,$23,$22,$0F,$05,$02,$0F,$CC  	; Maelle  Mercenary (3)
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
;    	 Exp  Wr  Wl  Ar  CA  BT 6 items	              8 sorts
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$03,$03,$02,$03,$01,$01
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	
;dta_viggo
; 	     Long V   i   g   g   o   ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI ExpExp
;	.byt $05,$56,$69,$67,$67,$6F,$DC,$07,$05,$01,$27,$24,$1D,$25,$1D,$15,$0E,$0E,$01,$0F,$C4,$00    ; Viggo  Godi  (5)
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;  	   	  Wr  Wl  Ar  CA  BT  6 items
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;dta_astrid
;        Long A   s   t   r   i   d  ArgArg   C  Eth CC  SC  St  Ag  In  Ms  HP  RP  HE  NI  Exp
;	.byt $06,$41,$73,$74,$72,$69,$64,$F3,$03,$06,$01,$1C,$22,$1F,$26,$25,$20,$0C,$0C,$01,$0F,$C7   	; Astrid  Sorceress (6)
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;        Exp  Wr  Wl  Ar CA   BT  6 items	              8 sorts 
;	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$04,$02,$03,$02,$02,$01,$01
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	
;----------------------------------------
; reserve d'octets pour cas où 6 perso au lieu de 3 avec 8 sorts possibles
	.byt $00,$00,$00,$00,$00,$00,$00,$00
	.byt $00,$00,$00,$00,$00,$00,$00,$00	
	.byt $00,$00,$00,$00,$00,$00,$00,$00
; réserve de 20 octets pour cas où nom des 6 perso à 9 lettres (6x9=54) au lieu de 5+7+5+6+5+6=34 soit delta de 20
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00	

;-------------------------  pointeurs perso ds data team  -------------------
;ptr_dta_perso
;	.byt <dta_kaeso,>dta_kaeso,<dta_elantia,>dta_elantia,<dta_carpo,>dta_carpo
;	.byt <dta_maelle,>dta_maelle,<dta_viggo,>dta_viggo,<dta_astrid,>dta_astrid
	
;-------------------------  noms fichiers portraits perso  / team /...  -------------------	
p_kaeso
	.asc "PKAESO   BIN",0
P_elantia
	.asc "PELANTIA BIN",0
p_carpo
	.asc "PCARPO   BIN",0
p_maelle
	.asc "PMAELLE  BIN",0
p_viggo
	.asc "PVIGGO   BIN",0
p_astrid
	.asc "PASTRID  BIN",0

ptr_p_perso	
	.byt <p_kaeso,>p_kaeso,<P_elantia,>P_elantia,<p_carpo,>p_carpo
	.byt <p_maelle,>p_maelle,<p_viggo,>p_viggo,<p_astrid,>p_astrid

;**********************************************
;***        textes data du listing T3       ***
;***     démarre en $732F dans CAMP.COM     ***
;**********************************************

ptr_ingr
	.byt <foie_tr,>foie_tr,<huile_ro,>huile_ro,<rose_va,>rose_va,<encre_po,>encre_po,<fleur_ly,>fleur_ly,<sang_ro,>sang_ro

; Ingredients
foie_tr
	.byt $66,$6F,$69,$65,$20,$64,$65,$20,$74,$72,$75,$69,$74,$65,$00		; foie de truite
huile_ro	
	.byt $68,$75,$69,$6C,$65,$20,$64,$75,$20,$52,$6F,$63,$00				; huile du Roc
rose_va	
	.byt $72,$6F,$73,$65,$20,$64,$75,$20,$56,$61,$6C,$00					; rose du Val
encre_po	
	.byt $65,$6E,$63,$72,$65,$20,$64,$65,$20,$70,$6F,$75,$6C,$70,$65,$00	; encre de poulpe
fleur_ly	
	.byt $66,$6C,$65,$75,$72,$20,$64,$65,$20,$4C,$79,$73,$00				; fleur de Lys
sang_ro	
	.byt $73,$61,$6E,$67,$73,$75,$65,$20,$72,$6F,$79,$61,$6C,$65,$00		; sangsue royale
;-----------------------------------------------------------------------------------------------

ptr_ptr_sorts
	.byt <sorcie_,>sorcie_,<mestr_,>mestr_,<septo_,>septo_

sorcie_
	.byt <somm_,>somm_,<feu_,>feu_,<pierre_,>pierre_ ,<venin_,>venin_,<sang_,>sang_,<foudr_,>foudr_,<lave_,>lave_,<seism_,>seism_		; sorciers
mestr_	
	.byt <eau_,>eau_,<serum_,>serum_,<muscl_,>muscl_,<boucli_,>boucli_,<elixi_,>elixi_,<ecran_,>ecran_,<vie_,>vie_,<mort_,>mort_		; mestres
septo_	
	.byt <eppe_f,>eppe_f,<force_,>force_,<charm_,>charm_,<vision_,>vision_,<glace_,>glace_,<illus_,>illus_,<vent_,>vent_,<drag_,>drag_	; septons Priestess

; Sorts
;$08
drag_
	.byt $44,$52,$41,$47,$4F,$4E,$00			; DRAGON	SORTS réservés aux druides (septon) Priestess
;$07	
vent_	
	.byt $56,$45,$4E,$54,$00					; VENT
;$06	
illus_	
	.byt $49,$4C,$4C,$55,$53,$49,$4F,$4E,$00	; ILLUSION
;$05	
glace_	
	.byt $47,$4C,$41,$43,$45,$00				; GLACE
;$04	
vision_	
	.byt $56,$49,$53,$49,$4F,$4E,$00			; VISION
;$03	
charm_	
	.byt $43,$48,$41,$52,$4D,$45,$00			; CHARME
;$02	
force_	
	.byt $46,$4F,$52,$43,$45,$00				; FORCE
;$01	
eppe_f	
	.byt $45,$50,$45,$45,$2D,$46,$45,$55,$00	; EPEE-FEU
;$08	
mort_	
	.byt $4D,$4F,$52,$54,$00					; MORT		SORTS réservés aux druides  (Mestre sorts de soins))
;$07	
vie_	
	.byt $56,$49,$45,$00						; VIE
;$06	
ecran_	
	.byt $45,$43,$52,$41,$4E,$00				; ECRAN
;$05	
elixi_	
	.byt $45,$4C,$49,$58,$49,$52,$00			; ELIXIR
;$04	
boucli_	
	.byt $42,$4F,$55,$43,$4C,$49,$45,$52,$00	; BOUCLIER
;$03	
muscl_	
	.byt $4D,$55,$53,$43,$4C,$45,$00			; MUSCLE
;$02	
serum_	
	.byt $53,$45,$52,$55,$4D,$00				; SERUM
;$01	
eau_	
	.byt $45,$41,$55,$00						; EAU
;$08
seism_	
	.byt $53,$45,$49,$53,$4D,$45,$00			; SEISME	SORTS réservés aux druides (sorcier)
;$07	
lave_
	.byt $4C,$41,$56,$45,$00					; LAVE
;$06	
foudr_
	.byt $46,$4F,$55,$44,$52,$45,$00			; FOUDRE
;$05	
sang_	
	.byt $53,$41,$4E,$47,$00					; SANG
;$04	
venin_
	.byt $56,$45,$4E,$49,$4E,$00				; VENIN
;$03	
pierre_	
	.byt $50,$49,$45,$52,$52,$45,$00			; PIERRE
;$02	
feu_
	.byt $46,$45,$55,$00						; FEU
;$01	
somm_	
	.byt $53,$4F,$4D,$4D,$45,$49,$4C,$00		; SOMMEIL	
;--------------------------------------------------------------------------

ptr_maison
	.byt <Celtic,>Celtic,<Egyptian,>Egyptian,<Gallic,>Gallic,<Thrace,>Thrace,<Persian,>Persian
	.byt <Roman,>Roman,<Viking,>Viking
	
; Maisons
;$09
Celtic	
	.byt $53,$54,$41,$52,$4B,$00					; STARK 		Celtic
;$08	
Egyptian	
	.byt $54,$55,$4C,$4C,$59,$00					; TULLY			Egyptian
;$07	
Gallic	
	.byt $4C,$41,$4E,$4E,$49,$53,$54,$45,$52,$00	; LANNISTER		Gallic
;$06	
Thrace	
	.byt $41,$52,$52,$59,$4E,$00					; ARRYN			Thrace
;$05	
Persian	
	.byt $47,$52,$45,$59,$4A,$4F,$59,$00			; GREYJOY		Persian
;$04	
Roman	
	.byt $54,$59,$52,$45,$4C,$4C,$00				; TYRELL		Roman
;$03	
Viking	
	.byt $42,$41,$52,$41,$54,$48,$45,$4F,$4E,$00	; BARATHEON		Viking
;$02	

	
;------------------------------------------------------------------------
ptr_etats
	.byt<FINE_,>FINE_,<POIS_,>POIS_,<PARA_,>PARA_,<DEAD_,>DEAD_
; Etats	
;$04
DEAD_
	.byt $44,$45,$41,$44,$00	 ; DEAD
;$03	
PARA_	
	.byt $50,$41,$52,$41,$00	 ; PARA
;$02	
POIS_	
	.byt $50,$4F,$49,$53,$00	 ; POIS
;$01	
FINE_	
	.byt $46,$49,$4E,$45,$00	 ; FINE
;------------------------------------------------------------------------

; Carrières
;$06
Sor_
	.byt $53,$6F,$72,$63,$65,$72,$65,$65,$00			;(6) Sorceress 						Astrid (viking: woman who manipulates illusions and magic energy) 
;$05	
God
	.byt $47,$6F,$44,$69,$00							;(5) Godi ( Viking prêtre-Chef)		Viggo
;$04	
Prie
	.byt $50,$72,$69,$65,$73,$74,$28,$65,$73,$73,$29,$00;(4)Priest(ess)						Elantia
;$03	
Merc
	.byt $4D,$65,$72,$63,$65,$6E,$61,$72,$79,$00		;(3)Mercenary						Maelle
;$02	
Gla
	.byt $47,$6C,$61,$64,$69,$61,$74,$6F,$72,$00		;(2)Gladiator						Carpophorus
;$01	
Leg
	.byt $4C,$65,$67,$69,$6F,$6E,$61,$69,$79,$00		;(1)Legionary						Kaeso

ptr_carr
	.byt <Leg,>Leg,<Gla,>Gla
	.byt <Merc,>Merc,<Prie,>Prie
	.byt <God,>God,<Sor_,>Sor_	

;*************************************************
;***        textes MARCHANDISES ECHOPPES       ***
;***        liste de mots terminés par 00      ***
;*************************************************
; DATA sauvegardées entre  $6AA2 et $6CD6 dans le code original de "Camp"
ptr_data_echopes
; ptr_arm
	.byt <arm_val,>arm_val,<arm_aci,>arm_aci,<arm_fer,>arm_fer,<cot_mail,>cot_mail,<cuira_,>cuira_,<arm_cuir,>arm_cuir
	.byt <rob_bur,>rob_bur,<epee_val,>epee_val,<hach_wint,>hach_wint,<morgen_,>morgen_,<fleau_,>fleau_,<mart_,>mart_
	.byt <epee_2_m,>epee_2_m,<epee_,>epee_,<arba_,>arba_,<arc_c,>arc_c,<frond_,>frond_,<filet_,>filet_,<poign_,>poign_
; ptr_herb	
	.byt <ongu_,>ongu_,<bois_div,>bois_div,<potio_ebe,>potio_ebe,<ess_vit,>ess_vit,<potio_div,>potio_div
	.byt <potio_Zo,>potio_Zo,<potio_gla,>potio_gla	
; ptr_baz
	.byt <outre_,>outre_,<mich_pai,>mich_pai,<cervoi_,>cervoi_,<poiss_sec,>poiss_sec,<cuis_sang,>cuis_sang
	.byt <pot_greg,>pot_greg,<pied_bich,>pied_bich,<bouss_,>bouss_,<sell_drag,>sell_drag 	
; ptr_anim
	.byt <Dire_w,>Dire_w,<panth_,>panth_,<mol_,>mol_,<aigl_,>aigl_,<faucon_,>faucon_,<dogu_,>dogu_,<chat_sauv,>chat_sauv
; ptr_div
	.byt <couron_,>couron_,<solit_,>solit_,<perl_ey,>perl_ey,<coeu_diam,>coeu_diam,<bours_,>bours_
	
; armures
;X=$00                
arm_val
	.byt $41,$72,$6D,$75,$72,$65,$20,$76,$61,$6C,$79,$72,$69,$65,$6E,$6E,$65,$00	; Armure valyrienne
;$01	
arm_aci	
	.byt $41,$72,$6D,$75,$72,$65,$20,$65,$6E,$20,$61,$63,$69,$65,$72,$00			; Armure en acier
;$02	
arm_fer	
	.byt $41,$72,$6D,$75,$72,$65,$20,$64,$65,$20,$66,$65,$72,$00					; Armure de fer
;$03	
cot_mail	
	.byt $43,$6F,$74,$74,$65,$20,$64,$65,$20,$6D,$61,$69,$6C,$6C,$65,$73,$00		; Cotte de mailles
;$04	
cuira_	
	.byt $43,$75,$69,$72,$61,$73,$73,$65,$00										; Cuirasse
;$05	
arm_cuir	
	.byt $41,$72,$6D,$75,$72,$65,$20,$64,$65,$20,$63,$75,$69,$72,$00				; Armure de cuir
;$06	
rob_bur	
	.byt $52,$6F,$62,$65,$20,$64,$65,$20,$62,$75,$72,$65,$00						; Robe de bure
; armes	
;$07
epee_val
	.byt $45,$70,$65,$65,$20,$76,$61,$6C,$79,$72,$69,$65,$6E,$6E,$65,$00					; Epee valyrienne
;$08	
hach_wint	
	.byt $48,$61,$63,$68,$65,$20,$64,$65,$20,$57,$69,$6E,$74,$65,$72,$66,$65,$6C,$6C,$00	; Hache de  Winterfell
;$09	
morgen_	
	.byt $4D,$6F,$72,$67,$65,$6E,$73,$74,$65,$72,$6E,$00									; Morgenstern
;$0a	
fleau_	
	.byt $46,$6C,$65,$61,$75,$20,$64,$27,$61,$72,$6D,$65,$73,$00							; Fleau d'armes
;$0b	
mart_	
	.byt $4D,$61,$72,$74,$65,$61,$75,$00													; Marteau
;$0c	
epee_2_m	
	.byt $45,$70,$65,$65,$20,$61,$20,$32,$20,$6D,$61,$69,$6E,$73,$00						; Epee a 2 mains
;$0d	
epee_	
	.byt $45,$70,$65,$65,$00																; Epee
;$0e	
arba_	
	.byt $41,$72,$62,$61,$6C,$65,$74,$65,$00												; Arbalete 
;$0f	
arc_c	
	.byt $41,$72,$63,$20,$63,$6F,$75,$72,$74,$00											; Arc court
;$10	
frond_	
	.byt $46,$72,$6F,$6E,$64,$65,$00														; Fronde
;$11	
filet_	
	.byt $46,$69,$6C,$65,$74,$00															; Filet
;$12	
poign_	
	.byt $50,$6F,$69,$67,$6E,$61,$72,$64,$00												; Poignard
; (233 bytes)	
;------------------------------------------------------------------------	

;$13
ongu_
	.byt $4F,$6E,$67,$75,$65,$6E,$74,$00 									; Onguent
;$14	
bois_div	
	.byt$42,$6F,$69,$73,$20,$64,$69,$76,$69,$6E,$00							; Bois divin
;$15	
potio_ebe	
	.byt $50,$6F,$74,$69,$6F,$6E,$20,$45,$62,$65,$6E,$65,$00				; Potion Ebene
;$16	
ess_vit	
	.byt $45,$73,$73,$65,$6E,$63,$65,$20,$76,$69,$74,$61,$6C,$65,$00		; Essence vitale
;$17	
potio_div	
	.byt $50,$6F,$74,$69,$6F,$6E,$20,$44,$69,$76,$69,$6E,$65,$00			; Potion  Divine
;$18	
potio_Zo	
	.byt $50,$6F,$74,$69,$6F,$6E,$20,$5A,$6F,$6D,$61,$6E,$00				; Potion Zoman
;$19	
potio_gla
	.byt $50,$6F,$74,$69,$6F,$6E,$20,$67,$6C,$61,$63,$69,$61,$6C,$65,$00	; Potion glaciale
	

;------------------------------------------------------------------------
	
;$1a
outre_	
	.byt $4F,$75,$74,$72,$65,$00														; Outre
;$1b	
mich_pai	
	.byt $4D,$69,$63,$68,$65,$20,$64,$65,$20,$70,$61,$69,$6E,$00						; Miche de pain
;$1c	
cervoi_	
	.byt $43,$65,$72,$76,$6F,$69,$73,$65,$00											; Cervoise
;$1d	
poiss_sec	
	.byt $50,$6F,$69,$73,$73,$6F,$6E,$20,$73,$65,$63,$00								; Poisson sec
;$1e	
cuis_sang	
	.byt $43,$75,$69,$73,$73,$65,$20,$64,$65,$20,$73,$61,$6E,$67,$6C,$69,$65,$72,$00	; Cuisse de sanglier
;$1f	
pot_greg	
	.byt $50,$6F,$74,$20,$47,$72,$65,$67,$65,$6F,$69,$73,$00							; Pot Gregeois
;$20	
fut_greg	
	.byt $46,$75,$74,$20,$47,$72,$65,$67,$65,$6F,$69,$73,$00							; Fut Gregeois
;$21	
pied_bich	
	.byt $50,$69,$65,$64,$20,$64,$65,$20,$62,$69,$63,$68,$65,$00						; Pied de biche
;$22	
bouss_	
	.byt $42,$6F,$75,$73,$73,$6F,$6C,$65,$00											; Boussole
;$23	
sell_drag	
	.byt $53,$65,$6C,$6C,$65,$20,$64,$65,$20,$44,$72,$61,$67,$6F,$6E,$00				; Selle de Dragon

;------------------------------------------------------------------------ 	

;$24	
Dire_w
	.byt $44,$69,$72,$65,$57,$6F,$6C,$66,$00					; DireWolf
;$25	
panth_	
	.byt $50,$61,$6E,$74,$68,$65,$72,$65,$00					; Panthere
;$26	
mol_	
	.byt $4D,$6F,$6C,$6F,$73,$73,$65,$00						; Molosse
;$27	
aigl_	
	.byt $41,$69,$67,$6C,$65,$00								; Aigle
;$28	
faucon_	
	.byt $46,$61,$75,$63,$6F,$6E,$00							; Faucon
;$29	
dogu_	
	.byt $44,$6F,$67,$75,$65,$00								; Dogue
;$2a	
chat_sauv	
	.byt $43,$68,$61,$74,$20,$73,$61,$75,$76,$61,$67,$65,$00	; Chat sauvage
 
;------------------------------------------------------------------------

;$2b	
couron_	
	.byt $43,$6f,$75,$72,$6F,$6E,$6E,$65,$00										; Couronne
;$2c	
solit_	
	.byt $53,$6F,$6C,$69,$74,$61,$69,$72,$65,$00									; Solitaire
;$2d	
perl_ey	
	.byt $50,$65,$72,$6C,$65,$73,$20,$64,$27,$45,$79,$72,$69,$65,$00				; Perles d'Eyrie
;$2e	
coeu_diam	
	.byt $43,$6F,$65,$75,$72,$20,$64,$65,$20,$64,$69,$61,$6D,$61,$6E,$74,$73,$00	; Coeur de diamants
;$2f	
bours_	
	.byt $42,$6F,$75,$72,$73,$65,$00												; Bourse
	
;------------------------------------------------------------------------	
	
;*****************************************
;**********       image        ***********
;*****************************************

dta_image
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$10,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$40,$6E,$60,$40,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$54,$52,$54,$40,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$4A,$62,$48,$6A,$68,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$40,$60,$52,$50,$40,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$48,$60,$51,$51,$68,$10,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$60,$52,$48,$FB,$E5,$00,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$48,$41,$40,$51,$50,$59,$00,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$60,$44,$64,$44,$48,$6E,$60,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$50,$52,$03,$52,$51,$5D,$50,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$41,$42,$48,$55,$74,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$50,$44,$40,$01,$6A,$07,$55,$50,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$42,$40,$41,$44,$42,$52,$55,$4C,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$48,$41,$44,$03,$52,$49,$5E,$7C,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$60,$40,$01,$69,$4A,$06,$F5,$EB,$00,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$40,$40,$65,$4A,$57,$57,$00,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$07,$44,$03,$42,$56,$65,$5D,$6A,$00,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$4D,$40,$01,$61,$57,$96,$7B,$55,$10,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$46,$60,$03,$07,$4A,$53,$5A,$78,$00,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$01,$40,$4F,$50,$03,$4A,$66,$5B,$6F,$C3,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$E2,$D7,$01,$61,$57,$06,$DD,$CB,$40,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$40,$5F,$7A,$68,$06,$FD,$DA,$E4,$C1,$40,$40,$40,$40,$40,$10
	.byt $04,$40,$40,$40,$40,$E2,$13,$00,$7A,$7C,$07,$67,$5E,$10,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$C0,$CA,$D7,$06,$EE,$E0,$CA,$80,$7F,$40,$40,$40,$40,$10
	.byt $04,$40,$40,$40,$40,$C1,$D4,$83,$55,$55,$C0,$84,$E4,$40,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$40,$C0,$C8,$EA,$EF,$F4,$EA,$D4,$80,$04,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$41,$84,$E4,$ED,$D1,$DB,$D5,$CA,$87,$60,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$41,$86,$E4,$87,$5A,$52,$6F,$7F,$5F,$60,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$41,$86,$D0,$CA,$EA,$D6,$EA,$CA,$87,$60,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$41,$84,$E8,$E5,$FE,$FB,$D4,$CA,$87,$60,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$E8,$C5,$D7,$FD,$F4,$C5,$87,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$13,$55,$90,$50,$55,$13,$74,$00,$4F,$10,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$F4,$FF,$F7,$ED,$EA,$CA,$87,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$EA,$83,$68,$5D,$15,$76,$90,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$7A,$94,$E5,$DE,$F4,$82,$E4,$E5,$10,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$F4,$FB,$FF,$FB,$FD,$D7,$87,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$11,$64,$72,$10,$45,$55,$6B,$57,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$EC,$EB,$60,$94,$F5,$CA,$87,$CF,$10,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$13,$40,$40,$11,$FF,$4A,$6A,$6B,$10,$10,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$FA,$D5,$40,$FF,$DA,$D6,$F1,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$4A,$11,$56,$74,$FB,$FB,$13,$64,$04,$4B,$10,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$EC,$C2,$EA,$D5,$EE,$FF,$F4,$CD,$F0,$C9,$40,$40,$40,$40,$10
	.byt $04,$40,$40,$40,$F5,$EF,$83,$7C,$46,$95,$55,$6E,$6A,$6B,$10,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$FA,$CB,$FF,$EB,$FF,$FF,$FB,$D5,$D8,$CB,$00,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$4B,$7B,$94,$EB,$FB,$FD,$D5,$D4,$7F,$C6,$10,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$F5,$D5,$60,$03,$6A,$69,$48,$55,$86,$EB,$00,$40,$40,$40,$10
	.byt $04,$40,$40,$40,$FC,$81,$7A,$54,$45,$5E,$65,$06,$EE,$C7,$00,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$4B,$94,$EB,$FF,$FB,$DF,$FF,$F4,$C0,$C1,$10,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$EE,$DB,$40,$01,$52,$6B,$50,$54,$87,$72,$00,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$7A,$44,$60,$40,$48,$41,$06,$FD,$DF,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$5B,$7E,$62,$48,$41,$74,$44,$50,$5B,$72,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$FE,$EB,$EB,$40,$07,$5A,$41,$5D,$94,$D3,$10,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$4D,$86,$EA,$FF,$01,$7D,$53,$7B,$90,$7B,$10,$03,$40,$40,$10
	.byt $06,$40,$40,$40,$40,$F6,$CB,$48,$06,$E7,$FF,$E8,$E2,$78,$40,$03,$40,$40,$10
	.byt $07,$40,$40,$40,$47,$83,$7E,$60,$07,$7E,$84,$FE,$87,$58,$40,$03,$40,$40,$10
	.byt $03,$40,$40,$40,$47,$7F,$81,$7D,$06,$F5,$F1,$F1,$83,$78,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$86,$D3,$D5,$40,$E4,$D7,$F2,$13,$10,$10,$03,$04,$04,$10
	.byt $06,$40,$40,$40,$42,$F2,$C9,$D5,$04,$F6,$C5,$FA,$87,$70,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$40,$CA,$F5,$13,$10,$E4,$C2,$FA,$EB,$00,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$47,$7F,$7F,$CB,$06,$F2,$D2,$EA,$83,$70,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$46,$86,$EA,$F7,$04,$F5,$DD,$D7,$FF,$00,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$47,$90,$6A,$76,$06,$CF,$CA,$D1,$C9,$10,$10,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$4B,$7D,$6F,$58,$40,$5F,$65,$55,$6E,$60,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$47,$5F,$11,$60,$97,$72,$11,$76,$76,$10,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$40,$DA,$83,$54,$06,$F0,$CD,$D5,$83,$10,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$40,$45,$F5,$13,$FA,$10,$EA,$EE,$EA,$FF,$40,$40,$40,$40,$40,$10
	.byt $05,$40,$40,$40,$40,$13,$6A,$10,$03,$4C,$79,$7F,$7E,$60,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$43,$4B,$7A,$70,$40,$06,$D3,$C1,$DD,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$45,$7F,$13,$7F,$97,$7D,$4A,$6D,$6D,$10,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$42,$6B,$E0,$60,$40,$45,$C0,$7F,$50,$10,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$4B,$7F,$60,$41,$47,$13,$66,$7A,$10,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$42,$48,$7F,$60,$42,$4B,$5B,$53,$56,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$42,$65,$5E,$40,$06,$41,$ED,$11,$52,$10,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$41,$41,$59,$01,$40,$57,$52,$13,$10,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$41,$50,$58,$40,$40,$40,$42,$70,$45,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$41,$65,$5E,$40,$42,$42,$40,$7C,$56,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$40,$60,$5A,$40,$40,$57,$60,$74,$44,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$69,$4D,$50,$62,$7D,$76,$78,$54,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$50,$45,$40,$40,$42,$69,$50,$44,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$40,$49,$45,$40,$40,$45,$55,$44,$68,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$74,$53,$44,$60,$6F,$7F,$68,$68,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$40,$64,$41,$40,$07,$55,$69,$40,$48,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$54,$43,$68,$4A,$13,$75,$10,$74,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$40,$40,$60,$06,$F2,$EF,$03,$64,$40,$40,$40,$40,$40,$10
	.byt $07,$40,$40,$40,$40,$52,$03,$60,$49,$5F,$7C,$05,$50,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$48,$62,$54,$05,$6F,$74,$03,$64,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$40,$40,$44,$40,$42,$48,$6A,$68,$01,$60,$40,$40,$40,$40,$40,$10
	.byt $03,$40,$40,$03,$40,$4A,$40,$01,$45,$4A,$70,$4A,$60,$40,$40,$40,$40,$40,$10
	.byt $01,$40,$40,$40,$40,$40,$48,$60,$03,$44,$48,$07,$70,$40,$40,$40,$40,$40,$10
	.byt $04,$40,$40,$44,$01,$48,$60,$48,$41,$54,$61,$07,$78,$40,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$44,$01,$42,$40,$41,$40,$03,$50,$57,$87,$78,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$4C,$40,$01,$40,$44,$03,$51,$4A,$06,$C5,$87,$40,$40,$40,$40,$10
	.byt $04,$40,$40,$68,$40,$40,$01,$60,$51,$06,$FF,$FA,$C6,$E3,$40,$40,$40,$40,$10
	.byt $06,$40,$40,$50,$40,$40,$40,$01,$44,$48,$03,$67,$7C,$87,$5C,$40,$40,$40,$10
	.byt $04,$40,$40,$60,$60,$03,$44,$40,$40,$41,$5A,$F0,$CD,$E0,$87,$60,$40,$40,$10
	.byt $07,$40,$40,$44,$40,$01,$52,$61,$42,$64,$11,$07,$6D,$57,$7F,$FF,$10,$10,$10
	.byt $06,$40,$54,$6C,$50,$40,$40,$03,$41,$42,$54,$5F,$85,$E2,$87,$5F,$60,$10,$10
	.byt $04,$40,$51,$76,$48,$01,$44,$40,$03,$07,$69,$57,$7D,$75,$6B,$7F,$5F,$10,$10	
	
;*************************************************************
;****  charge TEAM.BIN et transfert data dans code camp   ****
;*************************************************************
Main_dta_camp_hero
	jsr load_team_bin
	jsr calc_long_dta
	ldx #$00   ;01
lp_mdch
	lda $a007,x
	sta dta_kaeso,x
	inx
	cpx $2b
	bne lp_mdch
	rts
	
;--------------------------------------------------------------
load_team_bin
		jsr swap_0p_97p		; sauvegarde variables page $00 en page $97
		jsr $477			; passe en RAM overlay (code SEDORIC)
		lda $c009			; N° de drive			
		sta $c028
		lda #$00
		sta $c04d
		sta $c04e
		jsr nom_team_buff	; place le nom du fichier à charger dans le buffer SEDORIC 
		jsr $e0e5			; charge le fichier dont le nom est dans le buffer
; calcule adresse de fin de chargement en fonction adresse début et longueur		
		clc
		lda $c04f			; ll longueur fichier TEAM mémorisée 
		adc $c052			; ll adresse début chargement
		sta adr_ll_sauv+1	; ll adresse fin chargement
		lda $c050			; hh longueur fichier TEAM mémorisée pour sauvegarde ultérieure
		adc $c053			; hh adresse début chargement
		sta adr_hh_sauv+1	; hh adresse fin chargement
		jsr $477			; retour sur ROM atmos (Oric-1)
		jsr swap_97p_0p		; restaure les variable de la page $00
		rts
;--------------------------------------------------------------
nom_team_buff
			ldx #$0b			;Nombre de lettres à transférer
loop_nblt	
			lda adr_nom_team,X	;Début boucle de transfert
			sta $C029,X			;Vers BUFFNOM en $C029
			dex					;Décrémente le compteur de boucle
			bpl loop_nblt		;Boucle si pas fini
			rts 		
;---------
adr_nom_team
			.asc "TEAM     BIN",0
;--------------------------------------------------------------
calc_long_dta
		lda #$00
		sta $2b
		ldx #$00 ;#$06
lp_cldta
		lda $2b
		sta $2c,x
		jsr l_dta_1perso
		inx		; dex
		cpx #$06
		bne lp_cldta
		rts
;--------------------------------------------------------------	
l_dta_1perso	
			txa
			pha
			ldx $2b
			lda $a007,x
			sta $2a			; longeur nom perso
			adc #$03		; Long+3 pointe sur carriere (+$28 sur hero suivant)
			adc $2b
			tax
			lda $a007,x		; carrière
			cmp #$04
			bmi l_1c
			lda #$24		; longueur dta cas 4,5,6
			bne sk_1c
l_1c
			lda #$1c		; longueur data cas 1,2,3
sk_1c
			clc
			adc $2a			; longueur nom ajoutée à longueur data
			adc $2b			; ajouté à ancienne longueur totale
			sta $2b			; nouvelle longueur stockée dans longueur totale tous heros
			pla
			tax
			rts	
;*************************************************************************
;****  Sauve TEAM.BIN après transfert data au format camp  vers $A007 ****
;*************************************************************************
main_sav_team
	jsr load_team_bin
	jsr transf_20_a0
	jsr save_team
	rts
;--------------------------------
transf_20_a0
		ldx #$01
lp_20_a0
		lda dta_kaeso,x
adr_dta_A0
		sta $a007,x
		inx
		cpx $2b
		bne lp_20_a0
		rts
;--------------------------------

save_team
		jsr swap_0p_97p
		jsr $477
		sei					; Interdit les interruptions
		LDA #$C0			; Code pour save "U"
		STA $C04D			; dans VSALO0
		LDA #$00			; Partie basse adresse début sauvegarde
		STA $C052			; Placée dans DESALO
		LDA #$A0			; Partie haute adresse début sauvegarde $A007
		STA $C053			; Placée dans DESALO
adr_ll_sauv	
		LDA #$11			; Partie basse adresse fin sauvegarde  (renseignée par routine load_team_bin)
		STA $C054			; Placée dans FISALO
adr_hh_sauv	
		LDA #$22			; Partie haute adresse fin sauvegarde  (renseignée par routine load_team_bin)
		STA $C055			; Placée dans FISALO
		JSR nom_team_buff	; Recopie la chaîne "TEAM     BIN" dans BUFFNOM
		LDA #$40			; Code de fichier type "bloc de données"
		STA $C051			; Dans FTYPE
		JSR $DE0B			; Appel routine SAVE de SEDORIC
		cli					; re autorise les interruptions
		jsr $477
		jsr swap_97p_0p
		rts		
	
