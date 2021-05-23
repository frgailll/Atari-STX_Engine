;                  SOUS PROGRAMME LOADSPRITE
;        chargement d'un fichier contenant des motif de sprites
;            fichier au format .SPT cree avec SPRITEVC


; parametres:
;       D6=contient l'adresse de debut du nom du fichier sprite .SPT
;
; code de retour:
;       D0=nombre de motif de sprite chargé
;       D0<0 Erreur, fichier non trouve ou non charge



ldsp_nbsprt     EQU       0                         ;contient le nombre de sprite traites
ldsp_fhandle    EQU       2                         ;contient le Handle du fichier SPT
ldsp_buffer     EQU       4                         ;contient l'adresse de debut de la memoire buffer de lecture
ldsp_sprtaddr   EQU       8                         ;contient l'adresse de debut de la memoire de stockage des sprites 16x32
ldsp_maskaddr   EQU       12                        ;contient l'adresse de debut de la memoire de stockage des mask 16x32
ldsp_error      EQU       16                        ;contient le numero d'erreur retourner par les fonctions gemdos



              SECTION TEXT

;      /-----------------------------------------------/
;      / ouverture du fichier de sprites au format SPT /
;      /-----------------------------------------------/

;                  initialisation valeur

_STX_loadspriteset: 
                movem.l     D1-D2/D5-D6/A2-A5,minit_saveregs    ;sauvegarde des registres modifiés
                move.l      4(A7),D6                ;D6 contient l'adresse de la chaine de caractere du chemin
                lea         ldsp_data,A5            ;pointe sur la zone de data
                move.w      #-1,ldsp_error(A5)      ;charge ldsp_error avec la valeur -1
                move.w      #$00,ldsp_nbsprt(A5)    ;initialise le nombre de sprite a 0
 
;          Fixe la valeur du tampon DTA

                M_fsetdta   #ldsp_dtasprt           ;adresse du tampon DTA des sprites
             
;       Recherche du fichier de sprite avec D6

                M_fsfirst   #0,D6                   ;acces lecture / ecriture, D6 pointe sur le nom du fichier       
                tst.w       D0                      ;test D0 pour savoir si le fichier est trouve
                bne         .ldsp_end               ;fichier non trouve

;     calcul du nombre de sprite contenu dans le fichier

                move.l      ldsp_dtasprt+26,D1      ;D1 contient la taille du fichier
                subi.l      #32,D1                  ;soustrait la taille de la palette de couleur soit 32 octets
                divu        #160,D1                 ;divise par 160 taille d'un sprite(128) + mask(32), D1=nombre de sprite
                move.w      D1,ldsp_nbsprt(A5)      ;sauvegarde le nombre de sprite

;       reservation memoire pour buffer de lecture

                M_malloc    #160                    ;demande 160 octets de memoire (taille sprite + mask)
                tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .ldsp_end               ;branchement pour fermeture du fichier
                move.l      D0,ldsp_buffer(A5)      ;sinon sauvegarde l'adresse du debut de buffer

;          ouverture du fichier de sprite

                M_fopen     #0,D6                   ;ouverture du fichier en lecture seul
                tst.w       D0                      ;erreur apparue ?
                bmi         .ldsp_end               ;erreur donc retour D0<0, fin
                move.w      D0,ldsp_fhandle(A5)     ;stock le handle du fichier


;       /-----------------------------------------------/
;       / lecture des donnees de la palette des sprites /
;       /-----------------------------------------------/

;         lecture des 32 octets de la palette

                M_fread     #ldsp_newpal,#32,ldsp_fhandle(A5)    ;lecture de 32 octets à stocker dans le buffer de la palette
                cmp.l       #32,D0                  ;verifier si 32 octets lus ou erreur
                bne         .ldsp_freebuf           ;liberer le buffer, fermer le fichier end

;          chargement de la palette

                M_setpalette    #ldsp_newpal        ;adresse de debut des donnees de la palette


;       /---------------------------------------------------/
;       /  reservation memoire pour les sprites et les mask /
;       /---------------------------------------------------/

;          reservation memoires pour les sprite         

                move.l      #256,D2                 ;256 octets pour sprite 32x16 4 plans
                move.w      ldsp_nbsprt(A5),D1      ;D1 = nombre de sprite precedement calcules
                mulu        D1,D2                   ;D2=nombre sprites x 256 octet
                M_malloc    D2                      ;nombre d'octet a reserver
                tst.l       D0                      ;si D0<0
                bmi         .ldsp_freebuf           ;liberer buffer, fermer fichier
                move.l      D0,ldsp_sprtaddr(A5)    ;sinon sauvegarde l'adresse de debut des sprites

;          reservation memoires pour les mask

                move.l      #64,D2                  ;64 octets pour smask 32x16 1 plan
                move.w      ldsp_nbsprt(A5),D1      ;D1 = nombre de mask precedement calcules
                mulu        D1,D2                   ;D2=nombre mask x 64 octets
                M_malloc    D2
                tst.l       D0                      ;si D0<0
                bmi         .ldsp_freebuf           ;liberer buffer, fermer fichier
                move.l      D0,ldsp_maskaddr(A5)    ;stocke l'adresse de debut des mask

          
