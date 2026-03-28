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


