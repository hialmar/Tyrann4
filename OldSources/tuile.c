#define KEY_LEFT  8
#define KEY_RIGHT 9
#define KEY_DOWN  10
#define KEY_UP    11
#define KEY_SPACE ' '
#define KEY_ESC   27

extern void init_scr_hires();
extern void impl_car();
extern void cherche_et_aff_tuile();
extern void hires_et_atributs();
extern void hideCursor();
extern void showCursor();

extern unsigned char * ADDR_SCR;
extern unsigned char NUM_TUILE;


/* ================== TYPES ================== */
typedef unsigned char uchar;
typedef unsigned char bool; // boolean


/* ================== CONSTANTES ================== */

#ifndef NULL
#define NULL ((void *) 0)
#endif

#ifndef FALSE
#define FALSE ((bool) 0)
#define TRUE  (!FALSE)
#endif

// Adresse de début de l'écran HIRES
#define ADR_SCREEN 0xA003

// Dimensions de l'écran en 1/4 de tuiles
#define SCREEN_WIDTH  40
#define SCREEN_HEIGHT 28

// Dimensions X et Y de la fenêtre d'affichage
#define WIN_XSIZE  18
#define WIN_YSIZE  8

// Coordonnées du coin supérieur gauche de la fenêtre d'affichage
#define WX  0
#define WY  0

// Dimensions X et Y de la carte
#define MAP_XSIZE   100
#define MAP_YSIZE   100

// Divisions et multiplications entières par multiples de 2
// en utilisant des opérations de décalage de bits
// NB: ces macros  n'ont d'intérêt que sur des arguments qui sont des VARIABLES
//     En effet les calculs sur des littéraux ou des constantes déclarées par #define
//     sont normalement effectués dès la compilation pour simplifier la valeur
//     des expressions (à confirmer peut-être pour lcc ??)
//     
#define div2(x) ((x) >> 1)
#define div4(x) ((x) >> 2)
#define div8(x) ((x) >> 3)
#define mul2(x) ((x) << 1)
#define mul4(x) ((x) << 2)
#define mul8(x) ((x) << 3)


// Caractères utilisés pour la carte, le joueur, et le contour de la fenêtre
#define EMPTY 0x10    // herbe
#define WALL  0x00    // haute mer
#define WATER 0x01    // mer
#define HILL1 0x11    // montagne
#define HILL2 0x12    // montagne 2
#define TREE  0x15    // arbre

#define PLAYER 0x4b   // perso

char map[MAP_YSIZE][MAP_XSIZE];

void wait(unsigned int val)
{
	char i;
	while(val--) {
		i=100;
		while(i--);
	}
}


	uchar x = 8;
	uchar y = 3;

/**
 * main(): Point d'entrée du programme
 */  
