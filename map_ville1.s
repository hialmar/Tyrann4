#include "map_common_ville.s"

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
	jsr cadre_plan			; dessine un cadre blanc autour du plan de ville
	jsr bandeau				; dessine image au dessus du plan
main_loop
	; sei
	jsr scrl_fenetre		; Affiche/ scrolle les 105 tuiles dans la fenetre
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
sortie_main2
	; test bascule combat
	ldy #$0         ; grab string pointer
	lda #<ProgMap
	sta (sp),y
	iny
	lda #>ProgMap
	sta (sp),y
	dey
	jsr _SwitchToCommand
	;jsr _DiscLoad
	;jmp _main
	; rts						; sortie provisoire, rend la main au BASIC pour charger la FAKE ville et sortie
							; pour re-rentrer : CALL #2000
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
		lda direction_scroll					; mémoire touche pressée
		cmp #$ac				; recherche contenu tuile à gauche
		bne sens_2
		dec rang_map			; supprimer si retour
		bpl suite_chck_around_1	; bmi no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; le perso était en bord gauche map
suite_chck_around_1
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin,on peut soit scroller soit avancer
		bne tuile_speciale			; sinon test situile spéciale
sens_2
		cmp #$bc				; recherche contenu tuile à droite
		bne sens_3
		lda rang_map
		cmp #$1f				; rang tuile en bord droit de map
		bne suite_chck_around_2 ; Le beq no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; si perso en bord droit, pas de scroll
suite_chck_around_2
		inc rang_map					; si non, on regarde ce qu'il y a à droite
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin
		bne tuile_speciale
sens_3
		cmp #$9c				; recherche contenu tuile au dessus
		bne sens_4
		dec ligne_map			; a supprimer si retour
		bpl suite_sens_3		;Modif dûe à un "branch out of range"
		jmp no_scroll
;		bmi no_scroll
suite_sens_3
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin
		bne tuile_speciale
sens_4
		cmp #$b4				; recherche contenu tuile en dessous
		bne around_sortie
		lda ligne_map
		cmp #$30
		bne cont_b4
		jmp no_scroll
cont_b4
		inc ligne_map
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie
		bne tuile_speciale
around_sortie
		lda #FALSE
		sta scroll_est_interdit				; ré-autorise scroll (pour une boucle dans la direction demandée)
		sta depl_perso_est_interdit				; ré-autorise mvt perso (pour une boucle dans la direction demandée)
sortie_scroll_direct
		rts
;-----------------------------------------------------------------------------
tuile_speciale
		cmp#$51
		bmi no_scroll
		cmp #$52				; have you the right key for gate 1?
;		bmi no_scroll
		bne chck_54
		lda on_a_clef_1
		bne around_sortie		; test: $18 =1 => on a la clef_1	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
chck_54		; clef_1
		lda tuile_courante
		cmp #$54
		bne chck_58
		lda #TRUE
		sta on_a_clef_1					; met à 1 drapeau clef 1
		bne around_sortie
chck_58		; a guard ask for pass word
		lda tuile_courante
		cmp #$58				;
		bne chck_57
		lda mot_de_passe
		bne around_sortie		; test:   $1a =1 => on a mot de passe	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
chck_57		; patricienne donne mdp
		lda tuile_courante
		cmp #$57
		bne chck_55
		lda #TRUE
		sta mot_de_passe					; met à 1 drapeau mote de passe
		bne around_sortie
chck_55		; clef_2
		lda tuile_courante
		cmp #$55
		bne chck_53
		lda #TRUE
		sta on_a_clef_2			; met à 1 drapeau clef 2
		bne around_sortie
chck_53		; have you the rigth key for gate 2?
		lda tuile_courante
		cmp #$53
		bne around_sortie
		lda on_a_clef_2
		bne around_sortie		; test: $19 =1 => on a la clef_2	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
no_scroll
		lda #TRUE
		sta scroll_est_interdit				;mets à 1 drapeau scroll interdit (pour une boucle, dans la direction demandée)
		sta depl_perso_est_interdit				;mets à 1 drapeau mvt perso  interdit (pour une boucle, dans la direction demandée)
		rts
.)

#include "map_common.s"

