

;           /--------------------------------------------/
;           /    Reference des fonctions exposées en C   /
;           /--------------------------------------------/

; Fonctions Génériques définies dans StGfxEngine.h
                XREF        _STX_initstxengine                          ;Initialisation des librairies composant la STGFXengine
                XREF        _STX_uninitstxengine                        ;Désinitialisation des librairies composant la STGFXengine
                XREF        _STX_setscreenclipping                      ;permet de fixer les valeurs de clipping de l'écran
                XREF        _STX_clearlogscreen                         ;efface l'écran logique de son contenu
                XREF        _STX_erasescreen                            ;efface écran logique ou physique avec le blitter
                XREF        _STX_swapscreen                             ;inverse les écrans physique et logique entre eux
                XREF        _STX_getworkscreen                          ;retourne l'adresse de l'écran logique mémorisé
                XREF        _STX_version                                ;retourne la version de la STGFX
                XREF        _STX_changecolor                            ;Change une couleur
                XREF        _STX_gettosversion                          ;retourne la version du TOS
                XREF        _STX_randomize                              ;retourne une valeur pseudo aléatoire sur 24 bit
                XREF        _STX_waitvbl                                ;attente du retour de la VBL
                XREF        _STX_machinetype                            ;retourne la valeur du cookies _MCH (numéro de machine)
                XREF		_STX_blitterpresent							;indique si le blitter est présent
				
; Fonction concernant le control des joysticks, de la souris et du clavier

                XREF        _STX_startjoystickreport                    ;active le report du status des joysticks et stop le report de la souris
                XREF        _STX_startmousereport                       ;active le report du status de la soruis et stop le report du status des joysticks
                XREF        _STX_getjoystickstatus                      ;interroge l'état des deplacements du joystick et du bouton d'action
                XREF        _STX_readikbdmouseposition                  ;lecture de la position absolue de la souris
                XREF        _STX_readikbdmouseoffset                    ;Lecture de la position relative de la souris
                XREF        _STX_readikbddateandtime                    ;Lecture de la date et de l'heure du système
                XREF        _STX_writeikbddateandtime                   ;Ecriture de la date et de l'heure du système
                XREF        _STX_setikbdmousethreshold                  ;Fixe le nombre de Tick nescessaire pour declencher le report de la position de la souris
                XREF        _STX_setikbdmousescale                      ;Fixe le nombre de Tick definissant un deplacement de 1 pixel à l'écran
                XREF        _STX_keyboardkeypress                       ;Verifie si la touche demandée est préssée
                
; Fonctions concernant les sprites définies dans spritelib.h                
                XREF        _STX_loadspriteset                          ;Chargement des motifs de sprite en mémoire LOADSPRT.S
                XREF        _STX_clearallsprites                        ;detruit tous les sprites (initialise la structure) GESTSPRT.S
                XREF        _STX_createsprite                           ;création d'un sprite à afficher à l'écran
                XREF        _STX_showallsprites                         ;affichage de tous les sprites actifs et crées
                XREF        _STX_showsprite                             ;affiche un sprite specifique
                XREF        _STX_clearsprite                            ;efface un sprite specifique
                XREF        _STX_enablesprite                           ;active un sprite specifique pour affichage
                XREF        _STX_disablesprite                          ;desactive un sprite specifique pour l'affichage
                XREF        _STX_getspriteenabled                       ;retourne true si sprite enabled
                XREF        _STX_getspriteposition                      ;retourne la position X et Y d'un sprite
                XREF        _STX_setspriteposition                      ;fixe la position X et Y d'un sprite
                XREF        _STX_movesprite                             ;incrementation et decrementation des coordonnées du sprite
                XREF        _STX_setanimation                           ;fourni l'adresse du tableau d'animation
                XREF        _STX_animationenable                        ;active ou désactive l'animation
                XREF        _STX_changespritemotif                      ;change le motif du sprite
                XREF        _STX_setboundingboxe                        ;fixe les coordonnées de la bounding boxe d'un sprite
                XREF        _STX_spritescollision                       ;detection d'une collision entre deux sprites
                XREF        _STX_spriteclipped                          ;indique si un sprite est hors de la zone d'affichage clipping
                XREF        _STX_spritespeedadjuste                     ;ajuste les valeur de deplacement d'un sprite par rapport à la fréquence de balayage
                
; Fonctions concernant la gestion des images définies dans imagelib.h
                XREF        _STX_loadpicture                            ;charge une image au format Neochrome, Degas ou Degas Elite
                XREF        _STX_blitloadedpicture                      ;Blitte une image chargée
                XREF        _STX_displayspriteset                       ;affiche un motif en tant qu'image du fichier spriteset
                
; Fonctions concernant la gestion des tiles définies dans tileslib.h                
                XREF        _STX_loadtilesmap                           ;chargement de la tilesmap
                XREF        _STX_savetilesmap                           ;sauvegarde de la tilesmap en mémoire
                XREF        _STX_restoretilesmap                        ;restore la tilesmap suite à une sauvegarde
                XREF        _STX_releasetilesmap                        ;destruction de la tilesmap en mémoire
                XREF        _STX_settilesmaparea                        ;positionne la tilesmap aux coordonnées X et Y sur l'écran et fourni la hauteur et la largeur en tile
                XREF        _STX_gettilepositionfromsprite              ;Fourni la position sur la map en X tile et Y tile d'un sprite
                XREF        _STX_gettileid                              ;retourne l'id d'un tile
                XREF        _STX_gettilevalue                           ;fourni la valeur et l'id d'un tile de 8 pixel de large par rapport à ces coordonnées dans la map
                XREF        _STX_gettilevaluefromtileid                 ;fourni la valeur d'un tile par rapport à son id
                XREF        _STX_changetilevalue                        ;modifie la valeur d'un tile et la remplace à l'écran avec sa nouvelle representation
                XREF        _STX_redrawtile                             ;redessine un tile présent à l'écran suite changement de valeur
                XREF        _STX_drawtilesmap                           ;affiche la tilesmap à partir d'un tile de départ
                XREF        _STX_gettileprop1                           ;fourni la propriété 1 d'un tile
                XREF        _STX_settileprop1                           ;fixe la valeur de la propriété 1 d'un tile
                XREF        _STX_gettileprop2                           ;fourni la propriété 2 d'un tile
                XREF        _STX_settileprop2                           ;fixe la valeur de la propriété 2 d'un tile
                XREF        _STX_gettileprop3                           ;fourni la propriété 3 d'un tile
                XREF        _STX_settileprop3                           ;fixe la valeur de la propriété 3 d'un tile
                XREF        _STX_gettilesmapsize                        ;fourni la taille (largeur et hauteur) en tile de la map
                XREF        _STX_getscreenpositionfromtile              ;fourni les coordonnées X et Y en pixel d'un tile dans la partie visible de la map
 
