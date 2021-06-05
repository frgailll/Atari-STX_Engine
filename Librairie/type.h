/*! 
 * \file type.h
 * \author Laurent Gaillard
 * \date 27/12/2019
 * \version 1.00
 *			
 * \note Le fichier type.h defini les differentes constantes, et typages utilisées dans les différentes librairies
 * \note Dependance : Aucune
 * \note Machine cible : Atari ST avec blitter ou Atari STE
 * \note Outil de developpement : VBCC, VASM, VLINK
*/


#ifndef _TYPEH_
#define _TYPEH_


/*!
 * \ingroup STX_Engine
 * \brief Defini le type booleen et ses valeurs possibles
 *
 */
typedef unsigned char bool;
#define TRUE    0xFF                                    /*!< Valeur booleene vrai */
#define FALSE   0x00                                    /*!< Valeur booleene faux */
#define NULL ((void*)0)                                 /*!< Valeur pointeur NULL */

/*!
 * \ingroup Controllib
 * \brief Enumeration des valeurs de positionnement du joystick
 *
 */
typedef enum    {   JOY_ERROR=(unsigned char)0xFF,      /*!< Valeur en cas d'erreur (ID superieur à 1) */
                    JOY_UP=(unsigned char)0x01,         /*!< Valeur position joystick en haut */
                    JOY_RIGHT=(unsigned char)0x08,      /*!< Valeur position joystick à droite */
                    JOY_DOWN=(unsigned char)0x02,       /*!< Valeur position joystick en bas */
                    JOY_LEFT=(unsigned char)0x04,       /*!< Valeur position joystick à gauche */
                    JOY_UPRIGHT=(unsigned char)0x09,    /*!< Valeur position joystick en haut à droite */
                    JOY_DOWNRIGHT=(unsigned char)0x0A,  /*!< Valeur position joystick en bas à droite */
                    JOY_DOWNLEFT=(unsigned char)0x06,   /*!< Valeur position joystick en bas à gauche */
                    JOY_UPLEFT=(unsigned char)0x05,     /*!< Valeur position joystick en haut à gauche */
                    JOY_PAUSE=(unsigned char)0x00,      /*!< Valeur position joystick inactif */   
                }STX_joystickvalue;


/*!
 * \ingroup Controllib
 * \brief Enumeration des valeurs du bouton action du joystick
 *
 */ 
typedef enum    {   JOY_ACTION=(unsigned char)0x80,     /*!< Valeur activation bouton action joystick */
                    JOY_NOACTION=(unsigned char)0x00    /*!< Valeur bouton action joystick relaché */ 
                }STX_joystickaction;

 
/*!
 * \ingroup STX_Engine
 * \brief Enumeration des valeurs possibles pour definir la fréquence verticale de l'affichage (nombre d'images par seconde).
 *
 */
typedef enum    {   FV60=(unsigned short)0x0000,        /*!< fréquence verticale de 60Hz */
					FV50=(unsigned short)0x0002,        /*!< fréquence verticale de 50Hz */
                    FV30=(unsigned short)0x0100,        /*!< fréquence verticale de 30Hz */
                    FV25=(unsigned short)0x0102,        /*!< fréquence verticale de 25Hz */
					FV20=(unsigned short)0x0200,		/*!< fréquence verticale de 20Hz */
					FV15=(unsigned short)0x0300,		/*!< fréquence verticale de 15Hz */
                }STX_freqverticale; 
				


/*!
 * \ingroup STX_Engine
 * \brief Enumeration des valeurs possibles de machine 16 bits ATARI
 *
 */
typedef enum    {	
					MCH_STF=(short)0x0000,				/*!< Atari série STF */
					MCH_STE=(short)0x0100,				/*!< Atari série STE */
					MCH_STBOOK=(short)0x0108,			/*!< Atari ST-Book */
					MCH_MSTE=(short)0x0110,				/*!< Atari Mega STE */
					MCH_TT030=(short)0x0200,			/*!< Atari TT030 */
					MCH_FC030=(short)0x0300,			/*!< Atari Falcon 030 */
					MCH_UNKNO=(short)0xFFFF				/*!< Machine non identifiée, se produit avant le TOS 1.06 */
				}STX_machine16;


/*!
 * \ingroup Soundlib
 * \brief Enumeration des valeurs possibles pour definir la valeur du diviseur de fréquence du timer D du MFP
 *
 */
typedef enum    {   DIV4=(unsigned short)0x0001,        /*!< fréquence timer D de 614400 Hz */
                    DIV10=(unsigned short)0x0002,       /*!< fréquence timer D de 245760 Hz */
                    DIV16=(unsigned short)0x0003,       /*!< fréquence timer D de 153600 Hz */
                    DIV50=(unsigned short)0x0004,       /*!< fréquence timer D de 49152 Hz */
                    DIV64=(unsigned short)0x0005,       /*!< fréquence timer D de 38400 Hz */
                    DIV100=(unsigned short)0x0006,      /*!< fréquence timer D de 24576 Hz */
                    DIV200=(unsigned short)0x0007       /*!< fréquence timer D de 12288 Hz */
                }STX_sndtimerdiv;