;-----------------------------------------------------------------------------
; -----                initialise divers variables dont:                   ---
;	             coordonnées coin haut gauche partie table affichée      -----
;                     tuile perso affichée / index position perso
;-----------------------------------------------------------------------------
init_div_var
.(
	lda #$14		; coordonnées pour l'entrée (départ jeu)
	sta ligne_hg_map			; N° de ligne fixe tant que pas de scroll
	lda #$ff
	sta rang_hg_map			; rang ds ligne fixe tant que pas de scroll
	lda #$22
	sta tuile_perso_aff			; code tuile perso affichée
	lda #$2d
	sta index_perso			; valeur index perso dans table adresses hires fenêtre
	lda #$bc
	sta direction_scroll			;  valeurs => ddirection scroll demandée
	lda #$03
	sta ordo_perso_fen			; Abscisse perso dans fenêtre Hires
	lda #$01
	sta absc_perso_fen			; Ordonnée perso dans fenêtre Hires
	lda #0		; repère tuile Nemausus
	sta tuile_sous_pos_perso			; sous position perso au départ
	lda #FALSE
	sta peut_bouger_horiz			; drapeau deplacement horizontal perso dans fenêtre : 0 => pas de déplacement
	sta peut_bouger_vert			; drapeau deplacement vertical  perso dans fenêtre : 0 => pas de déplacement
	sta a_un_bateau			; drapeau bateau : 1 on a un bateau / 0 pas de bateau
	sta est_affiche_texte			; drapeau nom ville à l'écran 	1 : nom à l'ecran , 0 rien
	sta scroll_est_interdit			; drapeau scroll autorisé/interdit 	1 : interdit , 0 autorisé
	sta depl_perso_est_interdit			; drapeau déplacement perso autorisé/interdit 	1 : interdit , 0 autorisé
	sta on_a_clef_1
	sta on_a_clef_2
	sta mot_de_passe
	sta laisser_passer
	sta numero_lieu         ; indique lieu <> Gallia (0)
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
	cpx #$FC
	bne lp2_impl
	ldx #$00
lp3_impl
	lda dta_car_redef_p3,x
	sta	$9ef8,x
	inx
	cpx #$fc			;dernier car en $9ff4
	bne lp3_impl
	rts
.)


;************************************************
;******* Affiche différents textes   ************
;************************************************
aff_text
.(
;--------------------------------------------------
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	jsr hit_release_key
	jsr eff_text
;---------------------------------------------------
key_1	
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	jsr hit_release_key
	jsr eff_text
	
	ldx #$00
	lda t_key_3,x
	sta adr_ecr_txt+1
	lda #<t_key_3+1
	sta write_phrase+1
	lda #>t_key_3+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_release_key
	jsr eff_text
;-------------------------------------------------------------
voleur_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	jsr hit_release_key
	jsr eff_text
;-------------------------------------------------
_mot_de_passe
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	jsr hit_release_key
	jsr eff_text	
	rts
;-------------------------------------------------
garde_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$58				; valeur tuile pour garde 
	beq suite_garde
	jmp legat_
suite_garde
	jsr eff_tuile_spe
	ldx #$00
	lda t_garde_3,x
	sta adr_ecr_txt+1
	lda #<t_garde_3+1
	sta write_phrase+1
	lda #>t_garde_3+1
	sta write_phrase+2
	jsr write_phrase	

ldx #$00
	lda t_garde_4,x
	sta adr_ecr_txt+1
	lda #<t_garde_4+1
	sta write_phrase+1
	lda #>t_garde_4+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	
ldx #$00
	lda t_garde_5,x
	sta adr_ecr_txt+1
	lda #<t_garde_5+1
	sta write_phrase+1
	lda #>t_garde_5+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	rts	
;-------------------------------------------------
legat_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$59				; valeur tuile pour legat qui donne bourse
	beq suite_legat
	jmp entrance_	
suite_legat
	jsr eff_tuile_spe	
	ldx #$00
	lda t_legat_1,x
	sta adr_ecr_txt+1
	lda #<t_legat_1+1
	sta write_phrase+1
	lda #>t_legat_1+1
	sta write_phrase+2
	jsr write_phrase	

	ldx #$00
	lda t_legat_2,x
	sta adr_ecr_txt+1
	lda #<t_legat_2+1
	sta write_phrase+1
	lda #>t_legat_2+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text

	ldx #$00
	lda t_legat_3,x
	sta adr_ecr_txt+1
	lda #<t_legat_3+1
	sta write_phrase+1
	lda #>t_legat_3+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	rts
;-------------------------------------------------	
entrance_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$51				; valeur entrée ville
	bne medicus_
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
	rts
;-------------------------------------------------	
medicus_	
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	lda tuile_sous_pos_perso			; valeur tuile sous perso
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
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5e				; valeur auberge
	bne bazar_
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
bazar_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5f				; valeur Bazar
	bne coffre_
	ldx #$00
	lda t_bazar_1,x
	sta adr_ecr_txt+1
	lda #<t_bazar_1+1
	sta write_phrase+1
	lda #>t_bazar_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr eff_text	
;-------------------------------------------------
coffre_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$63				; valeur coffre
	bne fin_txt
	ldx #$00
	lda t_coffre_1,x
	sta adr_ecr_txt+1
	lda #<t_coffre_1+1
	sta write_phrase+1
	lda #>t_coffre_1+1
	sta write_phrase+2	
	jsr write_phrase
	
	ldx #$00
	lda t_coffre_2,x
	sta adr_ecr_txt+1
	lda #<t_coffre_2+1
	sta write_phrase+1
	lda #>t_coffre_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	lda direction_scroll
	cmp #$86
	bne sk_ef
	inc nb_coffres_non_ouverts
	jsr eff_tuile_spe
sk_ef	
	lda #$38
	sta direction_scroll
	jsr eff_text
;-------------------------------------------------		
fin_txt	
	rts
.)


