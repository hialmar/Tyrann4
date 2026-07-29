; -------------------------------------------------------------------------
; ----------  routines de chargement/sauvegarde de l'équipe
; -------------------------------------------------------------------------
   .text
;struct character {
;	char 		  nom[11]; // nom
    .align 256
_character_name .dsb 6*16
; 96 bytes
;	unsigned int  ri; // richesses (nom => 2 octets)
_character_ri .dsb 6*2
;	unsigned char cp; // carrière perso
_character_cp .dsb 6
;	unsigned char mp; // maison
_character_mp .dsb 6
;	unsigned char cc; // capacité de combat
_character_cc .dsb 6
;	unsigned char ct; // capacité de tir
_character_ct .dsb 6
;	unsigned char fo; // force
_character_fo .dsb 6
;	unsigned char ag; // agilité
_character_ag .dsb 6
;	unsigned char in; // intelligence
_character_in .dsb 6
;	unsigned char fm; // force mentale
_character_fm .dsb 6
;	unsigned char pv; // points de vie ou de blessures
_character_pv .dsb 6
;	unsigned char et; // état des PV
_character_et .dsb 6
;	unsigned char ok; // santé
_character_ok .dsb 6
;	unsigned char ni; // niveau (nom => 16 octets)
_character_ni .dsb 6
;	unsigned int  xp; // expérience
_character_xp .dsb 6*2
;	unsigned char wr; // arme droite (weapon right)
_character_wr .dsb 6
;	unsigned char wl; // arme gauche
_character_wl .dsb 6
;	unsigned char pt; // armure
_character_pt .dsb 6
;	unsigned char ca; // classe d'armure
_character_ca .dsb 6
;	unsigned char bt; // bête (nom => 23 octets)
_character_bt .dsb 6
; 6*21 = 126 bytes + 96 = 222 bytes

;char s = 1; // direction (est)
_team_s .dsb 1
;unsigned char x = 2; // coords
_team_x .dsb 1
;unsigned char y = 2;
_team_y .dsb 1
;
;struct character characters[6];
;
;unsigned char boussole;
_team_boussole .dsb 1
;unsigned char filet;
_team_filet .dsb 1
;unsigned char selle_dragon
; T4 bateau
_team_selle .dsb 1
;

; 228 bytes

;unsigned char ingredients[6]; // ingrédients
_team_ingredients .dsb 6
;
;unsigned char ville=0; // ville courante
_team_ville .dsb 1
;

; 235 bytes
;unsigned char dedans; // tableau de bits pour gérer le côté des portes et le mur à la fin
_team_dedans .dsb 1
;
;unsigned char tl; // top level  villes visitables.
_team_tl .dsb 1
;unsigned char np; // nombre d'ingredients de la potion
_team_np .dsb 1
;unsigned char nf; // nombre de fuites
_team_nf .dsb 1
;unsigned char pm; // potion faite ?
_team_pm .dsb 1
;
;unsigned char out=1; // sur la carte ?
_team_out .dsb 1
;
;char ca = 0; // case courante
_team_ca .dsb 1
;
;char * _teamfilename = "TEAM.BIN"; // fichier contenant l'équipe
;
;char io_needed = 1;
_team_io_needed .dsb 1

; 243 bytes

;	unsigned char version;
_team_version .dsb 1

; 244 bytes

.align 256
;	unsigned char sad[6]; // sac à dos
_character_sad .dsb 6*8
;	unsigned char sp[8]; // sorts
_character_sp .dsb 6*8
;};


;unsigned char cles[9][4]; // trousseau de clefs (36 octets) 
; T4 16 villes * 2 octets = 32 octets + 4 octets globaux
_team_cles .dsb 9*4
;
;unsigned char combats_coffres[9][5]; // combats et coffres sous forme de tableaux de bits (45 octets)
; T4 16 villes * 2 octets = 32 octets + 13 octets globaux
_team_combats_coffres .dsb 9*5
;


