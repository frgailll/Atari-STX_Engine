;           /----------------------------------------------------/
;           /            SOUS PROGRAMME BLITSPRTE                /
;           /   Affichage d'un sprite 16x16 avec le blitter      /
;           /                                                    /
;           /  parametres:                                       /
;           /    D5=adresse de l'ecran  xbios(2) ou xbios(3)     /
;           /    D3=numero du sprite en memoire a afficher       /
;           /    D1=coordonnee X de l'arriere plan               /
;           /    D2=coordonnee Y de l'arriere plan               /
;           /  retourne:                                         /
;           /    D0=0 blit ok, sinon -1 si clipping              /
;           /  dependances:                                      /
;           /    Memorisation local utilisation registre A4      /
;           /    BLITDEF.L utilisation du registre A5            /
;           /    SETCLIP.L utilisation du registre A6            /
;           /    Necessite d'etre en mode superviseur            /
;           /----------------------------------------------------/


bs_nbligne      EQU         0                           ;nombre de ligne du sprite … afficher
bs_yclipoffset  EQU         2                           ;offset vertical quand cliping haut
bs_mask1        EQU         4                           ;valeur du mask gauche du sprite
bs_mask3        EQU         6                           ;valeur du mask droit du sprite
bs_addrsprt     EQU         8                           ;adresse de debut de zone ou sont stocker les sprites
bs_addrmsksprt  EQU         12                          ;adresse de debut de zone ou sont stocker les mask des sprites



              SECTION TEXT

;        /---------------------------------/
;        /   Initialisation des données    /
;        /---------------------------------/

blitsprite:     move.w      #false,D0                   ;initialise le drapeau de clipping
                lea         bs_spritedata,A4            ;A4 pointe sur spritedata
                lea         ldsp_data,A6                ;pointe sur les informations des sprites chargés en mémoire
            
;        calcul de l'emplacement en memoire du sprite et de son mask
             
                lsl.l       #8,D3                       ;multiplie D3 par 256 (numero du sprite en memoire)
                move.l      ldsp_sprtaddr(A6),bs_addrsprt(A4) ;sauvegarde l'adresse de debut de stockage des sprites en memoire
                move.l      ldsp_maskaddr(A6),bs_addrmsksprt(A4) ;sauvegarde l'adresse de debut de stockage des mask de sprite en memoire
                add.l       D3,bs_addrsprt(A4)          ;contient l'adresse du sprite à afficher
                lsr.w       #2,D3                       ;divise D3 par 4 (numero du mask en memoire)
                add.l       D3,bs_addrmsksprt(A4)       ;contient l'adresse du mask à afficher
                move.w      D1,D3                       ;D3 = X
                andi.w      #$000F,D3                   ;concerve les 4 bits de poids faible de X
                move.b      D3,D6                       ;D6 = skew valeur de rotation
                add.b       D3,D3                       ;D3 = D3 x 2
                lea         blt_LeftMask,A5             ;pointe sur les valeurs du mask gauche
                move.w      (A5,D3.W),bs_mask1(A4)      ;valeur du mask1
                move.w      34(A5,D3.W),bs_mask3(A4)    ;pointe sur la valeur du mask droit et l'applique à mask3
                move.w      #16,bs_nbligne(A4)          ;16 lignes a afficher
                move.w      #$00,bs_yclipoffset(A4)     ;offset de ligne


;        /---------------------------------/
;        / Gestion des valeurs de clipping /
;        /---------------------------------/

                lea         clipvalues,A6               ;pointe sur les valeurs de setclipping

;          clipping vertical haut

                cmp.w       clipymin(A6),D2             ;si Y >= clipymin (signed)
                bge         .bs_clipvbas                ;aller a bs_clipvbas
                move.w      clipymin(A6),D3             ;copie clipymin dans D3
                sub.w       D2,D3                       ;D3 = clipymin - Y
                cmpi.w      #16,D3                      ;si D3 >= 16 (signed)
                bge         .endblitsprt                ;retour car clipping
                move.w      #16,D4                      ;D4 = 16
                sub.w       D3,D4                       ;D4 = 16 - (clipymin - Y)
                move.w      D4,bs_nbligne(A4)           ;bs_nbligne = D4 (16 - (clipymin - Y))
                lsl.w       #4,D3                       ;4 shift gauche de D3 (clipymin - Y)
                move.w      D3,bs_yclipoffset(A4)       ;met D3 dans bs_clipoffset
                move.w      clipymin(A6),D2             ;D2 = clipymin