; Fonctions concernant la gestion des effets audio définies dans soundlib.h   
                XREF        _STX_setsoundtimer                          ;configuration de la frequence du timer audio
                XREF        _STX_loadsoundeffect                        ;chargement d'un fichier d'effet audio
                XREF        _STX_unloadsoundeffect                      ;liberation du fichier d'effet audio
                XREF        _STX_playsound1                             ;joue un effet audio sur le premier  canal
                XREF        _STX_Stopsound1                             ;stop l'effet audio du premier canal
                XREF        _STX_playsound2                             ;joue un effet audio sur le second canal
                XREF        _STX_Stopsound2                             ;stop l'effet audio du second canal
                XREF        _STX_playsound3                             ;joue un effet audio sur le troisiémé canal
                XREF        _STX_Stopsound3                             ;stop l'effet audio du troisième canal
                XREF        _STX_mutesound                              ;mute les trois canaux audio du yamaha
                XREF        _STX_loaddmasample                          ;charge un fichier d'echantillions audio au format ADS				
				XREF        _STX_unloaddmasample                        ;decharge un fichier d'échantillions audio WAV ou AVR
                XREF        _STX_playdmasample                          ;joue des echantillions audio
                XREF		_STX_stopdmasample						    ;stop la lecture des echantillions
                XREF        _STX_setdmasampleinterrupt                  ;active l'interruption en fin de lecture des échantillons
                XREF        _STX_removedmasampleinterrupt               ;supprime l'interruption en fin de lecture des échantillons
                XDEF        _STX_dmasampleendframe                      ;fonction appelée suite interruption en fin de lecture des échantillons
                
; Fonctions concernant la gestions des evenement au travers d'un dispatcher
                XREF        _STX_regevent                               ;inscription auprés du dispatcher
                XREF        _STX_sendevent                              ;envoie d'un evenement au dispatcher
                XREF        _STX_sendeventex                            ;envoie d'un evenement avec parametres au dispatcher
                XREF        _STX_getevent                               ;recupération d'un evenement précedement envoyé
                XREF        _STX_geteventex                             ;recupération d'un evenement avec les paramètres precedement envoyé

; Fonction concernant la gestion des charset defini dans gestchar.s 
				XREF		_STX_loadcharset							;chargement en mémoire des charset
				XREF        _STX_Unloadcharset                          ;libere la mémoire des charset
                XREF		_STX_printstring	    					;affichage d'un string avec les charsets
                XREF        _STX_charto2digit                           ;convertie un octet en une chaine decimale affichable sur 2 digit
                XREF        _STX_shortto3digit                          ;convertie un mot en une chaine decimale affichable sur 3 digit
                XREF        _STX_shortto4digit                          ;convertie un mot en une chaine decimale affichable sur 4 digit
                XREF        _STX_longto5digit                           ;convertie un mot long en une chaine decimale affichable sur 5 digit
                XREF        _STX_longto6digit                           ;convertie un mot long en une chaine decimale affichable sur 6 digit
                XREF        _STX_longto7digit                           ;convertie un mot long en une chaine decimale affichable sur 7 digit
                XREF        _STX_longto8digit                           ;convertie un mot long en une chaine decimale affichable sur 8 digit
 
;           /--------------------------------------------/
;           /    Definitions des valeurs et constantes   /
;           /--------------------------------------------/

false           EQU         $00                     ;valeur booleen faux
true            EQU         $FF                     ;valeur booleen vrai
        

;           /--------------------------------------------/
;           /      Definitions des variables systèmes    /
;           /--------------------------------------------/

tos_vbblock     EQU         $462                    ;compteur de vbl
tos_frlock      EQU         $466                    ;compteur de vbl executée
tos_colorptr    EQU         $45A                    ;si différent de 0, contient le vecteur de la palette de couleur
tos_screenpt    EQU         $45E                    ;si différent de 0, contient la nouvelle adresse de l'écran physique
tos_vblsem      EQU         $452                    ;si variable à 0 pas d'execution de la vbl
tos_v_bas_ad    EQU         $44E                    ;variable contenant l'adresse de l'écran logique
tos_sysbase     EQU         $4F2                    ;adresse to start the operating system

            
            SECTION TEXT

;           /--------------------------------------------/
;           /   Inclusion des definitions des adresses   / 
;           /          et registre du hardware           /
;           /--------------------------------------------/

            INCLUDE     MACROS.S                    ;definition des fonctions Bios, Xbios et Gemdos
            INCLUDE     BLITDEF.S                   ;definition des adresses et registres du blitter
            INCLUDE     SHIFTDEF.S                  ;definition des adresses et registre du shifter
            INCLUDE     2149DEF.S                   ;definition des adresses et registre du Yamaha YM2149
            INCLUDE     MFPDEF.S                    ;definition des adresses et registre du MFP 68901
            INCLUDE     VECTDEF.S                   ;definition des vecteurs d'interruptions de l'atari ST(e)
            INCLUDE     AUDMADEF.S                  ;definition des adresses du DMA audio
            

;           /-------------------------------------------------/
;           /   Controle l'initialisation des différentes     /
;           /    librairie composant le moteur graphique      /
;           /                 ST_GFXengine                    /
;           /                                                 /
;           /   parametre sur la pile :                       /
;           /     Valeur fréquence verticale (w)              /
;           /     nombre de sprite à créer (w)                / 
;           /-------------------------------------------------/

