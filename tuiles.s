c .dsb 1

touche .asc "Touche",0

_main
	lda #$0
	sta _NUM_TUILE
	lda #$03
	sta _ADDR_SCR
	lda #$A0
	sta _ADDR_SCR+1
    jsr print
    jsr _wait_touche
    jsr _impl_car
	jsr _hires_et_atributs
	lda #18
	sta c
main_loop
	jsr _init_scr_hires
	jsr _cherche_et_aff_tuile
	lda _ADDR_SCR
	clc
	adc #2
	sta _ADDR_SCR
	lda _ADDR_SCR+1
	adc #0
	sta _ADDR_SCR+1
	dec c
	bne main_suite
	lda #18
	sta c
	lda _ADDR_SCR
	clc
	adc #$BC
	sta _ADDR_SCR
	lda _ADDR_SCR+1
	adc #1
	sta _ADDR_SCR+1
	jsr print
	jsr _wait_touche
main_suite
	ldx _NUM_TUILE
	inx
	stx _NUM_TUILE
	txa
	cmp #$4E
	bne main_loop
	rts

print
	ldx #$ff
print_loop
	inx
	lda touche,x
	sta $bf6a,x
	bne print_loop
	rts


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

