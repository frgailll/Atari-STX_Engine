/*! 
 * \file Controllib.h
 * \author Laurent Gaillard
 * \date 10/05/2020
 * \version 1.00
 *			
 * \note Controllib.h est le fichier de definition de la librairie de gestion des joystickx, de la souris et du clavier
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _CONTROLLIBH_
#define _CONTROLLIBH_

/*! 
 * \defgroup Controllib Control des Joysticks, du clavier et de la souris
 * \{
 */

//------------------ Touches de fonction -----------------
#define		KEY_F1				59								/*!< Touche de fonction F1 */
#define		KEY_F2				60								/*!< Touche de fonction F2 */
#define		KEY_F3				61								/*!< Touche de fonction F3 */
#define		KEY_F4				62								/*!< Touche de fonction F4 */
#define		KEY_F5				63								/*!< Touche de fonction F5 */
#define		KEY_F6				64								/*!< Touche de fonction F6 */
#define		KEY_F7				65								/*!< Touche de fonction F7 */
#define		KEY_F8				66								/*!< Touche de fonction F8 */
#define		KEY_F9				67								/*!< Touche de fonction F9 */
#define		KEY_F10				68								/*!< Touche de fonction F10 */

//------------------------- Ligne 1 -----------------------
#define		KEY_ECHAPE			1								/*!< Touche Escape */
#define		KEY_1				2								/*!< Touche 1 */
#define		KEY_2				3								/*!< Touche 2 */
#define		KEY_3				4								/*!< Touche 3 */
#define		KEY_4				5								/*!< Touche 4 */
#define		KEY_5				6								/*!< Touche 5 */
#define		KEY_6				7								/*!< Touche 6 */
#define		KEY_7				8								/*!< Touche 7 */
#define		KEY_8				9								/*!< Touche 8 */
#define		KEY_9				10								/*!< Touche 9 */
#define		KEY_0				11								/*!< Touche 0 */
#define		KEY_DEGRES			12								/*!< Touche ° */
#define		KEY_UNDERSCORE		13								/*!< Touche _ */
#define		KEY_LIVRE			41								/*!< Touche £ */
#define		KEY_BACKSPACE		14								/*!< Touche effacement arriere */

//------------------------- Ligne 2 -----------------------
#define		KEY_TAB				15								/*!< Touche Tabulation */
#define		KEY_A				16								/*!< Touche A */
#define		KEY_Z				17								/*!< Touche Z */
#define		KEY_E				18								/*!< Touche E */
#define		KEY_R				19								/*!< Touche R */
#define		KEY_T				20								/*!< Touche T */
#define		KEY_Y				21								/*!< Touche Y */
#define		KEY_U				22								/*!< Touche U */
#define		KEY_I				23								/*!< Touche I */
#define		KEY_O				24								/*!< Touche O */
#define		KEY_P				25								/*!< Touche P */
#define		KEY_CARET			26								/*!< Touche ^ */
#define		KEY_DOLLAR			27								/*!< Touche $ */
#define		KEY_DELETE			53								/*!< Touche effacement */

//------------------------- Ligne 3 -----------------------
#define		KEY_CONTROL			29								/*!< Touche Control */
#define		KEY_Q				30								/*!< Touche Q */
#define		KEY_S				31								/*!< Touche S */
#define		KEY_D				32								/*!< Touche D */
#define		KEY_F				33								/*!< Touche F */
#define		KEY_G				34								/*!< Touche G */
#define		KEY_H				35								/*!< Touche H */
#define		KEY_J				36								/*!< Touche J */
#define		KEY_K				37								/*!< Touche K */
#define		KEY_L				38								/*!< Touche L */
#define		KEY_M				39								/*!< Touche M */
#define		KEY_PURCENT			40								/*!< Touche % */
#define		KEY_RETURN			28								/*!< Touche Return */
#define		KEY_HASH			43								/*!< Touche # */

//--------------------------- ligne 4 ----------------------

#define		KEY_LEFTSHIFT		42								/*!< Touche Shift Gauche */
#define		KEY_MINUS			96								/*!< Touche - */
#define		KEY_W				44								/*!< Touche W */
#define		KEY_X				45								/*!< Touche X */
#define		KEY_C				46								/*!< Touche C */
#define		KEY_V				47								/*!< Touche V */
#define		KEY_B				48								/*!< Touche B */
#define		KEY_N				49								/*!< Touche N */
#define		KEY_QUESTION		50								/*!< Touche ? */
#define		KEY_SEMICOLON		51 								/*!< Touche ; */
#define		KEY_SLASH			52								/*!< Touche / */
#define		KEY_EQUALS			53								/*!< Touche = */
#define		KEY_RIGHTSHIFT		54								/*!< Touche Shift Droit */

//--------------------------- Ligne 5 -----------------------
#define		KEY_ALTERNATE		T56								/*!< Touche Alternette */
#define		KEY_SPACE			57								/*!< Touche Espace */
#define		KEY_CAPSLOCK		58								/*!< Touche Majuscule */

//------------------------- Zone fleche ---------------------
#define		KEY_HELP			98								/*!< Touche Help */
#define		KEY_UNDO			97								/*!< Touche Undo */
#define		KEY_INSERT			82								/*!< Touche Insert */
#define		KEY_UP				72								/*!< Touche Fleche haut */
#define		KEY_CLEARHOME		71								/*!< Touche Home */
#define		KEY_LEFT			75								/*!< Touche Fleche Gauche */
#define		KEY_DOWN			80								/*!< Touche Fleche Bas */
#define		KEY_RIGHT			77								/*!< Touche Fleche Droite */

