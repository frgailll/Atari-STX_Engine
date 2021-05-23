;              SOUS PROGRAMME INIT
;        initialisation de la librairie
;

; parametres:
;       D6=nombre de sprite a creer
;
; code de retour:
;      D0<0 Erreur durant l'initialisation
;
; dependences:  mainlib.s
;               gestsprt.s



;           /--------------------------------------------/
;           /           STRUCTURE D'UN SPRITE            /
;           /--------------------------------------------/

;                      Taille de la structure

sp_struct_size  EQU         560                      ;taille de la structure d'un sprite   

;                Definition des données de la structure

sp_created      EQU         0                       ;(b)si true sprite creer, false sinon
sp_enable       EQU         1                       ;(b)si true sprite actif donc visible
sp_nrmotif      EQU         2                       ;(w)numero du sprite chargé en memoire
sp_posx_aff     EQU         4                       ;(w)position X d'affichage du sprite logique
sp_posy_aff     EQU         6                       ;(w)position Y d'affichage du sprite logique
sp_clipped      EQU         8                       ;(b)si true sprite clippé, sortie de la zone d'affichage
sp_anim_enable  EQU         9                       ;(b)si true active l'animation
sp_anim_tab     EQU         10                      ;(l)adresse du tableau contenant la liste des numéros de frames
sp_anim_tabpos  EQU         14                      ;(b)position dans le tableau d'animation
sp_anim_vitess  EQU         15                      ;(b)vitesse de l'animation
sp_anim_counter EQU         16                      ;(b)compteur de position par rapport à la vitesse
sp_anim_loop    EQU         17                      ;(b)animation en boucle ou non
sp_aabbox_x     EQU         18                      ;(w)bounding boxe position X
sp_aabbox_y     EQU         20                      ;(w)bounding boxe position y
sp_aabbox_w     EQU         22                      ;(w)bounding boxe largeur
sp_aabbox_h     EQU         24                      ;(w)bounding boxe hauteur
sp_backgrnd_2   EQU         26                      ;(256) Arriere plan du sprite ecran physique
sp_backgrnd_3   EQU         282                     ;(256) Arriere plan du sprite ecran logique
sp_backgrnd_wrk EQU         538                     ;(l) contient l'adresse de sp_backgrnd_3 ou sp_backgrnd_2
sp_screenpos_2  EQU         542                     ;(l) contient l'adresse de position du sprite dans l'écran physique 
sp_screenpos_3  EQU         546                     ;(l) contient l'adresse de position du sprite dans l'écran Logique
sp_screen_work  EQU         550                     ;(l) contient l'adresse de sp_screenpos_3 ou sp_screenpos_2
sp_modback_2    EQU         554                     ;(b) mode de background 32x16 ou 16x16 dans l'ecran physique
sp_modback_3    EQU         555                     ;(b) mode de background 32x16 ou 16x16 dans l'ecran logique 
sp_modback_work EQU         556                     ;(l) contient l'adresse de sp_modback_2 ou sp_modback_3

 
              SECTION TEXT             
              


;       /--------------------------------------------------------/
;       /  reservation memoire tableau de structure des sprites  /
;       /         Entete à n adresse  + n structures             /
;       /      Parametres :                                      /
;       /      D6 = nombre de sprites                            /
;       /--------------------------------------------------------/

;           Recuperation du nombre de sprite demandés

initspritelib:  move.w       D6,initsp_nbsprit      ;sauvegarde nombre de sprite a creer
                
;           Calcul de la mémoire nescessaire pour n structure
              
                move.w      D6,D7                   ;met nombre de sprite dans D7
                move.w      D6,D5                   ;met nombre de sprite dans D5
                mulu        #4,D7                   ;multipli par 4 octets pour ajouter les pointeurs de l'entete
                mulu        #sp_struct_size,D6      ;multiplie D6 par la taille de la structure d'un sprite
                add.l       D7,D6                   ;ajoute l'entete (octets pour pointage adresse structures des sprites) 
                
;           Reservation mémoire pour toutes les strucutures
                
                M_malloc    D6
                tst.l       D0                      ;si D0 < 0
                bmi         .initsp_error           ;retour avec valeur negative
                lea         initsp_tabsprt,A6       ;sinon pointe sur adresse de stockage du debut tableau de pointeur de structure de sprite
                move.l      D0,(A6)                 ;sauvegarde adresse du debut du bloc ( entete + structures sprites)

;           initialisation des n adresses de l'entete du tableau de structure
        
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc (entete + structures sprites)
                move.l      (A6),D6                 ;D6 contient l'adresse du debut de bloc
                add.l       D7,D6                   ;Ajoute D7 (4 x nb sprites) à D6
                move.l      D6,(A5)                 ;met D6 dans entete (adresse de la premiere structure)
              
                subq.w      #2,D5                   ;decremente D5 (nombre de sprite a créer) de 2
.initsp_struct: add.l       #sp_struct_size,D6      ;ajoute la taille d'une structure a D6
                adda.l      #4,A5                   ;A5 pointe sur l'adresse d'entete suivante
                move.l      D6,(A5)                 ;A5 contient l'adresse de la structure suivante
                dbeq        D5,.initsp_struct       ;decrement D5 jusqu'a 0
              
;           initialisation des valeurs des structures des sprites              
              
                jsr         gst_initsptstruct       ;initialise les donnees des structures

                clr.l       D0                      ;efface D0 avant retour car pas d'erreur
.initsp_error:  rts




;       /-------------------------------------------------------/
;       /  liberation memoire tableau de structure des sprites  /
;       /             et chargé depuis LOADSPRT.S               /
;       /-------------------------------------------------------/

uninitspritelib:    
                move.l      initsp_tabsprt,D6       ;D6 = adresse de debut de memoire du tableau de pointeurs de structure de sprite
                beq         .uni_freesprite         ;si D6 = 0 alors aller a uni_freesprite
                move.l      D6,-(sp)                ;met D6 dans la pile
                move.w      #$49,-(sp)              ;numero fonction mfree
                trap        #1                      ;appel de la fonction
                addq.l      #6,sp                   ;correction de pile
.uni_freesprite jsr         ldsp_freemem            ;branchement pour liberation memoire 
                clr.l       D0                      ;efface D0 pour la valeur de retour
                rts                                 ;retour au programme appelant



              SECTION BSS

initsp_tabsprt: DS.L        1                       ;adresse de debut de memoire pour les adresses des structures de sprites
initsp_nbsprit: DS.W        1                       ;nombre de sprites a creer


    