_STX_initstxengine:
                movem.l     D1-D7/A0-A6,minit_saveregs  ;sauvegarde des registres modifiés
                M_cconws    #minit_clrscr           ;effacement de l'écran physique car ici logique = physique encore
                M_modesuper blt_SavePile            ;passage en mode superviseur        
                
                move.l      tos_sysbase,A0          ;A0 pointe sur le début de la structure system
                move.w      $02(A0),minit_tosver    ;version du tos                
            
                move.w      6(A7),D6                ;recupreration nombre de sprite passé sur la pile
                jsr         initspritelib           ;initialisation de la librairie de sprite
                jsr         initscreenclipping      ;initialisation des valeur clipping pour sprite 16x16
                tst.w       D0                      ;si D0<0
                bmi         .minit_error            ;alors erreur durant initialisation de la librairie de sprite

;           /--------------------------------------------------------/
;           /      Modification de la resolution si pas en 320x200   /
;           /--------------------------------------------------------/ 

                lea         shf_BaseAddr,A0         ;A0 pointe sur le shifter
                move.b      sfh_RezVideo(A0),D7     ;D7 = resolution video actuelle
                move.b      D7,minit_rezvideo       ;sauvgarde resolution video actuelle
                cmpi.b      #shfm_4planRez,D7       ;si D7 = de resolution 320 x 200
                beq         .minit_freque           ;continuer avec la frequence
                move.b      #shfm_4planRez,sfh_RezVideo(A0);modifi la resolution en 320 x 200

;           /--------------------------------------------------------/
;           /       Modification de la frequence verticale           / 
;           /--------------------------------------------------------/                              

;            Recuperation des données transmises sur la pile

.minit_freque   move.w      4(A7),D7                ;recupreation frequence verticale demandée              

;           Lecture de la valeur de frequence verticale actuelle
                
                clr.w       D6                      ;efface d6
                move.b      shf_SyncVideo(A0),D6    ;D6 contient la frequence verticale actuelle
                move.w      D6,minit_freqver        ;sauvegarde frequence  actuelle
 
;           fixe la nouvelle frequence verticale 

                move.b      D7,shf_SyncVideo(A0)    ;fixe la nouvelle frequence (poid faible de D7) 
                lsr.w       #8,D7                   ;recupere le bit de poid fort de D7
                move.b      D7,minit_vbl_Div        ;mémorise le bit de poid fort (diviseur de vbl)
                move.b      D7,minit_vbl_DivCt      ;mémorise le bit de poid fort (compteur pour diviseur de vbl)

;       /--------------------------------------------------------/
;       /          Sauvegarde de la palette actuelle             / 
;       /--------------------------------------------------------/ 

                moveq       #0,D6                   ;efface D6 compteur de couleur
                moveq       #0,D7                   ;efface D7 index memoire
                lea         minit_palette,A6        ;pointe sur memoire de stockage valeur couleur             
.minit_Getcolor:
                M_setcolor  #$FFFF,D6               ;met -1 pour lecture couleur, numero de la couleur
                move.w      D0,(A6,D7)              ;sauvegarde la couleur en A6+D7
                addq.w      #1,D6                   ;incremete de 1 la couleur
                addq.w      #2,D7                   ;increment de 2 l'index
                cmpi.w      #17,D6                  ;si couleur <>17
                bne         .minit_Getcolor         ;continuer pour la couleur suivante                



;       /--------------------------------------------------------/
;       /          Gestion des deux écrans Xbios2 et Xbios3      / 
;       /--------------------------------------------------------/ 

;       recuperation de l'adresse de l'écran physique xbios2

                M_phybase                           ;recupération adresse écran physique
                move.l      D0,minit_xbios2         ;sauvegarde l'adresse de Xbios2
                move.l      D0,minit_savephy        ;sauvegarde l'adresse de Xbios2 pour retour à la normale

;       initialisation du double buffering xbios3 <> Xbios2

                M_malloc    #32256                  ;taille d'une image + 256 octets
                tst.l       D0                      ;si D0 < 0
                bmi         .minit_error            ;partir car erreur d'alloction mémoire
                move.l      D0,minit_alloclog       ;sauvegarde l'adresse de malloc pour libération
                andi.l      #$FFFFFF00,D0           ;D0 doit etre un multiple de 256    
                addi.l      #256,D0                 ;D0 contient la nouvelle adresse de xbios3 multiple de 256
                move.l      D0,minit_xbios3         ;sauvegarde adresse de xbios3
                          
;       fixe les nouvelle valeur de l'écran logique xbios3       
       
                M_setscreen #-1,minit_xbios2,minit_xbios3   ;conserve la résolution actuelle, xbios2 inchangé, xbios3 precedement allouée
                move.b      #false,minit_swapscr    ;initialisation du flag d'inversion d'écran
                move.l      minit_xbios3,minit_workscr;initialisation de l'adresse de l'écran de travail avec Xbios3
          

;       /--------------------------------------------------------/
;       /                   initialisation des joystick          / 
;       /--------------------------------------------------------/

                jsr         cont_initjoysticks      ;initialisation des joysticks

;       /--------------------------------------------------------/
;       /                   initialisation tilesmap              / 
;       /--------------------------------------------------------/

                lea         tlm_properties,A0       ;pointe sur les propriétés de la tilesmap     
                move.l      #0,tlm_tilesmap(A0)     ;efface le pointeur d'adresse de la tilesmaps
                move.l      #0,tlm_tileset(A0)      ;efface le pointeur d'adresse du tileset
                move.l      #0,tlm_tilesprop(A0)    ;efface le pointeur d'adresse des propriétés des tiles
                move.l      #0,tlm_tilesscreen(A0)  ;efface le pointeur d'adresse des positions des tiles à l'écran
                move.w      #0,tlm_1sttileX(A0)     ;initialise la position X de la tilesmap à l'écran
                move.w      #0,tlm_1sttileY(A0)     ;initialise la position Y de la tilesmap à l'écran
                move.w      #0,tlm_nbtilesW(A0)     ;initialisation de la largeur de la tilemap
                move.w      #0,tlm_nbtilesH(A0)     ;initialisation de la hauteur de la tilemap
                