;          clipping vertical bas

.bs_clipvbas:   cmp.w       clipymax(A6),D2             ;si Y <= posymac (signed)
                ble         .bs_cliphleft               ;aller a bs_cliphleft
                move.w      D2,D3                       ;D3 = D2 (Y)
                sub.w       clipymax(A6),D3             ;D3 = Y - clipymax
                cmpi.w      #16,D3                      ;si D3 >= 16 (signed)
                bge         .endblitsprt                ;retour car clipping
                move.w      #16,D4                      ;D4 = 16
                sub.w       D3,D4                       ;D4 = 16 - (Y - clipymax)
                move.w      D4,bs_nbligne(A4)           ;bs_ligne = D4

;          clipping horizontal gauche

.bs_cliphleft:  cmp.w       clipxmin(A6),D1             ;si X >= clipxmin (signed)
                bge         .bs_cliphright              ;aller a bs_cliphright
                move.w      clipxmin(A6),D3             ;D3 = clipxmin
                sub.w       D1,D3                       ;D3 = clipxmin - X
                cmpi.w      #16,D3                      ;si D3 >= 16 (signed)
                bge         .endblitsprt                ;retour car clipping
                move.w      clipxmin(A6),D3             ;D3 = clipxmin
                move.w      clipxminmod(A6),D4          ;D4 = clipxminmod
                sub.w       D4,D3                       ;D3 = clipxmin - clipxminmod
                add.w       D3,D3                       ;D3 = 2 x D3
                lea         blt_LeftMask,A5             ;pointe sur les valeurs du mask gauche
                move.w      (A5,D3.W),bs_mask1(A4)      ;mask fixe derriere le clipping
                cmp.w       clipxminmod(A6),D1          ;si X >= clipxminmod (signed)
                bge         .bs_cliphright              ;aller a bs_cliphright
                move.w      clipxminmod(A6),D1          ;D1 = clipxminmod
                move.w      bs_mask3(A4),D3             ;D3 = bs_mask3
                and.w       D3,bs_mask1(A4)             ;bs_mask1 = bs_mask1 and bs_mask3
                move.b      #true,D0                    ;Drapeau de clipping à true

;          clipping horizontal droit

.bs_cliphright: move.w      D1,D3                       ;D3 = X
                addi.w      #16,D3                      ;D3 = X + 16
                cmp.w       clipxmax(A6),D3             ;si D3 <= clipxmax (signed)
                ble         .bs_calcparam               ;aller a bs_calcparam
                cmp.w       clipxmax(A6),D1             ;si D1 >= 16
                bge         .endblitsprt                ;aller a endblitsprt
                cmp.w       clipxmaxmod(A6),D1          ;si D1 >= clipxmaxmod
                bge         .bs_calcmask1               ;aller a bs_calclmask1 (signed)
                move.w      clipxmax(A6),D3             ;D3 = clipxmax
                move.w      clipxmaxmod(A6),D4          ;D4 = clipxmaxmod
                sub.w       D4,D3                       ;D3 = clipxmax - clipxmaxmod
                add.w       D3,D3                       ;D3 = D3 x 2
                lea         blt_RightMask,A5            ;pointe sur les valeurs du mask droit
                move.w      (A5,D3.W),bs_mask3(A4)      ;fixe la valeur du mask3
                bra         .bs_chdsuite                ;aller a bs_chdsuite
.bs_calcmask1:  move.w      clipxmax(A6),D3             ;D3 = clipxmax
                move.w      clipxmaxmod(A6),D4          ;D4 = clipxmaxmod
                sub.w       D4,D3                       ;D3 = clipxmax - clipxmaxmod
                add.w       D3,D3                       ;D3 = D3 x 2
                lea         blt_RightMask,A5            ;pointe sur les valeurs du mask droit
                move.w      (A5,D3.W),bs_mask1(A4)      ;fixe la valeur du mask1
.bs_chdsuite:   cmp.w       clipxmaxmod(A6),D1          ;si D1 <= clipxmaxmod
                ble         .bs_calcparam               ;aller a bs_calcparam
                move.w      clipxmaxmod(A6),D1          ;D1 = clipxmaxmod
                clr.w       D3                          ;efface D3 sur 16 bits
                move.b      D6,D3                       ;D3 = bs_skew
                add.b       D3,D3                       ;D3 = D3 x 2
                lea         blt_LeftMask,A5             ;pointe sur les valeurs du mask gauche
                move.w      (A5,D3.W),D4                ;D4 est charge avec la valeur du mask droit
                and.w       D4,bs_mask1(A4)             ;bs_mask1 = bs_mask1 and D4
                move.b      #true,D0                    ;Drapeau de clipping à true