;********************************************************	
;****            routine why no scroll               ****
;********************************************************
why_no_scoll
.(
		lda tuile_courante
		cmp #$52	;portail 1 vous n'avez pas clef_1
		bne chck_wns_58
		jsr no_pasaran
		rts
chck_wns_58		
		cmp #$58	; garde vousn 'avez pas mot de pass
		bne chck_wns_53
		jsr garde_nsc
		rts
chck_wns_53	
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

	ldx #$00
	lda t_garde_2,x
	sta adr_ecr_txt+1
	lda #<t_garde_2+1
	sta write_phrase+1
	lda #>t_garde_2+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text	
	rts
.)

;-------------------------------------
no_pasaran
.(
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
.)

	
;*******************************************
;*******    DATA PLAN VILLE_01   ************
;*******************************************
_L00
	.byt $13,$02,$01,$02,$01,$02,$01,$02,$01,$13,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$03,$04
_L01
	.byt $12,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12
_L02
	.byt $12,$00,$13,$02,$01,$02,$01,$02,$01,$03,$03,$04,$00,$13,$03,$04,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$04,$00,$12
_L03
	.byt $05,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$12,$00,$12,$00,$12,$00,$1e,$00,$00,$06,$0e,$00,$00,$57,$12,$00,$05
_L04
	.byt $04,$00,$12,$00,$14,$14,$14,$14,$14,$14,$00,$00,$00,$12,$00,$12,$00,$12,$1f,$20,$00,$00,$0f,$10,$00,$00,$1e,$13,$03,$04
_L05
	.byt $05,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$12,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$1f,$20,$12,$00,$05
_L06
	.byt $04,$00,$01,$03,$02,$01,$02,$01,$02,$01,$03,$11,$00,$12,$00,$12,$00,$01,$52,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$04
_L07
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
_L08
	.byt $13,$03,$02,$01,$02,$01,$02,$00,$13,$02,$01,$02,$01,$11,$00,$01,$03,$03,$04,$00,$04,$00,$04,$00,$04,$00,$00,$04,$00,$04
_L09
	.byt $12,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$12,$00,$12,$00,$12,$00,$00,$12,$00,$05
_L10
	.byt $13,$03,$02,$00,$01,$02,$01,$02,$11,$00,$13,$03,$04,$00,$13,$03,$04,$00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$12,$00,$04
_L11
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$12,$00,$12,$63,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$05
_L12
	.byt $04,$00,$04,$00,$04,$00,$13,$03,$04,$00,$12,$00,$13,$03,$11,$00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$04
_L13
	.byt $05,$00,$05,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
