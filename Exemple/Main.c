#include "StGfxEngine.h"


/* Squelette d'un programme avec la STX_Engine */

// fonction obligatoire, � mettre dans un de vos fichier C
// cette fonction est appeler � la fin de la lecture d'un audio DMA
void STX_dmasampleendframe()                                           
{
    
}

// programme principal
int main(int argc, char* argv[])
{
    short result;
    
    result = STX_initstxengine(FV50,1);                                 // initialisation STX avec Fr�quence de 50Hz et 1 Sprite minimum
    
    while(1)                                                            // boucle infini du jeu
    {
        // placer votre code ici
        
        result=STX_swapscreen(FALSE);                                   // Attente VBL et inversion �cran logique avec �cran physique, effacement sprite nouveau �cran logique
    }
    
    result = STX_uninitstxengine();                                     // lib�ration des ressources de la STX
}