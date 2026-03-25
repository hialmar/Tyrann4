extern void init_scr_hires();
extern void test_verif(unsigned char *adr);

/**
 * main(): Point d'entrée du programme
 */  
void main() {
    printf("Avant init scr hires \n");
    init_scr_hires();
    printf("Apres init scr hires \n");
    test_verif((unsigned char*)0xa002);
}