;       /--------------------------------------------------------/
;       /            initialisation vecteur VBL  GFXST           / 
;       /--------------------------------------------------------/

                move.w      SR,D1                   ;mémorisation du registre de service
                move.w      #$2700,SR               ;arret des interruptions
                move.l      vec_68000vbl,minit_savevblv ;sauvegarde du vecteur d'interruption de la VBL
                move.l      #GFXST_VBL,vec_68000vbl ;nouveau vecteur d'interruption de la VBL
                move.b      #true,minit_vbl_Flag    ;initialise le flag à true
                move.b      #0,minit_vbl_skeep      ;initialise le compteur de saut de vbl
               
;       /--------------------------------------------------------/
;       /          initialisation vecteur Timer D du MFP         / 
;       /--------------------------------------------------------/  

                lea         mf_BaseAddr,A0                              ;A0 pointe sur le MFP
                move.w      mf_TCDCR_Reg(A0),minit_saveTCDCR            ;sauvegarde le registre TCDR
                move.w      mf_TDDR_Reg(A0),minit_saveTDDR              ;sauvegarde du registre TDDR
                move.w      mf_IMRB_Reg(A0),minit_saveIMRB              ;sauvegarde registre IMRB
                move.w      mf_IERB_Reg(A0),minit_saveIERB              ;sauvegarde resgistre IERB
                move.l      vec_68901timerD,minit_savetdvec             ;sauvegarde du vecteur d'interruption du timer D
                move.l      #GFXST_SOUND,vec_68901timerD                ;nouveau vecteur d'interruption timer D
                move.w      D1,SR                                       ;remet la valeur d'origine dans le Registre de service
                
;       /--------------------------------------------------------/
;       /           initialisation du processeur audio           / 
;       /--------------------------------------------------------/                
                
                jsr         snd_initsoundeffect                         ;initialisation des données audio
                
;       /--------------------------------------------------------/
;       /         initialisation du dispatcher d'evenement       / 
;       /--------------------------------------------------------/ 

                jsr         evnt_initdispatcher                         ;initialisation du dispatcher d'evenement

;       /--------------------------------------------------------/
;       /              initialisation des charsets               / 
;       /--------------------------------------------------------/ 

				jsr			chr_initcharset


                clr.w       D0
.minit_error:   movem.l     minit_saveregs,D1-D7/A0-A6                  ;restitution des registres modifiés
                rts                





;           /-------------------------------------------------/
;           /  Controle la désinitialisation des différentes  /
;           /    librairie composant le moteur graphique      /
;           /                 ST_GFXengine                    /
;           /-------------------------------------------------/

_STX_uninitstxengine:

                movem.l     D1/D6/A1/A5,minit_saveregs    ;sauvegarde des registres utilisés
                   
                jsr         uninitspritelib         ;désinitialisation de la librairie des sprites
                jsr         cont_uninitjoysticks    ;désinitialisation des joystick
                jsr         uninittilesmap          ;libération mémoire de tilesmap
                
;       /--------------------------------------------------------/      
;       /        restitution de l'écran logique et physisque     /
;       /        libération de la mémoire de l'écran logique     / 
;       /--------------------------------------------------------/ 

                M_setscreen #-1,minit_savephy,minit_savephy ;conserve la résolution actuelle, écran physique xbios2 inchangé, écran logique xbios3 = xbios2               
                move.l      minit_alloclog,D6       ;D6 = xbios3
                beq         .muinit_clr             ;si D6 = 0 donc erreur durant réservation mémoire alors partir
                M_mfree     D6                      ;liberation memoire de Xbios3
                
.muinit_clr     M_cconws    #minit_clrscr           ;effacement de l'écran physique car ici logique = physique encore

;       /--------------------------------------------------------/
;       /     Restitution de la resolution video  sauvegardée    / 
;       /--------------------------------------------------------/  
 
                lea         shf_BaseAddr,A0         ;A0 pointe sur le shifter
                move.b      minit_rezvideo,D7       ;D7 = resolution video actuelle
                cmpi.b      #shfm_4planRez,D7       ;si D7 = de resolution 320 x 200
                beq         .minit_freque           ;continuer avec la frequence
                move.b      minit_rezvideo,sfh_RezVideo(A0);remet la resolution initiale

;       /--------------------------------------------------------/
;       /    Restitution de la frequence verticale sauvegardée   / 
;       /--------------------------------------------------------/   

;          chargement valeur de frequence verticale d'origine              

.minit_freque   clr.w       D6                      ;efface D6
                move.w      minit_freqver,D6        ;charge D6 avec la valeur de la frequence d'origine             
                move.b      D6,shf_SyncVideo(A0)    ;fixe la frequence verticale sur sa valeur d'origine
                 
;       /--------------------------------------------------------/
;       /    restitution de la palette de couleur d'origine      /
;       /            valeurs sauvegardées dans INIT.S            /
;       /--------------------------------------------------------/

                M_setpalette    #minit_palette 
                              
;       /--------------------------------------------------------/
;       /            Libération du vecteur VBL  GFXST            / 
;       /--------------------------------------------------------/
                
                move.w      SR,D1                   ;mémorisation du registre de service
                move.w      #$2700,SR               ;arret des interruptions
                lea         minit_savevblv,A1       ;pointe sur l'adresse de sauvegarde du vecteur d'origine
                move.l      (A1),vec_68000vbl       ;remet le vecteur vbl d'origine
                
