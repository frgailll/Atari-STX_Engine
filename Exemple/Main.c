#include "StGfxEngine.h"


/* Squelette d'un programme avec la STX_Engine */

// fonction obligatoire, à mettre dans un de vos fichier C
// cette fonction est appeler à la fin de la lecture d'un audio DMA
void STX_dmasampleendframe()                                           
{
    
}

// programme principal
int main(int argc, char* argv[])
{
    short result;
    
    result = STX_initstxengine(FV50,1);                                 // initialisation STX avec Fréquence de 50Hz et 1 Sprite minimum
    
    while(1)                                                            // boucle infini du jeu
    {
        // placer votre code ici
        
        result=STX_swapscreen(FALSE);                                   // Attente VBL et inversion écran logique avec écran physique, effacement sprite nouveau écran logique
    }
    
    result = STX_uninitstxengine();                                     // libération des ressources de la STX
}