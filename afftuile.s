
;********************************************************
;***      routine test pour vérification  tuiles      ***
;***  affiche toutes les tuiles l'une après l'autre   *** 
;***             par appui sur les flèches            ***
;********************************************************
_test_verif
	ldy #0
  	lda (sp),y ; Adr lo
  	sta tmp0
  	iny
  	lda (sp),y ; Adr hi
  	sta tmp1
	jsr impl_car
test_tuiles
	jsr hires_et_atributs			; spécifique à ce test passe en HIRES et installe 12 atributs de couleur (hauteur tuile)
	ldx #$00						; N° d'ordre de la tuile à afficher
lp_tuile
	jsr _init_scr_hires				; Spécifique pour mon test $A002, $A003
	txa								; sauve le n° de tuile  affichée
	pha								; sur la pile
	jsr cherche_et_aff_tuile		;************* C'EST LA ROUTINE QUE TU PEUX RECPERER TELLE QUELLE  *************
	pla
	tax
	jsr wait_touche					; attend appui puis relaché touche
chk_208	
	lda $208
	cmp #$BC						; touche flèche droite ==> tuile suivante
	bne autre_touche_1
	inx
	cpx #$4E						; Nb max de tuiles
	bne lp_tuile
	dex
	jmp chk_208
autre_touche_1	
	cmp #$AC						; touche flèche GAUCHE ==> tuile précédente		
	bne on_sort						; ni précédente, ni suivante
	dex
	cpx #$FF
	bne lp_tuile
	inx
	beq chk_208
on_sort	
	cmp #$84						; on sort par appui sur barre espace
	bne chk_208						; aucun des trois alors boucle sur test touches
	rts

;---------------------------------------------------------------------
;- passe en mode HIRES et installe 12 atributs couleur jaune et cyan -
;---------------------------------------------------------------------	 routine spécifique pour mon test
hires_et_atributs	
		jsr $EC33
		lda #$03
		sta $A001
		sta $A051
		sta $A0A1
		sta $A0F1	
		sta $A141
		sta $A191
		lda #$06
		sta $A029
		sta $A079
		sta $A0c9
		sta $A119
		sta $A169
		sta $A1b9
		rts

;-----------------------------------------------------------
;----   Affiche une tuile en haut à gauche de l'écran HIRES
;-----------------------------------------------------------
cherche_et_aff_tuile
; en entrée : X contient le n° de tuile
; En sortie : La tuile est à l'écran
	
		jsr find_compsants
		jsr aff__tuile			; côte à côte pour minimiser le Nn d'addition (adrsses écran)
		rts

;----------------------------------------------------------
;---            cherche  4 composants tuile             ---
;----------------------------------------------------------
; en entrée : X contient le n° de tuile
; en sortie : les 4 n° de sous tuiles sont stockées en $00,$01,$02,$03 

