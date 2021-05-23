/*! 
 * \file StGfxEngine.h
 * \author Laurent Gaillard
 * \date 27/12/2019
 * \version 0.01
 *			
 * \note StGfxEngine.h est le fichier de definition du moteur graphique pour Atari ST
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/

#ifndef _STGFXENGINEH_
#define _STGFXENGINEH_


#include "src\type.h"
#include "src\spritelib.h"
#include "src\imagelib.h"
#include "src\tileslib.h"
#include "src\soundlib.h"
#include "src\controllib.h"
#include "src\eventlib.h"
#include "src\charsetlib.h"


/*! 
 * \defgroup STX_Engine Initialisation du moteur 2D
 * \{
 */
                  
/*!
 * \brief Permet l'initialisation les bibliothéques composant la STGFXengine, reservation mémoire, sauvegarde de la palette de couleur d'origine, modification de la frequence d'affichage
 * \param freqv : fixe la fréquence verticale d'affichage
 * \param nbsprites : Nombre de sprites qui seront utilisés dans le jeu
 * \return 0 si l'initialisation c'est correctement passée sinon valeur négative
 *
 * \note Cette fonction met le ST en mode Superviseur et doit etre utilisée en premier afin d'initialiser les stuctures de données
 * \sa STX_freqverticale
 */
short STX_initstxengine(STX_freqverticale freqv, unsigned short nbsprites);


/*!
 * \brief Permet la désinitialisation les bibliothéques composant la STGFXengine en rendant le systéme dans l'état où il était.
 * \return 0 si la déinitialisation c'est correctement passée sinon valeur négative
 *
 * \note Cette fonction remet le ST en mode Utilisateur et doit être utilisée avant de quitter le jeu
 */
short STX_uninitstxengine(void);


/*!
 * \brief Permet de fixer les valeurs de clipping de l'écran
 * \param xmin : Valeur minimum de X (clipping à gauche de l'écran)
 * \param xmax : Valeur maximum de X (clipping à droite de l'écran)
 * \param ymin : Valeur minimum de Y (clipping en haut de l'écran)
 * \param ymax : Valeur minimum de Y (clipping en bas de l'écran)
 * \return 0 si mauvais paramétres X et Y, 1 si parametre X correcte et mauvais parametre Y, 2 si parametre Y correcte et mauvais parametre X, 3 si parametre X et Y correctes
 *
 * \note les valeurs par defaut sont : Xmin=0, Xmax=319, Ymin=0, Ymax=199
 */
short STX_setscreenclipping(unsigned short xmin, unsigned short xmax, unsigned short ymin, unsigned short ymax);


/*!
 * \brief Efface l'écran logique de son contenu
 */
void STX_clearlogscreen(void);


/*!
 * \brief assure l'effacement des sprites et leur réaffichage suivant les swap d'écrans pilotés par la routine VBL. La fréquence de swap des écrans est defini au moment de l'initialisation.
 * \param ViewCycle : si true, colorie en rouge les lignes écran correspondant à l'occupation du processeur, colorie en vert les lignes écran correspondant au temps processeur libre
 * \return nombre d'image sauter durant un affichage ou un traitement
 *
 * \sa STX_initstxengine
 */
unsigned char STX_swapscreen(bool ViewCycle);


/*!
 * \brief Retourne l'adresse de l'écran logique actuelle mémorisé dans la stgfx. Cette adresse sera modifié aprés un swapscreen()
 */
long int *STX_getworkscreen();


/*!
 * \brief Modifie une couleur affiché à l'écran
 * \param colornum : numéro de la couleur concerné compris entre 0 et 15
 * \param colorvalue : Valeur de la nouvelle couleur (voire note pour le codage)
 *
 * \note codage couleur STF : bits 10-9-8 = valeur rouge, bits 6-5-4 = valeur verte, bits 2-1-0 = valeur bleu
 * \note codage couleur STE : bits 10-9-8-11 = valeur rouge, bits 6-5-4-7 = valeur verte, bits 2-1-0-3 = valeur bleu
 */
void STX_changecolor(unsigned short colornum, unsigned short colorvalue);


/*!
 * \brief Indique le numéro de version de la STGFX Engine
 * \return pointeur sur une chaine de caractère retournant le numéro de version
 */
char *STX_version();


/*!
 * \brief Renseigne sur le type de machine Atari 16 bits sur lequel s'execute le programme
 * \return type de machine
 *
 * \sa STX_machine16
 */
STX_machine16 STX_machinetype();



/*!
 * \brief Indique la présence ou non d'un blitter Hardware dans la machine à partir du T0S 1.02
 * \return True si un blittert hardware existe
 */
bool STX_blitterpresent();



/*!
 * \brief Retourne un pointeur de caractére sur la version du TOS
 */
char *STX_gettosversion();


/*!
 * \brief Retourne une valeur pseudo-aléatoire sur 24 bits
 */
unsigned long int STX_randomize();


/*!
 * \brief Attends le retour de la VBL, puis continue
 */
void STX_waitvbl(void);

/*! \} 
 */


#endif