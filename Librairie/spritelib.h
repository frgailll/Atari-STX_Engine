/*! 
 * \file Spritelib.h
 * \author Laurent Gaillard
 * \date 27/12/2019
 * \version 0.01
 *			
 * \note Spritelib.h est le fichier de definition de la librairie de gestion des sprites écrite en assembleur
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _SPRITELIBH_
#define _SPRITELIBH_


/*! 
 * \defgroup Spritelib Gestion des sprites
 * \{
 */

/*!
 * \brief Permet de charger en mémoire les motifs des sprites et mask crées avec le logiciel SPRITEVC.PRG
 * \return 0 si les données ont bien été chargées en memoire, sinon retourne une valeur négative
 */
short STX_loadspriteset(char *Path);


/*!
 * \brief Permet de detruires tous les sprites, les structures de données sont remises à zéro
 */
void STX_clearallsprites(void);


/*!
 * \brief Permet de definir les attributs à donner aux sprites, fixer le motif utiliser, definir sa position et sa vitesse de déplacement
 * \param motif : Numero du motif dans le fichier .SPT chargé avec la fonction loadsprites
 * \param posx : positon X de départ du sprite à l'écran
 * \param posy : position Y de depart du sprite à l'écran
 * \param enable : si true, rends actif le sprite aprés sa création sinon false le désactive
 * \return l'id du sprite crée ou -1 si plus de place en mémoire
 */
short STX_createsprite(unsigned short motif, short posx, short posy, bool enable);


/*!
 * \brief Affiche tous les sprites créés et actifs
 * \return Le nombre de sprites affichés, si erreur retourne -1
 * \note si une animation existe pour un sprite celle-ci sera jouée, les coordonnées seront calculées
 */
void STX_showallsprites(void);


/*!
 * \brief change le motif d'un sprite à afficher
 * \param spriteid : id du sprite à afficher
 * \param motif : Numero du motif dans le fichier .SPT chargé avec la fonction loadsprites
 * \return 0 si pas d'erreur, -1 erreur ou de sprite non créé au préalable
 */
short STX_changespritemotif(unsigned short spriteid, unsigned short motif);


/*!
 * \brief Valide l'affichage du sprite dont l'id est spécifié
 * \param spriteid : id du sprite à afficher
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */ 
short STX_enablesprite(unsigned short spriteid);


/*!
 * \brief Dévalide l'affichage du sprite dont l'id est spicifié
 * \param spriteid : id du sprite concerné
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_disablesprite(unsigned short spriteid);


/*!
 * \brief Permet de savoir si le sprite dont l'id est spécifié est Enable ou Disable
 * \param spriteid : id du sprite concerné
 * \return true si sprite Enable, sinon false
 */
bool STX_getspriteenabled(unsigned short spriteid);


/*!
 * \brief Permet de récupérer la position X et Y d'un sprite
 * \param spriteid : id du sprite concerné
 * \param posx : adresse de la variable qui recevra la position X du sprite
 * \param posy : adresse de la variable qui recevra la position Y du sprite
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_getspriteposition(unsigned short spriteid, short *posx, short *posy);


/*!
 * \brief Permet de fixer la position X et Y d'un sprite
 * \param spriteid : id du sprite concerné
 * \param posx : Valeur de la position X du sprite
 * \param posy : Valeur de la position Y du sprite
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_setspriteposition(unsigned short spriteid, short posx, short posy);


/*!
 * \brief Permet de definir le deplacement du sprite en X et Y
 * \param spriteid : id du sprite concerné
 * \param xincr : Valeur du deplacement en X
 * \param yincr : Valeur du deplacement en Y
 * \return 0 si pas d'erreur, -1 si sprite non créé ou disable, 1 si clipping
 */
short STX_movesprite(unsigned short spriteid, short xincr, short yincr);


/*!
 * \brief Efface un sprite avec tous ces attributs
 * \param spriteid : id du sprite concerné
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_clearsprite(unsigned short spriteid);


/*!
 * \brief Defini l'animation d'un sprite par rapport à une liste de motifs contenus dans un tableau. La derniére valeur du tableau doit être 0xFFFF pour marquer la fin de l'animation
 * \param spriteid : id du sprite concerné
 * \param motiflist : pointeur sur un tableau contenant les numéros de motifs à afficher successivement, la derniére valeur du tableau doit être 0xFFFF
 * \param vitesse : vitesse d'affichage, corresponds au nombre de tour de la boucle infini pour changment de motif
 * \param animloop : si true, l'animation sera affichée en boucle, si false, l'animation sera effectuée une seul fois
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_setanimation(unsigned short spriteid, unsigned short *motiflist, unsigned char vitesse, bool animloop);


/*!
 * \brief Defini l'animation d'un sprite par rapport à une liste de motifs contenus dans un tableau
 * \param spriteid : id du sprite concerné
 * \param enable : active l'animation si true, sinon stop l'animation
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_animationenable(unsigned short spriteid, bool enable);


/*!
 * \brief Fixe les coordonnées de la boundingboxe dans un sprite pour les detections de collisions
 * \param spriteid : id du sprite concerné
 * \param posx : position x de la bounding boxe dans le sprite (default 0)
 * \param posy : position y de la bounding boxe dans le sprite (default 0)
 * \param width : largeur de la bounding box dans le sprite (default 15)
 * \param height : hauteur de la bounding box dans le sprite (default 15)
 * \return 0 si pas d'erreur, -1 en cas d'erreur ou de sprite non créé au préalable
 */
short STX_setboundingboxe(unsigned char spriteid,unsigned char posx, unsigned char posy, unsigned char width, unsigned char height);


/*!
 * \brief Fixe les coordonnées de la boundingboxe dans un sprite pour les detections de collisions
 * \param spriteid1 : id du premier sprite concerné
 * \param spriteid2 : id du second sprite concerné
 * \return true si collision, false sinon
 */
bool STX_spritescollision(unsigned short spriteid1, unsigned short spriteid2);


/*!
 * \brief Indique si le sprite est hors de la zone d'affichage clipping
 * \param spriteid1 : id du premier sprite concerné
 * \return true clipping, sinon false
 */
bool STX_spriteclipped(unsigned short spriteid1);


/*!
 * \brief Permet d'indiquer le nombre de pixel à deplacer un sprite pour lui assurer une vitesse constante par rapport à la frequence verticale
 * \param compteur : pointeur sur une variable contenant qui contiendra le pas d'avancement
 * \param speed_reg : valeur indiquant la vitesse regulée demandée par rapport à la frequence verticale
 * \return nombre de pixel à déplacer le sprite
 */
unsigned short STX_spritespeedadjuste(unsigned short *compteur, STX_speedadjustvalue speed_reg);

/*! \} 
 */

#endif