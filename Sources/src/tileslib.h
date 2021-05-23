/*! 
 * \file tileslib.h
 * \author Laurent Gaillard
 * \date 20/03/2020
 * \version 0.01
 *			
 * \note Le fichier tileslib.h cntient la definition des fonctions de gestion des tiles
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _TILESLIBH_
#define _TILESLIBH_

#include "src\type.h"

/*! 
 * \defgroup Tileslib Gestionnaire de tiles
 * \{
 */

/*!
 * \brief Charge en memoire un fichier de definition d'une tilesmap au format TLM et le fichier des tileset au format TLS
 * \param *Pathtilemap : pointeur sur le nom et le chemin d'accés au fichier .TLM
 * \param *Pathtileset : pointeur sur le nom et le chemin d'accés au fichier .TLS
 * \return la taille en octet de la tilemap si pas d'erreur, sinon valeur négative
 * \note Une seul tilesmap peut-étre charger à la fois
 */
short STX_loadtilesmap(char *Pathtilemap, char *Pathtileset);


/*!
 * \brief Sauvegarde en mémoire la tilesmap en cours
 * \param *saveadresse : pointeur sur l'adresse de sauvegarde
 * \return -1 si le pointeur est null, sinon 0
 */
short STX_savetilesmap(unsigned long int *saveadresse);


/*!
 * \brief Restore la tilesmap qui à été sauvegardée
 * \param *saveadresse : pointeur sur l'adresse de la sauvegarde
 * \return -1 si le pointeur est null, sinon 0
 */
short STX_restoretilesmap(unsigned long int *saveadresse);


/*!
 * \brief Fourni les dimensions en tiles de la map
 * \param *MapWidth : pointeur sur la variable qui recevera la largeur de la map en tiles
 * \param *MapHeight : pointeur sur la variable qui recevera la hauteur de la map en tiles
 */
void STX_gettilesmapsize(unsigned short *MapWidth, unsigned short *MapHeight);


/*!
 * \brief Libération des resources utilisées par la tilesmap
 */
void STX_releasetilesmap(void);


/*!
 * \brief Fourni les coordonnées X et Y en tile d'un sprite sur la map
 * \param spriteid : numéro du sprite pour lequel on veux connaitre ses coordonnées en tile
 * \param xanchoroffset : offset en X de l'ancre du sprite (en pixel)
 * \param yanchoroffset : offset en Y de l'ancre du sprite (en pixel)
 * \param tilex : pointeur d'adresse qui recevera la valeur X tile
 * \param tiley : pointeur d'adresse qui recevera la valeur Y tile
 * \return -1 si sprite non créé ou desable, sinon 0
 */
short STX_gettilepositionfromsprite(unsigned short spriteid, short xanchoroffset,short yanchoroffset, unsigned short *tilex, unsigned short *tiley);


/*!
 * \brief Fourni les coordonnées X et Y en pixel (position écran) d'un tile situé dans la zone visible de la map
 * \param tilex : position X du tile dans la map
 * \param tiley : position Y du tile dans la map 
 * \param posx : pointeur d'adresse qui recevera la valeur X en pixel ecran de la position du tile
 * \param posy : pointeur d'adresse qui recevera la valeur Y en pixel ecran de la position du tile
 * \return -1 si le tile est hors de la zone visible de la map, sinon 0
 */
short STX_getscreenpositionfromtile(unsigned short tilex, unsigned short tiley,unsigned short *posx, unsigned short *posy);


/*!
 * \brief fourni la valeur d'un tile par rapport à ces coordonnées dans la map
 * \param tilex : coordonnée X du tile dans la map
 * \param tiley : coordonnée Y du tile dans la map
 * \return 0 si coordonnées en dehors de la map, sinon la valeur du tile
 */
unsigned short STX_gettilevalue(unsigned short tilex, unsigned short tiley);


/*!
 * \brief fourni la valeur et l'id d'un tile par rapport à ces coordonnées dans la map
 * \param tilex : coordonnée X du tile dans la map
 * \param tiley : coordonnée Y du tile dans la map
 * \return 0 si coordonnées en dehors de la map, sinon l'id du tile
 */
unsigned short STX_gettileid(unsigned short tilex, unsigned short tiley);


