;********************************************************************************************
;****  liste des variables utilisées pour lecture hexa valeur bourse d'un des 6 persos   ****
;****         pour la transformation en décimal et l' affichage à l'écran HIRES          ****
;********************************************************************************************

; $25 contient partie basse adresse ecran hire pour octet caractère puis evolue ($24 au debut puis 8 fois +#$28 pour afficher car complet)
; $26 contient partie haute adresse ecran hire pour octet caractère puis evolue ($24 au debut puis 8 fois +#$28 pour afficher car complet)

; $27 utilisé pour partie basse adresse masque Yeme ligne carractère
; $28 utilisé pour partie haute adresse masque Yeme ligne carractère
; $29 compteur d'octet pour aff_carr (affiche un carractère)

; $2a longueur du nom héro en cours (peut varier dans une boucle de 1 à 6) sert aussi d'index

; $2c index début data 1er perso (#$00)
; $2d index début data 2ème perso (= $2c + $2a +(#$24 ou #$1c en fonction siperso peut avoir 8 sorts ou pas))
; $2e index début data 3ème perso (= $2d + $2a +(#$24 ou #$1c en fonction siperso peut avoir 8 sorts ou pas))
; $2f index début data 4ème perso (= $2e + $2a +(#$24 ou #$1c en fonction siperso peut avoir 8 sorts ou pas))
; $30 index début data 5ème perso (= $2f + $2a +(#$24 ou #$1c en fonction siperso peut avoir 8 sorts ou pas))
; $31 index début data 6ème perso (= $2f + $2a +(#$24 ou #$1c en fonction siperso peut avoir 8 sorts ou pas))

; $32 dizaines millers et centaines milliers pour calcul arithmétique BCD
; $33 millers et centaines pour calcul arithmétique BCD
; $34 unités et dizaines pour calcul arithmétique BCD
; $35 LL valeur Hexa pour calcul aritmétique BCD
; $36 hh valeur Hexa pour calcul aritmétique BCD


;*********************************************************************
;**** Routine, va chercher, dans les DATA persos , la valeur HEXA ****
;****        de la bourse du perso et l'écrit en $35-$36          ****
;****           puis transforme le NB Hexa en Décimal	          ****
;****  puis initialise les adresses écran des différents digits   ****
;****           et enfin affiche la valeur à l'écran              ****
;*********************************************************************
; en entrée : x contient le rang du perso dans la liste des DATA

aff_bourse_perso
	txa
	pha							; sauvegarde provisoire rang perso
	lda $2c,x					; nb d'octets à "sauter" pour atteindre data perso à partir data 1er perso (Kaeso)
	tax							; dans x pour index
	lda dta_kaeso,x				; longeur du nom du perso visé
	sta $2a						; stockée en $2a
	txa							; récupère dans A le Nb d'octets à sauter
	clc
	adc $2a						; auquel on ajoute le NB d'octets du noms du perso visé
	tax							; pour servir de nouvel index vers première valeur perso visé, soit partie basse valeur bourse
	inx
	lda dta_kaeso,x
	sta $35						; valeur stockée en $35
	inx							; pour viser partie haute
	lda dta_kaeso,x
	sta $36						; stockée en $36
	jsr hex_2_asc				; transforme valeur Hexa en décimal
	jsr init_adr_bourse_p		; Initialise adresses écran pour affichage
	jsr bourse_g				; affichage
	pla
	tax
	rts


;****************************************************************
;****       Transforme en nb Hexa stocké sur 2 octets        ****
;****                  en nombre décimal                     ****	
;****************************************************************
; En entrée : $35 / $36 contiennent la valeur bourse en hexa
; en sortie: $32/$33/$34 contiennent la valeur bourse en décimal
; 			 soit 5 demi-octets représentant unités,dizaines,  
; 			 centaines, milliers, dizaines de milliers,
;		
; Nota : cette routine n'est pas de moi mais "trouvée" sur le Net
hex_2_asc
		sed         ; Switch to decimal mode
		lda #$00    ; Ensure the result is clear
		sta$32
		sta $33
		sta $34
		ldx #$10	; 16 The number of source bits
        
nextBIT
		asl $35		; Shift out one bit (b7 ==> C  0 ==> b0)
		rol $36		; C ==> b0 puis  b7 ==> C 	
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
	
;********************************************************************************
;*****   initialise adresses octets écran HIRES où écrire la valeur decimale ****	
;********************************************************************************

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
;-----------------------------------------
adr_scr_UDCM_gv
	.asc $ad,$b2,$ac,$b2,$ab,$b2,$aa,$b2,$a9,$b2,$a8,$b2
	

;********************************************************
;*****      Ecrit valeur bourse sur écran HIRES      ****	
;********************************************************

; en entrée les lda $1111 sont déjà remplacés par l'adresse de la première donnée (adresse écran) de la liste d'adresses
; en sortie 
bourse_g
		ldx #$00
adr_UDCM_0	
		lda $1111,x					; partie basse adresse écran pour affichage unités
		sta $25						; partie basse adresses écran Hires pour routine affichage
		inx
adr_UDCM_1	
		lda $1111,x					; partie haute adresse écran pour affichage unités
		sta $26						; partie Haute adresse écran Hires pour routine affichage
		lda #$30					; Affiche un zéro (code ascii #$30) pour unités car la valeur stockée est la valeur bourse /10 donc unités toujours nulles
		jsr Aff_Car
		inx							; pour pointer sur adresse dizaines
lp_UDCM
		lda $1111,x					; partie basse adresse écran pour affichage dizaines (milliers)
		sta $25
		inx							; adresse suivante
adr_UDCM_2	
		lda $1111,x					; partie haute adresse écran pour affichage dizaines (milliers)
		sta $26	
byte_1
		lda $32						; prend octet contenant unités et dizaines (boucle 0) puis centaines et milliers (boucle 1) puis dizaines milliers (boucle 2)
		and #$0f					; masque dizaines ( milliers pour boucle 1) centaiens de milliers (boucle 2)
		ora #$30					; transforme en code ASCII
		jsr Aff_Car					; et affiche  unités BCD (mais en fait dizaines à l'écran) centaines pour boucle 1 (mais en fait milliers) dizaines de milliers (mais en fait centaines de milliers) sur écran HIRES
		inx							; index vers octets adresse suivante
		cpx #$0c					; dernière adresse				
		beq out_bourse				; si oui, affichage termniné
adr_UDCM_3
		lda $1111,x					; partie basse adresse écran pour affichage centaines (dizaines de milliers)
		sta $25
		inx
adr_UDCM_4
		lda $1111,x					; partie haute adresse écran pour affichage centaines (dizaines de miliers)
		sta $26
byte_2
		lda $32						; prend octet contenant unités et dizaines	/ centaines et milliers (boucle 1) dizaines de milliers et cantaines de milliers (boucle 2)					
		lsr							; fait passer le quartet dizaines ( Milliers/ centaines de milliers) sur les 4 premiers bits
		lsr
		lsr
		lsr
		ora #$30					; transforme en ASCII
		jsr Aff_Car					; et affiche sur HIRES
		inx							; Index vers adresse écran suivante
		inc byte_1+1				; pour lire octet contenant les quartets centaines et milliers (1ere boucle) puis dizaines de milliers et centaines de millierzs (2eme boucle)
		inc byte_2+1				; idem
		bne lp_UDCM					; Toujours vrai (évite un JMP sur 3 octets) on sort de la boucle lorsque l'index sur les adresses atteint 12 (#$0c)
out_bourse	
		rts
;-------------------------------------------
adr_scr_UDCM_bh
	.asc $a3,$ac,$a2,$ac,$a1,$ac,$a0,$ac,$9f,$ac,$9e,$ac


;------------------------------------------
;Sous Routine Affiche un caractère en HIRES
;Entrée:
;	A contient le code ascii du caractère
;	$25-$26 contient adresse octet écran
;	$2E3 n° jeu de caractères
;-------------------------------------------
Aff_Car	
			JSR Adr_car_tabl	;Sous routine cherche adresse carractère dans table	
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
			CPY #$08			;est-ce le 8éme ?
			BNE  loop1 			;sinon on continue
			RTS					;si oui, caractère affiché
			
;--------------------------------------------------------------------
;---  Sous routine cherche adresse carractère dans table	     ----
;---  copie et adaptation routine rom ATMOS à partir de  $F17E   ---- 
;---   (Adr car ds tab placé en $27-$28 au lieu de $0C-$0D)      ----
;--------------------------------------------------------------------	
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
;-----------------------------------------------------------------------------				
; sous routine calcule adresse et masque du point au dessous du point courant
;-----------------------------------------------------------------------------
adc_28	
				clc
				lda $25
				adc #$28
				sta $25
				bcc no_ret
				inc $26
no_ret
				rts				