void main() {
	uchar l = 0;
	uchar c = 0;
	char fin = 0;
	char keycode = 0;
	uchar px,py;   // coordonnees RELATIVES du personnage dans la fenêtre d'affichage
    uchar xv, yv;  // coordonnées de départ (offset) de la map pour l'affichage dans la fenêtre
    // optimisation v1.1: current_cell_addr = adresse case courante du tableau de la carte à afficher,
    //      initialisée à chaque "balayage" avec la coordonnée du coin supérieur gauche 
    //      de la partie visible du tableau de la carte à afficher
    char *current_cell_addr; // optimisation v1.1

	hideCursor();
	init_map();
    printf("Touche\n");
    get();
    impl_car();
	hires_et_atributs();
	while(!fin) {
		// Calcul coordonnées coin supérieur gauche (xv, yv) de la partie de la carte à afficher
        // en fonction des coordonnées (x,y) courantes du 'joueur'
        if(x <= WIN_XSIZE/2) xv = 0; else xv = x - WIN_XSIZE/2;
        if(y <= WIN_YSIZE/2) yv = 0; else yv = y - WIN_YSIZE/2;
        //  Corrections pour affichage extrémités droite et inferieure de la carte
        if(x >= MAP_XSIZE-WIN_XSIZE/2) xv = MAP_XSIZE-WIN_XSIZE;
        if(y >= MAP_YSIZE-WIN_YSIZE/2) yv = MAP_YSIZE-WIN_YSIZE;
		current_cell_addr = &map[yv][xv]; // optimisation v1.1
		// Affichage personnage: PX et PY sont les coordonnees relatives
        if(x > WIN_XSIZE/2) px = x - xv; else px = x;
        if(y > WIN_YSIZE/2) py = y - yv; else py = y;
		c=0;
		l=0;
		ADDR_SCR = (unsigned char *)0xa003;
		NUM_TUILE = 0x10;
		while(l != WIN_YSIZE) {
			init_scr_hires();
			if (c == px && l == py) {
				NUM_TUILE = 0x4b;
				// printf("(X,Y) = (%d,%d) adr = %x\n",x,y,ADDR_SCR);
			} else {
				NUM_TUILE = *current_cell_addr;
			}
			cherche_et_aff_tuile();
			ADDR_SCR+=2;
			current_cell_addr++;
			c++;
			if(c==WIN_XSIZE) {
				c=0;
				l++;
				ADDR_SCR+=40*11+4;
				current_cell_addr += (MAP_YSIZE - WIN_XSIZE); // optimisation v1.1
			}
		}
		
        // Gestion du clavier pour les déplacements et la 'fin de partie'
        //keycode = get_valid_keypress();
        keycode = key(); // key n'attend pas
        switch(keycode) {
            case KEY_ESC:
            case 'e':
            case 'E':
                fin = 1;
                break;
            case 'j':
            case 'J':
            case KEY_LEFT:
                if(x > 0) x--;
                break;
            case 'l':
            case 'L':
            case KEY_RIGHT:
                if(x < (MAP_XSIZE-1)) x++;
                break;
            case 'i':
            case 'I':
            case KEY_UP:
                if(y > 0) y--;
                break;
            case 'k':
            case 'K':
            case KEY_DOWN:
                if(y < (MAP_YSIZE-1)) y++;
                break;
        }
	}
	showCursor();
}



/** 
 * init_map(): initialisation du tableau représentant la carte 
 */
