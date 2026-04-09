
;;;; tuiles utilisées pour la carte aléatoire --- tempo

#define 	VIDE		$10    ;;;; herbe
#define 	MUR			$00    ;;;; haute mer
#define 	CARPERSO	$4b    ;;;; perso
#define 	ARBRE		$15    ;;;; arbre
#define 	LAC			$01    ;;;; mer
#define 	MONT1		$11    ;;;; montagne
#define 	MONT2		$12    ;;;; montagne 2
#define 	CADRE		$00    ;;;; haute mer


#define 	XMAX	128 
#define 	YMAX	128 

#define		XSIZE	18
#define		YSIZE	7


#define		MINARBRES 	250
#define		MAXARBRES	300

	.zero

	*= $00
	
XPTR	.dsb 1 ; pos perso x map
YPTR	.dsb 1 ; pos perso y map
ADDRTMP .dsb 2 ; adresse tempo

l .dsb 1 ; ligne courante
c .dsb 1 ; colonne courante

x .dsb 1 ; pos perso x espace ecran
y .dsb 1 ; pos perso y espace ecran

key .dsb 1; touche tapée

;;; STOP : 12 octets dispo en début de page 0

	.text

FLAGFIN
.dsb 1


XPERSO	.dsb 1
YPERSO	.dsb 1
PERSO   .dsb 1

Xtmp	.dsb 1
Ytmp	.dsb 1

SCRPTRX
.dsb 1
SCRPTRY
.dsb 1

NBOBJENPLUS	.dsb 2

STRINGS
AppuieTouche
.byt 1,12
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
MessageLacs
.asc "initialisation Lacs OK"
.byt 0
MessageExplications
.word M1,M2

M1 .asc " Utiliser fleches pour se deplacer",0
M2 .asc "        ESC pour sortir",0


