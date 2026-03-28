#include <lib.h>

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
	ADDR_SCR = (unsigned char *)0xa003;
	NUM_TUILE = 0;

    printf("Touche\n");
    get();
    impl_car();
	hires_et_atributs();
	while(NUM_TUILE != 0x4e) {
    	init_scr_hires();
    	cherche_et_aff_tuile();
   		printf("Adr %x, Tuile %x\n", ADDR_SCR, NUM_TUILE);
		NUM_TUILE++;
		ADDR_SCR+=2;
		c++;
		if(c==18) {
			c=0;
			l++;
			ADDR_SCR+=40*12+4;
			printf("Touche\n");
    		get();
		}
	}
}