;        /---------------------------------------------------/
;        / Calcul des paramétres du sprites pour l'affichage /
;        /---------------------------------------------------/

;         calcul de l'emplacement du sprite en memoire ecran

.bs_calcparam:  and.w       #$FFF0,D1                   ;D1 = X and $FFF0 (X modulo 16)
                lsr.w       #1,D1                       ;divise X par 2
                
;         multiplie Y par 160 (plus rapide que mulu)               
                
                lsl.w       #5,D2                       ;multiplie par 32
                move.w      D2,D4                       ;sauvegarde le resultat dans D0
                add.w       D4,D2                       ;Ajoute D0 
                add.w       D4,D2                       ;Ajoute D0
                add.w       D4,D2                       ;Ajoute D0
                add.w       D4,D2                       ;Ajoute D0            
                               
;         ajoute X à Y*160  et ajoute le resultat à l'adresse écran              
                
                add.w       D1,D2                       ;D2 = D1 + D2
                add.l       D2,D5                       ;contient l'adresse memoire ecran pour affichage du sprite
                move.l      D5,gback_posaddr            ;sauvegarde l'adresse de position du background
                    
;                 verification si rotation skew ou clippping clip

                lea         blt_BaseAddr,A6             ;A6 pointe sur le blitter
                
                tst.b       D6                          ;si bs_skew = 0
                beq         .bs_sprt16                  ;aller a bs_sprt16
                tst.b       D0                          ;si bs_clip <> false
                bne         .bs_sprt16                  ;aller a bs_sprt16
                
;        /-------------------------------------------/
;        /  Memorisation du background en mode 16x32 /
;        /-------------------------------------------/

                lea         blt_SrcXinc(A6),A5          ;A5 pointe sur le registre SrcXinc du blitter
                move.l      #$00020092,(A5)+            ;increment horizontal source (blt_SrcXinc) & increment vertical source (blt_SrcYinc)
                move.l      D5,(A5)+                    ;adresse de la source (blt_SrcAddr)
                move.l      #$FFFFFFFF,(A5)+            ;masque final 1 (blt_EndMask1) & ;masque final 2 (blt_EndMask2)
                move.w      #$FFFF,(A5)+                ;masque final 3 (blt_EndMask3)
                move.l      #$00020002,(A5)+            ;increment horizontal destination (blt_DstXinc) & ;increment vertical destination (blt_DstYinc)
                move.l      gback_store,(A5)+           ;adresse de la destination à déterminer (blt_DstAddr)
                move.l      #$00080010,(A5)+            ;taille dest horizontal en mot (blt_Xcount) & ;taille dest vertical en ligne (blt_Ycount)
                move.w      #$0203,(A5)+                ;utilisation de la source seule (blt_Hop) & mode affichage remplacer (blt_Op)
                move.w      #$8000,(A5)                 ;start le blitter avec partage de bus (blt_LineNum) & pas d'ajustement au pixel (blt_Skew)

.gbackloop1:    bset.b      #7,(A5)                     ;redemarre le blitter (blt_LineNum)
                nop
                bne         .gbackloop1
                move.b      #true,gback_mode3216        ;indique un arriere plan en 32x16

;        /-------------------------------------------/
;        / Gestion affichage du sprite en mode 16x32 /
;        /-------------------------------------------/

;                  initialisation du blitter

                lea         blt_SrcXinc(A6),A5          ;A5 pointe sur le registre SrcXinc du blitter
                move.l      #$00020002,(A5)+            ;increment horizontal source par plan (blt_SrcXinc) & ;increment vertical source par plan (blt_SrcYinc)
                moveq       #0,D3                       ;efface D3 sur 32 bits
                move.w      bs_yclipoffset(A4),D3       ;D3 = bs_yclipoffset
                add.l       bs_addrmsksprt(A4),D3       ;D3 = bs_yclipoffset + adresse du mask en memoire
                move.l      D3,(A5)+                    ;Adresse source (blt_SrcAddr)
                move.w      bs_mask1(A4),(A5)+          ;valeur du mask final 1 (blt_EndMask1)
                move.w      #$FFFF,(A5)+                ;valeur du mask final 2 (blt_EndMask2)
                move.w      bs_mask3(A4),(A5)+          ;valeur mask final 3 (blt_EndMask3)
                move.l      #$00080098,(A5)+            ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                move.b      D6,blt_Skew(A6)             ;rotation pour alignement au pixel
                move.w      #$0201,blt_Hop(A6)          ;utilisation de la source seule & (Op) mode d'affichage Source AND destination 
                move.w      bs_nbligne(A4),D2           ;D2 = nombre de ligne calculées à afficher
                
