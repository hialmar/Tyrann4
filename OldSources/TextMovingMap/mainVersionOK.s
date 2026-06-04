
#define 	VIDE	0  ;;;; ' '  ==>       32
#define 	MUR		1  ;;;; '#'  ==>       35
#define 	PERSO	2  ;;;; '*'  ==>       42
#define 	ARBRE	3  ;;;; '^'  ==>       94
#define 	LAC		4  ;;;; '%'  ==>       37
#define 	MONT1	5  ;;;; '/'  ==>       47
#define 	MONT2	6  ;;;; '\'  ==>       92
#define 	CADRE	7  ;;;; ' '  ==>       126


#define 	XMAX	128 
#define 	YMAX	128 

#define		XSIZE	32
#define		YSIZE	16


#define		MINARBRES 	250
#define		MAXARBRES	300

	.zero

	*= $30
	
XPTR	.dsb 1
YPTR	.dsb 1
ADDRMAP	.dsb 2
ADDRTMP .dsb 2

PGSCRA	.dsb 2
PGSCRB	.dsb 2

compteLignes .dsb 1


	.text

FLAGFIN
.dsb 1

TABCAR
.asc	" #*^%/\" ;;; caracteres utilises dans la MAP."
.byt    126

XPERSO	.dsb 1
YPERSO	.dsb 1

Xtmp	.dsb 1
Ytmp	.dsb 1

SCRPTRX
.dsb 1
SCRPTRY
.dsb 1

NBOBJENPLUS	.dsb 2

STRINGS
AppuieTouche
.asc "Appuyez sur une touche"
.byt 0
MessageVide
.asc "initialisation du vide OK"
.byt 0
MessageMur
.asc "initialisation du Mur OK"
.byt 0
MessageArbre
.asc "initialisation Arbres OK"
.byt 0
MessageMontagnes
.asc "initialisation Montagnes OK"
.byt 0


_main
.(
	jsr _cls
	jsr hideCursor
	jsr initSCRPTR
	jsr initRandom
	jsr initVars
	jsr _cls
	ldy #0
	lda #2
	sta (sp),y
	jsr _paper
	lda #4
	ldy #0
	sta (sp),y
	jsr _ink
	
	jsr afficheCadre
	
	lda #64
	sta XPERSO
	sta YPERSO
	lda #1
	sta FLAGFIN
	
boucleJeu
	jsr afficheMap
	
	jsr inKeys
	lda FLAGFIN
	bne boucleJeu
	
	
	
	lda #19
	sta $268
	jsr showCursor
	rts
.)

hideCursor
.(
	lda $26A
	and #$FE
	sta $26A
	lda #4
	sta $24E
	lda #1
	sta $24F
	rts
.)

showCursor
.(
	lda $26A
	ora #1
	sta $26A
	lda #32
	sta $24E
	lda #4
	sta $24F
	rts
.)

initSCRPTR
.(
	lda #2
	sta SCRPTRX
	lda #1
	sta SCRPTRY
	rts
.)

initRandom
.(
        lda $0276
        sta $FC
        sta $FE
        lda $0277
        sta $FB
        sta $FD
        lda #$80
        sta $FA
        rts
.)


affCarte
.(

	rts
.)

affExplications
	ldy #5
	lda #>AppuieTouche
	sta (sp),y
	dey
	lda #<AppuieTouche
	sta (sp),y
	jmp affiche
	
affVide
	ldy #5
	lda #>MessageVide
	sta (sp),y
	dey
	lda #<MessageVide
	sta (sp),y
	jmp affiche
	
affMur
	ldy #5
	lda #>MessageMur
	sta (sp),y
	dey
	lda #<MessageMur
	sta (sp),y
	jmp affiche
	
affArbre
	ldy #5
	lda #>MessageArbre
	sta (sp),y
	dey
	lda #<MessageArbre
	sta (sp),y
	jmp affiche
	
affMontagnes
	ldy #5
	lda #>MessageMontagnes
	sta (sp),y
	dey
	lda #<MessageMontagnes
	sta (sp),y
	jmp affiche
	
