
;                definition des adresses des ACIA de l'atari ST

acia_kbd_cont   EQU         $00FFFC00
acia_kbd_data   EQU         $00FFFC02
acia_midi_cont  EQU         $00FFFC04
acia_midi_data  EQU         $00FFFC06

;           Vecteurs du controleur de clavier des atari ST et STE

cont_midivec    EQU         0                       ;vecteur entrée MIDI
cont_vkbderr    EQU         4                       ;vecteur erreur clavier
cont_vmiderr    EQU         8                       ;vecteur erreur midi
cont_statvec    EQU         12                      ;vecteur status du clavier
cont_mousevec   EQU         16                      ;vecteur routine souris
cont_clockvec   EQU         20                      ;vecteur de l'horloge
cont_joyvec     EQU         24                      ;vecteur des joysticks
cont_midisys    EQU         28                      ;vecteur système midi
cont_ikbdsys    EQU         32                      ;vecteur systéme ikbd

;           Commandes du processeur clavier paour gestion evenement joystick

joy_eventstart  EQU         $14                     ;start Joystick evenement mode
joy_eventend    EQU         $1A                     ;stop Joystick evenement mode
mouse_relative  EQU         $08                     ;demarre le reporting de la position relative de la souris
mouse_position	EQU			$0D						;demande la position de la souris
ikbd_rdatetime	EQU			$1C						;demande la date et l'heure au processeur clavier
ikbd_wdatetime  EQU         $1B                     ;fixe la date et l'heure au processeur clavier
mouse_threshold EQU			$0B						;fixe la valeur du threshold en X et Y declenchant le report de la position relative
mouse_scale		EQU			$0C						;fixe l'echelle de déplacement de la souris en X et Y
mouse_stop      EQU         $12                     ;stop le report de la souris


				SECTION TEXT


;           /-------------------------------------------------/
;           /    Initialisation du Handler pour la gestion    /
;           /       des données en provenance du clavier      /
;           /-------------------------------------------------/

cont_initjoysticks:

;			initialisation des buffers de reception de données

				move.b      #0,cont_lastheader      ;initialise la mémoire de header
                move.w		#0,cont_datacount		;initialise le compteur de données
				move.b 		#0,cont_joy0data		;initialise le buffer de donnée du joystick 0
				move.b		#0,cont_joy1data		;initialise le buffer de donnée du joystick 1
				move.w		#0,cont_mouse_dpx		;initialise le buffer de position relative X de la souris
				move.w		#0,cont_mouse_dpy		;initialise le buffer de position relative Y de la souris

;           récupération et sauvegarde du vecteur clavier de base

                M_kbdvbase
				move.l      D0,cont_ikbd_base       ;D0 contient le vecteur IKBD à sauvegarder
                
;           modification du vecteur du clavier pour récupération des données

                move.l      D0,A6                                   ;A6 pointe sur KBDVBASE
                move.l      cont_ikbdsys(A6),cont_ikbdvector        ;sauvegarde du handler initiale du clavier
                move.l      #cont_ikbdsyshandler,cont_ikbdsys(A6)   ;défini la nouvelle routine du clavier
                rts



;           /-------------------------------------------------/
;           /  Handler de traitement de l'appel de la routine /
;           /         clavier pour la gestion des             /
;           /    joysticks, de la souris et des touches       /
;           /-------------------------------------------------/

cont_ikbdsyshandler:
                movem.l     D7-D5/A0-A2,cont_savereg
                clr.w       D6
                lea         cont_lastheader,A1      ;A1 pointe sur la mémoire du dernier header
                move.b      acia_kbd_data,D7        ;lecture donnée de l'ACIA
                move.b      (A1),D6                 ;D6 = valeur ancien header
                bne         .cont_newdata           ;alors aller à .cont_newdata
                