_main
.(
	jsr _hideCursor
    jsr print
    jsr _wait_touche
	jsr initRandom
	jsr initSCRPTR
	jsr initVars
    jsr _impl_car
	jsr _hires_et_atributs
	lda #64
	sta XPERSO
	sta YPERSO
	lda #3
	sta x
	sta y
main_loop
	; jsr calcPosPerso
	lda #3
	sta x
	sta y
	jsr afficheMap
	lda #0
	sta c
	sta l
	jsr draw_loop
; déplacements perso
	jsr depl_perso
	lda XPERSO      ; aff pos perso
	and #$0f
	clc
	adc #48
	sta $bf6a
	lda YPERSO
	and #$0f
	clc
	adc #48
	sta $bf6c
escape
	lda key
	cmp #$a9						; on sort par appui sur escape
	bne main_loop
	jsr _showCursor
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


draw_loop
.(
	jsr _init_scr_hires
	lda c
	cmp x
	bne tuile_def
	lda l
	cmp y
	bne tuile_def
	lda CARPERSO ; perso
	sta _NUM_TUILE
	jmp draw_tuile
tuile_def
	ldy c
	lda (tmp3),y    ;; cellule courante
	sta _NUM_TUILE
draw_tuile
	jsr _cherche_et_aff_tuile
	lda _ADDR_SCR
	clc
	adc #2
	sta _ADDR_SCR
	lda _ADDR_SCR+1
	adc #0
	sta _ADDR_SCR+1
	ldx c
	inx
	stx c
	cpx #XSIZE
	bne draw_loop
	lda #0
	sta c
	ldx l
	inx
	stx l
	cpx #YSIZE
	beq draw_end
	lda _ADDR_SCR
	clc
	adc #$BC
	sta _ADDR_SCR
	lda _ADDR_SCR+1
	adc #1
	sta _ADDR_SCR+1
	jmp draw_loop
draw_end
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
	sta tmp0 ;;; x coin supérieur gauche, espace map
	
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
	sta tmp1 ;;; y coin supérieur gauche, espace map

	ldy tmp1
	lda MapAddressLow,y
	clc
	adc tmp0
	sta tmp3 ;;; adresse dans la map
	lda MapAddressHigh,y
	adc #0
	sta tmp3+1 ;;; partie haute de l'adresse dans la map
	
;;; coin supérieur gauche de l'écran HIRES
	lda #3
	sta _ADDR_SCR
	lda #$a0
	sta _ADDR_SCR+1
	
	rts
.)


calcPosPerso
.(
;;;; calcule pos ecran du personnage
	ldx XPERSO
	cpx #(XSIZE/2)
	bcc suitexinf
	cpx #(XMAX-XSIZE/2)
	bcs suitexsup
	jmp suitexy

suitexinf
	inx
	inx
	txa
	pha
	jmp suitey
                         
suitexsup        ;;;;XaffPerso = 3 +  XPERSO - (XMAX - XSIZE)
	txa
	sec
	sbc #XMAX-XSIZE-2
	pha
	jmp suitey

suitexy
	lda #(XSIZE/2)+2
	pha
	
suitey
	stx x
	ldy YPERSO
	cpy #(YSIZE/2)
	bcc suiteyinf
	cpy #(YMAX-YSIZE/2)
	bcs suiteysup
	jmp suitez

suiteyinf
	jmp commonsuite
                         
suiteysup        
	tya
	sec
	sbc #YMAX-YSIZE
	tay
	jmp commonsuite
	
suitez
	ldy #(YSIZE/2)
	
commonsuite
	sty y
	rts
.)


inKeys
.(
	lda $208
	sta key
	cmp #$BC						; touche flèche droite 
	beq gdroite
	cmp #$AC						; touche flèche GAUCHE		
	beq ggauche
	cmp #$9c						; touche flèche HAUT	
	beq ghaut
	cmp #$b4                        ; touche flèche BAS	
	beq gbas
	cpx #27
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
suite
	rts
.)


depl_perso
.(
check_touche
	lda $208
	sta key
	cmp #$BC						; touche flèche droite 
	bne fleche_gauche
	ldx XPERSO
	inx
	stx XPERSO
	cpx #18
	bne depl_end 
	dex
	stx XPERSO
	rts
fleche_gauche	
	cmp #$AC						; touche flèche GAUCHE		
	bne fleche_haut	
	ldx XPERSO				
	dex
	stx XPERSO
	cpx #$FF
	bne depl_end
	inx
	stx XPERSO
	jmp depl_end
fleche_haut	
	ldx YPERSO
	cmp #$9c						; touche flèche HAUT	
	bne fleche_bas
	dex
	stx YPERSO
	cpx #$FF
	bne depl_end 
	inx
	stx YPERSO
	rts
fleche_bas
	cmp #$b4                        ; touche flèche BAS	
	bne autre_touche
	ldx YPERSO
	inx
	stx YPERSO
	cpx #7
	bne depl_end
	dex
	stx YPERSO
autre_touche
	cmp #$38
	beq check_touche
depl_end
	rts
.)

print
.(
	ldx #$ff
print_loop
	inx
	lda message_touche,x
	sta $bf6a,x
	bne print_loop
	rts
.)

; message à afficher
message_touche .asc "Touche",0


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
	tay
	lda MapAddressLow,y
	clc
	adc Xtmp
	sta ADDRTMP
	lda MapAddressHigh,y
	adc #0
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
	tay
	lda MapAddressLow,y
	clc
	adc Xtmp
	sta ADDRTMP
	lda MapAddressHigh,y
	adc #0
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
	tay
	lda MapAddressLow,y
	clc
	adc Xtmp
	sta ADDRTMP
	lda MapAddressHigh,y
	adc #0
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


	jsr affLacs
	lda #200
	ldy #0
	sta (sp),y
	jsr _delai
	rts

.)

	
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
	
affLacs
	ldy #5
	lda #>MessageLacs
	sta (sp),y
	dey
	lda #<MessageLacs
	sta (sp),y
	jmp affiche
	
