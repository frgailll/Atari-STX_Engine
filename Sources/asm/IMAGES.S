
pic_neooffset   EQU     $80
pic_degaoffset  EQU     $22
pic_degaeoffset EQU     $22

pic_neotype     EQU     1
pic_degastype   EQU     2
pic_degaseltype EQU     3





            SECTION TEXT
 
;           /-------------------------------------------------/
;           /      Chargement d'image Neochrome, Degas et     /
;           /       DegasElite en mémoire sans la palette     /
;           /                                                 /
;           /   parametre pile :                              /
;           /     Type de fichier                             /
;           /     chemin du fichier image                     /
;           /     Adresse memoire de stockage                 /
;           /   retourne :                                    /
;           /     D0 = 0 si pas d'erreur, sinon valeur <0     /
;           /-------------------------------------------------/  
 
_STX_loadpicture:   
                movem.l     D5-D7,minit_saveregs    ;sauvegarde des registres utilisés
                move.l      6(A7),D7                ;D7 = adresse chaine de caratere
                
;          Fixe la valeur du tampon DTA

                M_fsetdta   #ldsp_dtaimg            ;adresse du tampon DTA des images
                
;       Recherche du fichier de sprite avec D6

                M_fsfirst   #0,D7;acces normal, lecture / ecriture, pointe sur nom du fichier avec zero terminal
                tst.w       D0                      ;test D0 pour savoir si le fichier est trouve
                bne         .load_picend            ;fichier non trouve
                
;          ouverture du fichier picture

                M_fopen     #0,D7                   ;ouverture fichier en lecture seul, D7 pointe sur le nom du fichier
                tst.w       D0                      ;erreur apparue ?
                bmi         .load_picend            ;erreur donc retour D0<0, fin

;          chargement de l'image NEO ou DEGAS ou DEGASELITE
                
                move.w      4(A7),D7                ;D7 = type de picture 
                cmp.b       #pic_neotype,D7         ;si D7 <> pic_neotype
                bne         .pic_type2              ;tester le type suivant          
                move.l      10(A7),D7               ;D7 = adresse mémoire pour stockage picture
                move.w      14(A7),D5               ;D5 = valeur de chargement de la palette
                bsr         loadneopicture          ;charge une image neo
                bra         .load_picend
.pic_type2      cmp.b       #pic_degastype,D7       ;si D7 <> pic_degastype
                bne         .pic_type3
                move.l      10(A7),D7               ;D7 = adresse mémoire pour stockage picture
                move.w      14(A7),D5               ;D5 = valeur de chargement de la palette
                bsr         loaddegaspicture        ;charge une image degas
                bra         .load_picend
.pic_type3      cmp.b       #pic_degaseltype,D7     ;si D7 <> pic_degaseltype
                bne         .load_picend
                move.l      10(A7),D7               ;D7 = adresse mémoire pour stockage picture
                move.w      14(A7),D5               ;D5 = valeur de chargement de la palette
                bsr         loaddegaselitepicture   ;charge une image degaselite
.load_picend    movem.l     minit_saveregs,D5-D7    ;restitution des registres utilisés
                rts



;           /-------------------------------------------------/
;           / Sous programme de Chargement de la partie image / 
;           /             d'un fichier Neochrome              /
;           /                                                 /
;           /   parametre registres :                         /
;           /     D0 = handle du fichier                      /
;           /     D7 = adresse de debut de buffer             /
;           /-------------------------------------------------/ 

loadneopicture:
                move.w      D0,D6                   ;D6 = D0 = Handle du fichier

;           Deplacement du pointeur de donnée au début de l'image    

                M_fseek     #0,D6,#pic_neooffset    ;deplacement depuis le debut du fichier, D6=handle, offset=pic_neooffset
                                                
;           leture du fichier et mise en memoire
                
                M_fread     D7,#32000,D6            ;adresse du debut du buffer de l'image, nombre d'octet à lire, handle du fichier     
                                                
