/*! 
 * \file eventlib.h
 * \author Laurent Gaillard
 * \date 12/08/2020
 * \version 0.1
 *			
 * \note eventlib.h est le fichier de definition du dispatcher d'evenement
 * \note Dependance : Aucune
 * \note Machine cible : toutes
 * \note Outil de developpement : VBCC, VASM, VLINK
*/

#ifndef _EVENTLIBH_
#define _EVENTLIBH_

/*! 
 * \defgroup Eventlib Dispatcher d'evenements
 * \{
 */


/*!
 * \brief Inscription auprés du dispatcher d'evenement
 * \return l'idsender ou -1 si plus de sender possible (max 20)
 */ 
short STX_regevent();


/*!
 * \brief Envoie d'un evenement au dispatcher
 * \param idsender : Numéro d'id retourner par la fonction STX_regevent
 * \param eventvalue : valeur de l'evenement
 */
void STX_sendevent(short idsender, short eventvalue);


/*!
 * \brief Envoie d'un evenement avec parametres au dispatcher
 * \param idsender : Numéro d'id retourner par la fonction STX_regevent
 * \param eventvalue : valeur de l'evenement
 * \param param1 : paramétre 1 de l'evenement
 * \param param2 : paramétre 2 de l'evenement
 */
void STX_sendeventex(short idsender, short eventvalue, short param1, long int param2);


/*!
 * \brief Lecture d'un evenement du dispatcher
 * \param idsender : Numéro d'id retourner par la fonction STX_regevent
 * \param eventvalue : pointeur sur la valeur de l'evenement
 * \return TRUE si un evenement est present, sinon FALSE
 */
bool STX_getevent(short idsender, short *eventvalue);


/*!
 * \brief Lecture d'un evenement avec parametres du dispatcher
 * \param idsender : Numéro d'id retourner par la fonction STX_regevent
 * \param eventvalue : pointeur sur la valeur de l'evenement
 * \param param1 : pointeur sur la valeur du paramétre 1 de l'evenement
 * \param param2 : pointeur sur la valeur du paramétre 2 de l'evenement
 * \return TRUE si un evenement est present, sinon FALSE
 */
bool STX_geteventex(short idsender, short *eventvalue, short *param1, long int *param2);
 
 /*! \} 
 */

#endif