;                  affichage du mask plan 1
                                
                move.l      D5,D4                       ;adresse de destination
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)   
                move.w      #2,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit10  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit10
                
;                  affichage du mask plan 2
                
                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #2,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit11  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit11
                
;                 affichage du mask plan 3
                
                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)   
                move.w      #2,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit12  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit12
                
;                 affichage du mask plan 4
                
                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #2,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit13  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit13


;                         Affichage du sprite plan 1

                move.b      #7,blt_Op(A6)               ;mode d'affichage Source OR destination
                move.l      #$00080008,blt_SrcXinc(A6)  ;increment horizontal source par plan (blt_SrcXinc) & increment vertical source par plan (blt_SrcYinc)
                moveq       #0,D3                       ;efface D3 sur 32 bits
                move.w      bs_yclipoffset(A4),D3       ;D3 =  bs_yclipoffset
                add.l       bs_addrsprt(A4),D3          ;D3 =  bs_yclipoffset + adresse du sprite en memoire
                move.l      D3,blt_SrcAddr(A6)          ;Adresse source
                move.l      D5,D4                       ;adresse de destination
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)
                move.w      #2,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit20  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit20
                
;                 Affichage du sprite plan 2
                
                addq.l      #2,D4                       ;passe au plan suivant
                addq.l      #2,D3                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #2,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit21  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit21
                
;                 affichage du sprite plan 3
                
                addq.l      #2,D4                       ;passe au plan suivant
                addq.l      #2,D3                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)
                move.w      #2,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit22  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit22
                
;                 Affichage du sprite plan 4

                addq.l      #2,D4                       ;passe au plan suivant
                addq.l      #2,D3                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #2,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit23  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit23

;                 Fin d'affichage du sprite en 16x32

                clr.b       D0                          ;valeur de retour sprite non clippé
                rts


;        /-------------------------------------------/
;        / Memorisation du background  en mode 16x16 /
;        /-------------------------------------------/
;                  

.bs_sprt16:     lea         blt_SrcXinc(A6),A5          ;A5 pointe sur le registre SrcXinc du blitter
                move.l      #$0002009A,(A5)+            ;increment horizontal source (blt_SrcXinc) & ;increment vertical source (blt_SrcYinc)
                move.l      D5,(A5)+                    ;adresse de la source (blt_SrcAddr)
                move.l      #$FFFFFFFF,(A5)+            ;masque final 1 (blt_EndMask1) & ;masque final 2 (blt_EndMask2)
                move.w      #$FFFF,(A5)+                ;masque final 3 (blt_EndMask3)
                move.l      #$00020002,(A5)+            ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                move.l      gback_store,(A5)+           ;adresse de la destination à déterminer (blt_DstAddr)
                move.l      #$00040010,(A5)+            ;taille dest horizontal en mot (blt_Xcount) & ;taille dest vertical en ligne (blt_Ycount)
                move.w      #$0203,(A5)+                ;utilisation de la source seule (blt_Hop) & mode affichage remplacer (blt_Op)
                move.w      #$8000,(A5)                 ;start le blitter avec partage de bus (blt_LineNum) & pas d'ajustement au pixel (blt_Skew)

.gbackloop2:    bset.b      #7,(A5)                     ;redemarre le blitter (blt_LineNum)
                nop
                bne         .gbackloop2
                move.b      #false,gback_mode3216       ;indique un arriere plan en 16x16

;        /-------------------------------------------/
;        / Gestion affichage du sprite en mode 16x16 /
;        /-------------------------------------------/
;