;           traitement de l'entete des evenements des joystick
                
                cmp.b       #$FF,D7                 ;si D7 <> header JOYSTICK 1
                bne         .cont_nojoy1            ;aller à .cont_nojoy1
                move.b      D7,(A1)                 ;mémorise le header
                bra         .cont_endikbd

.cont_nojoy1:   cmp.b       #$FE,D7                 ;si D7 <> header JOYSTICK 0
                bne         .cont_nojoy0            ;aller à .cont_nojoy0
                move.b      D7,(A1)                 ;mémorise le header
                bra         .cont_endikbd
				           
;           traitement de l'entete Date and Time      

.cont_nojoy0:	cmp.b 		#$FC,D7					;si D7 <> $FC
				bne			.cont_nodattime			;aller à .cont_nodatetime
				move.b      D7,(A1)                 ;mémorise le header
                move.w		#0,cont_datacount		;compteur de donnée à 0
				bra         .cont_endikbd

;			traitement de l'entete de la souris pour deplacement absolu

.cont_nodattime	cmp.b		#$F7,D7					;si D7 < $F7
				bne			.cont_nomousea			;alors pas une commande de souris absolue
				move.b      D7,(A1)                 ;mémorise le header
				move.w		#0,cont_datacount		;compteur de donnée à 0
				bra         .cont_endikbd

;           traitement de l'entete de la souris pour deplacement relatif

.cont_nomousea	cmp.b		#$F8,D7					;si D7 < $F8
				blt			.cont_nomouser			;alors pas une commande de souris relative
				cmp.b		#$FB,D7					;si D7 > $FB
				bgt			.cont_nomouser			;alors pas une commande de souris relative
				move.b      D7,(A1)                 ;mémorise le header
				and.b 		#$03,D7					;D7 = D7 et $03 -> recupération valeur des boutons
				move.b 		D7,cont_mouse_but		;Stocke la valeur des boutons
				move.w		#0,cont_datacount		;compteur de donnée à 0
				bra         .cont_endikbd

;           traitement de l'entete / données du clavier

.cont_nomouser  move.b 		D7,D6					;D6 = D7 = valeur code touche +127 à -128
				lea			cont_keystable,A2		;A2 pointe sur la table des touches
				and.b 		#$7F,D6					;extrait le code de la touche à D6
				tas			D7						;si D7 > 0
				spl			0(A2,D6.w)				;alors met TRUE dans A2+D6, sinon False
				bra         .cont_endikbd

;            traitement des données associées aux evenements des joysticks 

.cont_newdata:  cmp.b       #$FF,D6                 ;si D6 <> header JOYSTICK 1
                bne         .cont_nodtajoy1         ;aller à .cont_nodtajoy1
                move.b      D7,cont_joy1data        ;stocke la donnée du joystick 1
                move.b      #0,(A1)                 ;efface l'ancien header
                bra         .cont_endikbd

.cont_nodtajoy1 cmp.b       #$FE,D6                 ;si D6 <> header JOYSTICK 0
                bne         .cont_nodtajoy0         ;aller à .cont_nodtajoy0
                move.b      D7,cont_joy0data        ;stcke la donnée du joystick 0
                move.b      #0,(A1)                 ;efface l'ancien header
                bra         .cont_endikbd

;			traitement des données associées au déplacment absolu de la souris

.cont_nodtajoy0	cmp.b		#$F7,D6					;si D7 < $F7
				bne			.cont_nodtmousa			;alors pas une commande de souris absolue
				lea			cont_mouse_abx,A2
				move.w		cont_datacount,D5		;D5 = cont_datacount
				move.b      D7,0(A2,D5.w)       	;position absolu X et Y (4 octets)
				add.w		#1,cont_datacount		;incremente la compteur de donnée
				cmp.w		#$04,D5					;si D5 <> 4
				bne			.cont_endikbd			;alors aller à .cont_endikbd
                move.b      #0,(A1)                 ;sinon efface l'ancien header
				move.b		#true,cont_mouse_ab		;position disponible
				bra         .cont_endikbd