_L14
	.byt $04,$00,$04,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$04,$00,$04
_L15
	.byt $05,$00,$05,$00,$01,$03,$11,$00,$01,$03,$11,$00,$01,$03,$03,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$05
_L16
	.byt $04,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$04
_L17
	.byt $05,$00,$05,$00,$13,$03,$03,$03,$03,$03,$03,$03,$45,$03,$03,$12,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
_L18
	.byt $04,$00,$04,$00,$12,$00,$00,$00,$00,$00,$00,$00,$5a,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04
_L19
	.byt $05,$00,$05,$00,$12,$00,$06,$06,$06,$06,$06,$06,$07,$00,$00,$12,$00,$00,$06,$0e,$00,$13,$03,$45,$45,$45,$04,$00,$00,$05
_L20
	.byt $04,$00,$04,$00,$12,$00,$0c,$0b,$0a,$0a,$0a,$0a,$42,$00,$00,$05,$00,$00,$0f,$10,$00,$05,$00,$5f,$5c,$5e,$12,$00,$00,$04
_L21
	.byt $05,$00,$05,$00,$12,$00,$0c,$08,$00,$00,$00,$00,$00,$00,$00,$58,$00,$00,$00,$00,$00,$00,$00,$00,$14,$00,$12,$00,$00,$05
_L22
	.byt $01,$03,$02,$00,$12,$00,$0c,$08,$00,$15,$16,$17,$00,$14,$14,$14,$00,$14,$14,$14,$00,$0c,$07,$00,$14,$00,$05,$00,$00,$04
_L23
	.byt $51,$00,$00,$00,$12,$00,$0c,$08,$59,$18,$1d,$1c,$00,$00,$00,$58,$00,$00,$00,$00,$00,$0c,$08,$00,$00,$00,$00,$00,$00,$05
_L24
	.byt $01,$03,$02,$00,$12,$00,$0c,$08,$00,$19,$1a,$1b,$00,$14,$14,$14,$00,$14,$14,$14,$00,$0c,$08,$00,$00,$00,$00,$00,$00,$04
_L25
	.byt $04,$63,$04,$00,$12,$00,$0c,$08,$00,$00,$00,$00,$00,$00,$00,$58,$00,$00,$00,$00,$00,$0d,$42,$00,$14,$00,$04,$00,$00,$05
_L26
	.byt $05,$00,$05,$00,$12,$00,$06,$06,$06,$06,$06,$06,$07,$00,$00,$04,$00,$00,$06,$0e,$00,$00,$00,$00,$14,$00,$05,$00,$00,$04
_L27
	.byt $04,$00,$04,$00,$12,$00,$0d,$0a,$0a,$0a,$0a,$0a,$42,$00,$00,$12,$00,$00,$0f,$10,$00,$04,$00,$00,$00,$00,$00,$00,$00,$05
_L28
	.byt $05,$00,$05,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$00,$00,$00,$01,$45,$45,$45,$45,$04,$00,$00,$04
_L29
	.byt $04,$00,$04,$00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$12,$00,$00,$04,$00,$00,$00,$5a,$5c,$5b,$5d,$12,$00,$00,$05
_L30
	.byt $05,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$01,$03,$45,$45,$45,$45,$45,$45,$11,$00,$00,$04
_L31
	.byt $04,$00,$04,$00,$13,$03,$04,$00,$13,$03,$04,$00,$13,$03,$03,$12,$00,$00,$00,$00,$5e,$5c,$5e,$5c,$5d,$5e,$00,$00,$00,$05
_L32
	.byt $05,$00,$05,$00,$12,$56,$12,$00,$12,$00,$12,$00,$12,$00,$63,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$04
_L33
	.byt $04,$00,$04,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$11,$00,$00,$05
_L34
	.byt $05,$00,$05,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12
_L35
	.byt $04,$00,$04,$00,$12,$00,$12,$63,$12,$00,$12,$00,$13,$03,$04,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$12
_L36
	.byt $05,$00,$05,$00,$05,$00,$01,$03,$11,$00,$01,$03,$11,$00,$12,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12
_L37
	.byt $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$03,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12
_L38
	.byt $05,$00,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$04,$00,$00,$00,$00,$00,$13,$03,$02,$01,$02,$01,$02,$01,$03,$04,$00,$05
