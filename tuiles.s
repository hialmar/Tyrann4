c .dsb 1
l .dsb 1 ; ligne courante
x .dsb 1 ; pos perso x
y .dsb 1 ; pos perso y
key .dsb 1; touche tapée

_main
	jsr hideCursor
	lda #$3
	sta x
	sta y
	lda #$0
	sta _NUM_TUILE
    jsr print
    jsr _wait_touche
    jsr _impl_car
	jsr _hires_et_atributs
main_loop
	lda #0
	sta c
	sta l
	lda #$03
	sta _ADDR_SCR
	lda #$A0
	sta _ADDR_SCR+1
	jsr draw_loop
; déplacements perso
	jsr depl_perso
	lda x
	clc
	adc #48
	sta $bf6a
	lda y
	clc
	adc #48
	sta $bf6c
escape
	lda key
	cmp #$a9						; on sort par appui sur escape
	bne main_loop
	jsr showCursor
	rts

hideCursor
.(
	lda #10
	sta $26A
	lda #4
	sta $24E
	lda #1
	sta $24F
	rts
.)

showCursor
.(
	lda #3
	sta $26A
	lda #32
	sta $24E
	lda #4
	sta $24F
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
	lda #$4b ; perso
	sta _NUM_TUILE
	jmp draw_tuile
tuile_def
	lda #$10 ; herbe
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
	cpx #18
	bne draw_loop
	lda #0
	sta c
	ldx l
	inx
	stx l
	cpx #7
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

depl_perso
.(
	jsr _wait_touche
check_touche
	lda $208
	sta key
	cmp #$BC						; touche flèche droite 
	bne fleche_gauche
	ldx x
	inx
	stx x
	cpx #18
	bne depl_end 
	dex
	stx x
	rts
fleche_gauche	
	cmp #$AC						; touche flèche GAUCHE		
	bne fleche_haut	
	ldx x				
	dex
	stx x
	cpx #$FF
	bne depl_end
	inx
	stx x
	jmp depl_end
fleche_haut	
	ldx y
	cmp #$9c						; touche flèche HAUT	
	bne fleche_bas
	dex
	stx y
	cpx #$FF
	bne depl_end 
	inx
	stx y
	rts
fleche_bas
	cmp #$b4                        ; touche flèche BAS	
	bne autre_touche
	ldx y
	inx
	stx y
	cpx #7
	bne depl_end
	dex
	stx y
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
;
; We define the adress of the HIRES screen.
;
#define DISPLAY_ADRESS $A000


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

; This table contains higher 8 bits of the adress
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

