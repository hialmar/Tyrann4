#include "tyrann.h"

#define TMAX 800
char textes[TMAX];
int tmax = TMAX;

extern char * ptTextes;
extern char nbTextes;

char * textesItems[55];

extern char s; // direction (est)
extern unsigned char x; // coords
extern unsigned char y;

extern struct character characters[6];

extern unsigned char ingredients[6]; // ingrédients

extern unsigned char boussole;

extern unsigned char cles[9][4]; // trousseau de clefs (36 octets)

extern unsigned char ville; // ville courante

extern char ca; // case courante

extern unsigned char nb_combat;

extern unsigned char tl; // top level  villes visitables.
extern unsigned char np; // nombre d'ingredients de la potion

extern unsigned char boussole;
extern unsigned char filet;
extern unsigned char selle_dragon;

extern unsigned char out;

extern char io_needed;
extern char eencre[];

char *classe[] = { "Legionary","Gladiator","Scout","Druid","Sem-Priest","Vestal" };
char *etat[] = { "OK", "-Empoi-  ", "-Paral-  ", ">MORT<  " };
char *maisons[] = { "Celtic","Egyptian","Gallic","Goth","Persian","Roman","Viking","Iberian"};

char *sorts[] = { "SOMMEIL","FEU","PIERRE","VENIN","SANG","FOUDRE", "LAVE", "SEISME",
				  "EAU", "SERUM", "MUSCLE", "BOUCLIER", "ELIXIR", "ECRAN", "VIE", "MORT",
				  "EPEE-FEU", "FORCE", "CHARME", "VISION", "GLACE", "ILLUSION", "VENT",
				  "DRAGON" };

char *nomIngredients[] = { "sangsue royale","fleur de Lys","encre de poulpe","rose du Val","huile du Roc","foie de truite"};

char tentatives = 0; // pour les coffres

// nom
extern unsigned char character_name[]; // .dsb 6*16 = 96 octets
// richesses
extern unsigned int character_ri[]; // .dsb 6*2
// carrière perso
extern unsigned char character_cp[]; // .dsb 6
// maison
extern unsigned char character_mp[]; // .dsb 6
// capacité de combat
extern unsigned char character_cc[]; // .dsb 6
// capacité de tir
extern unsigned char character_ct[]; // .dsb 6
// force
extern unsigned char character_fo[]; // .dsb 6
// agilité
extern unsigned char character_ag[]; // .dsb 6
// in; // intelligence
extern unsigned char character_in[]; // .dsb 6
// fm; // force mentale
extern unsigned char character_fm[]; // .dsb 6
// pv; // points de vie ou de blessures
extern unsigned char character_pv[]; // .dsb 6
// et; // état des PV
extern unsigned char character_et[]; // .dsb 6
// ok; // santé
extern unsigned char character_ok[]; // .dsb 6
// ni; // niveau (nom => 16 octets)
extern unsigned char character_ni[]; // .dsb 6
// xp; // expérience
extern unsigned char character_xp[]; // .dsb 6*2
// wr; // arme droite (weapon right)
extern unsigned char character_wr[]; // .dsb 6
// wl; // arme gauche
extern unsigned char character_wl[]; // .dsb 6
// pt; // armure
extern unsigned char character_pt[]; // .dsb 6
// ca; // classe d'armure
extern unsigned char character_ca[]; // .dsb 6
// bt; // bête (nom => 23 octets)
extern unsigned char character_bt[]; // .dsb 6
// 6*21 = 126 bytes + 96 = 222 bytes

// s = 1; // direction (est)
extern unsigned char team_s; // .dsb 1
// x = 2; // coords
extern unsigned char team_x; // .dsb 1
// y = 2;
extern unsigned char team_y; // .dsb 1

// boussole;
extern unsigned char team_boussole; // .dsb 1
// filet;
extern unsigned char team_filet; // .dsb 1
// selle
extern unsigned char team_selle; // .dsb 1

// 228 bytes

// ingredients[6]; // ingrédients
extern unsigned char team_ingredients[]; // .dsb 6

// ville=0; // ville courante
extern unsigned char team_ville; // .dsb 1

// 235 bytes
// dedans; // tableau de bits pour gérer le côté des portes et le mur à la fin
extern unsigned char team_dedans; // .dsb 1

// tl; // top level  villes visitables.
extern unsigned char team_tl; // .dsb 1
//  np; // nombre d'ingredients de la potion
extern unsigned char team_np; // .dsb 1
//  nf; // nombre de fuites
extern unsigned char team_nf; // .dsb 1
//  pm; // potion faite ?
extern unsigned char team_pm; // .dsb 1

//  out=1; // sur la carte ?
extern unsigned char team_out; // .dsb 1

//  ca = 0; // case courante
extern unsigned char team_ca; // .dsb 1
// io_needed = 1;
extern unsigned char team_io_needed; // .dsb 1