;          fermeture du fichier picture

                M_fclose    D6                      ;handle du fichier à fermer             
            
.load_neoend:   rts


;           /-------------------------------------------------/
;           / Sous programme de Chargement de la partie image / 
;           /                d'un fichier Degas               /
;           /                                                 /
;           /   parametre registres :                         /
;           /     D0 = handle du fichier                      /
;           /     D7 = adresse de debut de buffer             /
;           /-------------------------------------------------/ 

loaddegaspicture:
                move.w      D0,D6                   ;D6 contient le Handle du fichier                   
                
;           Deplacement du pointeur de donnée au début de l'image    

                M_fseek     #0,D6,#pic_degaoffset   ;deplacement depuis le debut, Handle du fichier, offset du deplacement               

;           leture du fichier et mise en memoire
                
                M_fread     D7,#32000,D6;adresse du debut du buffer de l'image, nombre d'octet à lire, handle du fichier  
                                                
;          fermeture du fichier picture

                M_fclose    D6                      ;handle du fichier à fermer
                              
.load_degend:   rts



;           /-------------------------------------------------/
;           / Sous programme de Chargement de la partie image / 
;           /             d'un fichier DegasElite             /
;           /                                                 /
;           /   parametre registres :                         /
;           /     D0 = handle du fichier                      /
;           /     D7 = adresse de debut de buffer             /
;           /-------------------------------------------------/ 

loaddegaselitepicture:
                move.w      D0,D6                   ;D6 contient le Handle du fichier                   
                
;           Deplacement du pointeur de donnée au début de l'image    

                M_fseek     #0,D6,#pic_degaeoffset  ;deplacement depuis le debut, Handle du fichier, offset de deplacement              

;           leture du fichier et mise en memoire                
                
                M_fread     D7,#32000,D6;adresse du debut du buffer de l'image, nombre d'octet à lire, handle du fichier 
                                
;          fermeture du fichier picture

                M_fclose    D6                      ;handle fichier à fermer              
                
.load_degeend:  rts




;           /-------------------------------------------------/
;           /       Copie d'une image ou partie d'image       /
;           /                                                 /
;           /   parametre sur la pile :                       /
;           /     Type d'image neo, degas ou degas elite      /
;           /     adresse mémoire source                      / 
;           /     adresse memoire de destination              /
;           /     Coordonnée X de la zone de l'image à copier /
;           /     Coordonnée Y de la zone de l'image à copier /
;           /     Largeur de la zone de l'image à copier      /
;           /     Hauteur de la zone de l'image à copier      /
;           /     Coordonnée X de la destination de l'image   /
;           /     Coordonnée Y de la destination de l'image   /
;           /-------------------------------------------------/ 

_STX_blitloadedpicture:
                movem.l     D2-D7/A4-A6,minit_saveregs ;sauvegarde des registres sur la pile
                
  ;         recupération des valeurs sur la pile
                
                move.l      4(A7),A5                ;Adresse source image
                move.l      8(A7),A4                ;Adresse destination image
                move.w      12(A7),D2               ;coordonnée X source
                move.w      14(A7),D3               ;coordonnée Y source
                move.w      16(A7),D4               ;largeur image
                move.w      18(A7),D5               ;hauteur image
                move.w      20(A7),D6               ;coordonnée X destination
                move.w      22(A7),D7               ;coordonnée Y destination
                            
                lea         blt_BaseAddr,A6         ;adresse de début des registres du blitter
                move.l      A5,blt_SrcAddr(A6)      ;adresse de stockage de l'image en memoire
                move.l      A4,blt_DstAddr(A6)      ;adresse de destination de la copie de l'image            
                