/*!
 * \brief fourni la valeur d'un tile par rapport à un id
 * \param tileid : valeur de l'id du tile
 * \return la valeur du tile suivant son id
 * \note si la valeur tileid est en dehors de la map, la valeur de retour sera 0
*/
unsigned short STX_gettilevaluefromtileid(unsigned short tileid);


/*!
 * \brief Recupére la propriété numéro 1 d'un tile par rapport à sa valeur
 * \param tilevalue : Valeur du tile dont on veut récupérer la propriété
 * \return La propriété numéro 1
 * \note les tiles ayant la valeur 0 sont exclus, la valeur de retour sera 0
 */
unsigned char STX_gettileprop1(unsigned short tilevalue);


/*!
 * \brief permet de modifier la propriété 1 associée à la valeur d'un tile
 * \param tilevalue : Valeur du tile dont on veut modifier la propriété
 * \param property : Valeur de la propriété
 * \note les tiles ayant la valeur 0 n'ont pas de proriété
 */
void STX_settileprop1(unsigned short tilevalue, unsigned char property);


/*!
 * \brief Recupére la propriété numéro 2 d'un tile par rapport à sa valeur
 * \param tilevalue : Valeur du tile dont on veut récupérer la propriété
 * \return La propriété numéro 2
 * \note les tiles ayant la valeur 0 sont exclus, la valeur de retour sera 0
 */
unsigned char STX_gettileprop2(unsigned short tilevalue);


/*!
 * \brief permet de modifier la propriété 2 associée à la valeur d'un tile
 * \param tilevalue : Valeur du tile dont on veut modifier la propriété
 * \param property : Valeur de la propriété
 * \note les tiles ayant la valeur 0 n'ont pas de proriété
 */
void STX_settileprop2(unsigned short tilevalue, unsigned char property);


/*!
 * \brief Recupére la propriété numero 3 d'un tile par rapport à sa valeur
 * \param tilevalue : Valeur du tile dont on veut récupérer la propriété
 * \return La propriéré numéro 3
 * \note les tiles ayant la valeur 0 sont exclus, la valeur de retour sera 0
 */
unsigned char STX_gettileprop3(unsigned short tilevalue);


/*!
 * \brief permet de modifier la propriété 3 associée à la valeur d'un tile
 * \param tilevalue : Valeur du tile dont on veut modifier la propriété
 * \param property : Valeur de la propriété
 * \note les tiles ayant la valeur 0 n'ont pas de proriété
 */
void STX_settileprop3(unsigned short tilevalue, unsigned char property);


/*!
 * \brief Defini taille affichable de le tilesmap ainsi que sa position de départ à l'écran
 * \param posx : position en X sur l'écran
 * \param posy : position en X sur l'écran
 * \param tileW : Nombre de tile en largeur qui sera déssiner
 * \param tileH : Nombre de tile en hauteur qui sera déssiner
 * \return valeur négative si erreur d'allocation mémoire, sinon 0
 * \note X doit être un multiple de 16
 */
int STX_settilesmaparea(unsigned short posx, unsigned short posy, unsigned char tileW, unsigned char tileH);


/*!
 * \brief Dessine la map à partir du tile en position X et Y
 * \param tileX : position en X du tile de départ
 * \param tileY : position en Y du tile de départ
 */
void STX_drawtilesmap(unsigned short tileX, unsigned short tileY);


/*!
 * \brief Modifie la valeur du tile au coordonnée X et Y dans la tilesmap
 * \param tileX : position en X du tile dans la tilesmap
 * \param tileY : position en Y du tile dans la tilesmap
 * \param newvalue : Nouvelle valeur du tile
 * \return -1 si X ou Y sont en dehors de la map, sinon 0
 */
int STX_changetilevalue(unsigned short tileX, unsigned short tileY, unsigned short newvalue);


/*!
 * \brief Redessine un tile au coordonnée X et Y dans la tilesmap
 * \param tileX : position en X du tile dans la tilesmap
 * \param tileY : position en Y du tile dans la tilesmap
 * \return -1 si X ou Y sont en dehors de la zone d'écran ou la tilesmap est visible, sinon 0
 */
int STX_redrawtile(unsigned short tileX, unsigned short tileY);

/*! \} 
 */


#endif