affExplications
.(
	lda #0
boucle
	pha
	asl
	tax
	inx
	lda MessageExplications,x
	ldy #5
	sta (sp),y
	dey
	dex
	lda MessageExplications,x
	sta (sp),y
	jsr affiche
	pla
	tax
	inx
	txa
	cpx #9
	bne boucle

	rts
.)

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


_delai
.(
	ldy #0
	lda (sp),y
	tay
delai1
	ldx #255
delai2
	dex
	bne delai2
	dey
	bne delai1
	rts
.)


;
; This is a simple display module
; called by the C part of the program
;



;
; We define the adress of the TEXT screen.
;
#define DISPLAY_ADRESS $BB80


;
; We use a table of bytes to avoid the multiplication 
; by 40. We could have used a multiplication routine
; but introducing table accessing is not a bad thing.
; In order to speed up things, we precompute the real
; adress of each start of line. Each table takes only
; 28 bytes, even if it looks impressive at first glance.
;

; This table contains lower 8 bits of the adress
ScreenAdressLow
	.byt <(DISPLAY_ADRESS+40*0)
	.byt <(DISPLAY_ADRESS+40*1)
	.byt <(DISPLAY_ADRESS+40*2)
	.byt <(DISPLAY_ADRESS+40*3)
	.byt <(DISPLAY_ADRESS+40*4)
	.byt <(DISPLAY_ADRESS+40*5)
	.byt <(DISPLAY_ADRESS+40*6)
	.byt <(DISPLAY_ADRESS+40*7)
	.byt <(DISPLAY_ADRESS+40*8)
	.byt <(DISPLAY_ADRESS+40*9)
	.byt <(DISPLAY_ADRESS+40*10)
	.byt <(DISPLAY_ADRESS+40*11)
	.byt <(DISPLAY_ADRESS+40*12)
	.byt <(DISPLAY_ADRESS+40*13)
	.byt <(DISPLAY_ADRESS+40*14)
	.byt <(DISPLAY_ADRESS+40*15)
	.byt <(DISPLAY_ADRESS+40*16)
	.byt <(DISPLAY_ADRESS+40*17)
	.byt <(DISPLAY_ADRESS+40*18)
	.byt <(DISPLAY_ADRESS+40*19)
	.byt <(DISPLAY_ADRESS+40*20)
	.byt <(DISPLAY_ADRESS+40*21)
	.byt <(DISPLAY_ADRESS+40*22)
	.byt <(DISPLAY_ADRESS+40*23)
	.byt <(DISPLAY_ADRESS+40*24)
	.byt <(DISPLAY_ADRESS+40*25)
	.byt <(DISPLAY_ADRESS+40*26)
	.byt <(DISPLAY_ADRESS+40*27)

; This table contains hight 8 bits of the adress
ScreenAdressHigh
	.byt >(DISPLAY_ADRESS+40*0)
	.byt >(DISPLAY_ADRESS+40*1)
	.byt >(DISPLAY_ADRESS+40*2)
	.byt >(DISPLAY_ADRESS+40*3)
	.byt >(DISPLAY_ADRESS+40*4)
	.byt >(DISPLAY_ADRESS+40*5)
	.byt >(DISPLAY_ADRESS+40*6)
	.byt >(DISPLAY_ADRESS+40*7)
	.byt >(DISPLAY_ADRESS+40*8)
	.byt >(DISPLAY_ADRESS+40*9)
	.byt >(DISPLAY_ADRESS+40*10)
	.byt >(DISPLAY_ADRESS+40*11)
	.byt >(DISPLAY_ADRESS+40*12)
	.byt >(DISPLAY_ADRESS+40*13)
	.byt >(DISPLAY_ADRESS+40*14)
	.byt >(DISPLAY_ADRESS+40*15)
	.byt >(DISPLAY_ADRESS+40*16)
	.byt >(DISPLAY_ADRESS+40*17)
	.byt >(DISPLAY_ADRESS+40*18)
	.byt >(DISPLAY_ADRESS+40*19)
	.byt >(DISPLAY_ADRESS+40*20)
	.byt >(DISPLAY_ADRESS+40*21)
	.byt >(DISPLAY_ADRESS+40*22)
	.byt >(DISPLAY_ADRESS+40*23)
	.byt >(DISPLAY_ADRESS+40*24)
	.byt >(DISPLAY_ADRESS+40*25)
	.byt >(DISPLAY_ADRESS+40*26)
	.byt >(DISPLAY_ADRESS+40*27)