;                    initialisation du blitter

                lea         blt_SrcXinc(A6),A5          ;A5 pointe sur le registre SrcXinc du blitter 
                move.l      #$00000004,(A5)+            ;increment horizontal source par plan (blt_SrcXinc) & increment vertical source par plan (blt_SrcYinc)
                moveq       #0,D3                       ;efface D3 sur 32 bits
                move.w      bs_yclipoffset(A4),D3       ;D3 = bs_yclipoffset
                add.l       bs_addrmsksprt(A4),D3       ;D3 = bs_yclipoffset + adresse du mask en memoire
                move.l      D3,(A5)+                    ;Adresse source (blt_SrcAddr)
                move.w      bs_mask1(A4),(A5)+          ;valeur du mask final 1 (blt_EndMask1)
                move.w      #$FFFF,(A5)+                ;valeur du mask final 2 (blt_EndMask2)
                move.w      bs_mask3(A4),(A5)+          ;valeur mask final 3 (blt_EndMask3)
                move.l      #$000000A0,(A5)+            ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                move.b      D6,blt_Skew(A6)             ;rotation pour alignement au pixel
                ori.b       #bltm_SkewFxsr,blt_Skew(A6) ;Force la lecture d'un mot avant
                move.w      #$0201,blt_Hop(A6)          ;utilisation de la source seule & (Op) mode d'affichage Source AND destination
                move.w      bs_nbligne(A4),D2           ;D2 = nombre de ligne calculées à afficher

;                  affichage du mask plan 1                
                
                move.l      D5,D4                       ;adresse de destination
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)
                move.w      #1,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit30  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit30

;                  affichage du mask plan 2

                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #1,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit31  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit31
 
;                  affichage du mask plan 3

                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.l      D4,(A5)+                    ;Adresse destination (blt_DstAddr)
                move.w      #1,(A5)+                    ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                    ;taille destination vertical en ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit32  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit32
                
;                  affichage du mask plan 4

                addq.l      #2,D4                       ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)
                move.w      D2,-(A5)                    ;taille destination vertical en ligne (blt_Ycount)
                move.w      #1,-(A5)                    ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                    ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)        ;start le blitter en mode partage de bus
.bs_modeblit33  bset.b      #7,blt_LineNum(A6)          ;redemarre le blitter
                nop
                bne         .bs_modeblit33               
                

;                 Affichage du sprite plan 1

                move.b      #7,blt_Op(A6)           ;mode d'affichage Source OR destination
                move.w      #16,blt_SrcYinc(A6)     ;increment vertical source par plan (blt_SrcYinc)
                moveq       #0,D3                   ;efface D3 sur 32 bits
                move.w      bs_yclipoffset(A4),D3   ;D3 = bs_yclipoffset
                add.l       bs_addrsprt(A4),D3      ;D3 = bs_yclipoffset + adresse du sprite en memoire
                move.l      D3,blt_SrcAddr(A6)      ;Adresse source
                move.l      D5,D4                   ;adresse de destination
                move.l      D4,(A5)+                ;Adresse destination (blt_DstAddr)
                move.w      #1,(A5)+                ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                ;taille destination vertical en ligne (blt_ycount)
                move.b      #128,blt_LineNum(A6)    ;start le blitter en mode partage de bus
.bs_modeblit40  bset.b      #7,blt_LineNum(A6)      ;redemarre le blitter
                nop
                bne         .bs_modeblit40

;                 Affichage du sprite plan 2

                addq.l      #2,D3                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)      ;Adresse source
                move.w      D2,-(A5)                ;taille destination vertical en ligne (blt_ycount)
                move.w      #1,-(A5)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)    ;start le blitter en mode partage de bus
.bs_modeblit41  bset.b      #7,blt_LineNum(A6)      ;redemarre le blitter
                nop
                bne         .bs_modeblit41
                
;                 Affichage du sprite plan 3

                addq.l      #2,D3                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)      ;Adresse source
                move.l      D4,(A5)+                ;Adresse destination (blt_DstAddr)
                move.w      #1,(A5)+                ;taille destination horizontal en mot (blt_Xcount)
                move.w      D2,(A5)+                ;taille destination vertical en ligne (blt_ycount)
                move.b      #128,blt_LineNum(A6)    ;start le blitter en mode partage de bus
.bs_modeblit42  bset.b      #7,blt_LineNum(A6)      ;redemarre le blitter
                nop
                bne         .bs_modeblit42
                
;                 Affichage du sprite plan 4   

                addq.l      #2,D3                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D3,blt_SrcAddr(A6)      ;Adresse source
                move.w      D2,-(A5)                ;taille destination vertical en ligne (blt_ycount)
                move.w      #1,-(A5)                ;taille destination horizontal en mot (blt_Xcount)
                move.l      D4,-(A5)                ;Adresse destination (blt_DstAddr)
                move.b      #128,blt_LineNum(A6)    ;start le blitter en mode partage de bus
.bs_modeblit43  bset.b      #7,blt_LineNum(A6)      ;redemarre le blitter
                nop
                bne         .bs_modeblit43
                
                clr.b       D0                      ;valeur de retour sprite non clippé 
                rts
                