_L39
	.byt $04,$00,$12,$00,$00,$00,$00,$00,$54,$00,$00,$00,$12,$00,$00,$00,$00,$00,$11,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$04
_L40
	.byt $05,$00,$12,$00,$14,$14,$14,$14,$14,$14,$00,$00,$12,$00,$35,$36,$00,$00,$00,$00,$14,$00,$14,$00,$14,$55,$14,$13,$03,$11
_L41
	.byt $04,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$38,$37,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$04
_L42
	.byt $05,$00,$01,$03,$03,$03,$03,$03,$03,$03,$53,$03,$11,$00,$00,$00,$00,$00,$01,$03,$02,$01,$02,$01,$02,$01,$03,$11,$00,$05
_L43
	.byt $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12
_L44
	.byt $01,$03,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$03,$11

ptr_Lignes

	.byt <_L00,>_L00,<_L01,>_L01,<_L02,>_L02,<_L03,>_L03,<_L04,>_L04,<_L05,>_L05,<_L06,>_L06,<_L07,>_L07,<_L08,>_L08,<_L09,>_L09
	.byt <_L10,>_L10,<_L11,>_L11,<_L12,>_L12,<_L13,>_L13,<_L14,>_L14,<_L15,>_L15,<_L16,>_L16,<_L17,>_L17,<_L18,>_L18,<_L19,>_L19
	.byt <_L20,>_L20,<_L21,>_L21,<_L22,>_L22,<_L23,>_L23,<_L24,>_L24,<_L25,>_L25,<_L26,>_L26,<_L27,>_L27,<_L28,>_L28,<_L29,>_L29
	.byt <_L30,>_L30,<_L31,>_L31,<_L32,>_L32,<_L33,>_L33,<_L34,>_L34,<_L35,>_L35,<_L36,>_L36,<_L37,>_L37,<_L38,>_L38,<_L39,>_L39
	.byt <_L40,>_L40,<_L41,>_L41,<_L42,>_L42,<_L43,>_L43,<_L44,>_L44



; --------------------------------------------------------------------
;    Table redéfinition  des tuiles (N)d'ordre des 4 car redefinis
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
		.byt $00,$00,$5d,$5e
_t37
		.byt $5f,$60,$61,$5e
_t38
		.byt $00,$62,$00,$5e
_t39
		.byt $63,$63,$64,$65
_t3a
		.byt $63,$63,$66,$65
_t3b
		.byt $63,$63,$67,$63
_t3c
		.byt $63,$63,$64,$63
_t3d
		.byt $16,$63,$19,$63
_t3e
		.byt $16,$63,$63,$63
_t3f
		.byt $63,$00,$63,$00
_t40
		.byt $63,$00,$00,$00
_t41
		.byt $68,$69,$19,$18
_t42
		.byt $05,$00,$00,$00
_t43
		.byt $0b,$0b,$02,$03
_t44
		.byt $08,$00,$05,$00

_t45
		.byt $01,$01,$6a,$6b	; Portail echoppes ex :47, 4a, 4c, 4e, 50
_t46
		.byt $00,$00,$00,$00	; libre
_t47
		.byt $00,$00,$00,$00	; libre
_t48
		.byt $00,$00,$00,$00	; libre
_t49
		.byt $00,$00,$00,$00	; libre
_t4a
		.byt $00,$00,$00,$00	; libre
_t4b
		.byt $00,$00,$00,$00	; libre
_t4c
		.byt $00,$00,$00,$00	; libre
_t4d
		.byt $00,$00,$00,$00	; libre
_t4e
		.byt $00,$00,$00,$00	; libre
_t4f
		.byt $00,$00,$00,$00	; libre
_t50
		.byt $00,$00,$00,$00	; libre
;à partir de 51 , 18  tuiles spéciales , gébéralement elles apparaissent en  noir comme les chemins
; mais peuvent déclancher un évènement (rencontre, trouvaille ...)	et dans certains cas, on peut passer dessus ou à travers
_t51
		.byt $00,$00,$00,$00	; Entrée ville
_t52
		.byt $01,$01,$3e,$3f	; Portail_1
_t53
		.byt $01,$01,$3e,$3f	; Portail_2
