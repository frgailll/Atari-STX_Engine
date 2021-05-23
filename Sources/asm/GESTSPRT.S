;                     SOUS PROGRAMME GESTSPRT
;              Gestion des sprites affiché à l'écran
;          utilisation des motif chargés depuis LOADSPRT


                SECTION TEXT
                

;           /----------------------------------------------------/
;           / Effacement de tous les sprites, initialisation des /
;           /             structures des sprites                 /
;           /   Parametres : aucun                               /
;           /   retour : aucun                                   /
;           /----------------------------------------------------/

_STX_clearallsprites:
gst_initsptstruct:
                movem.l     D6-D7/A5-A6,-(A7)       ;sauvegarde des registres
                move.w      initsp_nbsprit,D7       ;D7 contient le nombre de sprites à créer                
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
.gst_clear1     move.l      (A5)+,A6                ;A4 pointe sur la premiere structure, incrementation de 4 de A5
                move.b      #false,sp_created(A6)   ;efface le premiere sprite
                move.b      #false,sp_anim_enable(A6)   ;pas d'animation  
                move.l      A6,D6                   ;D6 contient l'adresse de la structure
                addi.l      #sp_backgrnd_3,D6       ;ajout de l'offset de sp_backgrnd_3
                move.l      D6,sp_backgrnd_wrk(A6)  ;initialise dans l'adresse sp_backgrnd_3 dans sp_backgrnd_wrk
                move.l      A6,D6                   ;D6 contient l'adresse de la structure
                addi.l      #sp_screenpos_3,D6      ;ajout de l'offset sp_screenpos_2 à D6
                move.l      D6,sp_screen_work(A6)   ;met D6 (adresse position dans l'ecran) dans l'adresse de travail de l'ecran
                move.l      #0,sp_screenpos_2(A6)   ;initialise la position du background à 0 (pas de background memorisé)
                move.l      #0,sp_screenpos_3(A6)   ;initialise la position du background à 0 (pas de background memorisé)
                move.l      A6,D6                   ;D6 contient l'adresse de la structure du sprite
                addi.l      #sp_modback_3,D6        ;ajout de l'offset sp_modback_3 à D6
                move.l      D6,sp_modback_work(A6)  ;met D6 (mode d'affichage background 32x16 ou 16x16) dans l'adresse de travail de mode              
                subi.w      #1,D7                   ;decrement D7 le nombre de sprite
                tst.w       D7                      ;si D7 <> 0
                bne         .gst_clear1
                movem.l     (A7)+,D6-D7/A5-A6       ;restitution des registres
                rts
                
                
;           /----------------------------------------------------/
;           /    Création d'un sprite pour affichage à l'écran   /
;           /    definition du motif et coordonnées initiales    /
;           /    parametres sur pile:   n°motif                  /
;           /                           position X               /
;           /                           position Y               /
;           /                           enable                   /
;           /   retour :  D0=-1 si erreur sinon numéro du sprite /
;           /----------------------------------------------------/

_STX_createsprite:  
                movem.l     D6/A5-A6,minit_saveregs ;sauvegarde des registres
                move.w      #0,D0                   ;met le numero du premier id de sprite
                move.w      initsp_nbsprit,D6       ;D6 contient le nombre de sprites à créer
                subq.w      #1,D6                   ;decremente D6 de 1 car id sprite commence à 0
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
.gst_structsuiv:                
                move.l      (A5)+,A6                ;A4 pointe sur la premiere structure, incrementation de 4 de A5
                tst.b		sp_created(A6)			;Verifie si structure non utilisée
				beq         .gst_structfree         ;aller à structfree pour remplir la structure avec les valeurs
                addq.w      #1,D0                   ;incremente D0 de 1, id sprite suivant
                cmp.w       D0,D6                   ;si D6 >= D0 compare la structure actuelle avec le nombre de strucutre totale (nombre de sprites à créer)
                bge         .gst_structsuiv         ;verifier la structure suivante
                move.w      #$FFFF,D0               ;pas de structure de libre D0=-1
                movem.l     minit_saveregs,D6/A5-A6 ;restitution des registres
                rts                                 ;retour au programme appelant               
.gst_structfree:    
                move.b      #true,(A6)+    			;(sp_created) structure utilisée par un sprite
                move.b      11(A7),(A6)+    		;(sp_enable) recuperation de l'activation ou non du sprite
				move.w      4(A7),(A6)+			    ;(sp_nrmotif) recuperation numéro du motif sur A7
                move.w      6(A7),(A6)+				;(sp_posx_aff) recuperation position X du sprite
                move.w      8(A7),(A6)+			    ;(sp_posy_aff) recuperation position Y du sprite
				move.b      #false,(A6)+   			;(sp_clipped) met le flag de clipping à false
			    move.b      #false,(A6)+   			;(sp_anim_enable) pas d'animation
                move.l      #$00000000,(A6)+  		;(sp_anim_tab) met à 0 l'adresse de l'animation
                move.b      #0,(A6)+   				;(sp_anim_tabpos) position dans le tableau d'animation
                move.b      #1,(A6)+   				;(sp_anim_vitess) vitesse d'animation
                move.b      #0,(A6)+  				;(sp_anim_counter) compteur d'avancement de l'animation
                move.b      #true,(A6)+  			;(sp_anim_loop) animation en boucle
                move.w      #0,(A6)+      			;(sp_aabbox_x) bounding boxe X
                move.w      #0,(A6)+      			;(sp_aabbox_y) bounding boxe Y
                move.w      #16,(A6)+     			;(sp_aabbox_w) bounding boxe largeur
                move.w      #16,(A6)+     			;(sp_aabbox_h) bounding boxe hauteur
                movem.l     minit_saveregs,D6/A5-A6 ;restitution des registres
                rts                                 ;retour au programme appelant
                
                
;           /----------------------------------------------------/
;           /      Affichage de tous les sprites à l'écran       /
;           /    ne tient pas compte du parametre priorite_z     /
;           /       parametres:                                  /
;           /           Aucun                                    /
;           /       retourne:                                    /
;           /           Rien                                     /
;           /----------------------------------------------------/

_STX_showallsprites: 
                movem.l     D1-D7/A2-A6,-(A7)       ;sauvegarde tous les registres sauf D0
                moveq       #0,D2                   ;efface D2 sur 32 bits (pour blitsprite)
                lea         initsp_tabsprt,A3       ;A3 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.w      4(A3),D7                ;D7 contient le nombre de sprites à afficher (initsp_nbsprit)
                move.l      (A3),A3                 ;A3 pointe sur le debut du bloc de structure des sprites
.gst_shoallsuiv:                
                move.l      (A3)+,A2                ;A2 pointe sur la premiere structure, incrementation de 4 de A3
                
;           verification si sprite crée et enable
                
                move.w      (A2),D1                 ;D1 = sp_created(poid ford) & sp_enable(poid faible)
                cmpi.w      #$FFFF,D1               ;si D1 <> $FFFF (si sp_created <> True & sp_enable <> True)
                bne         .gst_shoallno           ;alors pas d'affichage 
                    
;           verification si animation enable

                tst.b		sp_anim_enable(A2)		;si sp_anim_enable <> true
				beq			.gst_shoallnoanim		;alors pas d'animation
				jsr         gst_animsprite          ;aller sous-programme animation

;           affichage du sprite

.gst_shoallnoanim: 
                move.l      minit_workscr,D5        ;D5 contient l'adresse de l'ecran de travail              
                move.w      sp_nrmotif(A2),D3       ;D3 contient le numéro du sprite à afficher
                move.w      sp_posx_aff(A2),D1      ;D1 contient la position X d'effacement du sprite
                move.w      sp_posy_aff(A2),D2      ;D2 contient la position Y d'effacement du sprite
                move.l      sp_backgrnd_wrk(A2),gback_store ;adresse de sauvegarde de l'arriere plan              
                jsr         blitsprite              ;Appel fonction BLITSPRITE

;           recuperation des informations pour le reaffichage du background
                
                move.l      sp_screen_work(A2),A6   ;A6 pointe sur l'adresse contenu dans sp_screen_work (sp_screenpos_2 ou sp_screenpos_3)
                move.b      D0,sp_clipped(A2)       ;indique si clipping (True) ou non (false)
				beq         .gst_nocliping          ;si D0=0, aller à .gst_nocliping
                move.l      #0,gback_posaddr        ;sinon mettre 0 dans gback_posaddr (pour ne pas reafficher un background non sauvegardé)
.gst_nocliping  move.l      gback_posaddr,(A6)      ;sauvegarde la l'adresse de position du background dans sp_screenpos_2 ou sp_screenpos_3
                move.l      sp_modback_work(A2),A6  ;A6 pointe sur l'adresse contenu dans sp_screen_work (sp_modback_2 ou sp_modback_3)
                move.b      gback_mode3216,(A6)     ;sauvegarde du mode d'affichage du background dans sp_modback_2 ou sp_modback_3

;           sprite suivant

.gst_shoallno   subq.w      #1,D7                   ;decremente le nombre de sprite à afficher
                bne         .gst_shoallsuiv         ;si <> 0 alors verifier la structure suivante 
                movem.l     (A7)+,D1-D7/A2-A6  ;restitution de tous les registres sauf D0
                rts                                 ;retour programme appelant
                      

         
                
;           /----------------------------------------------------/
;           /         Detruit un sprite precedement créé         /
;           /       retourne -1 si sprite pas créé sinon 0       /
;           /----------------------------------------------------/

_STX_clearsprite:   
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile 
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_clearend           ;quitter et retourner -1                             
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_clearend           ;quitter et retourner -1
                move.b      #false,sp_created(A6)   ;marque le sprite libre
                move.b      #false,sp_anim_enable(A6)   ;marque animation desable
                move.l      #$00000000,sp_anim_tab(A6)   ;efface adresse d'animation
                clr.w       D0
.gst_clearend   movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts


;           /----------------------------------------------------/
;           /       Active un sprite précedement désactivé       /
;           /       retourne -1 si pas créé sinon retourne 0     /
;           /----------------------------------------------------/
                
_STX_enablesprite:  
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile 
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_enabend            ;quitter et retourner -1               
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_enabend            ;quitter et retourner -1
                move.b      #true,sp_enable(A6)     ;sinon Sprite Enable
                clr.w       D0                      ;efface D0 car pas d'erreur
.gst_enabend    movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts
                

;           /----------------------------------------------------/
;           /   Désactive le sprite si celui-ci est déja créé    /
;           /       retourne -1 si pas créé sinon retourne 0     /
;           /----------------------------------------------------/

_STX_disablesprite: 
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_desabend           ;quitter et retourner -1                
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_desabend           ;quitter et retourner -1
                move.b      #false,sp_enable(A6)    ;sinon Sprite desable
                clr.w       D0                      ;efface D0 car pas d'erreur
.gst_desabend   movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts
                

;           /----------------------------------------------------/
;           /            renvoie le status du sprite             /
;           /     retourne false si pas créé ou desable          / 
;           /               sinon retourne true                  /
;           /----------------------------------------------------/

_STX_getspriteenabled:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                clr.w       D0                      ;efface D0 car retournera une valeur sur 16 bits
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_getenabend         ;quitter et retourner -1               
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_getenabend         ;quitter et retourner false
                move.b      sp_enable(A6),D0        ;retournera dans D0 le status du sprite
.gst_getenabend movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts
                

;           /----------------------------------------------------/
;           / renvoie par reference les valeurs de Posx et Posy  /
;           /      retourne -1 si sprite pas créé sinon 0        / 
;           /----------------------------------------------------/

_STX_getspriteposition:
                movem.l     D7/A5-A6,minit_saveregs ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_getposend          ;quitter et retourner -1                
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
                move.l      (A5,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dann°D7        
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_getposend          ;quitter et retourner false
                move.l      6(A7),A5                ;recuperation adresse de Posx sur la pile
                move.w      sp_posx_aff(A6),(A5)    ;met la valeur posx dans l'adresse pointée par A6
                move.l      10(A7),A5               ;recuperation adresse de Posy sur la pile
                move.w      sp_posy_aff(A6),(A5)    ;met la valeur posy dans l'adresse pointée par A5
                clr.w       D0                      ;efface D0 car pas d'erreur
.gst_getposend  movem.l     minit_saveregs,D7/A5-A6 ;restitution des registres
                rts
              

;           /----------------------------------------------------/
;           /   Fixe les nouvelles valeur du positionnement du   /
;           /  sprite retourne -1 si sprite pas créé sinon 0     / 
;           /----------------------------------------------------/

_STX_setspriteposition:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_setposend          ;quitter et retourner -1                
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_setposend          ;quitter et retourner false
                move.w      6(A7),sp_posx_aff(A6)   ;sauvegarde la valeur de posx du sprite n°D7
                move.w      8(A7),sp_posy_aff(A6)   ;sauvegarde la valeur de posy du sprite n°D7
                move.b      #false,sp_clipped(A6)   ;met le flag de clipping à false
                clr.w       D0                      ;efface D0 car pas d'erreur
.gst_setposend  movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts
                


;           /----------------------------------------------------/
;           / incremente ou decremente les coordonnées du sprite /
;           /                    en x et y                       /
;           /  parametres pile :    n°sprite                     /
;           /                       incx                         /
;           /                       incy                         /
;           /  retour : -1 si sprite pas créé ou disable         / 
;           /           1 si clipping                            /
;           /           0 si pas erreur                          /
;           /----------------------------------------------------/

_STX_movesprite:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_movspend           ;quitter et retourner -1               
                lsl.w       #2,D7                   ;multiplie D7 par 4 (4 octets par pointeur de structure)
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dann°D7        

;           verification si sprite crée et enable
                
                move.w      (A6),D1                 ;D1 = sp_created(poid ford) & sp_enable(poid faible)
                cmp.w       D0,D1                   ;si D1 <> $FFFF (si sp_created <> True & sp_enable <> True)
                bne         .gst_movspend           ;alors pas d'affichage 
               
;       verification si sprite en dehors de la zone d'affichage

                move.w      #$0001,D0               ;D0 = 3 pour signaler le clipping du sprite
                tst.b		sp_clipped(A6)			;si sp_clipped <> false 
				bne         .gst_movspend           ;quitter et retourner 1
                
;       Calcul des nouvelles coordonnées en X et Y                
                
                move.w      6(A7),D7                ;Récupération valeur d'increment de X
                add.w       D7,sp_posx_aff(A6)      ;ajoute la valeur à la position d'affichage en X
                move.w      8(A7),D7                ;Récupération valeur d'increment de Y
                add.w       D7,sp_posy_aff(A6)      ;ajoute la valeur à la position d'affichage en Y
                clr.w       D0                      ;pas d'erreur

.gst_movspend   movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts



;           /----------------------------------------------------/
;           /     Fixe une nouvelle animation pour un sprite     /
;           /       Parametres pile :   Id du sprite             /
;           /                           pointeur tableau motif   /
;           /                           vitesse de l'animation   /
;           /                           lecture en boucle ou non /
;           /       retour : -1 si sprite pas créé sinon 0       / 
;           /----------------------------------------------------/

_STX_setanimation:  
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_setanimend         ;quitter et retourner -1
                lsl.w       #2,D7                   ;multipli D7 par 4
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A5 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_setanimend         ;quitter et retourner false
                move.l      6(A7),sp_anim_tab(A6)   ;stocke le pointer du tableau d'animation
                move.w      10(A7),D7               ;recupération vitesse de l'animation
                move.b      D7,sp_anim_vitess(A6)   ;stocke la vitesse de l'animation
                move.w      12(A7),D7               ;récuperation si animation en boucle ou non
                move.b      D7,sp_anim_loop(A6)     ;stocke la valeur de la loop d'animation
                move.b      #0,sp_anim_tabpos(A6)   ;initialise à 0 la position de l'animation
                move.b      #0,sp_anim_counter(A6)  ;initialise à 0 le compteur d'animation
                clr.w       D0
.gst_setanimend movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts


;           /----------------------------------------------------/
;           /     Active ou désactive l'animation du sprite      /
;           /       Parametres pile :   Id du sprite             /
;           /       retour : -1 si sprite pas créé sinon 0       / 
;           /----------------------------------------------------/

_STX_animationenable:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_anienabend         ;quitter et retourner -1 
                lsl.w       #2,D7                   ;multipli D7 par 4
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_anienabend         ;quitter et retourner false
                tst.l      	 sp_anim_tab(A6)  		;si adresse tableau animation null
                beq         .gst_anienabend         ;quiter et retourner false
                move.w      6(A7),D7                ;récupération valeur animation enable
                move.b      D7,sp_anim_enable(A6)   ;stocke la valeur de D6 true ou false
                clr.w       D0    
.gst_anienabend movem.l     minit_saveregs,D7/A6    ;restitution des registres                
                rts


;           /----------------------------------------------------/
;           /      Change le motif d'affichage d'un sprite       /
;           /       Parametres pile :   Id du sprite             /
;           /                           numero du motif          /
;           /       retour : -1 si sprite pas créé sinon 0       / 
;           /----------------------------------------------------/
_STX_changespritemotif:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres 
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_chgmotiend         ;quitter et retourner -1 
                lsl.w       #2,D7                   ;multipli D7 par 4
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)    		        ;si sp_created <> true
                beq         .gst_chgmotiend         ;quitter et retourner -1
                move.w      6(A7),sp_nrmotif(A6)    ;nouveau motif à afficher
                clr.w       D0
.gst_chgmotiend movem.l     minit_saveregs,D7/A6    ;restitution des registres 
                rts



;           /----------------------------------------------------/
;           /       Sous-programme d'animation des sprites       /
;           /       Parametres :   A4 pointe sur la structure du /
;           /                      sprite                        /
;           /       retour : aucun                               /
;           /       modification registres : A2, D1, D2          / 
;           /----------------------------------------------------/

;           verification si avancement de l'animation

gst_animsprite  addq.b      #1,sp_anim_counter(A2)  ;incremente le compteur
                move.b      sp_anim_vitess(A2),D1   ;D1 = vitesse de l'animation
                cmp.b       sp_anim_counter(A2),D1  ;si compteur <> vitesse
                bne         .gst_endanisprt         ;alors pas d'animation
                
;           avancer dans l'animation du sprite
                
                moveq       #0,D1                   ;efface D1 sur 32 bits
                move.b      D1,sp_anim_counter(A2)  ;remise à zero du compteur
                move.b      sp_anim_tabpos(A2),D1   ;D1 = position dans le tableau d'animation
                move.l      sp_anim_tab(A2),A6      ;A2 pointe l'adresse du tableau d'animation
                move.w      (A6,D1),D2              ;D2 = valeur du motif dans le tableau d'animation
                cmpi.w      #$FFFF,D2               ;si D2 = #$FFFF (fin du tableau)
                beq         .gst_endtabanim         ;aller à fin de l'animation
                move.w      D2,sp_nrmotif(A2)       ;copie D2 dans la memoire contenant le numéro de motif à afficher
                addq.b      #2,sp_anim_tabpos(A2)   ;incremente la position dans le tableau de 2 octets
                rts                                 ;retour programme appelant
                
;           fin animation, verification si loop demandé
                
.gst_endtabanim tst.b		sp_anim_loop(A2)  		;si true alors loop de l'animation
				beq			.gst_animnoloop         ;aller a pas de loop
				move.b      #0,sp_anim_tabpos(A2)   ;réinitialise à 0 la position de l'animation
                move.w      (A6),sp_nrmotif(A2)     ;met le numero du motif de la position 0 du tableau dans le mémoire contenant le numéro de motif à afficher
                rts                                 ;retour programme appelant
.gst_animnoloop move.b      #false,sp_anim_enable(A2)   ;arrete l'animation  
                move.b      #0,sp_anim_tabpos(A2)   ;réinitialise à 0 la position de l'animation               
.gst_endanisprt rts



;           /----------------------------------------------------/
;           /      Fixe les coordonnées de la bounding boxe      /
;           /       Parametres pile :   Id du sprite             /
;           /                           position X de la bboxe   /
;           /                           position Y de la bboxe   /
;           /                           largeur de la bboxe      /
;           /                           hauteur de la bboxe      /
;           /       retour : -1 si sprite pas créé sinon 0       / 
;           /----------------------------------------------------/

_STX_setboundingboxe:
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                move.w      #$FFFF,D0               ;D0 = -1 pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_endsetbox          ;quitter et retourner -1 
                lsl.w       #2,D7                   ;multipli D7 par 4
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites 
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)                    ;si sp_created <> true
                beq         .gst_endsetbox          ;quitter et retourner false
                move.w      6(A7),sp_aabbox_x(A6)   ;recuperation de position X bboxe de la pile
                move.w      8(A7),sp_aabbox_y(A6)   ;recuperation de position Y bboxe de la pile 
                move.w      10(A7),sp_aabbox_w(A6)  ;recuperation de la largeur bboxe de la pile
                move.w      12(A7),sp_aabbox_h(A6)  ;recuperation de la hauteur bboxe de la pile
                clr.w       D0                      ;efface D0 car pas d'erreur
.gst_endsetbox: movem.l     minit_saveregs,D7/A6    ;restitution des registres 
                rts                                 ;retour programme appelant

    
;           /----------------------------------------------------/
;           / determine si deux sprites sont rentrés en collision/
;           /       Parametres pile :   Id du sprite1            /
;           /                           Id du sprite2            /
;           /       retour : true si collision sinon false       / 
;           /----------------------------------------------------/

_STX_spritescollision:  ;à optimiser
                movem.l     D4-D7/A4-A6,minit_saveregs ;sauvegarde des registres
                clr.w       D0                      ;efface D0 sur 16 bits
                move.b      #false,D0               ;D0 = false pour signaler une erreur  
                move.w      4(A7),D7                ;récupération de l'id du sprite1 sur la pile
                move.w      6(A7),D6                ;récupération de l'id du sprite2 sur la pile
                
;           verification des id des sprites
                
                move.w      initsp_nbsprit,D5       ;récupération du nombre de sprite
                cmp.w       D5,D7                   ;si D7 > D5
                bge         .gst_enddetcoll         ;retourner false
                cmp.w       D5,D6                   ;si D6 > D5
                bge         .gst_enddetcoll         ;retourner false
                
;           verification si sprites crées
                
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites 
                lsl.w       #2,D7                   ;multipli D7 par 4
                lsl.w       #2,D6                   ;multipli D6 par 4
                move.l      (A5,D7),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	sp_created(A4)    		;si sp_created <> true
                beq         .gst_enddetcoll         ;quitter et retourner false
                move.l      (A5,D6),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D6  
                tst.b      	sp_created(A4)    		;si sp_created <> true
                beq         .gst_enddetcoll         ;quitter et retourner false
                
;           verification si sprite enable
                
                tst.b      	sp_enable(A4)     		;si sp_enable <> true
                beq         .gst_enddetcoll         ;quitter et retourner false
                move.l      (A5,D7),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	sp_enable(A4)     		;si sp_enable <> true
                beq         .gst_enddetcoll         ;quitter et retourner false

;           verification si sprite pas collision (box2.x >= box1.x + box1.w)
                
                move.w      sp_posx_aff(A4),D5      ;D5 = sp_posx_aff de D7 (box2)
                add.w       sp_aabbox_x(A4),D5      ;D5 = sp_posx_aff + sp_aabbox_x de D7 (box2)
                move.l      (A5,D6),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D6 (box1)       
                move.w      sp_posx_aff(A4),D4
                add.w       sp_aabbox_x(A4),D4      
                add.w       sp_aabbox_w(A4),D4      ;D4 = sp_posx_aff + sp_aabbox_x + sp_aabbox_w de D6 (box1)
                cmp.w       D4,D5                   ;si D5 >= D4
                bge         .gst_enddetcoll         ;retourne false, pas de collision
                
;           verification si sprite pas collision (box2.x + box2.w <= box1.x)

                sub.w       sp_aabbox_w(A4),D4      ;D4 = sp_posx_aff + sp_aabbox_x de D6 (box1)  
                move.l      (A5,D7),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D7
                add.w       sp_aabbox_w(A4),D5      ;D5 = sp_posx_aff + sp_aabbox_x + sp_aabbox_w de D7 (box2)
                cmp.w       D4,D5                   ;D5 <= D4
                ble         .gst_enddetcoll         ;retourne false, pas de collision
                
;           verification si sprite pas collision (box2.y >= box1.y + box1.h)

                move.w      sp_posy_aff(A4),D5      ;D5 = sp_posy_aff de D7 (box2)
                add.w       sp_aabbox_y(A4),D5      ;D5 = sp_posy_aff + sp_aabbox_y de D7 (box2)
                move.l      (A5,D6),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D6 (box1)
                move.w      sp_posy_aff(A4),D4
                add.w       sp_aabbox_y(A4),D4
                add.w       sp_aabbox_h(A4),D4      ;D4 = sp_posy_aff + sp_aabbox_y + sp_aabbox_h de D6 (box1)
                cmp.w       D4,D5                   ;D5 >= D4
                bge         .gst_enddetcoll         ;retourne false, pas de collision
                
;           verification si sprite pas collision (box2.y + box2.h <= box1.y)                
                
                sub.w       sp_aabbox_h(A4),D4      ;D4 = sp_posy_aff + sp_aabbox_y de D6 (box1)  
                move.l      (A5,D7),A4              ;A4 pointe sur la structure de l'Id du sprite recupérer dans D7
                add.w       sp_aabbox_h(A4),D5      ;D5 = sp_posy_aff + sp_aabbox_y + sp_aabbox_h de D7 (box2)
                cmp.w       D4,D5                  ;D5 <= D4
                ble         .gst_enddetcoll         ;retourne false, pas de collision
               
                move.b      #true,D0                ;valeur true
.gst_enddetcoll movem.l     minit_saveregs,D4-D7/A4-A6 ;restitution des registres
                rts



;           /----------------------------------------------------/
;           /       Indique si un sprite est en clipping         /
;           /       Parametres pile :   Id du sprite1            /
;           /       retour : true si clipping sinon false        / 
;           /----------------------------------------------------/

_STX_spriteclipped: 
                movem.l     D7/A6,minit_saveregs    ;sauvegarde des registres
                clr.w       D0                      ;efface de D0 sur 16 bits
                move.b      #false,D0               ;D0 = false pour signaler une erreur  
                move.w      4(A7),D7                ;recuperation de l'id du sprite sur la pile
                cmp.w       initsp_nbsprit,D7       ;si D7 > nombre de sprite
                bge         .gst_endclipped         ;quitter et retourner -1 
                lsl.w       #2,D7                   ;multipli D7 par 4
                lea         initsp_tabsprt,A6       ;pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A6                 ;A6 pointe sur le debut du bloc de structure des sprites 
                move.l      (A6,D7),A6              ;A6 pointe sur la structure de l'Id du sprite recupérer dans D7  
                tst.b      	(A6)                    ;si sp_created <> true
                beq         .gst_endclipped         ;quitter et retourner false             
                move.b      sp_clipped(A6),D0 
.gst_endclipped movem.l     minit_saveregs,D7/A6    ;restitution des registres
                rts



;           /----------------------------------------------------/
;           /     Ajuste la vitesse de déplacement d'un sprite   /
;           /            par rapport au frame rate               /
;           /      Parametres pile :   compteur de deplacement   /
;           /                          valeur de la vitesse      /
;           /      retour : le nombre de pixel à déplacer        /
;           /               le sprite                            / 
;           /----------------------------------------------------/

_STX_spritespeedadjuste:
                movem.l     D7/A5,minit_saveregs           
                clr.w       D0                      ; efface D0
                move.l      4(A7),A5                ; A5 pointe sur l'adresse du compteur
                cmp.w       #19,(A5)                ; si compteur =< 19
                ble         .speedadj_end           ; aller à .speedadj_end
                move.w      #00,(A5)                ; sinon compteur = 0
.speedadj_end   move.w      8(A7),D7                ; D7 = valeur de la vitesse demandée (40%, 50%,....)
                add.w       (A5),D7
                addi.w      #1,(A5)                 ; incremente le compteur
                lea         speeddata,A5            ; A6 pointe sur les données de vitesse
                move.b      (A5,D7.W),D0            ; D0 = lecture donnée True ou FALSE
                movem.l     minit_saveregs,D7/A5
                rts



                SECTION DATA
                
;                   Vitesse de 20% pour 60hz
speeddata:  DC.B    $01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00
;                   Vitesse de 25% pour 60hz
            DC.B    $01,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00
;                   Vitesse de 30% pour 60hz
            DC.B    $00,$00,$01,$00,$00,$01,$00,$00,$01,$00,$00,$00,$01,$00,$00,$01,$00,$00,$01,$00
;                   Vitesse de 35% pour 60hz
            DC.B    $00,$00,$01,$00,$00,$01,$00,$00,$01,$00,$00,$01,$00,$00,$01,$00,$00,$01,$00,$01
;                   Vitesse de 40% pour 60hz                    
            DC.B    $01,$00,$01,$00,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$00
;                   Vitesse de 45% pour 60hz             
            DC.B    $01,$00,$01,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00
;                   Vitesse de 50% pour 60hz             
            DC.B    $01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00
;                   Vitesse de 55% pour 60hz
            DC.B    $00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01
;                   Vitesse de 60% pour 60hz            
            DC.B    $00,$01,$00,$01,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$01
;                   Vitesse de 65% pour 60hz 
            DC.B    $01,$01,$00,$01,$01,$00,$01,$01,$00,$01,$01,$00,$01,$01,$00,$01,$01,$00,$01,$00
;                   Vitesse de 70% pour 60hz 
            DC.B    $01,$01,$01,$00,$01,$01,$00,$01,$01,$00,$01,$01,$01,$00,$01,$01,$00,$01,$01,$00
;                   Vitesse de 75% pour 60hz
            DC.B    $01,$01,$01,$00,$01,$01,$01,$00,$01,$01,$01,$00,$01,$01,$01,$00,$01,$01,$01,$00
;                   Vitesse de 80% pour 60hz 
            DC.B    $01,$01,$01,$01,$00,$01,$01,$01,$01,$00,$01,$01,$01,$01,$00,$01,$01,$01,$01,$00
;                   Vitesse de 85% pour 60hz
            DC.B    $01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01,$01,$01,$00
;                   Vitesse de 90% pour 60hz 
            DC.B    $01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00
;                   Vitesse de 95% pour 60hz 
            DC.B    $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00
;                   Vitesse de 100% pour 60hz                     
            DC.B    $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01                     
;                   Vitesse de 105% pour 60hz   
            DC.B    $02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01 
;                   Vitesse de 110% pour 60hz 
            DC.B    $02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01