.endblitsprt:   move.b      #true,D0                ;valeur de retour sprite clippé
                rts




;           /--------------------------------------------------------/
;           /               SOUS PROGRAMME SETBACKSPRITE             /
;           /       mise à l'ecran de l'arriere plan d'un sprite     /
;           /                utilisation du blitter                  /
;           /                                                        /
;           /   Parametres :                                         /
;           /               D4=mode d'affichage (true=32x16)         /
;           /               D5=adresse de l'ecran xbios              /
;           /               D6=adresse de stockage de                /
;           /                           l'arriere plan 256 octets    /
;           /   dependance :                                         /
;           /               BLITDEF.L utilisation du registre A5     /
;           /               Necessite d'etre en mode superviseur     /
;           /--------------------------------------------------------/

setbacksprite:  
;           verification si background à afficher

                lea         blt_BaseAddr+blt_SrcXinc,A6 ;A6 pointe sur l'adresse blt_SrcXinc
                
;           verification du mode d'affichage 32x16 ou 16x16

                tst.b       D4                      ;si D3=0
                beq         .sback16                ;alors mode d'affichage 16x16

;           restitution de la memoire d'un arriere plan de 32x16 pixel

                move.l      #$00020002,(A6)+        ;increment horizontal source (blt_SrcXinc) & increment vertical source (blt_SrcYinc)
                move.l      D6,(A6)+                ;adresse de la source (blt_SrcAddr)
                move.l      #$FFFFFFFF,(A6)+        ;masque final 1 (blt_EndMask1) & masque final 2 (blt_EndMask2)
                move.w      #$FFFF,(A6)+            ;masque final 3 (blt_EndMask3)
                move.l      #$00020092,(A6)+        ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                move.l      D5,(A6)+                ;adresse de la destination (blt_DstAddr)
                move.l      #$00080010,(A6)+        ;taille dest horizontal en mot (blt_Xcount) & ;taille dest vertical en ligne (blt_Ycount)
                move.w      #$0203,(A6)+            ;utilisation de la source seule (blt_Hop) & mode affichage remplacer (blt_Op)
                move.w      #$8000,(A6)             ;start le blitter avec partage de bus (blt_LineNum) & pas d'ajustement au pixel (blt_Skew)

.sbackloop1:    bset.b      #7,(A6)                 ;redemarre le blitter (blt_LineNum)
                nop
                bne         .sbackloop1
                rts             

;           restitution de la memoire d'un arriere plan de 16x16 pixel

.sback16:       move.l      #$00020002,(A6)+        ;increment horizontal source (blt_SrcXinc) & increment vertical source (blt_SrcYinc)
                move.l      D6,(A6)+                ;adresse de la source (blt_SrcAddr)
                move.l      #$FFFFFFFF,(A6)+        ;masque final 1 (blt_EndMask1) & masque final 2 (blt_EndMask2)
                move.w      #$FFFF,(A6)+            ;masque final 3 (blt_EndMask3)
                move.l      #$0002009A,(A6)+        ;increment horizontal destination (blt_DstXinc) & increment vertical destination (blt_DstYinc)
                move.l      D5,(A6)+                ;adresse de la destination (blt_DstAddr)
                move.l      #$00040010,(A6)+        ;taille dest horizontal en mot (blt_Xcount) & taille dest vertical en ligne (blt_Ycount)
                move.w      #$0203,(A6)+            ;utilisation de la source seule (blt_Hop) & mode affichage remplacer (blt_Op)
                move.w      #$8000,(A6)             ;start le blitter avec partage de bus (blt_LineNum) & pas d'ajustement au pixel (blt_Skew)

.sbackloop2:    bset.b      #7,(A6)                 ;redemarre le blitter (blt_LineNum)
                nop
                bne         .sbackloop2
.endsetback:    rts                                 ;retour au programme appelant




              SECTION BSS

bs_spritedata:  DS.W        1                       ;nbligne
                DS.W        1                       ;yclipoffset
                DS.W        1                       ;mask1
                DS.W        1                       ;mask3
                DS.L        1                       ;adresse memoire des sprites
                DS.L        1                       ;adresse memoire des masks des sprites
        
gback_store:    DS.L        1                       ;contient l'adresse de stockage de l'arriere plan
gback_posaddr:  DS.L        1                       ;contient l'adresse de position du background à l'ecran
gback_mode3216: DS.B        1                       ;mode 32x16 ou 16x16
                DS.B        1
                