_t54
		.byt $59,$00,$00,$00	; Clef_1
_t55
		.byt $00,$00,$00,$59	; Clef_2
_t56
		.byt $00,$00,$00,$00	; Voleur
_t57
		.byt $00,$00,$00,$00	; Mot de passe
_t58
		.byt $00,$00,$00,$00	; Garde
_t59
		.byt $00,$00,$00,$00	; Legat
_t5a
		.byt $00,$00,$00,$00	; Medicus
_t5b
		.byt $00,$00,$00,$00	; Armurerie
_t5c
		.byt $00,$00,$00,$00	; Herboriste
_t5d
		.byt $00,$00,$00,$00	; Animalerie
_t5e
		.byt $00,$00,$00,$00	; Taberna
_t5f
		.byt $00,$00,$00,$00	; Bazar
_t60
		.byt $00,$00,$00,$00	; libre
_t61
		.byt $00,$00,$00,$00	; libre
_t62
		.byt $00,$00,$00,$00	; libre
_t63
		.byt $7a,$7b,$7c,$7d	; Coffre

_t64
		.byt $7a,$7b,$7c,$7d	; Coffre


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
	.byt <_t60,>_t60,<_t61,>_t61,<_t62,>_t62,<_t63,>_t63,<_t64,>_t64




; -----------------------------------------------------------------------------
;                   proposition de textes pour tuiles spéciales
; -----------------------------------------------------------------------------

t_portail_1
	.byt $99
	.asc "You've got the right key",0
t_portail_2	
	.byt $c6 
	.asc "You can cross.",0
t_portail_3
	.byt $96
	.asc "You don't have the right key.",0	
; ------------------------------------	
t_key_1
	.byt $9d
	.asc "You've found a key.",0 ;(key_1)
t_key_2	
	.byt $c3	
	.asc "Now all you have to do",0
t_key_3	
	.byt $9a	
	.asc "is find the right door.",0
; ------------------------------------	
t_voleur_1
	.byt $9a
	.asc "A pickpocket skillfully;",0
t_voleur_2	
	.byt $c2	
	.asc "steals from Carpophorus.",0
; ------------------------------------	
t_m_de_passe_1
	.byt $96
	.asc "Understanding your situation,",0
t_m_de_passe_2	
	.byt $bc	
	.asc "a patrician says: 'Festina lente'.",0
; ------------------------------------
t_garde_1
	.byt $9a
	.asc "A guard says 'Festina'.",0
t_garde_2
	.byt $bd
	.asc "And is waiting for your answer.",0
t_garde_3
	.byt $9a
	.asc "A guard says 'Festina'.",0
t_garde_4
	.byt $c5
	.asc "You say 'Lente'",0
t_garde_5
	.byt $9a
	.asc "the guard lets you in.",0		
; ------------------------------------
t_legat_1
	.byt $94
	.asc "On orders received from Antoninus,",0
t_legat_2
	.byt $bf	
	.asc "the legate gives you a purse",0
t_legat_3
	.byt $9b	
	.asc "of 20,000 sesterces.",0	
; ------------------------------------	
t_entrance_1
	.byt $99	
	.asc "The entrance to the city,",0
t_entrance_2	
	.byt $c3	
	.asc "do you want to leave?",0
; ------------------------------------	
t_do_you_1
	.byt $c6	
	.asc "do you enter?",0
; ------------------------------------	
t_medicus_1
	.byt $a1	
	.asc "MEDICUS",0
; ------------------------------------
t_armurerie_1
	.byt $9d	
	.asc "FABER ARMORUM",0
; ------------------------------------	
t_herboriste_1
	.byt $a0	
	.asc "HERBARIUS",0
; ------------------------------------	
t_animalerie_1
	.byt $9d	
	.asc "OMNIA ANIMALIA",0
; ------------------------------------	
t_taberna_1
	.byt $a1	
	.asc "TABERNA",0
; ------------------------------------
t_bazar_1
	.byt $a2	
	.asc "bazar",0
; ------------------------------------		
t_coffre_1
	.byt $9d	
	.asc "You find a chest,",0
t_coffre_2
	.byt $c6	
	.asc "do you take it?",0
; ------------------------------------