affiche
.(
	dey
	lda #0
	sta (sp),y
	dey
	lda SCRPTRY
	sta (sp),y
	dey
	lda #0
	sta (sp),y
	dey
	lda SCRPTRX
	sta (sp),y
	
	jsr _AdvancedPrint
	inc SCRPTRY
	lda SCRPTRY
	cmp #28
	bne fin
	lda #1
	sta SCRPTRY
fin	
	rts
.)

initVars
.(
	lda #<TMAP
	sta locaddrMAP+1
	lda #>TMAP
	sta locaddrMAP+2
	lda #MUR

;;;;;   VIDE + MURS HAUT ET BAS   ;;;;;
	ldy #YMAX
boucle1
	ldx #XMAX
boucle2
locaddrMAP
	sta $1234
	clc
	inc locaddrMAP+1
	bne suite
	inc locaddrMAP+2
suite
	dex
	bne boucle2
	lda #VIDE
	dey
	beq suite2
	cpy #1
	bne boucle1
	lda #MUR
	jmp boucle1
	
	
;;;;;   M U R S   C O T E S   ;;;;;

suite2
	jsr affVide
	lda #<(TMAP+XMAX)
	sta ADDRTMP
	lda #>(TMAP+XMAX)
	sta ADDRTMP+1
	
	ldy #0
	lda #MUR
	ldx #(YMAX-2)
boucle3	
	sta (ADDRTMP),y
	ldy #XMAX
	dey
	sta (ADDRTMP),y
	ldy #0
	lda ADDRTMP
	clc
	adc #XMAX
	sta ADDRTMP
	lda ADDRTMP+1
	adc #0
	sta ADDRTMP+1
	lda #MUR
	dex
	bne boucle3

	jsr affMur
	
;;;;;   A R B R E S   ;;;;;
dessineArbres
.(
	jsr _random
	and #$7F       ;;;; 0 à 64 arbres en plus
	sta NBOBJENPLUS
	ldy #2
	tya
	pha
	ldx NBOBJENPLUS
boucle4
	txa
	pha
	lda #0
	sta op1+1
	sta op2+1
repeatrandom
	jsr _random   ;;; Astuce : un seul appel pour X et Y. A ==> coord X ; Y ==> coord Y
	and #$7F      ;;; en dur : on limite à 127... à revoir si XMAX > 128
	cmp #$7E
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite5
	sta Xtmp
	txa           ;;; on récupère le deuxième entier de random
	and #$7F      ;;; en dur : on limite à 127... à revoir si YMAX > 128
	cmp #$7E
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite7
	sta op1
	lda #XMAX
	sta op2
	jsr mul16u
	lda Xtmp
	clc
	adc tmp
	sta ADDRTMP
	lda #0
	adc tmp+1
	sta ADDRTMP+1
	clc
	lda #<TMAP
	adc ADDRTMP
	sta ADDRTMP
	lda #>TMAP
	adc ADDRTMP+1
	sta ADDRTMP+1
	lda #ARBRE
	ldy #0
	sta (ADDRTMP),y
	pla
	tax
	dex
	bne boucle4
	ldx #0        ;;;;; +256 arbres
	pla
	tay
	dey
	tya
	pha
	bne boucle4
	pla
.)

	
	jsr affArbre
	
;;;;;   M O N T A G N E S  ;;;;;

dessineMontagnes
.(
	jsr _random
	and #$3F       ;;;; 0 à 63 montagnes
	ora #$40       ;;;; on ajoute 64
	
	sta NBOBJENPLUS
	ldx NBOBJENPLUS
boucle4
	txa
	pha
	lda #0
	sta op1+1
	sta op2+1
repeatrandom
	jsr _random   ;;; Astuce : un seul appel pour X et Y. A ==> coord X ; Y ==> coord Y
	and #$7F      ;;; en dur : on limite à 127... à revoir si XMAX > 128
	cmp #$7E
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite5
	sta Xtmp
	txa           ;;; on récupère le deuxième entier de random
	and #$7F      ;;; en dur : on limite à 127... à revoir si YMAX > 128
	cmp #$7D
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite7
	sta op1
	lda #XMAX
	sta op2
	jsr mul16u
	lda Xtmp
	clc
	adc tmp
	sta ADDRTMP
	lda #0
	adc tmp+1
	sta ADDRTMP+1
	clc
	lda #<TMAP
	adc ADDRTMP
	sta ADDRTMP
	lda #>TMAP
	adc ADDRTMP+1
	sta ADDRTMP+1
	lda #MONT1
	ldy #0
	sta (ADDRTMP),y
	lda #MONT2
	iny
	sta (ADDRTMP),y
	pla
	tax
	dex
	bne boucle4
.)

	
	jsr affMontagnes

;;;;;   L A C S  ;;;;;

dessineLacs
.(
	jsr _random
	and #$1F       ;;;; 0 à 31 lacs
	ora #$20       ;;;; on ajoute 32 ==> 32 à 63 lacs
	
	sta NBOBJENPLUS
	ldx NBOBJENPLUS
boucle4
	txa
	pha
	lda #0
	sta op1+1
	sta op2+1
repeatrandom
	jsr _random   ;;; Astuce : un seul appel pour X et Y. A ==> coord X ; Y ==> coord Y
	and #$7F      ;;; en dur : on limite à 127... à revoir si XMAX > 128
	cmp #$7B
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite5
	sta Xtmp
	txa           ;;; on récupère le deuxième entier de random
	and #$7F      ;;; en dur : on limite à 127... à revoir si YMAX > 128
	cmp #$7C
	bcs repeatrandom
	cmp #$1
	bcc repeatrandom
suite7
	sta op1
	lda #XMAX
	sta op2
	jsr mul16u
	lda Xtmp
	clc
	adc tmp
	sta ADDRTMP
	lda #0
	adc tmp+1
	sta ADDRTMP+1
	clc
	lda #<TMAP
	adc ADDRTMP
	sta ADDRTMP
	lda #>TMAP
	adc ADDRTMP+1
	sta ADDRTMP+1
	lda #LAC
	ldx #3
boucleX
	ldy #4
boucleY	
	dey
	sta (ADDRTMP),y
	bne boucleY
	
	lda ADDRTMP
	clc
	adc #XMAX
	sta ADDRTMP
	lda ADDRTMP+1
	adc#0
	sta ADDRTMP+1
	lda #LAC
	dex
	bne boucleX
	
	pla
	tax
	dex
	bne boucle4
.)


	
	rts

.)

