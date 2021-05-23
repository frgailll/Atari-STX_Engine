/*! 
 * \file imagelib.h
 * \author Laurent Gaillard
 * \date 27/02/2020
 * \version 0.01
 *			
 * \note Le fichier imagelib.h cntient la definition des fonctions de gestion des images
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _IMAGELIBH_
#define _IMAGELIBH_

/*! 
 * \defgroup Imagelib Gestion des images
 * \{
 */


#define     STX_PICTURESIZE     32000                   /*!< Taille d'une image en m�moire */


/*!
 * \brief Charge en memoire une image Neochrome, degas ou degaselite
 * \param type : Type de l'image à charger
 * \param *path : pointeur sur le nom et le chemi d'accés au fichier
 * \param memory : Adresse de stockage de l'image en mémoire
 * \return 0 si pas d'erreur, sinon valeur négative
 * \sa STX_picturetype
 */
int STX_loadpicture(STX_picturetype type,char *path,long int *memory);


/*!
 * \brief copie l'image ou une partie de l'image de la memoire source à une position dans une memoire destination
 * \param srcaddr : Adresse source de stockage de l'image
 * \param destaddr : Adresse de destination de copie de l'image
 * \param src_x : Position X dans l'image de la zone à blitter
 * \param src_y : Position Y dans l'image de la zone à blitter
 * \param src_width : Largeur de la zone à blitter
 * \param src_height : Hauteur de la zone à blitter
 * \param dest_x : Position X de l'image dans la mémoire de destination
 * \param dest_y : Position Y de l'image dans la mémoire de destination
 */
void STX_blitloadedpicture(long int *srcaddr, long int *destaddr, unsigned short src_x, unsigned short src_y, unsigned short src_width,unsigned short src_height, unsigned short dest_x,unsigned short dest_y);


/*!
 * \brief affiche un motif de spriteset en tant qu'image, pas de mémorisation de l'arriére plan
 * \param motifid : numéro du motif dans la fichier
 * \param posx : coordonnée d'affichage X à l'écran
 * \param posy : coordonnée d'affichage Y à l'écran
 * \param mode : mode d'affichage Replace, transparent ou efface
 *
 * \sa STX_displaymode
 */
void STX_displayspriteset(unsigned short motifid, unsigned short posx, unsigned short posy, STX_displaymode mode);


/*! \} 
 */
 
#endif