dta_bandeau	
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$3,$60,$40,$48,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$3,$40,$41,$67,$47,$6E,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$3,$40,$4A,$7F,$43,$7E,$60,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$3,$40,$5A,$7C,$41,$7F,$70,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$3,$40,$4F,$7F,$60,$40,$40,$57,$60,$40,$4F,$68,$40,$40,$7F,$7E,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$7,$40,$5F,$7E,$70,$3,$42,$6F,$78,$40,$7F,$6A,$7,$41,$7F,$7B,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0,$4,$40,$40,$13,$0,$67,$7F,$7D,$41,$7F,$7F,$7C,$41,$7F,$7C,$40,$42,$5F,$10,$4,$0,$4,$0,$4,$0,$4,$0,$4,$0
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$7,$40,$47,$7F,$70,$40,$7F,$7E,$68,$3,$47,$5F,$60,$40,$4F,$7D,$7,$43,$7F,$7A,$60,$41,$7F,$7C,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$3,$40,$4F,$7F,$58,$40,$7F,$7F,$58,$40,$47,$7E,$40,$40,$41,$6D,$40,$43,$7F,$7D,$60,$43,$7F,$76,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$7,$40,$5F,$7F,$6C,$40,$5B,$7E,$70,$3,$57,$70,$40,$40,$41,$7B,$50,$41,$D0,$C4,$7,$47,$7F,$7B,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$3,$40,$5F,$7F,$54,$40,$43,$6A,$0,$3,$5B,$78,$40,$40,$40,$7F,$50,$40,$4E,$68,$40,$47,$7F,$75,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$7,$40,$5F,$7F,$6C,$40,$43,$6A,$0,$3,$5E,$60,$40,$40,$40,$45,$70,$7,$4E,$68,$40,$47,$7F,$7B,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$0,$4,$0,$4,$3,$40,$4D,$75,$58,$40,$43,$6A,$0,$3,$5D,$70,$40,$40,$40,$5D,$70,$40,$4E,$68,$40,$43,$5D,$56,$0,$4,$0,$4,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$7,$40,$43,$7F,$78,$40,$41,$75,$40,$40,$43,$6A,$0,$3,$5F,$60,$40,$40,$40,$4F,$40,$7,$4E,$68,$40,$40,$5D,$50,$40,$43,$7F,$78,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$3,$40,$47,$7F,$6C,$40,$41,$75,$40,$40,$43,$6A,$40,$41,$6F,$40,$40,$40,$40,$47,$54,$40,$4E,$68,$40,$40,$5D,$50,$40,$47,$7F,$6C,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$7,$40,$4F,$7F,$76,$40,$41,$75,$40,$40,$43,$6A,$3,$41,$68,$40,$40,$40,$40,$48,$7C,$7,$4E,$68,$40,$40,$5D,$50,$40,$4F,$7F,$76,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$3,$40,$4F,$7F,$6A,$40,$41,$75,$40,$40,$43,$6A,$40,$41,$7F,$60,$40,$40,$40,$47,$7C,$40,$4E,$68,$40,$40,$5D,$50,$40,$4F,$7F,$6A,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$7,$40,$4F,$7F,$76,$40,$41,$75,$40,$40,$43,$6A,$40,$4,$FF,$40,$40,$40,$3,$47,$78,$7,$4E,$68,$40,$40,$5D,$50,$40,$4F,$7F,$76,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$3,$40,$46,$7A,$6C,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$5E,$40,$40,$40,$40,$41,$78,$40,$4E,$68,$40,$40,$5D,$50,$40,$46,$7A,$6C,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$7,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$3,$43,$53,$40,$40,$40,$40,$46,$56,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$3,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$43,$77,$40,$40,$40,$40,$47,$5E,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$7,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$3,$41,$7E,$40,$40,$40,$40,$43,$7C,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$3,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$7C,$70,$40,$40,$40,$49,$78,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$7,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$3,$43,$4B,$60,$40,$40,$40,$4E,$77,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$3,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$43,$7F,$48,$40,$40,$40,$57,$7E,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$7,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$3,$41,$7F,$70,$40,$40,$40,$5F,$7C,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$40,$3,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$4D,$70,$40,$40,$40,$5F,$60,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$7,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$3,$7F,$68,$40,$40,$40,$7F,$78,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$3,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$43,$7F,$5A,$40,$40,$42,$73,$7E,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$7,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$3,$7B,$7E,$40,$40,$43,$7A,$78,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$3,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$47,$76,$60,$40,$4B,$5F,$40,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$7,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$3,$5F,$66,$60,$40,$4B,$6F,$78,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$0,$4,$0,$4
	.byt $0,$4,$0,$4,$40,$3,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$5F,$7F,$70,$40,$4D,$7B,$70,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$40,$7,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$3,$7D,$70,$40,$5D,$78,$40,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$40,$3,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$40,$43,$7F,$70,$40,$4F,$7E,$40,$40,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$40,$7,$40,$7A,$60,$40,$41,$75,$40,$40,$43,$6A,$40,$3,$47,$73,$60,$40,$4E,$5F,$40,$7,$4E,$68,$40,$40,$5D,$50,$40,$40,$7A,$60,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$40,$40,$3,$7F,$60,$40,$41,$7F,$40,$40,$43,$7E,$40,$40,$40,$4F,$7C,$41,$7F,$60,$40,$40,$4F,$78,$40,$40,$5F,$70,$40,$40,$7F,$60,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$7,$40,$43,$7F,$78,$40,$43,$7F,$70,$40,$47,$7F,$60,$40,$3,$5F,$4F,$7F,$63,$70,$40,$7,$7F,$7C,$40,$41,$7F,$78,$40,$43,$7F,$78,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$3,$40,$4F,$7F,$7E,$40,$4F,$7F,$7C,$40,$5F,$7F,$78,$40,$40,$41,$7C,$41,$7C,$40,$40,$43,$7F,$7F,$40,$47,$7F,$7E,$40,$4F,$7F,$7E,$40,$0,$4,$0
	.byt $0,$4,$0,$4,$40,$40,$C0,$C0,$C0,$C0,$C0,$C0,$FC,$C0,$C0,$87,$78,$40,$3,$47,$40,$40,$47,$40,$7,$43,$7F,$7F,$84,$C7,$E0,$C0,$C0,$C0,$C0,$87,$60,$0,$4,$0
	.byt $0,$4,$0,$7,$40,$44,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$44,$40,$3,$43,$78,$43,$78,$40,$7,$44,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$44,$0,$4,$0
	.byt $0,$4,$0,$7,$40,$47,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7C,$40,$3,$4E,$40,$40,$4E,$40,$7,$47,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7C,$0,$4,$0
	.byt $0,$4,$0,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$3,$48,$40,$40,$42,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$0,$4,$0,$4,$0a