;
; The message and display position will be read from the stack.
; sp+0 => X coordinate
; sp+2 => Y coordinate
; sp+4 => Adress of the message to display
;
_AdvancedPrint
.(
	; Initialise display adress
	; this uses self-modifying code
	; (the $0123 is replaced by display adress)
	
	; The idea is to get the Y position from the stack,
	; and use it as an index in the two adress tables.
	; We also need to add the value of the X position,
	; also taken from the stack to the resulting value.
	
	ldy #2
	lda (sp),y				; Access Y coordinate
	tax
	
	lda ScreenAdressLow,x	; Get the LOW part of the screen adress
	clc						; Clear the carry (because we will do an addition after)
	ldy #0
	adc (sp),y				; Add X coordinate
	sta write+1
	lda ScreenAdressHigh,x	; Get the HIGH part of the screen adress
	adc #0					; Eventually add the carry to complete the 16 bits addition
	sta write+2				



	; Initialise message adress using the stack parameter
	; this uses self-modifying code
	; (the $0123 is replaced by message adress)
	ldy #4
	lda (sp),y
	sta read+1
	iny
	lda (sp),y
	sta read+2


	; Start at the first character
	ldx #0
loop_char

	; Read the character, exit if it's a 0
read
	lda $0123,x
	beq end_loop_char

	; Write the character on screen
write
	sta $0123,x

	; Next character, and loop
	inx
	jmp loop_char  

	; Finished !
end_loop_char
	rts
.)
	
;
; The message and display position will be read from the stack.
; sp+0 => X coordinate
; sp+2 => Y coordinate
; sp+4 => Char to display
; sp+6 => number of times to repeat char
;
_APlot
.(
	; Initialise display adress
	; this uses self-modifying code
	; (the $0123 is replaced by display adress)
	
	; The idea is to get the Y position from the stack,
	; and use it as an index in the two adress tables.
	; We also need to add the value of the X position,
	; also taken from the stack to the resulting value.
	
	ldy #2
	lda (sp),y				; Access Y coordinate
	tax
	
	lda ScreenAdressLow,x	; Get the LOW part of the screen adress
	clc						; Clear the carry (because we will do an addition after)
	ldy #0
	adc (sp),y				; Add X coordinate
	sta writP+1
	lda ScreenAdressHigh,x	; Get the HIGH part of the screen adress
	adc #0					; Eventually add the carry to complete the 16 bits addition
	sta writP+2				

	ldy #6
	lda (sp),y
	tax
	
	; Initialise message adress using the stack parameter
	; this uses self-modifying code
	; (the $0123 is replaced by message adress)
	ldy #4
	lda (sp),y

	
	; Write the character x times on screen
loop1
	dex
writP
	sta $0123,x
	cpx #0
	beq end_loop_plot
	jmp loop1
end_loop_plot
	rts
.)




#define 	XMAX	128 
#define 	YMAX	128 

.dsb 256-(*&255)

TMAP	.dsb XMAX*YMAX