afficheCadre
.(
	ldy #1
	lda ScreenAdressLow,y
	clc
	adc #2
	sta locpgscra+1
	lda ScreenAdressHigh,y
	adc #0
	sta locpgscra+2
	
	ldy #YSIZE+2
	lda ScreenAdressLow,y
	clc
	adc #2
	sta locpgscrb+1
	lda ScreenAdressHigh,y
	adc #0
	sta locpgscrb+2

	ldx #XSIZE+2
	
boucle1
	lda TABCAR+CADRE
boucle3	
locpgscra
	sta $1234,x
locpgscrb
	sta $1234,x
	dex
	bne boucle3
	

suite2
	ldy #2
	
boucle4
	lda ScreenAdressLow,y
	sta locpgscrc+1
	sta locpgscrd+1
	lda ScreenAdressHigh,y
	sta locpgscrc+2
	sta locpgscrd+2
	lda TABCAR+CADRE
	ldx #3
locpgscrc
	sta $1234,x
	ldx #XSIZE+4
locpgscrd
	sta $1234,x
	iny
	cpy #YSIZE+3
bne boucle4
	
	rts
.)

afficheMap
.(
;;; détermination de la fenetre de la MAP a afficher

	lda XPERSO
	cmp #(XMAX-XSIZE/2)
	bcc suite0
	lda #(XMAX-XSIZE/2)
suite0
	sec
	sbc #XSIZE/2
	bcs suite1
	lda #0
suite1
	sta tmp0
	
	lda YPERSO
	cmp #(YMAX-YSIZE/2)
	bcc suite21
	lda #(YMAX-YSIZE/2)
suite21
	sec
	sbc #YSIZE/2
	bcs suite2
	lda #0
suite2
	sta tmp1

	ldy tmp1
	lda MapAddressLow,y
	clc
	adc tmp0
	sta tmp3
	lda MapAddressHigh,y
	adc #0
	sta tmp3+1
	
;;; détermination du coin supérieur gauche de lécran
	ldy #2
	lda ScreenAdressLow,y
	clc
	adc #4
	sta tmp2
	lda ScreenAdressHigh,y
	adc #0
	sta tmp2+1

	sei
	
;;		boucler sur le nombre de lignes  de 0 à YSIZE
	
	lda #0
	sta compteLignes

pgetiq_boucleY
	
;;		boucler sur le nombre de colonnes  de 0 à XSIZE

	ldy #0

pgetiq_boucleX
	
	lda (tmp3),y
	tax
	lda TABCAR,x
	sta (tmp2),y		
	
	iny						;;	Ajouter 1 à Adresse Ecran
	cpy #XSIZE
	bne pgetiq_boucleX		;;	fin boucle
	
	inc compteLignes
	lda compteLignes
	cmp #YSIZE
	beq pgetiq_finboucleY
	
;;		Ajouter 40  à Adresse Ecran
	lda #40
	clc
	adc tmp2
	sta tmp2
	lda tmp2+1
	adc #0
	sta tmp2+1
	
;;  incrémenter aussi les compteurs de tmp
	lda #XMAX
	clc
	adc tmp3
	sta tmp3
	lda tmp3+1
	adc #0
	sta tmp3+1

	jmp pgetiq_boucleY
	
;;	fin boucle
	
pgetiq_finboucleY
	cli
;;;; affichage du personnage
	ldx XPERSO
	cpx #(XSIZE/2)
	bcc suitexinf
	cpx #(XMAX-XSIZE/2)
	bcs suitexsup
	jmp suitexy

suitexinf
	inx
	inx
	inx
	inx
	txa
	pha
	jmp suitey
                         
suitexsup        ;;;;XaffPerso = 3 +  XPERSO - (XMAX - XSIZE)
	txa
	sec
	sbc #XMAX-XSIZE-4
	pha
	jmp suitey

suitexy
	lda #(XSIZE/2)+4
	pha
	
suitey
	ldy YPERSO
	cpy #(YSIZE/2)
	bcc suiteyinf
	cpy #(YMAX-YSIZE/2)
	bcs suiteysup
	jmp suitez

suiteyinf
	iny
	iny
	jmp commonsuite
                         
suiteysup        
	tya
	sec
	sbc #YMAX-YSIZE-2
	tay
	jmp commonsuite
	
suitez
	ldy #(YSIZE/2)+2
	
commonsuite
	lda ScreenAdressLow,y
	sta tmp2
	lda ScreenAdressHigh,y
	sta tmp2+1
	pla
	tay
	lda TABCAR+PERSO
	sta (tmp2),y
	
	rts
	
.)



inKeys
.(
	jsr _get
	txa
	cmp #73
	beq ghaut
	cmp #74
	beq ggauche
	cmp #75
	beq gbas
	cmp #76
	beq gdroite
	cmp #27
	beq gfin
	jmp inKeys

ggauche
	ldx YPERSO
	ldy XPERSO
	dey
	jmp testcase
	
gdroite
	ldx YPERSO
	ldy XPERSO
	iny
	jmp testcase
	
ghaut
	ldx YPERSO
	ldy XPERSO
	dex
	jmp testcase
	
gbas
	ldx YPERSO
	ldy XPERSO
	inx
	jmp testcase

suite
	rts
	
gfin
	lda #0
	sta FLAGFIN
	rts
	
testcase
	lda MapAddressLow,x
	sta tmp1
	lda MapAddressHigh,x
	sta tmp1+1
	lda (tmp1),y
	cmp #0
	bne suite
	sty XPERSO
	stx YPERSO
	rts
.)