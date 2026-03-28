#include <lib.h>

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

extern unsigned char * ADDR_SCR;
extern unsigned char NUM_TUILE;

void wait(unsigned int val)
{
	char i;
	while(val--) {
		i=100;
		while(i--);
	}
}

/**
 * main(): Point d'entrée du programme
 */  
void main() {
	int l = 0;
	int c = 0;
	int x = 8;
	int y = 3;
	char fin = 0;
	char keycode = 0;

    printf("Touche\n");
    get();
    impl_car();
	hires_et_atributs();
	while(!fin) {
		c=0;
		l=0;
		ADDR_SCR = (unsigned char *)0xa003;
		NUM_TUILE = 0x10;
		while(l != 8) {
			init_scr_hires();
			if (c == x && l == y) {
				NUM_TUILE = 0x4b;
				printf("(X,Y) = (%d,%d) adr = %x\n",x,y,ADDR_SCR);
			} else {
				NUM_TUILE = 0x10;
			}
			cherche_et_aff_tuile();
			ADDR_SCR+=2;
			c++;
			if(c==18) {
				c=0;
				l++;
				ADDR_SCR+=40*11+4;
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
                if(x < 17) x++;
                break;
            case 'i':
            case 'I':
            case KEY_UP:
                if(y > 0) y--;
                break;
            case 'k':
            case 'K':
            case KEY_DOWN:
                if(y < 7) y++;
                break;
        }

	}
}