MapAddressLow
	.byt <(TMAP+XMAX*0)
	.byt <(TMAP+XMAX*1)
	.byt <(TMAP+XMAX*2)
	.byt <(TMAP+XMAX*3)
	.byt <(TMAP+XMAX*4)
	.byt <(TMAP+XMAX*5)
	.byt <(TMAP+XMAX*6)
	.byt <(TMAP+XMAX*7)
	.byt <(TMAP+XMAX*8)
	.byt <(TMAP+XMAX*9)
	.byt <(TMAP+XMAX*10)
	.byt <(TMAP+XMAX*11)
	.byt <(TMAP+XMAX*12)
	.byt <(TMAP+XMAX*13)
	.byt <(TMAP+XMAX*14)
	.byt <(TMAP+XMAX*15)
	.byt <(TMAP+XMAX*16)
	.byt <(TMAP+XMAX*17)
	.byt <(TMAP+XMAX*18)
	.byt <(TMAP+XMAX*19)
	.byt <(TMAP+XMAX*20)
	.byt <(TMAP+XMAX*21)
	.byt <(TMAP+XMAX*22)
	.byt <(TMAP+XMAX*23)
	.byt <(TMAP+XMAX*24)
	.byt <(TMAP+XMAX*25)
	.byt <(TMAP+XMAX*26)
	.byt <(TMAP+XMAX*27)
	.byt <(TMAP+XMAX*28)
	.byt <(TMAP+XMAX*29)
	.byt <(TMAP+XMAX*30)
	.byt <(TMAP+XMAX*31)
	.byt <(TMAP+XMAX*32)
	.byt <(TMAP+XMAX*33)
	.byt <(TMAP+XMAX*34)
	.byt <(TMAP+XMAX*35)
	.byt <(TMAP+XMAX*36)
	.byt <(TMAP+XMAX*37)
	.byt <(TMAP+XMAX*38)
	.byt <(TMAP+XMAX*39)
	.byt <(TMAP+XMAX*40)
	.byt <(TMAP+XMAX*41)
	.byt <(TMAP+XMAX*42)
	.byt <(TMAP+XMAX*43)
	.byt <(TMAP+XMAX*44)
	.byt <(TMAP+XMAX*45)
	.byt <(TMAP+XMAX*46)
	.byt <(TMAP+XMAX*47)
	.byt <(TMAP+XMAX*48)
	.byt <(TMAP+XMAX*49)
	.byt <(TMAP+XMAX*50)
	.byt <(TMAP+XMAX*51)
	.byt <(TMAP+XMAX*52)
	.byt <(TMAP+XMAX*53)
	.byt <(TMAP+XMAX*54)
	.byt <(TMAP+XMAX*55)
	.byt <(TMAP+XMAX*56)
	.byt <(TMAP+XMAX*57)
	.byt <(TMAP+XMAX*58)
	.byt <(TMAP+XMAX*59)
	.byt <(TMAP+XMAX*60)
	.byt <(TMAP+XMAX*61)
	.byt <(TMAP+XMAX*62)
	.byt <(TMAP+XMAX*63)
	.byt <(TMAP+XMAX*64)
	.byt <(TMAP+XMAX*65)
	.byt <(TMAP+XMAX*66)
	.byt <(TMAP+XMAX*67)
	.byt <(TMAP+XMAX*68)
	.byt <(TMAP+XMAX*69)
	.byt <(TMAP+XMAX*70)
	.byt <(TMAP+XMAX*71)
	.byt <(TMAP+XMAX*72)
	.byt <(TMAP+XMAX*73)
	.byt <(TMAP+XMAX*74)
	.byt <(TMAP+XMAX*75)
	.byt <(TMAP+XMAX*76)
	.byt <(TMAP+XMAX*77)
	.byt <(TMAP+XMAX*78)
	.byt <(TMAP+XMAX*79)
	.byt <(TMAP+XMAX*80)
	.byt <(TMAP+XMAX*81)
	.byt <(TMAP+XMAX*82)
	.byt <(TMAP+XMAX*83)
	.byt <(TMAP+XMAX*84)
	.byt <(TMAP+XMAX*85)
	.byt <(TMAP+XMAX*86)
	.byt <(TMAP+XMAX*87)
	.byt <(TMAP+XMAX*88)
	.byt <(TMAP+XMAX*89)
	.byt <(TMAP+XMAX*90)
	.byt <(TMAP+XMAX*91)
	.byt <(TMAP+XMAX*92)
	.byt <(TMAP+XMAX*93)
	.byt <(TMAP+XMAX*94)
	.byt <(TMAP+XMAX*95)
	.byt <(TMAP+XMAX*96)
	.byt <(TMAP+XMAX*97)
	.byt <(TMAP+XMAX*98)
	.byt <(TMAP+XMAX*99)
	.byt <(TMAP+XMAX*100)
	.byt <(TMAP+XMAX*101)
	.byt <(TMAP+XMAX*102)
	.byt <(TMAP+XMAX*103)
	.byt <(TMAP+XMAX*104)
	.byt <(TMAP+XMAX*105)
	.byt <(TMAP+XMAX*106)
	.byt <(TMAP+XMAX*107)
	.byt <(TMAP+XMAX*108)
	.byt <(TMAP+XMAX*109)
	.byt <(TMAP+XMAX*110)
	.byt <(TMAP+XMAX*111)
	.byt <(TMAP+XMAX*112)
	.byt <(TMAP+XMAX*113)
	.byt <(TMAP+XMAX*114)
	.byt <(TMAP+XMAX*115)
	.byt <(TMAP+XMAX*116)
	.byt <(TMAP+XMAX*117)
	.byt <(TMAP+XMAX*118)
	.byt <(TMAP+XMAX*119)
	.byt <(TMAP+XMAX*120)
	.byt <(TMAP+XMAX*121)
	.byt <(TMAP+XMAX*122)
	.byt <(TMAP+XMAX*123)
	.byt <(TMAP+XMAX*124)
	.byt <(TMAP+XMAX*125)
	.byt <(TMAP+XMAX*126)
	.byt <(TMAP+XMAX*127)
	.byt <(TMAP+XMAX*128)
	