//----------------------- Pave numerique --------------------
#define		KEY_NUMPAD_OPENPAREN		99						/*!< Pavé Numérique ( */
#define		KEY_NUMPAD_CLOSEPAREN		100						/*!< Pavé Numérique ) */
#define		KEY_NUMPAD_SLASH			101						/*!< Pavé Numérique / */
#define		KEY_NUMPAD_ASTERISK			102						/*!< Pavé Numérique * */
#define		KEY_NUMPAD_7				103						/*!< Pavé Numérique 7 */
#define		KEY_NUMPAD_8				104						/*!< Pavé Numérique 8 */
#define		KEY_NUMPAD_9				105						/*!< Pavé Numérique 9 */
#define		KEY_NUMPAD_MINUS			74						/*!< Pavé Numérique - */
#define		KEY_NUMPAD_4				106						/*!< Pavé Numérique 4 */
#define		KEY_NUMPAD_5				107						/*!< Pavé Numérique 5 */
#define		KEY_NUMPAD_6				108						/*!< Pavé Numérique 6 */
#define		KEY_NUMPAD_PLUS				78						/*!< Pavé Numérique + */
#define		KEY_NUMPAD_1				109						/*!< Pavé Numérique 1 */							
#define		KEY_NUMPAD_2				110						/*!< Pavé Numérique 2 */
#define		KEY_NUMPAD_3				111						/*!< Pavé Numérique 3 */
#define		KEY_NUMPAD_ENTER			114						/*!< Pavé Numérique Enter */
#define		KEY_NUMPAD_0				112						/*!< Pavé Numérique 0 */								
#define		KEY_NUMPAD_PERIOD			113						/*!< Pavé Numérique . */


/*! 
 * \brief Active le report du status des joysticks 0 et 1
 *
 * \note Cette fonction stopera le reprot du status de la souris
 */
void STX_startjoystickreport();


/*! 
 * \brief Active le report du status de la souris
 *
 * \note Cette fonction stopera le reprot du status des joystick 0 et 1
 */
void STX_startmousereport();


/*! 
 * \brief Lecture du status d'un joystick et de l'état du bouton d'action
 * \param joystickid : numéro du joystick, 0 ou 1
 * \param *action : adresse de la variable qui reçevera l'état du bouton action 
 * \return valeur de positionnement du joystick
 *
 * \note fonctionne pour les joysticks connectés sous le clavier des atari STF et STE
 * \sa STX_joystickvalue, STX_joystickaction
 */
STX_joystickvalue STX_getjoystickstatus(unsigned char joystickid, STX_joystickaction *action);


/*! 
 * \brief Lecture de la position absolue en X et Y de la souris
 * \param *PosAbsolueX : Pointeur qui recevera la valeur X
 * \param *PosAbsolueY : Pointeur qui recevera la valeur Y 
 */
void STX_readikbdmouseposition(unsigned short *PosAbsolueX, unsigned short *PosAbsolueY);


/*! 
 * \brief Lecture de la position relative en X et Y de la souris
 * \param *PosRelativeX : Pointeur qui recevera la valeur X
 * \param *PosRelativeY : Pointeur qui recevera la valeur Y 
 */
void STX_readikbdmouseoffset(short *PosRelativeX, short *PosRelativeY);


/*! 
 * \brief Lecture de la date et l'heure du système
 * \param *datetime : Pointeur sur une structure ikbddatetime
 *
 * \note Dand la struture ikbddatetime les valeurs sont fournies en BCD 
 */
void STX_readikbddateandtime(STX_ikbddatetime *datetime);


/*! 
 * \brief Ecriture de la date et l'heure du système
 * \param *datetime : Pointeur sur une structure ikbddatetime
 *
 * \note Dand la struture ikbddatetime les valeurs sont fournies en BCD 
 */
bool STX_writeikbddateandtime(STX_ikbddatetime *datetime);


/*! 
 * \brief Fixe le nombre de Ticks en X et Y nescessaire pour le declenchement du report de la position relative de la souris
 * \param TicksX : Nombre de Ticks sur l'axe horizontal
 * \param TicksY : Nombre de Ticks sur l'axe vertical
 *
 * \note Les ticks represente le nombre d'impulsions créées par les roues dentés de la souris
 */
void STX_setikbdmousethreshold(unsigned char TicksX, unsigned char TicksY);


/*! 
 * \brief Fixe le nombre de Ticks en X et Y nescessaires pour assurer un déplacement de 1 pixel à 'écran
 * \param TicksX : Nombre de Ticks sur l'axe horizontal
 * \param TicksY : Nombre de Ticks sur l'axe vertical
 *
 * \note Les ticks represente le nombre d'impulsions créées par les roues dentés de la souris
 */
void STX_setikbdmousescale(unsigned char TicksX, unsigned char TicksY);


/*! 
 * \brief Vérifie si la touche demandée est pressée
 * \param KeyValue : Numéro de la touche
 * \return True si la touche attendue est préssée
 */
bool STX_keyboardkeypress(unsigned char KeyValue);


/*! \} 
 */


#endif
