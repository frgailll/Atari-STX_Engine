;                     SOUS PROGRAMME DRAWMAP
;              Dessine une MAP depuis avec des tiles de 8*x et 16*x



                SECTION TEXT
                
;           /-----------------------------------------------/
;           /      Dessine un tile de 8 pixels de large     /
;           /            utilisation du blitter             /
;           /                                               /
;           /   parametres:                                 /
;           /               D5=adresse source du tile       /
;           /               D4=adresse de destination       /
;           /               D3=nombre de ligne              /
;           /               D2=valeur de rotation           /
;           /-----------------------------------------------/

drawmap8:       lea         blt_BaseAddr,A1             ;pointe sur l'adresse de base du blitter
                lea         blt_SrcXinc(A1),A3          ;pointe sur l'adresse de base du blitter + blt_SrcXinc
                                                
;           paramétres fixes du blitter
              
                move.l      #$00000008,(A3)+            ;pas d'incrementation horizontal (blt_SrcXinc) & incrementation pour passer à la ligne suivante (blt_SrcYinc)
                move.l      D5,(A3)+                    ;adresse du tile à dessiner (blt_SrcAddr)
                move.b      D2,blt_Skew(A1)             ;valeur de rotation, 8 ou 0
                beq         .drt8_noskew                ;si rotation = 0, alors aller à .drt8_noskew
                move.w      #$00FF,(A3)+                ;valeur masque 1 pour skew = 8 (blt_EndMask1)
                bra         .drt8_skew
.drt8_noskew    move.w      #$FF00,(A3)+                ;valeur masque 1 pour skew = 0 (blt_EndMask1)
.drt8_skew      move.l      #$FFFFFFFF,(A3)+            ;valeur masque 2 (blt_EndMask2) & valeur masque 3 (blt_EndMask3)
                move.l      #$000000A0,(A3)+            ;pas d'incrementation horizontal (blt_DstXinc) & incrementation pour passer à la ligne suivante (blt_DstYinc)
                move.w      #$0203,blt_Hop(A1)          ;source seul sans mémoire demi-teinte & opération logique Source seul
                                
;               affichage tile plan 1

                move.l      D4,(A3)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.w      #1,(A3)+                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.w      D3,(A3)+                ;nombre de lignes à traiter (blt_Ycount)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt8_blrest10  bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt8_blrest10

;               affichage tile plan 2

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.w      D3,-(A3)                ;nombre de lignes à traiter (blt_Ycount)
                move.w      #1,-(A3)                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.l      D4,-(A3)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt8_blrest11  bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt8_blrest11
                
;               affichage tile plan 3

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.l      D4,(A3)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.w      #1,(A3)+                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.w      D3,(A3)+                ;nombre de lignes à traiter (blt_Ycount)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt8_blrest12  bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt8_blrest12

;               affichage tile plan 4

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.w      D3,-(A3)                ;nombre de lignes à traiter (blt_Ycount)
                move.w      #1,-(A3)                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.l      D4,-(A3)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt8_blrest13  bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt8_blrest13

                rts                



;           /-----------------------------------------------/
;           /      Dessine un tile de 16 pixels de large    /
;           /            utilisation du blitter             /
;           /                                               /
;           /   parametres:                                 /
;           /               D5=adresse source du tile       /
;           /               D4=adresse de destination       /
;           /               D3=nombre de ligne              /
;           /-----------------------------------------------/

drawmap16:      lea         blt_BaseAddr,A1             ;pointe sur l'adresse de base du blitter
                lea         blt_SrcXinc(A1),A3          ;pointe sur l'adresse de base du blitter + blt_SrcXinc
                move.l      #$00000008,(A3)+            ;pas d'incrementation horizontal (blt_SrcXinc) & incrementation pour passer à la ligne suivante (blt_SrcYinc)
                move.l      D5,(A3)+                    ;adresse du tile à dessiner (blt_SrcAddr)
                move.b      #0,blt_Skew(A1)             ;valeur de rotation, 8 ou 0
                move.w      #$FFFF,(A3)+                ;valeur masque 1 (blt_EndMask1)
                move.l      #$FFFFFFFF,(A3)+            ;valeur masque 2 (blt_EndMask2) & valeur masque 3 (blt_EndMask3)
                move.l      #$000000A0,(A3)+            ;pas d'incrementation horizontal (blt_DstXinc) & incrementation pour passer à la ligne suivante (blt_DstYinc)
                move.w      #$0203,blt_Hop(A1)          ;source seul sans mémoire demi-teinte & opération logique Source seul
                
 ;               affichage tile plan 1

                move.l      D4,(A3)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.w      #1,(A3)+                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.w      D3,(A3)+                ;nombre de lignes à traiter (blt_Ycount)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt16_blrest10 bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt16_blrest10

;               affichage tile plan 2

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.w      D3,-(A3)                ;nombre de lignes à traiter (blt_Ycount)
                move.w      #1,-(A3)                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.l      D4,-(A3)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt16_blrest11 bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt16_blrest11

;               affichage tile plan 3

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.l      D4,(A3)+                ;adresse de destination à l'écran (blt_DstAddr)
                move.w      #1,(A3)+                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.w      D3,(A3)+                ;nombre de lignes à traiter (blt_Ycount)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt16_blrest12 bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt16_blrest12
                
;               affichage tile plan 4

                addq.l      #2,D5                   ;passe au plan suivant
                addq.l      #2,D4                   ;passe au plan suivant
                move.l      D5,blt_SrcAddr(A1)      ;adresse du tile à dessiner
                move.w      D3,-(A3)                ;nombre de lignes à traiter (blt_Ycount)
                move.w      #1,-(A3)                ;lecture de 4 mots en horizontal car 4 plan (blt_Xcount)
                move.l      D4,-(A3)                ;adresse de destination à l'écran (blt_DstAddr)
                move.b      #128,blt_LineNum(A1)    ;start le blitter en mode partage de bus
.drt16_blrest13 bset.b      #7,blt_LineNum(A1)      ;redemarre le blitter
                nop
                bne         .drt16_blrest13

                rts
                
                
                
                
                