void init_map() {
    uchar i, j, k, kx, ky, n;
    uchar xmax_inside; // coord x max entre les murs d'enceinte
    uchar ymax_inside; // coord y max entre les murs d'enceinte
    char *cell_addr1, *cell_addr2; // optimisation v1.2

    // ceinturer la carte de murs ('#') et la remplir de blancs (espaces)
    printf("Ajout des murs d'enceinte...\n");

    // Murs horizontaux haut & bas
    cell_addr1 = &map[0][0];
    cell_addr2 = &map[MAP_YSIZE-1][0];
    for(i=0; i < MAP_XSIZE; i++) {
        // map[0][i] = WALL;
        *cell_addr1++ = WALL;
        //map[MAP_YSIZE-1][i] = WALL;
        *cell_addr2++ = WALL;
    }

    // Murs verticaux gauche & droit
    cell_addr1 = &map[0][0];
    cell_addr2 = &map[0][MAP_XSIZE-1];
    for(i=0; i < MAP_YSIZE; i++) {
        //map[i][0] = WALL;
        *cell_addr1 = WALL;
        cell_addr1 += MAP_XSIZE;
        //map[i][MAP_XSIZE-1] = WALL;
        *cell_addr2 = WALL;
        cell_addr2 += MAP_XSIZE;

    }

    // Initialiser l'intérieur de la carte avec des blancs (= cases 'vides')
    printf("Remplissage de la carte de blancs...\n");
    #define YMAX_INSIDE (MAP_YSIZE-1)
    #define XMAX_INSIDE (MAP_XSIZE-1)

    cell_addr1 = &map[1][1];
    for(i = 1; i < YMAX_INSIDE; i++) {
        for(j = 1; j < XMAX_INSIDE; j++) {
            //map[i][j] = EMPTY;
            *cell_addr1++ = EMPTY;
        }
        cell_addr1 += 2; // sauter case XMAX et case 0 ligne suivante
    }

    // Ajouter de 100 a 150 arbres
    // (ATTENTION ici on ne peut pas dépasser 255 car n est un "uchar",
    //  et la fonction rnd() elle-même attend un uchar en parametre !!!)
    n = rnd(100)+51; // ne marche pas si #include <lib.h>
    //n = 230;
    printf("Ajout de %d arbres...\n", n);
    for(k = 0; k < n; k++) {
        map[rnd(MAP_YSIZE-3)+1][rnd(MAP_XSIZE-3)+1] = TREE;
    }
    // Ajouter de 60 a 100 montagnes
   n = rnd(60)+41; // ne marche pas si #include <lib.h>
   //n = 71;
    printf("Ajout de %d montagnes...\n", n);
    for(k = 0; k < n; k++) {
        kx = rnd(MAP_XSIZE-4)+1;
        ky = rnd(MAP_YSIZE-2)+1;
        //map[ky][kx++] = HILL1;
        //map[ky][kx]   = HILL2; 
        cell_addr1 = &map[ky][kx];
        *cell_addr1++ = HILL1;
        *cell_addr1   = HILL2; 
    }

    // Ajouter de 30 a 50 lacs de 4x3 cases
    n = rnd(30)+21; // ne marche pas si #include <lib.h>
    //n = 41;
    printf("Ajout de %d lacs...\n", n);
    for(k = 0; k < n; k++) {
        kx = rnd(MAP_XSIZE-8)+1;
        ky = rnd(MAP_YSIZE-5)+1;

        // - 1e ligne du lac
        //map[ky][kx] = WATER; map[ky][kx+1] = WATER; map[ky][kx+2] = WATER;
        //ky++; // Incrémmenter ky pour la ligne suivante
        //kx++; // et incrémenter aussi kx pour décaler d'une case à droite
        cell_addr1 = &map[ky][kx];
        *cell_addr1++ = WATER; *cell_addr1++ = WATER; *cell_addr1++ = WATER; *cell_addr1++ = WATER; 

        // - 2e ligne du lac
        //map[ky][kx] = WATER; map[ky][kx+1] = WATER; map[ky][kx+2] = WATER;
        //ky++; // Incrémmenter ky pour la ligne suivante
        //kx++; // et incrémenter aussi kx pour décaler d'une case à droite
        cell_addr1 += MAP_XSIZE; 
        // on est déjà décalé d'une case à droite après passage à la ligne à cause du dernier 'cell_addr1++'
        *cell_addr1-- = WATER; *cell_addr1-- = WATER; *cell_addr1-- = WATER; *cell_addr1++ = WATER;
        // noter le dernier "cell_addr1++" pour se remettre en décalage d'une cellule à droite

        // - 3e ligne du lac
        //map[ky][kx] = WATER; map[ky][kx+1] = WATER; map[ky][kx+2] = WATER;
        cell_addr1 += MAP_XSIZE; 
        *cell_addr1++ = WATER; *cell_addr1++ = WATER; *cell_addr1++ = WATER; *cell_addr1 = WATER; 
    }
}


/** 
 * rnd(uchar max) : renvoie un nombre aléatoire (entier positif) dans l'intervalle  [0...max[
 *  arg max: borne supérieure délimitant l'intervalle des nombres aléatoires générés
 *           (type unsigned char ==> valeur maxi : 255)
 */
uchar rnd(uchar max) {
    // ATTENTION - ne PAS inclure <lib.h> sinon ça fait bugger la définition de rand()
    // qui renvoie systématiquement zéro !!
    uchar val = (uchar) (rand()/(32768/max));
    //printf("rnd(%d)=%d -- press space  \n", max, val); wait_spacekey();
    return val;
}