;            traitement des données associées au déplacment relatif de la souris 

.cont_nodtmousa cmp.b		#$F8,D6					;si D7 < $F8
				blt			.cont_nodtamser			;alors pas une donnée de souris
				cmp.b		#$FB,D6					;si D7 > $FB
				bgt			.cont_nodtamser			;alors pas une donnée de souris
				lea			cont_mouse_dpx,A2		;pointe sur la valeur relative X
				move.w		cont_datacount,D5		;D5 = cont_datacount
				ext.w		D7						;étant D7 sur un mot
				add.w       D7,0(A2,D5.w)       	;position relative X puis de Y additionné au précedent relevé
				add.w		#2,cont_datacount		;incremente la compteur de donnée
				cmp.w		#$02,D5					;si D5 <> 1
				bne			.cont_endikbd			;alors aller à .cont_endikbd
                move.b      #0,(A1)                 ;sinon efface l'ancien header
				bra         .cont_endikbd

;           traitement des  données associées à Date and Time

.cont_nodtamser cmp.b 		#$FC,D6					;si D6 <> $FC
				bne			.cont_endikbd			;alors pas une donnée date time
				lea			cont_datetime,A2		;pointe sur le debut des données de date time
				move.w		cont_datacount,D5		;D5 = cont_datacount
				move.b      D7,0(A2,D5.w)       	;stocke les 6 octets de date time
				add.w		#1,cont_datacount		;incremente la compteur de donnée
				cmp.w		#$05,D5					;si D5 <> 5
				bne			.cont_endikbd			;alors aller à .cont_endikbd
                move.b      #0,(A1)                 ;sinon efface l'ancien header
				move.b 		#true,cont_dateflag		;met le drapeau de recption à true
 
.cont_endikbd:  movem.l     cont_savereg,D7-D5/A0-A2
                rts



;           /-------------------------------------------------/
;           /     Verifie si la touche attendue du clavier    / 
;           /                  est pressée                    /
;			/  Paramétres:		                              /
;           /               Le numéro de la touche voulue     /
;           /  retourne:                                      /
;           /               True si la touche est préssée     /
;           /-------------------------------------------------/

_STX_keyboardkeypress:
                movem.l     D7/A0,minit_saveregs
                lea         cont_keystable,A0
                move.w      4(A7),D7
                move.b      (A0,D7.w),D0
                movem.l     minit_saveregs,D7/A0
                rts
                


;           /-------------------------------------------------/
;           /     Active le report du status des joysticks    /
;			/	      et stop le report de la souris		  /
;           /-------------------------------------------------/

_STX_startjoystickreport:
.startjoywait	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.startjoywait			;attendre
				move.w		#0,cont_mouse_dpx		;initialise le buffer de position relative X de la souris
				move.w		#0,cont_mouse_dpy		;initialise le buffer de position relative Y de la souris
				move.b      #joy_eventstart,acia_kbd_data	;envoi la commande de surveillance des joysticks
				rts
				
				

;           /-------------------------------------------------/
;           /     Active le report du status de la souris     /
;			/	     et stop le report des joysticks		  /
;           /-------------------------------------------------/
				
_STX_startmousereport:
.startmousewait	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.startmousewait			;attendre
				move.b 		#0,cont_joy0data		;initialise le buffer de donnée du joystick 0
				move.b		#0,cont_joy1data		;initialise le buffer de donnée du joystick 1
				move.b      #mouse_relative,acia_kbd_data	;active le mode mouse relative
				rts
				


;           /-------------------------------------------------/
;           /      Stop le report du status de la souris      /
;           /-------------------------------------------------/

_STX_stopmousereport:
.stopmousewait	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.stopmousewait			;attendre
                move.b      #mouse_stop,acia_kbd_data   ;stop le report de la souris
                rts
               