find_compsants

			asl					;vers table DATA PLAN T4
			tax					;
			lda ptr_t,x			;Partie basse adresse composants
			sta adr_compo+1
			inx
			lda ptr_t,x	;partie haute adresse composants
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
			ldx #$00				; 0 pour indexer le premier 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères supérieurs (dont n° d'ordre stocké en $00 et $01)
			ldx #$02				; 2 pour indexer le 3 ème 1/4 de tuile
			jsr aff_demi_t			; les 2 caractères inférieurs (dont n° d'ordre stocké en $02 et $03)
			rts	
;----------------------------------
;--- init adresses écran HIRES ----
;----------------------------------
_init_scr_hires
				lda tmp0				;Routine et Adresses spécifiques pour mon test
				sta adr_screen_1+1
				lda tmp1
				sta adr_screen_1+2
				sta adr_screen_2+2
				lda tmp0
				clc
				adc 1
				sta adr_screen_2+1
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
;----------------------------------
;--- MàJ adresses écran HIRES ----
;----------------------------------
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
; -----  routine attend appui touche puis relacher ---
;------------------------------------------------------ spécifique pour mon test
wait_touche	
		lda $208
		cmp #$38
		beq wait_touche
wait_lachez	
		lda $208
		cmp #$38
		bne wait_lachez	
		rts		
		
		
;************************************************
;***   implantation caractères redéfinis      ***
;************************************************ 	peut être lancé séparément pour ne charger dans le jeu
;													que la zone des caractères  une fois rédéfinie
impl_car
	ldx #$00
lp1_impl	
	lda dta_car_redef_p1,x
	sta $b900,x
	inx
	cpx #$FC
	bne lp1_impl
	ldx #$00
lp2_impl	
	lda dta_car_redef_p2,x
	sta	$b9fc,x
	inx
	cpx #$50
	bne lp2_impl	
	jsr hires_
	rts
	
;---------------------------------------------------------------------
;- passe en mode HIRES et installe 12 atributs couleur jaune et cyan -
;---------------------------------------------------------------------	 Routine Spécifique pour mon test
hires_	
	jsr $EC33
	lda #$03
	sta $A001
	sta $A051
	sta $A0A1
	sta $A0F1	
	sta $A141
	sta $A191
	lda #$06
	sta $A029
	sta $A079
	sta $A0c9
	sta $A119
	sta $A169
	sta $A1b9
	rts	

	
; -----------------------------------------------
;       Table redéfinition  2nd jeu de car 
; -----------------------------------------------

dta_car_redef_p1
;00 en $b900
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $fe	;1,1,1,1,1,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0	

;01 en $b906
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0	


;02 en $b90c
	.byt $fb	;1,1,1,1,1,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	
;03 en $b912
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0	
	
;04 en $b918
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1	
	
;05 en $b91e
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $f3 	;1,1,1,1,0,0,1,1	
	
;06 en $b924
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $7a 	;0,1,1,1,1,0,1,0
	.byt $dc 	;1,1,0,1,1,1,0,0
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $cd 	;1,1,0,0,1,1,0,1	
	
;07  en $b92a
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $55	;0,1,0,1,0,1,0,1	
	
;08  en $b930
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $55	;0,1,0,1,0,1,0,1	
	
;09  en $b936
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $55	;0,1,0,1,0,1,0,1	
	
;0A  en $b93c
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $73 	;0,1,1,1,0,0,1,1
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $5f 	;0,1,0,1,1,1,1,1
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1	

;0B  en $b942
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $43 	;0,1,0,0,0,0,1,1
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $57 	;0,1,0,1,0,1,1,1
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $7f 	;0,1,1,1,1,1,1,1

;0C  en $b948
	.byt $cf 	;1,1,0,0,1,1,1,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $7e 	;0,1,1,1,1,1,1,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $7f 	;0,1,1,1,1,1,1,1

;0D  en $b94e
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $63 	;0,1,1,0,0,0,1,1
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $47 	;0,1,0,0,0,1,1,1
	
;0E  en $b954
	.byt $62 	;0,1,1,0,0,0,1,0
	.byt $71 	;0,1,1,1,0,0,0,1
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $71 	;0,1,1,1,0,0,0,1
	.byt $78 	;0,1,1,1,1,0,0,0
	.byt $54 	;0,1,0,1,0,1,0,0	
	
;0F  en $b95a
	.byt $63 	;0,1,1,0,0,0,1,1
	.byt $45 	;0,1,0,0,0,1,0,1
	.byt $60 	;0,1,1,0,0,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1
	.byt $68 	;0,1,1,0,1,0,0,0
	.byt $51 	;0,1,0,1,0,0,0,1	
	
;10  en $b960
	.byt $69 	;0,1,1,0,1,0,0,1
	.byt $5c 	;0,1,0,1,1,1,0,0
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $72 	;0,1,1,1,0,0,1,0
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $72 	;0,1,1,1,0,0,1,0	
	
;11  en $b966
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0		
	
;12  en $b96c
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0	
	
;13  en $b972
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0	
	
;14  en $b978
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1	
	
;15  en $b97e
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1	
	
;16  en $b984
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $55 	;0,1,0,1,0,1,0,1

;17  en $b98a
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	
;18  en $b990
	.byt $c0 	;1,1,0,0,0,0,0,0 
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0	
	
;19  en $b996
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1	
	
;1A  en $b99c
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0	
	
;1B  en $b9a2
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0	
	
;1C  en $b9a8
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $dc 	;1,1,0,1,1,1,0,0	
	
;1D  en $b9ae
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1	
	
;1E  en $b9b4
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $ec 	;1,1,1,0,1,1,0,0	
	
;1F  en $b9ba
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $d1 	;1,1,0,1,0,0,0,1
	.byt $c1	;1,1,0,0,0,0,0,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0	
	
;20  en $b9c0
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0	
	
;21  en $b9c6
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $76 	;0,1,1,1,0,1,1,0	
	
;22  en $b9cc
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $6a 	;0,1,1,0,1,0,1,0
	.byt $55 	;0,1,0,1,0,1,0,1

;23  en $b9d2
	.byt $76 	;0,1,1,1,0,1,1,0
	.byt $f6 	;1,1,1,1,0,1,1,0
	.byt $db 	;1,1,0,1,1,0,1,1
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0
	.byt $de 	;1,1,0,1,1,1,1,0

;24  en $b9d8
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0

;25  en $b9de
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0

;26  en $b9e4
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c4 	;1,1,0,0,0,1,0,0
	.byt $ce 	;1,1,0,0,1,1,1,0

;27  en $b9ea
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0

;28  en $b9f0
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c7 	;1,1,0,0,0,1,1,1
	.byt $cd 	;1,1,0,0,1,1,0,1	
	
;29  en $b9f6
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $c0 	;1,1,0,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0	

dta_car_redef_p2	
;2A  en $b9fc
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c6 	;1,1,0,0,0,1,1,0
	.byt $c7 	;1,1,0,0,0,1,1,1	
	
;2B  en $ba02
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e2 	;1,1,1,0,0,0,1,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $c8 	;1,1,0,0,1,0,0,0
	.byt $cc 	;1,1,0,0,1,1,0,0	
	
;2C  en $ba08
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1	
	
;2D  en $ba0e
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0	
	
;2E  en $ba14
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c5 	;1,1,0,0,0,1,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c6 	;1,1,0,0,0,1,1,0	
	
;2F  en $ba1a
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e4 	;1,1,1,0,0,1,0,0     ;1,1,1,0,0,0,1,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0     ;1,1,0,0,0,0,0,0

;30  en $ba20
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c1 	;1,1,0,0,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c7 	;1,1,0,0,0,1,1,1

;31  en $ba26
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $e0 	;1,1,1,0,0,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $f8 	;1,1,1,1,1,0,0,0

;32  en $ba2c
	.byt $cb 	;1,1,0,0,1,0,1,1
	.byt $c9 	;1,1,0,0,1,0,0,1      ;1,1,0,1,0,0,0,1
	.byt $c3 	;1,1,0,0,0,0,1,1
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0
	.byt $c2 	;1,1,0,0,0,0,1,0       ;1,1,0,0,0,0,0,0

;33  en $ba32
	.byt $f4 	;1,1,1,1,0,1,0,0
	.byt $e8 	;1,1,1,0,1,0,0,0
	.byt $f0 	;1,1,1,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d0 	;1,1,0,1,0,0,0,0
	.byt $d8 	;1,1,0,1,1,0,0,0
	
;34  en $ba38
	.byt $ff 	;1,1,1,1,1,1,1,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $41 	;0,1,0,0,0,0,0,1
	.byt $61 	;0,1,1,0,0,0,0,1
	.byt $55 	;0,1,0,1,0,1,0,1
	.byt $5f 	;0,1,0,1,1,1,1,1	
	
;35  en $ba3e
	.byt $df 	;1,1,0,1,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $47 	;0,1,0,0,0,1,1,1
	.byt $7c 	;0,1,1,1,1,1,0,0	
	
;36  en $ba44
	.byt $4f 	;0,1,0,0,1,1,1,1
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $fe 	;1,1,1,1,1,1,1,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0	
	
;37  en $ba4a
	.byt $70 	;0,1,1,1,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0
	.byt $40 	;0,1,0,0,0,0,0,0	

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
		.byt $00,$04,$04,$02
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
		.byt $11,$01,$12,$02
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
		.byt $19,$1A,$1B,$1C
_t48 
		.byt $1D,$1E,$1F,$20
_t49 
		.byt $24,$25,$26,$27		
_t4A 
		.byt $28,$29,$2A,$2B		
_t4B 
		.byt $2C,$2D,$2E,$2F		
_t4C 
		.byt $30,$31,$32,$33
_t4D 
		.byt $34,$35,$36,$37		
; -----------------------------------------------
;       Table des pointeurs adresse tuiles  
; ----------------------------------------------- 	évite d'additionner n fois 4 pour trouver la composition 
;													de la tuile n (rapidité scroll)
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

; -----------------------------------------------------------------------------
;    Table adresses car modifiés dans 2nd jeu de car mode Hires (1/4 de tuile)
; ----------------------------------------------------------------------------- ici, pas besoin de pointerus d'adresses car pas d'addition 
;																				pour trouver l'adresse du car n il suffit de décaler à gauche
;																				le registre contenant le n° du car pour trouver l'adresse.		   
sous_tuile
	.byt $9d,$00,$9d,$06,$9d,$0c,$9d,$12,$9d,$18,$9d,$1e,$9d,$24,$9d,$2a,$9d,$30,$9d,$36,
	.byt $9d,$3c,$9d,$42,$9d,$48,$9d,$4e,$9d,$54,$9d,$5a,$9d,$60,$9d,$66,$9d,$6c,$9d,$72,
	.byt $9d,$78,$9d,$7e,$9d,$84,$9d,$8a,$9d,$90,$9d,$96,$9d,$9c,$9d,$a2,$9d,$a8,$9d,$ae,
	.byt $9d,$b4,$9d,$ba,$9d,$c0,$9d,$c6,$9d,$cc,$9d,$d2,$9d,$d8,$9d,$de,$9d,$e4,$9d,$ea,
	.byt $9d,$f0,$9d,$f6,$9d,$fc,$9e,$02,$9e,$08,$9e,$0e,$9e,$14,$9e,$1a,$9e,$20,$9e,$26,	
	.byt $9e,$2c,$9e,$32,$9e,$38,$9e,$3e,$9e,$44,$9e,$4a	


	
	
	