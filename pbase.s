;******************************************************************
;*****         Routine de décompactage algorithme LZ77         ****
;*** code et commentaires issus de l'article que j'ai publié    ***
;***           page 15 du CEO MAg n° 265  de mai 2012           ***
;***            (d'où les étiquettes un peu bizares)            ***
;******************************************************************

;***  initialisation adresses  ***
_main
	LDA #$00
	STA $58 	; $58-59 => $0600
	LDA #$06	; adresse de début
	STA $59 	; de la table décompactée 
	LDA #$8D	;
	STA $5A 	; $5A-5B => $8D3d
	LDA #$3C 	; Adresse de fin
	STA $5B 	; de la table décompactée
	LDA #<dta_map	;							<== A MODIFIER EN FONCION DU NOM DES DATA (ex : dta_ville1)
	STA $56 	; $56-57 => adr dta_titre1
	LDA #>dta_map 	;							<== A MODIFIER EN FONCION DU NOM DES DATA
	STA $57 	; de la table compactée
	LDY #$00
	LDA #$01 	; Valeur initiale de $6E pour 255C STA $6E entrer dans la boucle principale
	STA $6E
	
;**** Boucle principale   ***

e_255E
	LSR $6E 	; $6E => #$00 et C=1
	BNE e_256D
	LDA ($56),Y ; prend 1 octet (#FF ou #xy )
	INC $56 	; LLadr.+1
	BNE e_256A 	; si pas nul saute
	INC $57  	;si nul HHadr.+1
e_256A
	ROR 		; Cb7 b0C
	STA $6E 	; $6E => #FF ou #xy
e_256D	
	BCC e_2593  ; Si C=0 aller traiter le cas spécial où on doit remonter dans le code déjà
				; transféré pour trouver les prochains octets à transférer. Les deux
				; prochains octets vont permettre de calculer le nombre d’octets à
				; remonter pour atteindre le premier à dupliquer ainsi que le nombre
				; d’octets à dupliquer de la sorte. Si C=1, on prend simplement l’octet
				; suivant pour le transférer.
	LDA ($56),Y ; octet de la table de départ
	STA ($58),Y ; vers la table d’arrivée
	INC $56 	; Incrémente adresse
	BNE e_2579 	; de départ LL partie basse
	INC $57 	; et HH partie haute si nécessaire
e_2579	
	LDA #$01
	STA $72 	; $72=>1
e_257D	
	CLC
	LDA $58 	; Maj LL adresse arrivée
	ADC $72 	; +1 si octet normal
	STA $58 	; +($72) si octets déjà
	BCC e_2588 	; existants + haut dans table arrivée
	INC $59 	; et HH, partie haute si besoin
e_2588	
	CMP $5A 	; compare à
	LDA $59 	; adresse de fin
	SBC $5B
	BCC e_255E 	; si pas fini on boucle
	JMP $0600 	; si fini, lance le jeu : SORTIE    <== ATTENTION ADRESSE D'EXECUTION A CHANGER EN FONCTION  ($600 est l'adresse de MAP.com)

; Nous allons étudier la routine ci-dessous, pour le cas
; $56-$57 => $2B72 et $58-$59 => $0C96

;*** Routine de gestion des tronçons de code dupliqués ***
e_2593
	LDA ($56),Y ; # 19
	ADC #$01 	; #$1A
	STA $5E 	; $5E => #A
	INY
	LDA ($56),Y ; # 04
	TAX
	AND #$0F 	; force 0 ds b7b6b5b4
	ADC #$00 	; ajoute la retenue
	STA $5F 	; $5F => #04
	TXA 		; récupère #04
	LSR 		; 4 décalages
	LSR 		; font passer HH
	LSR 		; dans LL
	LSR
	CLC 		; Prépare addition
	ADC #$03 	; ajoute 3
	STA $72 	; $72 => #03 c’est le nb d’octets
	SEC 		; prépare soustraction
	LDA $58 	; Soustrait ($5E)de($58)
	SBC $5E 	; place résultat en $5C
	STA $5C 	; $5C=> #96 - #1A=#7C et C=0
	LDA $59 	; Soustrait ($5F)de($59)
	SBC $5F 	; place résultat en $5D
	STA $5D 	; $5D => #0C-#04 - 0 = #08
	DEY 		; Y=0
e_25BB	
	LDA ($5C),Y ;($087C,Y)on remonte donc
	STA ($58),Y ; ds la table départ et on
	INY 		; continue ds table arrivée
	CPY $72 	; tant que Y < 3)
	BNE e_25BB 	; on boucle
	LDY #$00 	; initialise Y pour suite
	LDA $56
	ADC #$01 	; mise à jour adresse
	STA $56 	; dans la table de départ
	BCC e_257D
	INC $57
	BNE e_257D 	; saut inconditionnel car ($57) toujours <> 0