;           /-------------------------------------------------/
;           /    lecture des valeurs de positionnement d'un   /
;           /    joystick et l'état du  bouton d'action des   /
;           /      joysticks 0 ou 1 de l'atari STF ou STE     /
;           /   Parametres : Numéro du joystique (0 ou 1)     /
;           /   retourne :   valeur du positionnement         /
;           /   retourne :   état bouton action par reference /
;           /-------------------------------------------------/
                   
_STX_getjoystickstatus:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde les registres utilisés
                clr.w       D0                      ;efface D0 sur 2 octets
                move.b      #$FF,D0                 ;D0 = -1 valeur retournée en cas d'erreur
                move.w      4(A7),D7                ;numéro du joystick (0 ou 1)
                move.l      6(A7),A6                ;valeur pointeur variable action
                cmpi.b      #1,D7                   ;si D7 > 1
                bgt         .cont_getjstatend       ;quitter et retourner 0
                cmpi.b      #1,D7                   ;si D7 = 1
                beq         .cont_valstatjoy1       ;aller à .cont_valuejoy1
                move.b      cont_joy0data,D0        ;met la valeur du positionnement + tir du joystick 0 dans D0
                andi.b      #$80,D0                 ;mask les bits 6 à 0 des deplacements
                move.w      D0,(A6)                 ;retourne valeur bouton action par reference
                move.b      cont_joy0data,D0        ;met la valeur du positionnement + tir du joystick 0 dans D0
                andi.b      #$7F,D0                 ;mask le bit 7 du tir
                movem.l     minit_saveregs,D7/A6    ;restitution les registres utilisés
                rts                                 ;retour au programme appelant avec position joystick 0 dans D0
.cont_valstatjoy1:
                move.b      cont_joy1data,D0        ;met la valeur du positionnement + tir du joystick 1 dans D0
                andi.b      #$80,D0                 ;mask les bits 6 à 0 des deplacements
                move.w      D0,(A6)                 ;retourne valeur bouton action par reference
                move.b      cont_joy1data,D0        ;met la valeur du positionnement + tir du joystick 1 dans D0
                andi.b      #$7F,D0                 ;mask le bit 7 du tir 
.cont_getjstatend:
                movem.l     minit_saveregs,D7/A6    ;restitution les registres utilisés
                rts                                 ;retour au programme appelant avec position joystick 1 dans D0
 


;           /-------------------------------------------------/
;           /    lecture de la position absolue de la souris  /
;           /   Parametres : 								  /
;			/				pointeur position X				  /
;			/				pointeur position Y				  /
;			/   retourne:									  /
;			/               valeur de la position X			  /
;			/				valeur de la position Y			  /
;           /-------------------------------------------------/

_STX_eadikbdmouseposition:
				movem.l		A2-A1,minit_saveregs
				move.l		4(A7),A1				;pointeur sur la variable qui recevera la valeur X
				move.l 		8(A7),A2				;pointeur sur la variable qui recevera la valeur Y
				move.b		#false,cont_mouse_ab	;efface le drapeau de reception
.getmousewait	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.getmousewait			;attendre
				move.b      #mouse_position,acia_kbd_data	;envoie la commande
.cont_getpswait	cmp.b		#true,cont_mouse_ab		;si drapeau de reception <> true
				bne			.cont_getpswait			;alors attendre
				move.w		cont_mouse_abx,(A1)		;stocker la valeur de X
				move.w		cont_mouse_aby,(A2)		;stocker la valeur de Y
				movem.l 	minit_saveregs,A2-A1
				rts
				


;           /-------------------------------------------------/
;           / lecture de l'offset de deplacement de la souris /
;           /   Parametres : 								  /
;			/				pointeur offset X				  /
;			/				pointeur offset Y				  /
;			/   retourne:									  /
;			/               valeur de l'offset X			  /
;			/				valeur de l'offset Y			  /
;           /-------------------------------------------------/
				