;       /------------------------------------------------/
;       / lecture de 256 octets (128 sprites + 32 Mask) /
;       /------------------------------------------------/
;
;               initialisation des pointeurs

                movea.l     ldsp_sprtaddr(A5),A4    ;A4 pointe sur le debut de la memoire sprite
                movea.l     ldsp_maskaddr(A5),A3    ;A3 pointe sur le debut de la memoire mask
                move.w      #0,D2                   ;initialise D2 a 0

;           lecture des données et mise en memoire

.ldsp_loop3:    M_fread     ldsp_buffer(A5),#160,ldsp_fhandle(A5)   ;adresse du buffer de lecture,nombre d'octet à lire, handle du fichier
                cmp.l       #160,D0                 ;verifier si 160 octets lus ou erreur ou fin de fichier
                bne         .ldsp_calc              ;calcul nombre de sprite traite,liberer le buffer, fermer le fichier end

;       fabrication d'un sprite 16x32 a partir d'un sprite 16x16

                movea.l     ldsp_buffer(A5),A2      ;A2 pointe sur l'adresse du buffer contenu dans 4(A5)
                move.w      #15,D1                  ;compteur numero de ligne
.ldsp_loop1:    move.l      (A2)+,(A4)+             ;lecture / ecriture plan 1 et 2 bits sprite 0 a 15
                move.l      (A2)+,(A4)+             ;lecture / ecriture plan 3 et 4 bits sprite 0 a 15
                move.l      #$00000000,(A4)+        ;ecriture plan 1 et 2 bits sprite 16 a 32
                move.l      #$00000000,(A4)+        ;ecriture plan 3 et 4 bits sprite 16 a 32
                move.w      #0,CCR                  ;remet Z … 0 sinon dbeq ne fonctionne pas
                dbeq        D1,.ldsp_loop1          ;continue pour faire les 16 lignes du srpite

;       fabrication d'un mask 16x32 a partir d'un mask 16x16
 
                move.w      #15,D1                  ;compteur numero de ligne
.ldsp_loop2:    move.w      (A2)+,(A3)+             ;lecture / ecriture plan 1 mask bit 0 a 15
                move.w      #$FFFF,(A3)+            ;ecriture plan 1 mask bits 16 a 32
                dbeq        D1,.ldsp_loop2          ;continue pour faire les 16 lignes du mask
                addi.w      #1,D2                   ;ajoute 1 a D2
                bra         .ldsp_loop3             ;continue pour faire les N sprites et mask

;     Calcul du nombre de sprite et mask mis en memoire

.ldsp_calc:     move.w      D2,ldsp_nbsprt(A5)      ;nombre de sprite traites en 16x32


;           /--------------------------------/
;           / fermeture du fichier de sprite /
;           /--------------------------------/

;        liberation de la memoire du buffer de lecture

                move.w      #0,ldsp_error(A5)       ;pas d'erreur rencontrée
.ldsp_freebuf:  M_mfree     ldsp_buffer(A5)         ;adresse de debut de buffer contenu a l'adresse pointee par A5
                
;                  fermeture du fichier

.ldsp_closef:   M_fclose    ldsp_fhandle(A5)        ;handle du fichier
               
;         traitement des erreurs si erreur

                move.w      ldsp_error(A5),D0       ;charge D0 avec le numero d'erreur suavegarde
                bmi         .ldsp_end               ;si D0<0 alors quitter et retourner le numero d'erreur
                move.w      ldsp_nbsprt(A5),D0      ;mettre le nombre de sprite traites dans D0
.ldsp_end:      movem.l     minit_saveregs,D1-D2/D5-D6/A2-A5    ;restitution des registres modifiés
                rts                                 ;retour au programme appelant




;           /-----------------------------------------------/
;           /                 Sous programme                /
;           / liberation memoire de stockage sprite et mask /
;           /-----------------------------------------------/

ldsp_freemem:   lea         ldsp_data,A5            ;A5 pointe sur les donnees de la fonction
                move.l      ldsp_sprtaddr(A5),D0    ;adresse memoire de stockage des sprites dans DO
                beq         .ldsp_freadr2           ;si D0=0 alors pas de memoire allouee, aller a ldsp_freadr2

;        liberation de la memoire des sprites

                M_mfree     ldsp_sprtaddr(A5)
                move.l      #$0,ldsp_sprtaddr(A5)   ;efface adresse de debut de memoire

.ldsp_freadr2:  move.l      ldsp_maskaddr(A5),D0    ;adresse memoire de stockage des mask dans DO
                beq         .ldsp_memend            ;si D0=0 alors pas de memoire allouee, aller a ldsp_freadr2

;        liberation de la memoire des mask

                M_mfree     ldsp_maskaddr(A5)
                move.l      #$0,ldsp_maskaddr(A5)   ;efface adresse de debut de memoire

.ldsp_memend:   rts                                 ;retour au programme appelant


;            /---------------------------------/
;            /  Zone de donnees de la fonction /
;            /---------------------------------/

              SECTION BSS

ldsp_data:      DS.W        1                       ;nombre de sprites et mask en memoire
                DS.W        1                       ;handle du fichier sprite ouvert
                DS.L        1                       ;contient l'adresse du buffer de lecture
ldsp_memspt:    DS.L        1                       ;contient l'adresse de debut des sprites en memoire
ldsp_memmsk:    DS.L        1                       ;contient l'adresse de debut des mask en memoire
                DS.W        1                       ;contient les erreurs retournees dans D0
ldsp_newpal:    DS.B        32                      ;contient la palette de couleur
ldsp_dtasprt:   DS.B        44                      ;buffer pour la DTA