;       /--------------------------------------------------------/
;       /            Libération du vecteur Timer D               / 
;       /--------------------------------------------------------/

                lea         mf_BaseAddr,A0
                move.w      minit_saveTCDCR,mf_TCDCR_Reg(A0)  ;restitue le registre TCDR
                move.w      minit_saveTDDR,mf_TDDR_Reg(A0)    ;restitue le registre TDDR
                move.w      minit_saveIMRB,mf_IMRB_Reg(A0)    ;restitue le registre IMRB
                move.w      minit_saveIERB,mf_IERB_Reg(A0)    ;restitue le resgistre IERB
                move.l      minit_savetdvec,vec_68901timerD   ;restitue le vecteur du timer D
                move.w      D1,SR                   ;remet la valeur d'origine au registre de service
                
;       /--------------------------------------------------------/
;       /                Arret du processeur audio               / 
;       /--------------------------------------------------------/
                            
                jsr         snd_uninitsoundeffect   ;déinitialisation des données audio

;       /--------------------------------------------------------/
;       /             Liberation mémoire des charsets            / 
;       /--------------------------------------------------------/
				
				jsr			chr_uninitcharset
                
                M_modeuser  blt_SavePile            ;passage en mode utilisateur
                
                clr.w       D0                      ;retournera 0
                
                movem.l     minit_saveregs,D1/D6/A1/A5    ;restitution des registres utilisés
                M_pterm                             ;fin du processus, liberation des ressources
                rts

       
                         
   
;       /--------------------------------------------------------/
;       /       Inversion des écrans physique et logiques        /
;       /              Aucun parametre sur la pile               /
;       /--------------------------------------------------------/

_STX_swapscreen:    
                movem.l     D7-D4/A6-A3,minit_saveregs    ;sauvegarde des registres modifiés                
                move.w      initsp_nbsprit,D7       ;D7 contient le nombre de sprite
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites

;           lecture du flag d'inversion d'écran
              
                not.b       minit_swapscr           ;inversion des bits du flag d'inversion d'écran 
                beq         .minit_swap_no          ;si minit_swapscr = 0, remettre xbios2=xbios2 et xbios3=xbios3
 
;           inverser les écrans de tel sorte que Xbios2 = Xbios3

                    ;move.l      minit_xbios3,minit_screenpt    ;SI UTILISATION DU SCROLLING HARDWARE
                move.l      minit_xbios3,D0         ;adresse de l'écran physique xbios3 (si pas utilisation du scrolling hardware)
                lsr.w       #8,D0                   ;decalage de 8 bits à droite (si pas utilisation du scrolling hardware)
                move.l      D0,shf_BaseAddr         ;stockage dans registre SHIFTER (si pas utilisation du scrolling hardware)
                move.l      minit_xbios2,tos_v_bas_ad ;adresse de l'écran logique xbios2 pour le système
                move.l      minit_xbios2,minit_workscr;ecran de travail = Xbios2

;           Mode trace si demande, couleur verte = temps libre processeur

                move.w      4(A7),D5                ;D5 = valeur du flag
                beq         .minit_waitvbl0         ;si D5 = false, aller à .minit_waitvbl
                lea         shf_BaseAddr,A5         ;sinon A5 pointe sur le shifter
                move.w      #$0070,shf_RegColor_0(A5);la couleur de fond passe au vert

;           Attente de la VBL
                
.minit_waitvbl0 move.b      minit_vbl_skeep,D0      ;D0 = valeur compteur de saut de vbl
                move.b      #false,minit_vbl_Flag   ;passe le flag à false
.minit_waitvbl2 cmpi.b      #true,minit_vbl_Flag    ;si flag <> true
                bne         .minit_waitvbl2         ;aller à .minit_waitvbl2
                
;           Mode trace si demande, couleur rouge = temps occupation processeur

                tst.b       D5                      ;si D7 = false
                beq         .minit_clrsprt2         ;aller à .minit_clrsprt
                move.w      #$0700,shf_RegColor_0(A5);sinon la couleur de fond passe au rouge

;           fixer l'adresse de travail de memorisation du background sur sp_backgrnd_2 et effacer les sprites