_STX_readikbdmouseoffset:
				movem.l 	A2-A1,minit_saveregs
				move.l		4(A7),A1				;pointeur sur la variable qui recevera l'offset X
				move.l 		8(A7),A2				;pointeur sur la variable qui recevera l'offset Y
				move.w		cont_mouse_dpx,(A1)		;stocke l'offset X
				move.w		cont_mouse_dpy,(A2)		;stocke l'offset Y
				movem.l 	minit_saveregs,A2-A1
				rts
				


;           /-------------------------------------------------/
;           /    lecture de la date et l'heure du clavier     /
;           /   Parametres : 								  /
;			/				pointeur sur structure DateTime	  /
;			/   retourne:									  /
;			/               valeur DateTime			  		  /
;           /-------------------------------------------------/			
	
_STX_readikbddateandtime:
				movem.l		A2-A1,minit_saveregs
				move.l		4(A7),A1				;pointe sur la structure DateTime
				move.b 		#false,cont_dateflag	;efface le flag de reception
.getdatewait	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.getdatewait			;attendre
				move.b 		#ikbd_rdatetime,acia_kbd_data	;envoie la commande
.cont_getdtwait cmp.b 		#true,cont_dateflag
				bne			.cont_getdtwait
				lea			cont_datetime,A2
				move.b		(A2)+,(A1)+				;deux derniers digit de l'année
				move.b		(A2)+,(A1)+				;mois
				move.b		(A2)+,(A1)+				;date
				move.b		(A2)+,(A1)+				;heure
				move.b		(A2)+,(A1)+				;minutes
				move.b		(A2)+,(A1)+				;seconde
				movem.l 	minit_saveregs,A2-A1
				rts
 

;           /-------------------------------------------------/
;           /    Ecriture de la date et l'heure du clavier    /
;           /   Parametres : 								  /
;			/				pointeur sur structure DateTime	  /
;			/   retourne:									  /
;			/               True si pas d'erreur     		  /
;           /-------------------------------------------------/

_STX_writeikbddateandtime:
                movem.l		A1,minit_saveregs
                move.b      #false,D0
                move.l		4(A7),A1				;pointe sur la structure DateTime
                cmp.b       #$99,(A1)+              ;si Année > 99
                bhi         .setdateend             ;fin
                cmp.b       #$12,(A1)+              ;si mois > 12
                bhi         .setdateend             ;fin
                cmp.b       #$31,(A1)+              ;si jour > 31
                bhi         .setdateend             ;fin
                cmp.b       #$23,(A1)+              ;si heure > 23
                bhi         .setdateend             ;fin
                cmp.b       #$59,(A1)+              ;si minute > 59
                bhi         .setdateend             ;fin
                cmp.b       #$59,(A1)               ;si seconde > 59
                bhi         .setdateend             ;fin
                move.l		4(A7),A1				;pointe sur la structure DateTime
.setdatewait1	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait1			;attendre
                move.b 		#ikbd_wdatetime,acia_kbd_data	;envoie la commande
.setdatewait2	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait2			;attendre 
                move.b      (A1)+,acia_kbd_data     ;envoie Année
.setdatewait3	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait3			;attendre   
                move.b      (A1)+,acia_kbd_data     ;envoie Mois
.setdatewait4	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait4   
                move.b      (A1)+,acia_kbd_data     ;envoie Jour
.setdatewait5	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait5 
                move.b      (A1)+,acia_kbd_data     ;envoie Heure
.setdatewait6	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait6 
                move.b      (A1)+,acia_kbd_data     ;envoie minute
.setdatewait7	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setdatewait7 
                move.b      (A1),acia_kbd_data      ;envoie seconde
                move.b      #true,D0  
.setdateend     movem.l		minit_saveregs,A1
                rts