/*!
 * \ingroup Imagelib
 * \brief Enumeration des type d'image possible à charger et à afficher
 *
 */
typedef enum    {   PICTYPNEO=(unsigned char)1,         /*!< Numero du type d'image Neocharome */
                    PICTYPDEGAS=(unsigned char)2,       /*!< Numero du type d'image Degas */
                    PICTYPDEGASEL=(unsigned char)3      /*!< Numero du type d'image DegasElite */
                }STX_picturetype;
                

/*!
 * \ingroup Imagelib
 * \brief Enumeration des mode d'affichage des spriteset en tant que image
 *
 */                
typedef enum    {   REPLACE=(unsigned char)0,          /*!< Affichage en mode replace */
                    TRANSPARENT=(unsigned char)1,      /*!< Affichage en mode transparence */
                    EFFACE=(unsigned char)2            /*!< Affichage en mode effacement */
                }STX_displaymode;


/*!
 * \ingroup Charsetlib
 * \brief Enumeration des sens d'affichage d'un string de charsets
 *
 */
typedef enum    {   HOR=(bool)TRUE,                     /*!< Affichage Horizontal du string */
                    VER=(bool)FALSE                     /*!< Affichage Vertical du string */
                }STX_displaysens;


/*!
 * \ingroup Controllib
 * \brief Structure de valeur BCD fournissant la date et l'heure du systéme
 *
 */ 
typedef struct  {   unsigned char Year;                 /*!< Deux derniers digit en BCD de l'année */
                    unsigned char Month;                /*!< Le mois en BCD */
                    unsigned char Day;                  /*!< La date du jour en BCD */
                    unsigned char Hours;                /*!< L'heure en BCD */
                    unsigned char Minutes;              /*!< Les minutes en BCD */
                    unsigned char Seconds;              /*!< Les secondes en BCD */
                }STX_ikbddatetime;


/*!
 * \ingroup Spritelib
 * \brief Enumeration des differentes regulation de vitesse pour le deplacement des sprites
 *
 */
typedef enum    {   REG_VITESSE_20=(unsigned short)0,       /*!< vitesse de deplacement de 20% par rapport au frame rate */    
                    REG_VITESSE_25=(unsigned short)20,      /*!< vitesse de deplacement de 25% par rapport au frame rate */
                    REG_VITESSE_30=(unsigned short)40,      /*!< vitesse de deplacement de 30% par rapport au frame rate */
                    REG_VITESSE_35=(unsigned short)60,      /*!< vitesse de deplacement de 35% par rapport au frame rate */
                    REG_VITESSE_40=(unsigned short)80,      /*!< vitesse de deplacement de 40% par rapport au frame rate */
                    REG_VITESSE_45=(unsigned short)100,     /*!< vitesse de deplacement de 45% par rapport au frame rate */
                    REG_VITESSE_50=(unsigned short)120,     /*!< vitesse de deplacement de 50% par rapport au frame rate */
                    REG_VITESSE_55=(unsigned short)140,     /*!< vitesse de deplacement de 55% par rapport au frame rate */
                    REG_VITESSE_60=(unsigned short)160,     /*!< vitesse de deplacement de 60% par rapport au frame rate */
                    REG_VITESSE_65=(unsigned short)180,     /*!< vitesse de deplacement de 65% par rapport au frame rate */
                    REG_VITESSE_70=(unsigned short)200,     /*!< vitesse de deplacement de 70% par rapport au frame rate */
                    REG_VITESSE_75=(unsigned short)220,     /*!< vitesse de deplacement de 75% par rapport au frame rate */
                    REG_VITESSE_80=(unsigned short)240,     /*!< vitesse de deplacement de 80% par rapport au frame rate */
                    REG_VITESSE_85=(unsigned short)260,     /*!< vitesse de deplacement de 85% par rapport au frame rate */
                    REG_VITESSE_90=(unsigned short)280,     /*!< vitesse de deplacement de 90% par rapport au frame rate */
                    REG_VITESSE_95=(unsigned short)300,     /*!< vitesse de deplacement de 95% par rapport au frame rate */
                    REG_VITESSE_100=(unsigned short)320,    /*!< vitesse de deplacement de 100% par rapport au frame rate */
                    REG_VITESSE_105=(unsigned short)340,    /*!< vitesse de deplacement de 105% par rapport au frame rate */
                    REG_VITESSE_110=(unsigned short)360     /*!< vitesse de deplacement de 110% par rapport au frame rate */
                }STX_speedadjustvalue;

#endif