MapAddressHigh
	.byt >(TMAP+XMAX*0)
	.byt >(TMAP+XMAX*1)
	.byt >(TMAP+XMAX*2)
	.byt >(TMAP+XMAX*3)
	.byt >(TMAP+XMAX*4)
	.byt >(TMAP+XMAX*5)
	.byt >(TMAP+XMAX*6)
	.byt >(TMAP+XMAX*7)
	.byt >(TMAP+XMAX*8)
	.byt >(TMAP+XMAX*9)
	.byt >(TMAP+XMAX*10)
	.byt >(TMAP+XMAX*11)
	.byt >(TMAP+XMAX*12)
	.byt >(TMAP+XMAX*13)
	.byt >(TMAP+XMAX*14)
	.byt >(TMAP+XMAX*15)
	.byt >(TMAP+XMAX*16)
	.byt >(TMAP+XMAX*17)
	.byt >(TMAP+XMAX*18)
	.byt >(TMAP+XMAX*19)
	.byt >(TMAP+XMAX*20)
	.byt >(TMAP+XMAX*21)
	.byt >(TMAP+XMAX*22)
	.byt >(TMAP+XMAX*23)
	.byt >(TMAP+XMAX*24)
	.byt >(TMAP+XMAX*25)
	.byt >(TMAP+XMAX*26)
	.byt >(TMAP+XMAX*27)
	.byt >(TMAP+XMAX*28)
	.byt >(TMAP+XMAX*29)
	.byt >(TMAP+XMAX*30)
	.byt >(TMAP+XMAX*31)
	.byt >(TMAP+XMAX*32)
	.byt >(TMAP+XMAX*33)
	.byt >(TMAP+XMAX*34)
	.byt >(TMAP+XMAX*35)
	.byt >(TMAP+XMAX*36)
	.byt >(TMAP+XMAX*37)
	.byt >(TMAP+XMAX*38)
	.byt >(TMAP+XMAX*39)
	.byt >(TMAP+XMAX*40)
	.byt >(TMAP+XMAX*41)
	.byt >(TMAP+XMAX*42)
	.byt >(TMAP+XMAX*43)
	.byt >(TMAP+XMAX*44)
	.byt >(TMAP+XMAX*45)
	.byt >(TMAP+XMAX*46)
	.byt >(TMAP+XMAX*47)
	.byt >(TMAP+XMAX*48)
	.byt >(TMAP+XMAX*49)
	.byt >(TMAP+XMAX*50)
	.byt >(TMAP+XMAX*51)
	.byt >(TMAP+XMAX*52)
	.byt >(TMAP+XMAX*53)
	.byt >(TMAP+XMAX*54)
	.byt >(TMAP+XMAX*55)
	.byt >(TMAP+XMAX*56)
	.byt >(TMAP+XMAX*57)
	.byt >(TMAP+XMAX*58)
	.byt >(TMAP+XMAX*59)
	.byt >(TMAP+XMAX*60)
	.byt >(TMAP+XMAX*61)
	.byt >(TMAP+XMAX*62)
	.byt >(TMAP+XMAX*63)
	.byt >(TMAP+XMAX*64)
	.byt >(TMAP+XMAX*65)
	.byt >(TMAP+XMAX*66)
	.byt >(TMAP+XMAX*67)
	.byt >(TMAP+XMAX*68)
	.byt >(TMAP+XMAX*69)
	.byt >(TMAP+XMAX*70)
	.byt >(TMAP+XMAX*71)
	.byt >(TMAP+XMAX*72)
	.byt >(TMAP+XMAX*73)
	.byt >(TMAP+XMAX*74)
	.byt >(TMAP+XMAX*75)
	.byt >(TMAP+XMAX*76)
	.byt >(TMAP+XMAX*77)
	.byt >(TMAP+XMAX*78)
	.byt >(TMAP+XMAX*79)
	.byt >(TMAP+XMAX*80)
	.byt >(TMAP+XMAX*81)
	.byt >(TMAP+XMAX*82)
	.byt >(TMAP+XMAX*83)
	.byt >(TMAP+XMAX*84)
	.byt >(TMAP+XMAX*85)
	.byt >(TMAP+XMAX*86)
	.byt >(TMAP+XMAX*87)
	.byt >(TMAP+XMAX*88)
	.byt >(TMAP+XMAX*89)
	.byt >(TMAP+XMAX*90)
	.byt >(TMAP+XMAX*91)
	.byt >(TMAP+XMAX*92)
	.byt >(TMAP+XMAX*93)
	.byt >(TMAP+XMAX*94)
	.byt >(TMAP+XMAX*95)
	.byt >(TMAP+XMAX*96)
	.byt >(TMAP+XMAX*97)
	.byt >(TMAP+XMAX*98)
	.byt >(TMAP+XMAX*99)
	.byt >(TMAP+XMAX*100)
	.byt >(TMAP+XMAX*101)
	.byt >(TMAP+XMAX*102)
	.byt >(TMAP+XMAX*103)
	.byt >(TMAP+XMAX*104)
	.byt >(TMAP+XMAX*105)
	.byt >(TMAP+XMAX*106)
	.byt >(TMAP+XMAX*107)
	.byt >(TMAP+XMAX*108)
	.byt >(TMAP+XMAX*109)
	.byt >(TMAP+XMAX*110)
	.byt >(TMAP+XMAX*111)
	.byt >(TMAP+XMAX*112)
	.byt >(TMAP+XMAX*113)
	.byt >(TMAP+XMAX*114)
	.byt >(TMAP+XMAX*115)
	.byt >(TMAP+XMAX*116)
	.byt >(TMAP+XMAX*117)
	.byt >(TMAP+XMAX*118)
	.byt >(TMAP+XMAX*119)
	.byt >(TMAP+XMAX*120)
	.byt >(TMAP+XMAX*121)
	.byt >(TMAP+XMAX*122)
	.byt >(TMAP+XMAX*123)
	.byt >(TMAP+XMAX*124)
	.byt >(TMAP+XMAX*125)
	.byt >(TMAP+XMAX*126)
	.byt >(TMAP+XMAX*127)
	.byt >(TMAP+XMAX*128)