// 243 bytes

//	char *ptr; tmp0
// version;
extern unsigned char team_version; // .dsb 1

// 244 bytes

// .align 256
// sad[6]; // sac à dos
extern unsigned char character_sad[]; // .dsb 6*8
// sp[8]; // sorts
extern unsigned char character_sp[]; // .dsb 6*8



// cles[9][4]; // trousseau de clefs (36 octets)
extern unsigned char team_cles[]; //  .dsb 9*4

// combats_coffres[9][5]; // combats et coffres sous forme de tableaux de bits
extern unsigned char team_combats_coffres[]; // .dsb 9*5

void loadTextesItems()
{
	char filename[16];
	char ret, a;
	char *ptr;
	memset(filename, 0, 16);
	sprintf(filename, "TITEMS.BIN", ville);
	//printf("Chargement de %s\n", filename);
    ret = DiscLoad(filename);
    //printf("Retour %d\n", ret);
    if (ret==0) {
		ptr = (char*)0xa000;
		//printf("Nb NPC : %d\n", pmax);
		loadTexts(ptr, textesItems);
		#ifdef debug
		printf("Fin des textes, on utilise %d caracteres sur %d\n",
			(ptTextes-textes), TMAX);
		puts("taper sur une touche pour continuer\n");
        a = (char)getchar();
        #endif
	}
}

void printTeam(void)
{
	char i,encre;
	attribAtXY(0,20,A_FWWHITE);
	attribAtXY(1,20,A_BGRED); // fond rouge
	printAtXY(2,20," PERSONNAGE    CASTE     PV   ET  CA");
	for(i=0;i<6;i++) {
		switch(characters[i].cp) {
			case 1:
				encre = A_FWYELLOW; // jaune
				break;
			case 2:
				encre = A_FWWHITE; // blanc
				break;
			case 3:
				encre = A_FWCYAN; // cyan
				break;
			case 4:
				encre = A_FWMAGENTA; // magenta
				break;
			case 5:
				encre = A_FWBLUE; // bleu
				break;
			default:
				encre = A_FWGREEN; // bleu
		}
		if (characters[i].ok==4) encre = A_FWRED;
		// efface la ligne précédente
		printAtXY (2,21+i, "                                     ");
		attribAtXY(1,21+i,encre);
		printAtXY (2,21+i, itoa(i+1));
		printAtXY (4,21+i, characters[i].nom);
		if (characters[i].ok==1) {
			printAtXY (17,21+i,classe[characters[i].cp-1]);
		} else {
			printAtXY (17,21+i,etat[characters[i].ok-1]);
		}
		printAtXY (27,21+i, itoa(characters[i].pv));
		printAtXY (32,21+i, itoa(characters[i].et));
		printAtXY (37,21+i, itoa(characters[i].ca));
	}
}