;           Calcul position de départ en mémoire

                andi.w      #$FFF0,D2               ;position X mode 16
                lsr.w       #1,D2                   ;divise X par 2
                mulu        #160,D3                 ;multiplie Y par 160
                add.w       D2,D3                   ;D3=D3+D2
                add.l       D3,blt_SrcAddr(A6)      ;ajoute le resultat D6 à l'adresse source d'image
                
;           calcul position d'arrivée en mémoire

                andi.w      #$FFF0,D6               ;position X mode 16
                lsr.w       #1,D6                   ;divise X par 2
                mulu        #160,D7                 ;multiplie Y par 160
                add.w       D6,D7                   ;D7=D7+D6
                add.l       D7,blt_DstAddr(A6)      ;ajoute le resultat D7 à l'adresse destination d'image
                
;           calcul nombre de mot en largeur à traiter et nombre de ligne en hauteur
                
                andi.w      #$FFF0,D4               ;largeur mode 16
                lsr.w       #2,D4                   ;divise la largeur par 4 = nombre de mot
                move.w      D4,blt_Xcount(A6)       ;nombre de mot en X à traiter
                move.w      D5,blt_Ycount(A6)       ;nombre de ligne à traiter
                
;           Valeur d'increment en largeur et hauteur (attention si changement de largeur d'écran)
               
                lsl.w       #1,D4                   ;multiplie par 2 = nombre d'octet
                move.w      #160,D5
                sub.w       D4,D5                    ;D5 = D5 - D4 (160 - D4)
                addi.w      #2,D5                   ;ajoute 2 car dernier increment en X non réalisé
                move.w      D5,blt_SrcYinc(A6)      ;nombre d'octet à incrementer en Y pour la source
                move.w      D5,blt_DstYinc(A6)      ;nombre d'octet à incrementer en Y pour la destination
                move.w      #2,blt_SrcXinc(A6)      ;nombre d'octet à incrmenté en X pour la source
                move.w      #2,blt_DstXinc(A6)      ;nombre d'octet à incrmenté en X pour la destination
                
;           Autres parametres du blitter

                move.w      #$FFFF,blt_EndMask1(A6) ;mask de début
                move.w      #$FFFF,blt_EndMask2(A6) ;mask du milieu
                move.w      #$FFFF,blt_EndMask3(A6) ;mask de fin
                move.b      #2,blt_Hop(A6)          ;pas d'interaction avec la ram de demi-teinte
                move.b      #3,blt_Op(A6)           ;la destination est remplacée par la source
                move.b      #0,blt_Skew(A6)         ;pas de rotation
                
;           Demarre le blitter et copie l'image
                
                move.b      #128,blt_LineNum(A6)    ;start le blitter en mode partage de bus
.pic_rstblit:   bset.b      #7,blt_LineNum(A6)      ;redemarre le blitter
                nop
                bne         .pic_rstblit
                
                movem.l     minit_saveregs,D2-D7/A4-A6 ;restitution des registres sur la pile
                rts
                
                
                
;           /----------------------------------------------------/                
;           /   Affiche un motif du spriteset en tant qu'image   /
;           /                                                    /
;           /   Paramétres:                                      /
;           /       numéro du motif en mémoire                   /
;           /       coordonnee X de l'arriere plan               /
;           /       coordonnee Y de l'arriere plan               /
;           /       mode transparent                             /
;           /--------------------------------------------------- /

_STX_displayspriteset:
                movem.l     D2-D7/A4-A6,minit_saveregs
                moveq       #0,D6
                moveq       #0,D7
                move.w      6(A7),D7                ;D7 = X
                move.w      D7,D3                   ;D3 = X
                and.w       #$000F,D3               ;D3 = valeur de rotation pour alignement au pixel
                and.w       #$FFF0,D7               ;D7 = X and $FFF0 (X modulo 16)
                lsr.w       #1,D7                   ;divise X par 2
                