;--------------------------------------------------	
dta_nom_ville

	.byt $1,$43,$60,$58,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$43,$70,$58,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $1,$43,$78,$58,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	.byt $3,$43,$58,$58,$4F,$61,$77,$67,$61,$7E,$4E,$4E,$4F,$47,$47,$47,$60
	.byt $1,$43,$5C,$58,$5F,$71,$7F,$7F,$73,$7F,$4E,$4E,$5F,$67,$47,$4F,$70
	.byt $3,$43,$4C,$58,$58,$79,$79,$79,$72,$47,$4E,$4E,$58,$67,$47,$4C,$50
	.byt $1,$43,$4E,$58,$78,$79,$71,$71,$70,$47,$4E,$4E,$5C,$47,$47,$4E,$40
	.byt $3,$43,$46,$58,$7F,$79,$71,$71,$71,$7F,$4E,$4E,$5F,$47,$47,$4F,$60
	.byt $1,$43,$43,$58,$7F,$79,$71,$71,$73,$7F,$4E,$4E,$47,$77,$47,$43,$78
	.byt $3,$43,$43,$58,$78,$41,$71,$71,$73,$67,$4E,$4E,$41,$77,$47,$40,$78
	.byt $1,$43,$41,$78,$7C,$49,$71,$71,$73,$67,$4E,$5E,$51,$77,$4F,$48,$78
	.byt $3,$43,$41,$78,$5F,$79,$71,$71,$73,$7F,$4F,$7E,$5F,$77,$7F,$4F,$78
	.byt $1,$43,$40,$78,$4F,$71,$71,$71,$71,$7F,$47,$6E,$4F,$43,$77,$47,$60	