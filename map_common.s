
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


;********************************************************
;**** routine ecrit une phrase sur ligne écran text  ****
;********************************************************
write_phrase
.(
	lda $1111,x
	beq end_phrase
+adr_ecr_txt
	sta $bf11,x
	inx
	bne write_phrase
end_phrase
	lda #$01
	sta est_affiche_texte
	rts
.)

;****************************************************
;****  routine attend appui sur 'Y' et laché  ****
;****************************************************
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
;****************************************************
;****   routine attend appui et laché  any key   ****
;****************************************************
hit_release_key
.(
	lda $208
	cmp #$38
	bne hit_release_key
ld_208
	lda $208
	cmp #$38
	beq ld_208
	rts
.)
;************************************************
;*******       efface le texte       ************
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
	lda #$0
	rts
.)







