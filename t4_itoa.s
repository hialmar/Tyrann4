;
; itoa
;
_t4_itoa
.(
	ldy #0
	lda (sp),y
	sta op2
	iny
	lda (sp),y
	sta op2+1

t4_itoa
	ldy #0
	sty bufconv
	;lda op2+1
	jmp t4_uitoa
	;lda #$2D	; minus sign
	;sta bufconv
	;sec
	;lda #0
	;sbc op2
	;sta op2
	;lda #0
	;sbc op2+1
	;sta op2+1

t4_itoaloop
	jsr udiv10
	pha
	iny
	lda op2
	ora op2+1
	bne t4_itoaloop
	
	lda bufconv
	beq t4_poploop
	inx
t4_poploop
	pla
	clc
	adc #$30
	sta bufconv,x
	inx
	dey
	bne t4_poploop
	lda #0
	sta bufconv,x
	ldx #<bufconv
	lda #>bufconv
	rts

t4_uitoa
	ldy #0
	sty bufconv
	jmp t4_itoaloop

t4_bufconv
	.byt 0,0,0,0,0,0,0,0,0,0,0,0

;
; udiv10 op2= op2 / 10 and A= tmp2 % 10
;
t4_udiv10
	lda #0
	ldx #16
	clc
t4_udiv10lp
	rol op2
	rol op2+1
	rol 
	cmp #10
	bcc t4_contdiv
	sbc #10
t4_contdiv
	dex
	bne t4_udiv10lp
	rol op2
	rol op2+1
    rts
.)

