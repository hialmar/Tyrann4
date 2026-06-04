
_testbit
.(

	ldy #2
	lda (sp),y
	tax
	inx
	dey
	dey
	lda (sp),y
boucle
	lsr
	dex
	bne boucle
	bcc fin
	inx
fin
	lda #0
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




ranPGTMP .byt $00
_rand01
.(
	ldx #$ff
	jsr $E355
	lda $D1
	and #$01
	tax
	lda #$00
	rts
.)

_rand1248
.(
	ldx #$ff
	jsr $E355
	lda $D1
	and #$0F
	tax
	lda #$00
	rts
.)

_rand124
.(
	ldx #$ff
	jsr $E355
	lda $D1
	and #$07
	tax
	lda #$00
	rts
.)