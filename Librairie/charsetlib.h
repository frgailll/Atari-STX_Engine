/*! 
 * \file charsetlib.h
 * \author Laurent Gaillard
 * \date 26/10/2020
 * \version 0.01
 *			
 * \note charsetlib.h est le fichier de definition d'affichage des caractéres graphiques definis par l'utilisateur
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _CHARSETLIBH_
#define _CHARSETLIBH_

#include "src\type.h"

/*! 
 * \defgroup Charsetlib Gestion des caractères en mode graphique
 * \{
 */
 
 
 
/*!
 * \brief Permet de charger en mémoire un fichier de charset au format .CRS
 * \param Path : Pointeur sur le chemin d'accés et le nom du fichier CRS
 * \return -1 en cas d'erreur, sinon 0
 */
short STX_loadcharset(char *Path);


/*!
 * \brief decharge les charset et libère la mémoire
 */
void STX_Unloadcharset();


/*!
 * \brief Affiche une chaine de caractère en utilisant les charsets
 * \param carx : Coordonnée X en caractère comprise entre 0 et 39
 * \param cary : Coordonnée Y en caractère comprise entre 0 et 24
 * \param color : Couleur d'affichage de 0 à 15
 * \param mode : Trois mode d'affichage disponible (remplacement, transparence, effacement)
 * \param sens : affichage horizontalement (de la gauche vers la droite) ou verticalement (de bas en haut)
 * \param *text : pointeur sur une chaine de caractère à 0 terminale
 *
 * \sa STX_displaymode, STX_displaysens
 */
void STX_printstring(unsigned short carx, unsigned short cary, unsigned char color, STX_displaymode mode, STX_displaysens sens, char *text);


/*!
 * \brief Convertie en une chaine de caractère de 2 digit une valeur decimal d'un octet (0 à 99)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 3 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_charto2digit(char value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 3 digit une valeur decimal d'un mot (0 à 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 4 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_shortto3digit(short value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 4 digit une valeur decimal d'un mot (0 à 9 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 5 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_shortto4digit(short value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 5 digit une valeur decimal d'un mot long (0 à 99 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 6 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_longto5digit(long int value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 6 digit une valeur decimal d'un mot long (0 à 999 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 7 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_longto6digit(long int value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 7 digit une valeur decimal d'un mot long (0 à 9 999 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 8 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_longto7digit(long int value, char *String, bool showzero);


/*!
 * \brief Convertie en une chaine de caractère de 8 digit une valeur decimal d'un mot long (0 à 99 999 999)
 * \param value : valeur à convertir en chaine de caractère
 * \param String : pointeur sur un tableau de 9 char
 * \param showzero : si true, affiche les zeros non significatif
 */
void STX_longto8digit(long int value, char *String, bool showzero);




/*! \} 
 */

#endif