void inspect(void)
{
	char a, i, j;
	char titre[32];

	printTitle(8,4, A_BGRED, "INSPECTER QUEL HEROS ? ", 23);
	while(1) {
		a = get();
		if (a<'1' || a>'6')
			ping(); // ping si pas correct
		else
			break; // correct : on sort
	}
	cls();
	printFrame(23);
	i = a - '1';
	// construction du nom/titre
	strcpy(titre, " < ");
	strcat(titre, characters[i].nom);
	if(characters[i].mp != 1) {
		strcat(titre, " ");
		strcat(titre, maisons[characters[i].mp-2]);
	}
	strcat(titre, " > ");
	j = strlen(titre);
	a = (31-j)/2 + 4;
	// affichage du titre
	printTitle(a,2, A_BGRED, titre, j);
	// affichage classe, niv, xp
	printAtXY(5,  4, "Carr :");
	printAtXY(11, 4, classe[characters[i].cp-1]);
	printAtXY(22, 4, "Niv:");
	printAtXY(27, 4, itoa(characters[i].ni));
	printAtXY(29, 4, "EXP:");
	printAtXY(33, 4, itoa(characters[i].xp));

	// affichage santé, pv
	printAtXY(5,  6, "Sant{:");
	printAtXY(11, 6, etat[characters[i].ok-1]);
	printAtXY(22, 6, "PV :");
	printAtXY(27, 6, itoa(characters[i].et));
	printAtXY(30, 6, "/");
	printAtXY(32, 6, itoa(characters[i].pv));
	// affichage bourse
	printAtXY(5,  8, "Bourse:");
	printAtXY(13, 8, itoa(characters[i].ri*10));
	printAtXY(21, 8, "Cerfs d'Argent");

	// affichage de l'équipement porté
	printAtXY(5,  10, "Arme D:");
	if (characters[i].wr != 0)
		printAtXY(13, 10, textesItems[characters[i].wr-1]);

	printAtXY(5,  11, "Arme G:");
	if (characters[i].wl != 0)
		printAtXY(13, 11, textesItems[characters[i].wl-1]);

	printAtXY(5,  12, "Animal:");
	if (characters[i].bt != 0)
		printAtXY(13, 12, textesItems[characters[i].bt-1]);

	printAtXY(5,  13, "Armure:");
	if (characters[i].pt != 0)
		printAtXY(13, 13, textesItems[characters[i].pt-1]);
	printAtXY(29, 13, "CA:");
	printAtXY(33, 13, itoa(characters[i].ca));

	// affiche les caracs
	printTitle(4,15, A_BGRED, "CC  CT  Fo  Ag  In  FM ", 23);
	printAtXY(7,16, itoa(characters[i].cc));
	printAtXY(11,16, itoa(characters[i].ct));
	printAtXY(15,16, itoa(characters[i].fo));
	printAtXY(19,16, itoa(characters[i].ag));
	printAtXY(23,16, itoa(characters[i].in));
	printAtXY(27,16, itoa(characters[i].fm));
	// affichage du sac à dos
	for(j=0;j<6;j++) {
		printAtXY(5,18+j, itoa(j+1));
		if (characters[i].sad[j]!=0) {
			if (characters[i].sad[j]-1<nbTextes)
			    printAtXY(8,18+j, textesItems[characters[i].sad[j]-1]);
			else
				printAtXY(8,18+j, "objet bugge");
		} else {
			printAtXY(8,18+j, "..............");
		}
	}
	// les morts et les paralysés ne peuvent pas lancer de sorts!
	if (characters[i].cp>3 && characters[i].ok<3)
		printTitle(10,25, A_BGRED, " <ESPACE> : SORTS ", 18);
	else
		printTitle(10,25, A_BGRED, " <ESPACE> : RETOUR", 18);
	printTitle(4,26, A_BGBLUE, " DONNER :  ", 11);
	printTitle(16,26, A_BGRED, " A)rgent O)bjet ? ", 17);
//	while(1) {
//		a = get();
//		if (a=='A') {
//			money(i);
//			break;
//		} else if (a=='O') {
//			items(i);
//			break;
//		} else if (a==' ') {
//			if (characters[i].cp>3 && characters[i].ok<3)
//				spells(i);
//			break;
//		} else
//			ping();
//	}
}


void printTeamFull(void)
{
	char i, encre, a;
	cls();
	ink(eencre[ville-1]);
	// affichage des titres
	printTitle(8,2, A_BGRED, " * TYRANN 3 - EQUIPE * ", 23);
	printTitle(2,4, A_BGRED, "PERSONNAGES MAISON    CARRIERE NIV ", 35);
	printTitle(2,5, A_BGBLUE, " Argent      CC CT Fo Ag In FM PV  ", 35);
	// affichage persos
	for(i=0;i<6;i++) {
		switch(characters[i].cp) {
			case 1:
				encre = A_FWYELLOW; // jaune
				break;
			case 2:
				encre = A_FWWHITE; // blanc
				break;
			case 3:
				encre = A_FWCYAN; // cyan
				break;
			case 4:
				encre = A_FWMAGENTA; // magenta
				break;
			case 5:
				encre = A_FWBLUE; // bleu
				break;
			default:
				encre = A_FWGREEN; // bleu
		}
		attribAtXY(1,7+3*i,encre);
		printAtXY (3,7+3*i, itoa(i+1));
		printAtXY (5,7+3*i, characters[i].nom);
		if (characters[i].mp != 1) printAtXY (17,7+3*i, maisons[characters[i].mp-2]);
		printAtXY (27,7+3*i, classe[characters[i].cp-1]);
		printAtXY (37,7+3*i, itoa(characters[i].ni));
		printAtXY (6,7+3*i+1, itoa(characters[i].ri));
		printAtXY (13,7+3*i+1, "0 se");
		printAtXY (18,7+3*i+1, itoa(characters[i].cc));
		printAtXY (21,7+3*i+1, itoa(characters[i].ct));
		printAtXY (24,7+3*i+1, itoa(characters[i].fo));
		printAtXY (27,7+3*i+1, itoa(characters[i].ag));
		printAtXY (30,7+3*i+1, itoa(characters[i].in));
		printAtXY (33,7+3*i+1, itoa(characters[i].fm));
		printAtXY (36,7+3*i+1, itoa(characters[i].pv));
	}
	printTitle(2,25, A_BGBLUE, " Argent      CC CT Fo Ag In FM PV  ", 35);
	printTitle(2,26, A_BGRED, "            < ESPACE >            ", 34);
	while(1) {
		a = get();
		if (a==' ') {
			break;
		} else
			ping();
	}
}

extern void load_t4_characters();

void main()
{
		io_needed=1;
        loadCharacters();
        team_io_needed=0;
        load_t4_characters();

        loadTextesItems();
        printTeamFull();
        inspect();

        // printT4TeamFull();
}