;           /-------------------------------------------------/
;           /   Fixe le nombre de ticks en X et Y declenchant /
;			/  le report de la position relative de la souris /
;           /   Parametres : 								  /
;			/				Nombre ticks en X	  			  /
;			/				Nombre ticks en Y				  /
;           /-------------------------------------------------/	

_STX_setikbdmousethreshold:
				movem.w		D1,minit_saveregs
.setthreswait1	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setthreswait1			;attendre
				move.b 		mouse_threshold,acia_kbd_data
.setthreswait2	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setthreswait2			;attendre
				move.w		4(A7),D1
				move.b 		D1,acia_kbd_data
.setthreswait3	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setthreswait3			;attendre				
				move.w		6(A7),D1
				move.b 		D1,acia_kbd_data
				movem.w 	minit_saveregs,D1

				
				
;           /-------------------------------------------------/
;           /   Fixe le nombre de ticks en X et Y definisant  /
;			/      l'echelle de deplacement de la souris      /
;           /   Parametres : 								  /
;			/				Nombre ticks en X	  			  /
;			/				Nombre ticks en Y				  /
;           /-------------------------------------------------/	

_STX_setikbdmousescale:
				movem.w		D1,minit_saveregs
.setscalewait1	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setscalewait1			;attendre
				move.b 		mouse_scale,acia_kbd_data
.setscalewait2	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setscalewait2			;attendre
				move.w		4(A7),D1
				move.b 		D1,acia_kbd_data
.setscalewait3	btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
				beq			.setscalewait3			;attendre				
				move.w		6(A7),D1
				move.b 		D1,acia_kbd_data
				movem.w 	minit_saveregs,D1



;           /-------------------------------------------------/
;           /   désinitialisation du Handler de traitement    /
;           /     de l'appel de la routine clavier pour la    / 
;           /  gestion joysticks, de la souris et des touches /
;           /-------------------------------------------------/

cont_uninitjoysticks:   

;           envoie commande au processeur du clavier pour stopper les evenements des joystick

.cont_uniwait1  btst.b		#1,acia_kbd_cont		;si buffer de transmission plein
                beq         .cont_uniwait1          ;attendre
                move.b      #joy_eventend,acia_kbd_data 	;stop l'envoi des évenements des joysticks  
.cont_uniwait2  btst.b		#1,acia_kbd_cont		;si buffer de transmission plein                
                beq         .cont_uniwait2          ;attendre
                move.b      #mouse_relative,acia_kbd_data	;active le mode mouse relative
                
;           remet le vecteur initiale de gestion du clavier
      
                move.l      cont_ikbd_base,D0
                move.l      D0,A5
                move.l      cont_ikbdvector,cont_ikbdsys(A5)
                rts
 


				SECTION BSS
       
       
cont_ikbd_base  DS.L        1                       ;sauvegarde du vecteur ikbd d'origine
cont_ikbdvector DS.L        1                       ;sauvegarde du vecteur du clavier d'origine
cont_datacount  DS.W		1						;compteur de données attendues
cont_lastheader DS.B        1                       ;mémorise le dernier header reçu
cont_mouse_but  DS.B        1                       ;etat des boutons de la souris
cont_mouse_dpx  DS.W        1                       ;deplacement souris relatif en X
cont_mouse_dpy  DS.W        1                       ;deplacement souris relatif en Y
cont_mouse_abx	DS.B		2						;deplacement souris absolu en X
cont_mouse_aby  DS.B		2						;deplacement souris absolu en Y
cont_mouse_ab	DS.B		1						;drapeau reception position absolue de la souris et reçue
cont_joy0data   DS.B        1                       ;données de retour du joystick 0
cont_joy1data   DS.B        1                       ;données de retour du joystick 1
cont_datetime	DS.B		6						;données date et Time
cont_dateflag	DS.B		1						;reception drapeau datetime
cont_keystable  DS.B		116						;table de booleen par activation ou relachement des touches
cont_savereg    DS.L        6                       ;sauvegarde registre avant appel interruption joystick

