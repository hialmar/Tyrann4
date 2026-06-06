#define PatCar 37 

	.zero

	*= $F3
	
PatLacPtr
.dsb 2
	.text
	

_testmem
.(
	ldy #0
	lda (sp),y
	sta tmp0
	iny
	lda (sp),y
	sta tmp0+1
	
	iny
	lda (sp),y
	tay
	dey
boucle1
	lda (tmp0),y
	beq zerotrouve
	dey
	bne boucle1
	lda #0
	ldx #0
	rts
	
zerotrouve
	lda #1
	ldx #1
	rts

.)

.dsb 256-(*&255)
saverti
.dsb 3
PATTERNS

PatLac
.byt 7,56,0,0,7,56,0,0,7,56,0,0
Timer
.dsb 1

_animate
.(
	pha
	tya
	pha
	php

	inc Timer
	lda Timer
	cmp #$30
	bne fin
	lda #0
	sta Timer
	
	ldy #0
boucle
	lda 46080+PatCar*8,y
	cmp #$20
	rol
	and #$3F
	sta 46080+PatCar*8,y
	iny
	cpy #8
	bne boucle
fin
	plp
	pla
	tay
	pla
	rti
.)

_setanimate
.(
	lda #<PatLac
	sta PatLacPtr
	lda #>PatLac
	sta PatLacPtr+1
	
suite
	ldy #0
boucle
	lda (PatLacPtr),y
	sta 46080+PatCar*8,y
	iny
	cpy #8
	bne boucle
fin
	sei
	lda #0
	sta Timer
	lda $24A
	sta saverti
	lda $24B
	sta saverti+1
	lda $24C
	sta saverti+2
	lda #$4C
	sta $24A
	lda #<_animate
	sta $24B
	lda #>_animate
	sta $24C
	cli
	rts
.)

_unsetanimate
.(
	sei
	lda saverti
	sta $24A
	lda saverti+1
	sta $24B
	lda saverti+2
	sta $24C
	cli
	rts
.)

*=$a000
_map
.dsb 5000

*=$6000
.dsb 1