;void loadCharacters(void)
;{

#define zone_mem tmp0
#define index_name tmp1
#define index_sad tmp2
#define index_sp tmp3
#define index_ri tmp4
#define index_xp tmp5
#define team_namelen tmp6
#define team_perso tmp7
#define ret_load reg0
#define index reg1
; ----------
; Charge l'équipe
; tmp0 adresse début HIRES qui stocke les données
; tmp1 indice tableau noms
; tmp2 indice tableau sac
; tmp3 indice tableau sorts
; tmp4 indice tableau richesses
; tmp5 indice tableau xp
; tmp6 longueur nom
; tmp7 num perso courant
; tmp8 retour chargement
; tmp9 indice lecture
;
_load_t4_characters
.(
;	// 48000 PRINT SPC(9);"Veuillez Patienter..."
;	// POKE 48035,0:POKE#26A,PEEK(#26A)AND254
;	poke(48035,0);
    lda #0
    sta 48035
;	poke(0x26a,peek(0x26a)&254);
    lda $26a
    and #254
    sta $26a
;	puts("         Veuillez Patienter...\n");
	ldx #0
	lda t_load_wait_1,x
	sta adr_ecr_txt+1
	lda #<t_load_wait_1+1
	sta write_phrase+1
	lda #>t_load_wait_1+1
	sta write_phrase+2
	jsr write_phrase
;	// 48005 CLOAD"TEAM"
;	if (io_needed) {
    lda _team_io_needed
    beq skip_load
;		//printf("Chargement de %s\n", _teamfilename);
	ldy #0         ; grab string pointer
	lda #<t_team_filemane
	sta (sp),y
	iny
	lda #>t_team_filemane
	sta (sp),y
	dey
	jsr _DiscLoad
;		ret = DiscLoad(teamfilename);
;		//printf("Retour %d\n", ret);
;	} else {
;		ret = 0;
;	}
;	if (ret==0) {
skip_load
;		// 48010 O1=#A000
;		// 48015 O1=O1+1:VIL=PEEK(O1):PRINT SPC(9);"...";
;		ptr = (char*)0xa001;
        lda #1
        sta zone_mem
        lda #$a0
        sta zone_mem+1
;		printf("debut : (%x) ou %d\n", (unsigned int) ptr, (int) ptr);
;		version = *ptr; ptr++;
        ldy #0
        lda (zone_mem),y
        sta _team_version
        iny
;		x = *ptr; ptr++;
        lda (zone_mem),y
        sta _team_x
        iny
;		y = *ptr; ptr++;
        lda (zone_mem),y
        sta _team_y
        iny
;		s = *ptr; ptr++;
        lda (zone_mem),y
        sta _team_s
        iny
;		ca = *ptr; ptr++;
        lda (zone_mem),y
        sta _team_ca
        iny
;		ville = *ptr; ptr++;
        lda (zone_mem),y
        sta _team_ville
        iny
;		printf("x=%d y=%d s=%d ca=%d ville=%d\n", x, y, s, ca, ville);
;		// test
;		if (x==0 || x > 100) {
;			x = 2; y = 2; s = 1; ville = 4;
;			// printf("x=%d y=%d s=%d ca=%d\n", x, y, s, ca);
;		}
;		ink(eencre[ville-1]);
;		printf("ville: %d\n", ville);
;		puts("         ...\n");
;		// 48020 FOR P=1TO6
        lda #0
        sta team_perso
        sta index_name
        sta index_sad
        sta index_sp
        sta index_ri
        sta index_xp
;		for(perso=0;perso<6;perso++) {
;			// 48030 O1=O1+1:DD=PEEK(O1)
;			namelen = *ptr; ptr++;
read_characters
        jsr get_next_byte
        sta team_namelen
;			// 48040 FORJ=1TODD:O1=O1+1:N$(P)=N$(P)+CHR$(PEEK(O1)):NEXTJ
;			for(i=0;i<namelen;i++) {
        lda #0
        sta index
loop_read_write_name
;				if (i < 10)
;				    characters[perso].nom[i]=*ptr;
        jsr get_next_byte
        ldx index_name
        sta _character_name,x
        inc index_name
        inc index
        lda index
        cmp team_namelen
        beq read_name_over
        cmp #15
        bmi loop_read_write_name
        ; name is too long, we skip the rest
        ldx index
loop_skip_rest_of_name
;				ptr++;
;			}
        jsr get_next_byte
        inx
        txa
        cmp team_namelen
        bmi loop_skip_rest_of_name
read_name_over
;			if (i>10) i=10;
;			characters[perso].nom[i]=0;
        lda #0
        ldx index_name
        sta _character_name,x
        inc index_name
        inc index
        lda index
        cmp #16
        bne read_name_over
;			memcpy((char*)&(characters[perso].ri), ptr, 21);
;			ptr+=21;
;#ifdef debug
;			printf("...\n");
;			printf("perso %d : longueur %d nom %s\n", perso, namelen, characters[perso].nom);
;			printf("richesse %d0\n", characters[perso].ri);
        jsr get_next_byte
        ldx index_ri
        sta _character_ri,x
        inc index_ri
        jsr get_next_byte
        ldx index_ri
        sta _character_ri,x
        inc index_ri
        ldx team_perso
;			printf("classe %d\n", _characters[perso].cp);
        jsr get_next_byte
        sta _character_cp,x
;			printf("taper sur une touche pour continuer\n");
;			printf("maison %d\n", _characters[perso].mp);
        jsr get_next_byte
        sta _character_mp,x
;			printf("CC %d\n", _characters[perso].cc);
        jsr get_next_byte
        sta _character_cc,x
;			printf("CT %d\n", _characters[perso].ct);
        jsr get_next_byte
        sta _character_ct,x
;			printf("FO %d\n", _characters[perso].fo);
        jsr get_next_byte
        sta _character_fo,x
;			printf("AG %d\n", _characters[perso].ag);
        jsr get_next_byte
        sta _character_ag,x
;			printf("IN %d\n", _characters[perso].in);
        jsr get_next_byte
        sta _character_in,x
;			printf("FM %d\n", _characters[perso].fm);
        jsr get_next_byte
        sta _character_fm,x
;			a = (char)getchar();
;			printf("PV %d\n", _characters[perso].pv);
        jsr get_next_byte
        sta _character_pv,x
;			printf("etat %d\n", _characters[perso].et);
        jsr get_next_byte
        sta _character_et,x
;			printf("OK %d\n", _characters[perso].ok);
        jsr get_next_byte
        sta _character_ok,x
;			printf("NI %d\n", _characters[perso].ni);
        jsr get_next_byte
        sta _character_ni,x
;			printf("XP %d\n", _characters[perso].xp);
        jsr get_next_byte
        ldx index_xp
        sta _character_xp,x
        inc index_xp
        jsr get_next_byte
        ldx index_xp
        sta _character_xp,x
        inc index_xp
;			printf("WR %d\n", _characters[perso].wr);
        ldx team_perso
        jsr get_next_byte
        sta _character_wr,x
;			printf("WL %d\n", _characters[perso].wl);
        jsr get_next_byte
        sta _character_wl,x
;			printf("Armure %d\n", _characters[perso].pt);
        jsr get_next_byte
        sta _character_pt,x
;			printf("CA %d\n", _characters[perso].ca);
        jsr get_next_byte
        sta _character_ca,x
;			printf("bete %d\n", _characters[perso].bt);
        jsr get_next_byte
        sta _character_bt,x
;			a = (char)getchar();
;#endif
;			// 48230 FORI=1TO6:O1=O1+1:SAD(P,I)=PEEK(O1):NEXTI
;			memcpy((char*)&(_characters[perso].sad), ptr, 6);
        lda #0
        sta index
read_sad
        jsr get_next_byte
        ldx index_sad
        sta _character_sad,x
        inc index_sad
        inc index
        lda index
        cmp #6
        bne read_sad
;			ptr+=6;
;#ifdef debug
;			for(i=0;i<6;i++) {
;				printf("SAD(%d) : %d\n", i, _characters[perso].sad[i]);
;			}
;#endif
;			//printf("taper sur une touche pour continuer\n");
;        	//a = (char)getchar();
;			// 48235 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:SN(P,I)=PEEK(O1):NEXT
        lda #0
        sta index
read_sp
        ldx team_perso
        lda _character_cp,x
        cmp #4
        bmi skip_load_save_sp
;			if (_characters[perso].cp>3) {
;				memcpy((char*)&(_characters[perso].sp), ptr, 8);
;				ptr+=8;
;#ifdef debug
;				for(i=0;i<8;i++) {
;					printf("SP(%d) : %d\n", i, _characters[perso].sp[i]);
;				}
;#endif
        jsr get_next_byte
        ldx index_sp
        sta _character_sp,x
 skip_load_save_sp
        inc index_sp
        inc index
        lda index
        cmp #8
 ;			}
        bne read_sp
 ;			// 48240 PRINT "...";:NEXT P
;		}
        inc team_perso
        lda team_perso
        cmp #6
        beq end_characters
        jmp read_characters
end_characters
;		// 48250 O1=O1+1:BS=PEEK(O1)
;		boussole = *ptr; ptr++;
        jsr get_next_byte
        sta _team_boussole
;		//printf("Boussole %d\n", boussole);
;		// 48260 O1=O1+1:FI=PEEK(O1)
        jsr get_next_byte
        sta _team_filet
;		filet = *ptr; ptr++;
;		//printf("filet %d\n", filet);
;		selle_dragon = *ptr; ptr++;
        jsr get_next_byte
        sta _team_selle
;		//printf("selle dragon %d\n", selle_dragon);
;		// 48270 FOR L=1TO9:FOR C=1TO4:O1=O1+1:CLEF(L,C)=PEEK(O1):NEXT C,L
;		memcpy((char*)cles, ptr, 36);
        ldx #0
read_cles
        jsr get_next_byte
        sta _team_cles,x
        inx
        txa
        cmp #36
        bne read_cles
;		ptr+=36;
;#ifdef debug
;		for(i=0;i<9;i++) {
;			for (j=0;j<4;j++) {
;				printf("cle(%d,%d) = %d\n", i, j, cles[i][j]);
;			}
;		}
;		puts("taper sur une touche pour continuer\n");
;        a = (char)getchar();
;#endif
;		// 48290 FOR I=1TO6:O1=O1+1:INGREDIENT(I)=PEEK(O1):NEXT
;		memcpy((char*)ingredients, ptr, 6);
        ldx #0
read_ingredients
        jsr get_next_byte
        sta _team_ingredients,x
        inx
        txa
        cmp #6
        bne read_ingredients
;		ptr+=6;
;#ifdef debug
;		for(i=0;i<6;i++) {
;			printf("ingredients(%d) = %d\n", i, ingredients[i]);
;		}
;#endif
;		memcpy((char*)combats_coffres, ptr, 45);
        ldx #0
read_combats_coffres
        jsr get_next_byte
        sta _team_combats_coffres,x
        inx
        txa
        cmp #45
        bne read_combats_coffres
;		ptr+=45;
;		dedans=*ptr;
        jsr get_next_byte
        sta _team_dedans
;		ptr++;
;		tl=*ptr;
        jsr get_next_byte
        sta _team_tl
;		ptr++;
;		//printf("tl %d\n", tl);
;		np=*ptr;
        jsr get_next_byte
        sta _team_np
;		ptr++;
;		nf=*ptr;
        jsr get_next_byte
        sta _team_nf
;		ptr++;
;		pm=*ptr;
        jsr get_next_byte
        sta _team_pm
;		ptr++;
;		out=1;//*ptr;
        ; jsr get_next_byte
        lda #1
        sta _team_out
;		printf("out : %d", out);
;		ptr++;
;		printf("longueur %d\n", (int) (ptr - 0xa000));
;	} else {
;		printf("Erreur lors du chargement de TEAM.BIN\n");
;		exit(1);
;	}
;}
        rts
.)

