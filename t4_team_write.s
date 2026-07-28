	.zero
	*= $a0
; TODO : à virer
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