.minit_clrsprt2 subq.w      #1,D7                   ;D7=D7-1 car id sprite commence à 0
                lsl.w       #2,D7                   ;multipli D7 par 4 (4 octets par adresse de structure de sprite)
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
.minit_backswp2 move.l      (A5,D7.W),A4            ;A4 pointe sur la derniere structure
                lea         sp_backgrnd_2(A4),A3    ;A3 pointe sur A4 + sp_backgrnd_2
                move.l      A3,sp_backgrnd_wrk(A4)  ;met la valeur de A3 dans sp_backgrnd_wrk(A4)
                move.l      A3,D6                   ;D6 contient l'adresse de stockage du background du sprite
                lea         sp_modback_2(A4),A3     ;A3 pointe sur A4 + sp_modback_2
                move.l      A3,sp_modback_work(A4)  ;met la valeur de A3 dans sp_modback_work(A4)
                move.b      (A3),D4                 ;D4 contient la valeur du mode d'affichage du background contenu dans sp_modback_2 ou sp_modback_3 
                lea         sp_screenpos_2(A4),A3   ;A3 pointe sur A4 + sp_screenpos_2
                move.l      A3,sp_screen_work(A4)   ;met la valeur de A3 dans sp_screen_work(A4)
                move.l      (A3),D5                 ;D5 contient l'adresse contenu dans sp_screen_2 ou sp_screen_3
                beq         .minit_nodisp2          ;si D5=0 (sprite non affiché à l'écran), passer au sprite suivant
                jsr         setbacksprite           ;affiche le background du sprite (efface le sprite)
                move.l      #0,(A3)                 ;met à 0 la position ecran du background car background réaffiché
.minit_nodisp2  subq.w      #4,D7                   ;decremente de 4 pour passer à la structure suivante
                bge         .minit_backswp2         ;si D7 >0, aller à .minit_backswp3  
                movem.l     minit_saveregs,D7-D4/A6-A3    ;restitution des registres modifiés            
                rts
                
                
;           inverser les écrans de tel sorte que Xbios2 = Xbios2 du depart
                
.minit_swap_no:    ;move.l      minit_xbios2,minit_screenpt    ;SI UTILISATION DU SCROLLING HARDWARE
                move.l      minit_xbios2,D0         ;adresse de l'écran physique xbios2 (si pas utilisation du scrolling hardware)
                lsr.w       #8,D0                   ;decalage de 8 bits à droite (si pas utilisation du scrolling hardware)
                move.l      D0,shf_BaseAddr         ;stockage dans registre SHIFTER (si pas utilisation du scrolling hardware)
                move.l      minit_xbios3,tos_v_bas_ad ;adresse de l'écran logique xbios3 pour le système
                move.l      minit_xbios3,minit_workscr;ecran de travail = Xbios2 

;           Mode trace si demande, couleur verte = temps libre processeur

                move.w      4(A7),D5                ;D5 = valeur du flag
                beq         .minit_waitvbl1         ;si D5 = false, aller à .minit_waitvbl
                lea         shf_BaseAddr,A5         ;sinon A5 pointe sur le shifter
                move.w      #$0070,shf_RegColor_0(A5);la couleur de fond passe au vert


;           Attente de la VBL
                
.minit_waitvbl1 move.b      minit_vbl_skeep,D0      ;D0 = valeur compteur de saut de vbl
                move.b      #false,minit_vbl_Flag   ;passe le flag à false
.minit_waitvbl3 cmpi.b      #true,minit_vbl_Flag    ;si flag <> true
                bne         .minit_waitvbl3         ;aller à .minit_waitvbl2

;           Mode trace si demande, couleur rouge = temps occupation processeur

                tst.b       D5                      ;si D5 = false
                beq         .minit_clrsprt3         ;aller à .minit_clrsprt
                move.w      #$0700,shf_RegColor_0(A5);sinon la couleur de fond passe au rouge

;           fixer l'adresse de travail de memorisation du background sur sp_backgrnd_3

.minit_clrsprt3 subq.w      #1,D7                   ;D7=D7-1 car id sprite commence à 0
                lsl.w       #2,D7                   ;multipli D7 par 4 (4 octets par adresse de structure de sprite)
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
.minit_backswp3 move.l      (A5,D7.W),A4            ;A4 pointe sur la derniere structure
                lea         sp_backgrnd_3(A4),A3    ;A3 pointe sur A4 + sp_backgrnd_3
                move.l      A3,sp_backgrnd_wrk(A4)  ;met la valeur de A3 dans sp_backgrnd_wrk(A4)
                move.l      A3,D6                   ;D6 contient l'adresse de stockage du background du sprite
                lea         sp_modback_3(A4),A3     ;A3 pointe sur A4 + sp_modback_3
                move.l      A3,sp_modback_work(A4)  ;met la valeur de A3 dans sp_modback_work(A4)
                move.b      (A3),D4                 ;D4 contient la valeur du mode d'affichage du background contenu dans sp_modback_2 ou sp_modback_3 
                lea         sp_screenpos_3(A4),A3   ;A3 pointe sur A4 + sp_screenpos_3
                move.l      A3,sp_screen_work(A4)   ;met la valeur de A3 dans sp_screen_work(A4)
                move.l      (A3),D5                 ;D5 contient l'adresse contenu dans sp_screen_2 ou sp_screen_3
                beq         .minit_nodisp3          ;si D5=0 (sprite non affiché à l'écran), passer au sprite suivant
                jsr         setbacksprite           ;affiche le background du sprite (efface le sprite)
                move.l      #0,(A3)                 ;met à 0 la position ecran du background car background réaffiché
.minit_nodisp3  subq.w      #4,D7                   ;decremente de 4 pour passer à la structure suivante
                bge         .minit_backswp3         ;si D7 >0, aller à .minit_backswp3
                movem.l     minit_saveregs,D7-D4/A6-A3    ;restitution des registres modifiés            
                rts
                



;       /--------------------------------------------------------/
;       /               Vecteur d'Interruptoin VBL               /
;       /        Gestion des demandes de changement de couleur   /
;       /         Inversion des écrans physique et logiques      /
;       /--------------------------------------------------------/

GFXST_VBL:      movem.l     D0/A0-A1,-(sp)
                addq.l      #1,tos_vbblock          ;incremente compter systéme appel VBL _vbblock
                move.w      tos_vblsem,D0           ;D0 = interruption systéme vbl _vblsem
                beq         .gfxst_vbl_end          ;si D0 = 0, interruption du traitemnt des procedure de la vbl
                addq.l      #1,tos_frlock           ;incremente compter systéme VBL effectuée _frlock
                
;           diviseur de fréquence pour 30hz et 25hz

                tst.b       minit_vbl_DivCt         ;si diviseur de frequence = 0
                beq         .gfxst_color
                subq.b      #1,minit_vbl_DivCt
                bra         .gfxst_vbl_end

;           affectation des couleurs si vecteur minit_colorptr <> 0
                
.gfxst_color    lea         tos_colorptr,A0         ;A0 pointe sur le vecteur d'affectation des couleurs
                tst.l       (A0)                    ;si (A0) = 0
                beq         .gfxst_phybase          ;aller à .gfxst_phybase
                move.l      (A0),A1                 ;A1 pointe sur la premiere valeur de couleur
                move.l      #0,(A0)                 ;remet le vecteur de couleur à 0
                lea         shf_BaseAddr+shf_RegColor_0,A0 ;A0 pointe sur le shifter
                move.w      (A1)+,(A0)+				;Affecte la couleur 0 (shf_RegColor_0)
                move.w      (A1)+,(A0)+				;Affecte la couleur 1 (shf_RegColor_1)
                move.w      (A1)+,(A0)+				;Affecte la couleur 2 (shf_RegColor_2)
                move.w      (A1)+,(A0)+				;Affecte la couleur 3 (shf_RegColor_3)
                move.w      (A1)+,(A0)+				;Affecte la couleur 4 (shf_RegColor_4)
                move.w      (A1)+,(A0)+				;Affecte la couleur 5 (shf_RegColor_5)
                move.w      (A1)+,(A0)+				;Affecte la couleur 6 (shf_RegColor_6)
                move.w      (A1)+,(A0)+				;Affecte la couleur 7 (shf_RegColor_7)
                move.w      (A1)+,(A0)+				;Affecte la couleur 8 (shf_RegColor_8)
                move.w      (A1)+,(A0)+				;Affecte la couleur 9 (shf_RegColor_9)
                move.w      (A1)+,(A0)+				;Affecte la couleur 10 (shf_RegColor_10)
                move.w      (A1)+,(A0)+				;Affecte la couleur 11 (shf_RegColor_11)
                move.w      (A1)+,(A0)+				;Affecte la couleur 12 (shf_RegColor_12)
                move.w      (A1)+,(A0)+				;Affecte la couleur 13 (shf_RegColor_13)
                move.w      (A1)+,(A0)+				;Affecte la couleur 14 (shf_RegColor_14)
                move.w      (A1),(A0)				;Affecte la couleur 15 (shf_RegColor_15)
 
;           affectation de la nouvelle adresse de l'écran physique version STE pour scrolling Hardware 

.gfxst_phybase  lea         tos_screenpt,A0         ;A0 pointe sur le vecteur d'affection de l'adresse de l'écran physique      
                tst.l       (A0)                    ;si (A0) = 0
                beq         .gfx_vblflag            ;aller à .gfx_vblflag
                move.l      (A0),D0                 ;D0 = nouvelle adresse de l'écran physique
                move.l      #0,(A0)                 ;efface l'adresse contenu dans minit_screenpt
                lea         shf_BaseAddr,A0         ;A0 pointe sur l'adresse du shifter
                lsr.w       #8,D0                   ;decalage de 8 bits à droite
                move.l      D0,(A0)                 ;stockage D0 dans shf_HighMemVideo et shf_MidlMemVideo
                move.w      #0,shf_LowMemVideo(A0)  ;met shf_LowMemVideo à 0 A REVOIR SI ADRESSE ECRAN PAS MULTIPLE DE 256
                move.w      #0,shf_LineWideOffset(A0)   ;pas d'offset de ligne car pas de scrolling 
                move.w      #0,shf_FineScrollH(A0)      ;pas de décallage horizontal car pas de scrolling
                move.l      D0,shf_HighAddVideo(A0) ;stockage D0 dans shf_HighAddVideo et shf_MidlAddVideo
                move.w      #0,shf_LowAddVideo(A0)  ;met shf_LowAddVideo à 0 A REVOIR SI ADRESSE ECRAN PAS MULTIPLE DE 256
                               
;           positionne le flag de vbl + compteur de saut de vbl (skeep frames)
                
.gfx_vblflag    tst.b       minit_vbl_Flag          ;si minit_vbl_Flag = 0 (false)
                beq         .gfx_vblflagok          ;aller à .gfx_vblflagok
                addq.b      #1,minit_vbl_skeep      ;sinon incrementer le compteur de saut de vbl
                bra         .gfxst_vbl_end          ;aller à .gfxst_vbl_end

.gfx_vblflagok  move.b      #true,minit_vbl_Flag    ;positionne le flag de vbl à true 
                clr.b       minit_vbl_skeep         ;remise à zero du compteur de saut de vbl
                move.b      minit_vbl_Div,minit_vbl_DivCt;réinitialiser le diviseur de frequence
                      
.gfxst_vbl_end: movem.l     (sp)+,D0/A0-A1
                rte



;       /--------------------------------------------------------/
;       /          Retourne un pointeur contenant l'adresse      /
;       /                de l'écran logique xbios(3)             /
;       /--------------------------------------------------------/
                
_STX_getworkscreen:
                move.l      minit_workscr,D0
                rts



;       /--------------------------------------------------------/
;       /        Change une valeur de couleur immediatement      /
;       /   parametres:                                          /
;       /       numero de la couleur (0 à 15)                    /
;       /       valeur de la couleur                             /
;       /--------------------------------------------------------/

_STX_changecolor:
                movem.l     D7/A6,minit_saveregs
                lea         shf_BaseAddr,A6         ;pointe sur le shifter
                move.w      4(A7),D7                ;numero de la couleur à modifier
                cmpi.w      #15,D7                  ;si D7 > 15
                bgt         .stgfx_chgcolend        ;fin, pas de changement de couleur
                lsl.w       #1,D7                   ;multipli D7 par 2
                move.w      6(A7),shf_RegColor_0(A6,D7.W);met la valeur à l'adresse shf_BaseAddr + shf_RegColor_0 + D7
.stgfx_chgcolend:
                movem.l     minit_saveregs,D7/A6
                rts



;       /--------------------------------------------------------/
;       /          Retourne un pointeur sur la version           /
;       /                   de la STGFX Engine                   /
;       /--------------------------------------------------------/

_STX_version:
                move.l      #minit_version,D0       ;met l'adresse des informations de version dans D0
                rts                



;       /--------------------------------------------------------/
;       /       Retourne la version du TOS en valeur ASCII       /
;       /--------------------------------------------------------/

_STX_gettosversion:
                move.w      minit_tosver,D0
                andi.w      #$000F,D0
                addi.b      #$30,D0
                move.b      D0,minit_osversion+3
                
                move.w      minit_tosver,D0
                andi.w      #$00F0,D0
                lsr.w       #4,D0
                addi.b      #$30,D0
                move.b      D0,minit_osversion+2
                
                move.w      #46,minit_osversion+1
                
                move.w      minit_tosver,D0
                andi.w      #$0F00,D0
                lsr.w       #8,D0
                addi.b      #$30,D0
                move.b      D0,minit_osversion
                
                move.b      #0,minit_osversion+4
                
                move.l      #minit_osversion,D0
                rts


;       /--------------------------------------------------------/
;       /          Retourne une valeur pseudo-aléatoire          /
;       /--------------------------------------------------------/   
             
_STX_randomize:               
                M_random
                rts
            

;       /--------------------------------------------------------/
;       /              Attends le retour de la VBL               /
;       /--------------------------------------------------------/             
_STX_waitvbl:
                M_vsync
                rts
                
                

;       /--------------------------------------------------------/
;       /            Effacement de l'écran logique               /
;       /             Aucun parametre sur la pile                /
;       /--------------------------------------------------------/

_STX_clearlogscreen
                movem.l     A1,minit_saveregs
                lea         blt_BaseAddr+blt_SrcXinc,A1
                move.w      #0,(A1)+                ;Source X increment
                move.w      #0,(A1)+                ;Source Y increment
                move.l      4(A7),(A1)+             ;Source Addr
                move.w      #$FFFF,(A1)+            ;Mask 1
                move.w      #$FFFF,(A1)+            ;Mask 2
                move.w      #$FFFF,(A1)+            ;Mask 3
                move.w      #2,(A1)+                ;Dest X increment
                move.w      #2,(A1)+                ;Dest Y increment
                move.l      minit_workscr,(A1)+     ;Dest Addr
                move.w      #80,(A1)+               ;Xcount
                move.w      #200,(A1)+              ;Ycount
                move.w      #$0200,(A1)+            ;Half Tone & Operation logique (tout à 0)
                move.w      #$8000,(A1)             ;Demarrage blitter en partage de bus & Skew
                
.clr_loop1      bset.b      #7,(A1)                 ;redemarre le blitter
                nop
                bne         .clr_loop1
                
                movem.l     minit_saveregs,A1
                rts
                


;       /--------------------------------------------------------/
;       /               Lecture du cookies Machine               /
;       /             retourne : numéro de la machine            /
;       /--------------------------------------------------------/

_STX_machinetype:
                movem.l     D1,minit_saveregs
				M_getcookies    '_MCH',D0           ; recherche le cookies _MCH
                tst.b		D0						; si D0 < 0
				bmi			.mch_nocookies			; alors pas de cookies
				move.l		D0,D1					; met D0 dans D1
				swap		D1						; inverse mot poids fort avec mot poid faible
				lsl.w		#8,D1					; décale de 8 bits à gauche
				or.w		D1,D0					; combine D1 et D0
.mch_nocookies	movem.l     minit_saveregs,D1			
				rts
               



;       /--------------------------------------------------------/
;       /               Lecture du status du blitter             /
;       /            retourne : true si blitter present          /
;       /--------------------------------------------------------/

_STX_blitterpresent:
				M_blitmode	#-1						;interroge le status du blitter
				btst.b		#1,D0					;test le bit1 de DO
				beq			.blit_nohard			;si bit1 = 0, alors pas de blitter
				move.b		#$FF,D0					;sinon blitter present
				rts
.blit_nohard	move.b		#$00,D0					;blitter absent
				rts




                SECTION BSS
                
minit_freqver:  DS.W        1                       ;frequence verticale actuelle (initialisé à 50hz)
minit_palette:  DS.W        16                      ;valeur de la palette actuelle
minit_xbios2:   DS.L        1                       ;sauvegarde de l'adresse de xbios2
minit_xbios3:   DS.L        1                       ;sauvegarde adresse de xbios3
minit_savephy:  DS.L        1                       ;sauvegarde adresse ecran physique xbios2
minit_workscr:  DS.L        1                       ;adresse de l'écran de travaille
minit_alloclog: DS.L        1                       ;sauvegarde l'adresse mémoire reservée pour l'écran logique
minit_rezvideo: DS.B        1                       ;valeur resolution actuelle
minit_vbl_ste   DS.B        1                       ;si false pas de version ste pour la vbl (non utilisé)
minit_saveregs: DS.B        60                      ;sauvegarde des registres D0-D7/A0-A6 
minit_savevblv: DS.L        1                       ;sauvegarde le vecteur de l'interruption VBL
minit_vbl_Flag  DS.B        1                       ;flag de vbl
minit_vbl_skeep DS.B        1                       ;compteur de saut de frames
minit_vbl_Div:  DS.B        1                       ;diviseur de fréquence de balayage
minit_vbl_DivCt DS.B        1                       ;compteur du divseur de fréquence de balayage (30Hz et 25Hz)
minit_swapscr:  DS.B        1                       ;drapeau d'inversion d'ecran logique ou physique
minit_osversion DS.B        5                       ;version de l'os (TOS) en mode caratere
minit_tosver:   DS.W        1                       ;TOS version

minit_savetdvec DS.L        1                       ;sauvegarde du vecteur d'interruption du timer D               
minit_saveTCDCR DS.W        1                       ;sauvegarde valeur de diviseur timer C et D                
minit_saveTDDR: DS.W        1                       ;sauvegarde valeur de compteur timer D 
minit_saveIMRB: DS.W        1                       ;sauvegarde les masques d'interruption du registre B (Timer C et D)      
minit_saveIERB: DS.W        1                       ;sauvegarde de l'activation / déactivation des interruption du registre B


                SECTION DATA

minit_clrscr:   DC.B        27,'E',0,0              ;sequence d'effacement de l'ecran     
minit_version:  DC.B        '1','.','0','0',0,0     ;numéro de la version de la STGFX engine


 
 
;           /----------------------------------------------/
;           /      Inclusion des differents fichiers       /
;           /               de la librairie                /
;           /----------------------------------------------/

                
                INCLUDE     INITSPRT.S              ;Initialisation de la librairie de sprites  
                INCLUDE     LOADSPRT.S              ;chargement motif des sprites en memoire
                INCLUDE     GESTSPRT.S              ;fonctions pour gestion des sprites
                INCLUDE     SETCLIP.S               ;fonctions permettant de fixer les valeurs de clipping
                INCLUDE     BLITSPRT.S              ;fonctions d'affichage d'un sprite à l'écran
                INCLUDE     CONTROL.S               ;fonctions de gestion des joysticks
                INCLUDE     IMAGES.S                ;fonctions de gestion des images
                INCLUDE     GESTILES.S              ;fonctions de gestions des tiles
                INCLUDE     DRAWTILE.S              ;fonctions permettant de dessiner un tiles
                INCLUDE     GESTSND.S               ;fonction de gestion des effets audio
                INCLUDE     EVENTDIS.S              ;fonction de gestion du dispatcher d'evenement
                INCLUDE		GESTCHAR.S				;fonction de gestion des charateres 
                