; y contains the offset
; the next byte will be in acc
; if y goes over then we increment the byte at zone_mem+1
get_next_byte
.(
    lda (zone_mem),y
    iny
    bne fin
    inc zone_mem+1
    ldy #0
fin
    rts
.)


; y contains the offset
; the next byte to put is in acc
; if y goes over then we increment the byte at zone_mem+1
put_next_byte
.(
    sta (zone_mem),y
    iny
    bne fin
    inc zone_mem+1
    ldy #0
fin
    rts
.)



; ----------
; Sauve l'équipe
; tmp0 adresse début HIRES ou stocker les données temporaires
; tmp1 indice tableau noms
; tmp2 indice tableau sac
; tmp3 indice tableau sorts
; tmp4 indice tableau richesses
; tmp5 indice tableau xp
; tmp6 longueur nom
; tmp7 num perso courant
; tmp8 retour chargement
; tmp9 indice lecture
;
_save_t4_characters
.(
;	// 48000 PRINT SPC(9);"Veuillez Patienter..."
;	// POKE 48035,0:POKE#26A,PEEK(#26A)AND254
;	poke(48035,0);
    lda #0
    sta 48035
;	poke(0x26a,peek(0x26a)&254);
    lda $26a
    and #254
    sta $26a
;	puts("         Veuillez Patienter...\n");
	ldx #0
	lda t_save_wait_1,x
	sta adr_ecr_txt+1
	lda #<t_save_wait_1+1
	sta write_phrase+1
	lda #>t_save_wait_1+1
	sta write_phrase+2
	jsr write_phrase

        lda #1
        sta zone_mem
        lda #$a0
        sta zone_mem+1

        ldy #0
        lda _team_version
        sta (zone_mem),y
        iny
;		x = *ptr; ptr++;
        lda _team_x
        sta (zone_mem),y
        iny
;		y = *ptr; ptr++;
        lda _team_y
        sta (zone_mem),y
        iny
;		s = *ptr; ptr++;
        lda _team_s
        sta (zone_mem),y
        iny
;		ca = *ptr; ptr++;
        lda _team_ca
        sta (zone_mem),y
        iny
;		ville = *ptr; ptr++;
        lda _team_ville
        sta (zone_mem),y
        iny
;		printf("x=%d y=%d s=%d ca=%d ville=%d\n", x, y, s, ca, ville);
;		// test
;		if (x==0 || x > 100) {
;			x = 2; y = 2; s = 1; ville = 4;
;			// printf("x=%d y=%d s=%d ca=%d\n", x, y, s, ca);
;		}
;		ink(eencre[ville-1]);
;		printf("ville: %d\n", ville);
;		puts("         ...\n");
;		// 48020 FOR P=1TO6
        lda #0
        sta team_perso
        sta index_name
        sta index_sad
        sta index_sp
        sta index_ri
        sta index_xp
        sta team_namelen
;		for(perso=0;perso<6;perso++) {
;			// 48030 O1=O1+1:DD=PEEK(O1)
;			namelen = *ptr; ptr++;
write_characters
        ; compute current character name length
        lda #0
        sta team_namelen
        ldx index_name
loop_compute_namelen
        lda _character_name,x
        inx
        inc team_namelen
        cmp #0
        bne loop_compute_namelen
        ldx team_namelen
        dex ; we counted a 0
        txa
        jsr put_next_byte
;			// 48040 FORJ=1TODD:O1=O1+1:N$(P)=N$(P)+CHR$(PEEK(O1)):NEXTJ
;			for(i=0;i<namelen;i++) {
        ; write the name
        ldx index_name
        lda #0
        sta index
loop_write_name
        lda _character_name,x
        beq loop_skip_remaining
        jsr put_next_byte
        inx
        inc index_name
        inc index
        bne loop_write_name ; inconditionnel car index != 0
loop_skip_remaining
        lda index
        cmp #15
        beq read_name_over
        inc index
        inc index_name
        bne loop_skip_remaining ; inconditionnel car index_name != 0
read_name_over
        inc index_name ; on saute le 15ème car
;			printf("richesse %d0\n", characters[perso].ri);
        ldx index_ri
        lda _character_ri,x
        jsr put_next_byte
        inc index_ri
        ldx index_ri
        lda _character_ri,x
        jsr put_next_byte
        inc index_ri
        ldx team_perso
;			printf("classe %d\n", _characters[perso].cp);
        lda _character_cp,x
        jsr put_next_byte
;			printf("taper sur une touche pour continuer\n");
;			printf("maison %d\n", _characters[perso].mp);
        lda _character_mp,x
        jsr put_next_byte
;			printf("CC %d\n", _characters[perso].cc);
        lda _character_cc,x
        jsr put_next_byte
;    	printf("CT %d\n", _characters[perso].ct);
        lda _character_ct,x
        jsr put_next_byte
;			printf("FO %d\n", _characters[perso].fo);
        lda _character_fo,x
        jsr put_next_byte
;			printf("AG %d\n", _characters[perso].ag);
        lda _character_ag,x
        jsr put_next_byte
;			printf("IN %d\n", _characters[perso].in);
        lda _character_in,x
        jsr put_next_byte
;			printf("FM %d\n", _characters[perso].fm);
        lda _character_fm,x
        jsr put_next_byte
;			a = (char)getchar();
;			printf("PV %d\n", _characters[perso].pv);
        lda _character_pv,x
        jsr put_next_byte
;			printf("etat %d\n", _characters[perso].et);
        lda _character_et,x
        jsr put_next_byte
;			printf("OK %d\n", _characters[perso].ok);
        lda _character_ok,x
        jsr put_next_byte
;			printf("NI %d\n", _characters[perso].ni);
        lda _character_ni,x
        jsr put_next_byte
;			printf("XP %d\n", _characters[perso].xp);
        ldx index_xp
        lda _character_xp,x
        inc index_xp
        jsr put_next_byte
        ldx index_xp
        lda _character_xp,x
        inc index_xp
;			printf("WR %d\n", _characters[perso].wr);
        jsr put_next_byte
        ldx team_perso
        lda _character_wr,x
;			printf("WL %d\n", _characters[perso].wl);
        jsr put_next_byte
        lda _character_wl,x
;			printf("Armure %d\n", _characters[perso].pt);
        jsr put_next_byte
        lda _character_pt,x
;			printf("CA %d\n", _characters[perso].ca);
        jsr put_next_byte
        lda _character_ca,x
;			printf("bete %d\n", _characters[perso].bt);
        jsr put_next_byte
        lda _character_bt,x
        jsr put_next_byte
;			a = (char)getchar();
;#endif
;			// 48230 FORI=1TO6:O1=O1+1:SAD(P,I)=PEEK(O1):NEXTI
;			memcpy((char*)&(_characters[perso].sad), ptr, 6);
        lda #0
        sta index
write_sad
        ldx index_sad
        lda _character_sad,x
        jsr put_next_byte
        inc index_sad
        inc index
        lda index
        cmp #6
        bne write_sad
;			ptr+=6;
;#ifdef debug
;			for(i=0;i<6;i++) {
;				printf("SAD(%d) : %d\n", i, _characters[perso].sad[i]);
;			}
;#endif
;			//printf("taper sur une touche pour continuer\n");
;        	//a = (char)getchar();
;			// 48235 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:SN(P,I)=PEEK(O1):NEXT
        lda #0
        sta index
write_sp
        ldx team_perso
        lda _character_cp,x
        cmp #4
        bmi skip_save_sp
;			if (_characters[perso].cp>3) {
;				memcpy((char*)&(_characters[perso].sp), ptr, 8);
;				ptr+=8;
;#ifdef debug
;				for(i=0;i<8;i++) {
;					printf("SP(%d) : %d\n", i, _characters[perso].sp[i]);
;				}
;#endif
        ldx index_sp
        lda _character_sp,x
        jsr put_next_byte
 skip_save_sp
        inc index_sp
        inc index
        lda index
        cmp #8
 ;			}
        bne write_sp
 ;			// 48240 PRINT "...";:NEXT P
;		}
        inc team_perso
        lda team_perso
        cmp #6
        beq end_characters
        jmp write_characters
end_characters
;		// 48250 O1=O1+1:BS=PEEK(O1)
;		boussole = *ptr; ptr++;
        lda _team_boussole
        jsr put_next_byte
;		//printf("Boussole %d\n", boussole);
;		// 48260 O1=O1+1:FI=PEEK(O1)
        lda _team_filet
        jsr put_next_byte
;		filet = *ptr; ptr++;
;		//printf("filet %d\n", filet);
;		selle_dragon = *ptr; ptr++;
        lda _team_selle
        jsr put_next_byte
;		//printf("selle dragon %d\n", selle_dragon);
;		// 48270 FOR L=1TO9:FOR C=1TO4:O1=O1+1:CLEF(L,C)=PEEK(O1):NEXT C,L
;		memcpy((char*)cles, ptr, 36);
        ldx #0
write_cles
        lda _team_cles,x
        jsr put_next_byte
        inx
        txa
        cmp #36
        bne write_cles
;		ptr+=36;
;#ifdef debug
;		for(i=0;i<9;i++) {
;			for (j=0;j<4;j++) {
;				printf("cle(%d,%d) = %d\n", i, j, cles[i][j]);
;			}
;		}
;		puts("taper sur une touche pour continuer\n");
;        a = (char)getchar();
;#endif
;		// 48290 FOR I=1TO6:O1=O1+1:INGREDIENT(I)=PEEK(O1):NEXT
;		memcpy((char*)ingredients, ptr, 6);
        ldx #0
write_ingredients
        lda _team_ingredients,x
        jsr put_next_byte
        inx
        txa
        cmp #6
        bne write_ingredients
;		ptr+=6;
;#ifdef debug
;		for(i=0;i<6;i++) {
;			printf("ingredients(%d) = %d\n", i, ingredients[i]);
;		}
;#endif
;		memcpy((char*)combats_coffres, ptr, 45);
        ldx #0
write_combats_coffres
        lda _team_combats_coffres,x
        jsr put_next_byte
        inx
        txa
        cmp #45
        bne write_combats_coffres
;		ptr+=45;
;		dedans=*ptr;
        lda _team_dedans
        jsr put_next_byte
;		ptr++;
;		tl=*ptr;
        lda _team_tl
        jsr put_next_byte
;		ptr++;
;		//printf("tl %d\n", tl);
;		np=*ptr;
        lda _team_np
        jsr put_next_byte
;		ptr++;
;		nf=*ptr;
        lda _team_nf
        jsr put_next_byte
;		ptr++;
;		pm=*ptr;
        lda _team_pm
        jsr put_next_byte
;		ptr++;
;		out=1;//*ptr;
        ; jsr get_next_byte
        lda _team_out
        jsr put_next_byte
;		printf("out : %d", out);
;		ptr++;
;		printf("longueur %d\n", (int) (ptr - 0xa000));
;	} else {
;		printf("Erreur lors du chargement de TEAM.BIN\n");
;		exit(1);
;	}
;}
    lda _team_io_needed
    beq skip_save
    ; y contient la partie basse de l'adresse de fin
    sty zone_mem
;		//printf("Sauvegarde de %s\n", _teamfilename);
	ldy #0         ; grab string pointer
	lda #<t_team_filemane
	sta (sp),y
	iny
	lda #>t_team_filemane
	sta (sp),y
    iny
    ; adresse début
    lda #0
    sta (sp),y
    iny
    lda #$a0
    sta (sp),y
    iny
    ; adresse fin
    lda tmp0
    sta (sp),y
    iny
    lda tmp0+1
    sta (sp),y
	dey
	jsr _DiscSave
;		//printf("Retour %d\n", ret);
;	} else {
;		ret = 0;
;	}
;	if (ret==0) {
skip_save
        rts
.)



t_load_wait_1
	.byt $9a
	.asc "Loading - Please wait.",0
t_save_wait_1
	.byt $9a
	.asc "Saving - Please wait.",0

t_team_filemane
	.asc "TEAM.BIN",0

