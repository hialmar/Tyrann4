	.zero
	*= $a0
direction_scroll .dsb 1
est_affiche_texte .dsb 1


   .text

;********************************************************
;**** routine ecrit une phrase sur ligne écran text  ****
;********************************************************
write_phrase
.(
	lda $1111,x
	beq end_phrase
+adr_ecr_txt
	sta $bf11,x
	inx
	bne write_phrase
end_phrase
	lda #$01
	sta est_affiche_texte
	rts
.)

;------------------------------------------------------
; -----  routine attend appui touche puis relacher ---
;------------------------------------------------------ spécifique pour mon test
_wait_key
.(
		lda $208
		cmp #$38
		beq _wait_key
		cmp #$ac
		bne next_key_1
		beq end_key
next_key_1
		cmp #$bc
		bne next_key_2
		beq end_key
next_key_2
		cmp #$9c
		bne next_key_3
		beq end_key
next_key_3
		cmp #$b4
;		bne next_key_4
		bne end_key
		beq end_key
;next_key_4
;		cmp #$86
;		bne no_key
;		beq end_key
;no_key
;		lda #$38
end_key
		sta direction_scroll
		rts
.)