;           multiplie Y par 160 (plus rapide que mulu)               
                
                move.w      8(A7),D6                ;D6 = Y
                lsl.w       #5,D6                   ;multiplie par 32
                move.w      D6,D4                   ;sauvegarde le resultat dans D4
                add.w       D4,D6                   ;Ajoute D4 
                add.w       D4,D6                   ;Ajoute D4
                add.w       D4,D6                   ;Ajoute D4
                add.w       D4,D6                   ;Ajoute D4            
                               
;           ajoute X à Y*160  et ajoute le resultat à l'adresse écran              
                
                move.l      minit_workscr,D4        ;D4 = adresse écran de travail
                add.w       D7,D6                   ;D6 = D7 + D6 (offset de positionnement à l'écran)
                add.l       D4,D6                   ;D6 = D6 + D4  (adresse écran de destination)
                move.l      D6,D4                   ;D4 = D6 (sauvegarde adresse écran de destination)
                
;           offset du motif en mémoire                
                                         
                move.w      4(A7),D7                ;D7 contient le numero du motif à afficher
                move.w      D7,D2                   ;D2 contient le numero du mask à afficher
                lsl.w       #6,D2                   ;multipli D2 par 64 (taille d'un mask en 16x32 sur 1 plan)
                lsl.w       #8,D7                   ;multipli D7 par 256 (taille d'un motif en 16x32 sur 4 plans)
                                      
;           configuration du blitter

                lea         blt_BaseAddr,A4         ;adresse de début des registres du blitter
                lea         blt_SrcXinc(A4),A6
                move.l      #$00020002,(A6)+        ;increment horizontal source par plan (blt_SrcXinc) & increment vertical source par plan (blt_SrcYinc)
                ;move.w      #2,(A6)+                ;increment horizontal source par plan (blt_SrcXinc)
                ;move.w      #2,(A6)+                ;increment vertical source par plan (blt_SrcYinc)
                move.l      ldsp_memmsk,D5          ;D5 = adresse de debut de stockage des mask de spriteset
                add.l       D2,D5                   ;D5 = D5 + D7 (adresse du mask à afficher)
                move.l      D5,(A6)+                ;adresse de stockage du mask du motif en memoire (blt_SrcAddr)
                move.b      D3,blt_Skew(A4)         ;rotation pour alignement au pixel
                lea         blt_LeftMask,A5         ;pointe sur les valeurs du mask gauche
                add.w       D3,D3                   ;multipli D5 par 2 (car mask sur 2 octets)
                move.w      (A5,D3.W),(A6)+         ;applique la valeur du mask gauche (blt_EndMask1)
                move.w      #$FFFF,(A6)+            ;valeur du mask central (blt_EndMask2)
                lea         blt_RightMask,A5        ;pointe sur les valeurs du mask droit
                move.w      (A5,D3.W),(A6)+         ;applique la valeur du mask droit (blt_EndMask3)
                move.l      #$00080098,(A6)+        ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                ;move.w      #8,(A6)+                ;increment horizontal destination (blt_DstXinc)
                ;move.w      #152,(A6)+              ;increment vertical destination (blt_DstYinc)
                move.w      #$0201,blt_Hop(A4)      ;utilisation de la source seule (blt_Hop) & mode d'affichage Source AND destination (blt_Op)
                                
;           affichage du mask du motif pour la transparence  plan 1

                move.w      10(A7),D3               ;D3 = mode d'affichage
                tst.b       D3                      ;si D3 = 0 
                beq         .pic_disp_motif1        ;aller à .pic_disp_motif (mode replace)
                move.l      D6,(A6)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.l      #$00020010,(A6)+         ;taille destination horizontal en mot (blt_Xcount) & ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,(A6)+                ;taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,(A6)+               ;taille destination vertical en ligne (16) (blt_Ycount)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit10  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit10
                
;           affichage du mask du motif pour la transparence  plan 2

                addq.l      #2,D6                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      #$00020010,-(A6);taille destination vertical en ligne (16) (blt_Ycount) & taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,-(A6)               ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,-(A6)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D6,-(A6)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit11  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit11
                
;           affichage du mask du motif pour la transparence  plan 3

                addq.l      #2,D6                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      D6,(A6)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.l      #$00020010,(A6)+        ;taille destination horizontal en mot (blt_Xcount) & ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,(A6)+                ;taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,(A6)+               ;taille destination vertical en ligne (16) (blt_Ycount)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit12  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit12
                
;           affichage du mask du motif pour la transparence  plan 4                
                
                addq.l      #2,D6                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      #$00020010,-(A6)        ;taille destination vertical en ligne (16) (blt_Ycount) & taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,-(A6)               ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,-(A6)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D6,-(A6)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit13  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit13
                
                
;           mode d'affichage du motif               
                
                cmp.b       #2,D3                   ;si mode affichage = 2 (Effacement)
                beq         .pic_disp_end           ;alors ne pas afficher le motif
                move.b      #7,blt_Op(A4)           ;mode d'affichage Source OR destination si transparence
                bra         .pic_disp_motif2
.pic_disp_motif1:
                move.b      #3,blt_Op(A4)           ;la destination est remplacée par la source si pas transparence             

;           affichage du motif plan 1

.pic_disp_motif2:
                move.w      #8,blt_SrcXinc(A4)      ;increment horizontal source par plan (blt_SrcXinc)
                move.w      #8,blt_SrcYinc(A4)      ;increment vertical source par plan (blt_SrcYinc)
                move.l      ldsp_memspt,D5          ;D5 = adresse de debut de stockage des spriteset
                add.l       D7,D5                   ;D5 = D5 + D7 (adresse du spriteset à afficher)
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      D4,(A6)+                ;adresse de destination du motif à l'écran (blt_DstAddr)
                move.l      #$00020010,(A6)+        ;taille destination horizontal en mot (blt_Xcount) & taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,(A6)+                ;taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,(A6)+               ;taille destination vertical en ligne (16) (blt_Ycount)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit20  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit20
                
;           affichage du motif plan 2                
                               
                addq.l      #2,D5                   ;passe au plan suivant de la source
                addq.l      #2,D4                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      #$00020010,-(A6)        ;taille destination vertical en ligne (16) (blt_Ycount) & taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,-(A6)               ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,-(A6)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A6)                ;adresse de destination du motif à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit21  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit21
                
;           affichage du motif plan 3

                addq.l      #2,D5                   ;passe au plan suivant de la source
                addq.l      #2,D4                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      D4,(A6)+                ;adresse de destination du motif à l'écran (blt_DstAddr)
                move.l      #$00020010,(A6)+        ;taille destination horizontal en mot (blt_Xcount) & taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,(A6)+                ;taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,(A6)+               ;taille destination vertical en ligne (16) (blt_Ycount)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit22  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit22
                
;           affichage du motif plan 4                
                
                addq.l      #2,D5                   ;passe au plan suivant de la source
                addq.l      #2,D4                   ;passe au plan suivant de la destination
                move.l      D5,blt_SrcAddr(A4)      ;adresse de stockage du mask du motif en memoire
                move.l      #$00020010,-(A6)        ;taille destination vertical en ligne (16) (blt_Ycount) & taille destination horizontal en mot (blt_Xcount)
                ;move.w      #16,-(A6)               ;taille destination vertical en ligne (16) (blt_Ycount)
                ;move.w      #2,-(A6)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A6)                ;adresse de destination du motif à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A4)    ;start le blitter en mode partage de bus
.pic_rstblit23  bset.b      #7,blt_LineNum(A4)      ;redemarre le blitter
                nop
                bne         .pic_rstblit23
                
.pic_disp_end   movem.l     minit_saveregs,D2-D7/A4-A6
                rts




            SECTION BSS
            
ldsp_dtaimg:    DS.B        44                      ;buffer pour la DTA
