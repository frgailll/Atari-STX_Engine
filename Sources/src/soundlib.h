/*! 
 * \file soundlib.h
 * \author Laurent Gaillard
 * \date 09/05/2019
 * \version 0.01
 *			
 * \note soundlib.h est le fichier de definition du moteur pour les effet audio pour Atari ST
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/

#ifndef _SOUNDLIBH_
#define _SOUNDLIBH_

#include "src\type.h"

/*! 
 * \defgroup Soundlib Control des effets audio et de la lecture d'echantillons DMA
 * \{
 */

/*!
 * \brief Permet de fixer la base de temps du timer en charge des effets audios en interruption
 * \param div : valeur correspondant au diviseur interne du timer
 * \param compteur : valeur de compteur du timer
 * \sa STX_sndtimerdiv
 */
void STX_setsoundtimer(STX_sndtimerdiv div, unsigned char compteur); 


/*!
 * \brief Permet de charger en mémoire un fichier d'effet audio avec l'extension .AEF
 * \param Path : Pointeur sur le chemin d'accés et le nom du fichier AEF
 * \return Pointeur sur l'adresse de stockage du fichier en mémoire, sinon 0 en cas d'erreur
 */
long int *STX_loadsoundeffect(char *Path);


/*!
 * \brief Permet de décharger de la mémoire un fichier d'effet audio .AEF
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 */
void STX_unloadsoundeffect(long int *memory);


/*!
 * \brief Permet de jouer un effet audio chargé en mémoire sur le player 1
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 * \param boucle : si true, joue l'effet audio en boucle
 */
void STX_playsound1(long int *memory, bool boucle);


/*!
 * \brief Permet de jouer un effet audio chargé en mémoire sur le player 2
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 * \param boucle : si true, joue l'effet audio en boucle
 */
void STX_playsound2(long int *memory, bool boucle);


/*!
 * \brief Permet de jouer un effet audio chargé en mémoire sur le player 3
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 * \param boucle : si true, joue l'effet audio en boucle
 */
void STX_playsound3(long int *memory, bool boucle);


/*!
 * \brief Stop le player 1
 */
void STX_Stopsound1(void);


/*!
 * \brief Stop le player 2
 */
void STX_Stopsound2(void);


/*!
 * \brief Stop le player 3
 */
void STX_Stopsound3(void);


/*!
 * \brief Coupe tous les players audio en cours
 */
void STX_mutesound();


/*!
 * \brief Permet de charger en mémoire un fichier d'echantillons .ADS pour la lecture DMA
 * \param Path : Pointeur sur le chemin d'accés et le nom du fichier ADS
 * \return Pointeur sur l'adresse de stockage du fichier en mémoire, sinon 0 en cas d'erreur
 */
long int *STX_loaddmasample(char *Path);


/*!
 * \brief Permet de décharger de la mémoire un fichier .ADS d'echantillons DMA
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 */
void STX_unloaddmasample(long int *memory);


/*!
 * \brief Permet de jouer un fichier .ADS d'echantillons DMA
 * \param memory : Pointeur sur l'adresse de stockage du fichier en mémoire
 * \param boucle : si true, joue les echantillons en boucle
 */
void STX_playdmasample(long int *memory, bool boucle);


/*!
 * \brief Stop un fichier .ADS d'echantillons DMA en cours
 */
void STX_stopdmasample();


/*!
 * \brief Active l'appel de la fonction STX_dmasampleendframe() en fin de lecture d'echantillons DMA
 */
void STX_setdmasampleinterrupt(); 


/*!
 * \brief Désactive l'appel de la fonction STX_dmasampleendframe() en fin de lecture d'echantillons DMA
 */
void STX_removedmasampleinterrupt();


/*!
 * \brief Fonction appeleé à la fin de chaque lecture d'echantillons DMA si STX_setdmasampleinterrupt() aà été appelée auparavent.
 * \
 * \note Cette fonction doit être impérativement implémementée dans le code C, dans le cas contraire une erreur de linkage interviendra.
 */
void STX_dmasampleendframe();

/*! \} 
 */


#endif