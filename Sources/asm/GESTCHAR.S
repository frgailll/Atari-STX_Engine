;                          SOUS PROGRAMME GESTCHAR
;              Gestion de l'affichage des caractères graphiques


charsetsize		EQU			760						;8 octets du code ascii 32 à 126	



				SECTION TEXT
				
				
;        /-----------------------------------------------/
;        /          Initialisation des charsets          /
;        /-----------------------------------------------/				

chr_initcharset	move.l		#0,chr_charaddr
				rts
				



;        /-----------------------------------------------/
;        /         Déinitialisation des charsets         /
;        /-----------------------------------------------/

_STX_Unloadcharset:				
chr_uninitcharset:	
				cmp.l		#0,chr_charaddr
				beq			.chr_enduninit
				M_mfree     chr_charaddr            ;adresse de debut de memoire des charset
                move.l      #$0,chr_charaddr   		;efface adresse de debut de memoire
.chr_enduninit	rts
				



;        /-----------------------------------------------/
;        /      ouverture et chargement des charsets     /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              chemin et nom du fichier         /
;        /  retourne:                                    /    
;        /             -1 en cas d'erreur, sinon 0       /
;        /-----------------------------------------------/
				
_STX_loadcharset:				
				movem.l     D7-D6/A6,minit_saveregs
				move.l      4(A7),D6                ;contient le pointeur sur le fichier charset
                move.w      #$FFFF,D0               ;D0 = -1 (erreur)
                tst.l       chr_charaddr            ;si chr_charaddr <> 0
                bne         .chr_loadend            ;alors charset déja chargé
                
;          Fixe la valeur du tampon DTA

                M_fsetdta   #chr_dtacharset         ;adresse du tampon DTA de la tilesmap
                                
;       Recherche du fichier d'effet audio dans D6

                M_fsfirst   #0,D6                   ;acces normal, lecture / ecriture, pointe sur nom du fichier charset avec zero terminal
                tst.w       D0                      ;si D0<0
                bne         .chr_loadend            ;alors le fichier n'existe pas
                
;       reservation mémoire pour stockage du fichier

                M_malloc    #charsetsize*2          ;taille du fichier charset multiplié par 4 (charset 16x32)
                tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .chr_loadend            ;branchement pour fermeture du fichier
				move.l		D0,chr_charaddr			;sauvegarde de l'adresse des charset en mémoire
                move.l      D0,A6                   ;A6 pointe sur l'adresse de stockage des charset

;          ouverture du fichier charset

                M_fopen     #0,D6                   ;ouverture fichier en lecture seul, D6 pointe sur le nom du fichier
                tst.w       D0                      ;si D0<0
                bmi         .chr_loadend            ;alors erreur d'ouverture
                move.w      D0,D7                   ;D7 = le handle du fichier
				
;			lecture fichier et fabrication des données en mémoire

.chr_nextchar   M_fread     A6,#1,D7;adresse de stockage des charset, ecture octet par octet, handle du fichier
                tst.w		D0						;si D0 = 0
				beq			.chr_closechar 			;plus d'octet à lire, fermer le fichier
				adda.l		#1,A6					;incremente l'adresse de 1
				move.b		#00,(A6)+				;stocke 00 (8bits) et incremete le pointeur d'adresse
                bra			.chr_nextchar			;lit l'octet suivant
				
;         fermeture du fichier de charset   

.chr_closechar  M_fclose    D7                      ;handle du fichier à fermer                
				
				moveq       #0,D0
.chr_loadend    movem.l     minit_saveregs,D7-D6/A6
                rts				
				

				

;        /-----------------------------------------------/
;        /    Affichage de charsets en mode caractères   /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              coordonnée X                     /
;        /              coordonnée Y                     /
;        /              couleur d'affichage              /
;        /              mode d'affichage                 /
;        /              Sens d'affichage                 /
;        /              chaine de caractère              /
;        /-----------------------------------------------/

_STX_printstring:
				movem.l     D7-D1/A6-A4,minit_saveregs
		    
;              Verification si pas de dépassement hors de l'écran
                
                moveq       #0,D7
                move.w		4(A7),D7				;recuperation carx dans D7
				cmp.w       #39,D7                  ;si carx > 39
                bhi         .prnt_noplan            ;quitter
                move.w		6(A7),D6				;recuperation de cary dans D6
                cmp.w       #24,D6                  ;si cary > 24
                bhi         .prnt_noplan            ;quitter
                move.l      D7,D2                   ;sauvgarde de D7
                move.w      D6,D1                   ;sauvgarde de D6
                
;                   initialisation des registres

                move.l      chr_charaddr,D4         ;D4 contient l'adresse de debut des caratères
                move.l      minit_workscr,D0        ;D0 contient l'adresse de l'écran de travail
                lea			chr_carytable,A6		;pointe sur la table des offset en y
                lea         blt_BaseAddr,A5         ;pointe sur le blitter
                move.w      8(A7),D3                ;D3 contient la couleur d'affichage
                cmp.b       #15,D3                  ;si couleur <= 15
                bls         .prnt_colorOK           ;couleur OK, passer à la suite
                move.b      #15,D3                  ;sinon couleur = 15
.prnt_colorOK   move.l      14(A7),A4               ;recupération pointeur sur la chaine de caractère
            
;                   initialisation du blitter
                              
                move.l      #$00000002,blt_SrcXinc(A5)  ;pas d'increment sur la source en X avec avance de 2 octet en vertical (blt_SrcYinc)
                move.l      #$FFFFFFFF,blt_EndMask2(A5) ;mask2 avec mask3
                move.l      #$000000A0,blt_DstXinc(A5)  ;pas d'incrementation en X avec passe à la ligne suivante (blt_DstYinc)
                move.b      #2,blt_Hop(A5)          ;pas d'utilisation de la demi-teinte

;                 calcul adresse de destination
                
.prnt_nextcar   move.l      D2,D7                   ;rappel de carx
                move.w      D1,D6                   ;rappel de cary
                andi.w		#$FFFE,D7				;pas de coordonnée impaire pou carx
				lsl.w		#2,D7					;multipli D7 par 4
                add.w       D6,D6                   ;D6 = D6 x 2 (car valeur table sur 2 octets)
                add.w		(A6,D6.W),D7	        ;D7 = offset adresse écran vertical
                add.l       D0,D7                   ;D7 = adresse destination
                         
;               lecture d'un caractère de la chaine                
                
                moveq       #0,D5                   ;efface D5
                move.b      (A4)+,D5                ;D5 contient le premier caractère de la chaine
                beq         .prnt_noplan            ;si D5 = 0 (fin de chaine), quitter
                subi.b      #32,D5                  ;soustraie 32 (valeur ascii de debut de caractère imprimable)
                lsl.w       #4,D5                   ;multipli D5 par 16 (un caractere fait 8+8 octets)
                add.l       D4,D5                   ;D5 contient l'adresse du caractere à afficher           

;                    calcul des masques et valeur rotation

                btst.l      #0,D2                   ;test bit 0 de crx
                beq         .prnt_norota            ;si egal à 0, pas de rotation
                move.w      #$00FF,blt_EndMask1(A5) ;sinon mask pour rotation de 8
                move.b      #8,blt_Skew(A5)         ;rotation de 8 pour les caracteres
                bra         .prnt_modeaff1          ;aller à la suite
.prnt_norota    move.w      #$FF00,blt_EndMask1(A5) ;mask1 pour rotation de 0
                move.b      #0,blt_Skew(A5)         ;pas de rotation de caractere
               
.prnt_modeaff1  cmp.w       #0,10(A7)               ;si mode affichage = 0 (replace)
                beq         .prnt_modeaff2          ;alors afficher directement sans le mask

;                   mask plan 1 (fabrication et affichage)

                move.b      #4,blt_Op(A5)           ;mode d'affichage Not Source AND destination
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltmask1  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltmask1

;                   mask plan 2 (fabrication et affichage)

                addq.l      #2,D7                   ;passe au plan suivant pour la destination
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)          
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltmask2  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltmask2

;                   mask plan 3 (fabrication et affichage)

                addq.l      #2,D7                   ;passe au plan suivant pour la destination
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltmask3  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltmask3

;                   mask plan 4 (fabrication et affichage)

                addq.l      #2,D7                   ;passe au plan suivant pour la destination
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltmask4  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltmask4
                

;                       mode d'affichage du motif

                subi.l      #6,D7                   ;repositionne D7 sur le premier plan
                cmp.w       #2,10(A7)               ;si mode effacement
                beq         .prnt_suivant           ;passer au caractere suivant
                move.b      #7,blt_Op(A5)           ;source ou destination (mode transparence)
                bra         .prnt_carplan1
.prnt_modeaff2  move.b      #3,blt_Op(A5)           ;source seul (mode remplacement)
                

;                   caractere plan 1 (bit 0 of color)
           
.prnt_carplan1  btst.b      #0,D3
                beq         .prnt_carplan2
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltplan1  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltplan1

;                   caractere plan 2 (bit 1 of color)

.prnt_carplan2  addq.l      #2,D7                   ;passe au plan suivant pour la destination
                btst.b      #1,D3
                beq         .prnt_carplan3
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltplan2  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltplan2
                
;                   caractere plan 3 (bit 2 of color)

.prnt_carplan3  addq.l      #2,D7                   ;passe au plan suivant pour la destination
                btst.b      #2,D3
                beq         .prnt_carplan4
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltplan3  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltplan3   

;                   caractere plan 4 (bit 3 of color)

.prnt_carplan4  addi.l      #2,D7                   ;passe au plan suivant pour la destination
                btst.b      #3,D3
                beq         .prnt_suivant
                move.l      D5,blt_SrcAddr(A5)      ;adresse de la source
                move.l      D7,blt_DstAddr(A5)      ;adresse de la destination
                move.l      #$00010008,blt_Xcount(A5)   ;nombre de mot à lire avec  nombre de ligne (blt_Ycount)
                move.b      #128,blt_LineNum(A5)    ;start le blitter en mode partage de bus
.prnt_bltplan4  bset.b      #7,blt_LineNum(A5)      ;redemarre le blitter
                nop
                bne         .prnt_bltplan4                
                
;                 calcul parametre pour carctere suivant

.prnt_suivant   move.w      12(A7),D5               ;recupère la valeur du sens d'affichage
                beq         .prnt_sensv             ;si D5 = 0 (vertical) alors aller à .prnt_sensv
                addq.w      #1,D2                   ;incrementer D7 (carx)
                bra         .prnt_nextcar           ;passer au caractère suivant 
.prnt_sensv     subq.w      #1,D1                   ;decrementer D6 (cary)
                bra         .prnt_nextcar           ;passer au caractere suivant
                
                
.prnt_noplan    movem.l     minit_saveregs,D7-D1/A6-A4
				rts
				


;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 2 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_charto2digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.w      4(A7),D7
                lea         chr_hextobcd+4,A5
                                 
;           extraction du premier quarte pour convertion en BCD
                 
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to2_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to2_digit2     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to2_tostring           ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2         
            
;                           convertion BCD en String
            
.to2_tostring   move.l      6(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      10(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to2_affzero            ;si D6 <> false

                rol.b       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to2_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to2_tostring1          ;sinon afficher que le digit 1        
                
.to2_affzero    rol.b       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to2_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to2_tostring1  rol.b       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts

 
   
   
;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 3 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_shortto3digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.w      4(A7),D7
                lea         chr_hextobcd+4,A5
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to3_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6     
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to3_digit2     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to3_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to3_digit3     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to3_tostring           ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2

;                           convertion BCD en String
            
.to3_tostring   move.l      6(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      10(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to3_affzero            ;si D6 <> false

                rol.w       #8,D7                   ;rotation de 8 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to3_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to3_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to3_tostring1          ;sinon afficher que le digit 1 

.to3_affzero    rol.w       #8,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to3_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to3_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to3_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts
                
                

;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 4 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_shortto4digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.w      4(A7),D7
                lea         chr_hextobcd+4,A5 
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to4_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6 
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4
                
;           extraction du deuxieme quarte pour convertion en BCD
            
.to4_digit2     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to4_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to4_digit3     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to4_digit4             ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du quatrieme quarte pour convertion en BCD

.to4_digit4     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to4_tostring           ;si valeur à convertir = 0 alors passer au digit 5
                lea         chr_bcdtbl_4+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_4
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2

;                           convertion BCD en String
            
.to4_tostring   move.l      6(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      10(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to4_affzero            ;si D6 <> false

                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 4
                bne         .to4_tostring4          ;si Digit4 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to4_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to4_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to4_tostring1          ;sinon afficher que le digit 1          

.to4_affzero    rol.w       #4,D7                   ;traitement Digit 4
                move.b      D7,D6
                andi.b      #$0F,D6
.to4_tostring4  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to4_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to4_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to4_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts

                
                
                
;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 5 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_longto5digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.l      4(A7),D7
                lea         chr_hextobcd+4,A5      
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to5_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6   
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to5_digit2     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to5_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to5_digit3     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to5_digit4             ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du quatrieme quarte pour convertion en BCD

.to5_digit4     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to5_digit5             ;si valeur à convertir = 0 alors passer au digit 5
                lea         chr_bcdtbl_4+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_4
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                lea         3(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du cinquième quarte pour convertion en BCD

.to5_digit5     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to5_tostring           ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_5+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3

;                           convertion BCD en String
            
.to5_tostring   move.l      8(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      12(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to5_affzero            ;si D6 <> false

                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 5
                bne         .to5_tostring5          ;si Digit5 <> 0 alors l'afficher
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 4
                bne         .to5_tostring4          ;si Digit4 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to5_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to5_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to5_tostring1          ;sinon afficher que le digit 1         

.to5_affzero    swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                move.b      D7,D6                   ;traitement Digit 5
                andi.b      #$0F,D6
.to5_tostring5  addi.b      #$30,D6
                move.b      D6,(A6)+
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;traitement Digit 4
                move.b      D7,D6
                andi.b      #$0F,D6
.to5_tostring4  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to5_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to5_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to5_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts


                
                
;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 6 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_longto6digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.l      4(A7),D7
                lea         chr_hextobcd+4,A5
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to6_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to6_digit2     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to6_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD          
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to6_digit3     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to6_digit4             ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du quatrieme quarte pour convertion en BCD

.to6_digit4     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to6_digit5             ;si valeur à convertir = 0 alors passer au digit 5
                lea         chr_bcdtbl_4+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_4
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                lea         3(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du cinquième quarte pour convertion en BCD

.to6_digit5     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to6_tostring           ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_5+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3

;                           convertion BCD en String
            
.to6_tostring   move.l      8(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      12(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to6_affzero            ;si D6 <> false

                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                ror.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 6
                bne         .to6_tostring6          ;si Digit6 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 5
                bne         .to6_tostring5          ;si Digit5 <> 0 alors l'afficher
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 4
                bne         .to6_tostring4          ;si Digit4 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to6_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to6_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to6_tostring1          ;sinon afficher que le digit 1            

.to6_affzero    swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible 
                ror.w       #4,D7                   ;traitement Digit 6
                move.b      D7,D6
                andi.b      #$0F,D6
.to6_tostring6  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 5
                move.b      D7,D6
                andi.b      #$0F,D6
.to6_tostring5  addi.b      #$30,D6
                move.b      D6,(A6)+
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;traitement Digit 4
                move.b      D7,D6
                andi.b      #$0F,D6
.to6_tostring4  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to6_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to6_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to6_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts

                


;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 7 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_longto7digit:
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.l      4(A7),D7
                lea         chr_hextobcd+4,A5 
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6  
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to7_digit2     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to7_digit3     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_digit4             ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du quatrieme quarte pour convertion en BCD

.to7_digit4     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_digit5             ;si valeur à convertir = 0 alors passer au digit 5
                lea         chr_bcdtbl_4+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_4
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                lea         3(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du cinquième quarte pour convertion en BCD

.to7_digit5     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_digit6             ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_5+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 4
                lea         4(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;             extraction du sixième quarte pour convertion en BCD

.to7_digit6     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to7_tostring           ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_6+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 4
            
;                           convertion BCD en String
            
.to7_tostring   move.l      8(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      12(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to7_affzero            ;si D6 <> false

                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #8,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 7
                bne         .to7_tostring7          ;si Digit7 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 6
                bne         .to7_tostring6          ;si Digit6 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 5
                bne         .to7_tostring5          ;si Digit5 <> 0 alors l'afficher
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 4
                bne         .to7_tostring4          ;si Digit4 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to7_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to7_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to7_tostring1          ;sinon afficher que le digit 1            

.to7_affzero    swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible 
                rol.w       #8,D7                   ;traitement Digit 7
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring7  addi.b      #$30,D6 
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 6
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring6  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 5
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring5  addi.b      #$30,D6
                move.b      D6,(A6)+
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;traitement Digit 4
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring4  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to7_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to7_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts




;        /-----------------------------------------------/
;        /  Convertie un char en une valeur sur 8 digit  /
;        /                                               /
;	     /  Paramétres:		                             /
;        /              valeur sur 1 octet               /
;        /              si true affichage des 0          /
;        /                                               /
;        /  retourne :                                   /
;        /              pointeur sur une chaine          /
;        /-----------------------------------------------/

_STX_longto8digit:
                
                movem.l     D7-D6/A6-A5,minit_saveregs
                moveq       #0,D6                   ;initialise l'index de table
                clr.l       chr_hextobcd            ;resultat de la convertion
                andi.b      #$EB,CCR                ;efface les bit Z et X
            
;                   recupération valeur à convertir    
            
                move.l      4(A7),D7
                lea         chr_hextobcd+4,A5 
                                 
;           extraction du premier quarte pour convertion en BCD
            
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit2             ;si valeur à convertir = 0 alors passer au digit 2
                lea         chr_bcdtbl_1+1,A6
                adda.l      D6,A6                   ;A6 pointe sur la valeur BCD du quarte 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat
                lea         1(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du deuxieme quarte pour convertion en BCD
            
.to8_digit2     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit3             ;si valeur à convertir = 0 alors passer au digit 3
                lea         chr_bcdtbl_2+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;           extraction du troisieme quarte pour convertion en BCD

.to8_digit3     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit4             ;si valeur à convertir = 0 alors passer au digit 4
                lea         chr_bcdtbl_3+2,A6       ;A6 pointe au debut des valeurs BCD
                add.w       D6,D6                   ;multiplie D6 par 2
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                lea         2(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du quatrieme quarte pour convertion en BCD

.to8_digit4     lsr.l       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit5             ;si valeur à convertir = 0 alors passer au digit 5
                lea         chr_bcdtbl_4+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_4
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                lea         3(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;           extraction du cinquième quarte pour convertion en BCD

.to8_digit5     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit6             ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_5+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 4
                lea         4(A5),A5                ;repositionne A5 sur chr_hextobcd+4

;             extraction du sixième quarte pour convertion en BCD

.to8_digit6     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_digit7             ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_6+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 4
                lea         4(A5),A5                ;repositionne A5 sur chr_hextobcd+4
            
;               extraction du septieme quarte pour convertion en BCD

.to8_digit7     lsr.w       #4,D7                   ;decale D7 à droite
                move.b      D7,D6                   ;D6 = valeur octet poid faible de D7
                andi.w      #$000F,D6               ;garde quarte de poids faible
                beq         .to8_tostring           ;si valeur à convertir = 0 alors passer au digit 6
                lea         chr_bcdtbl_7+4,A6       ;A6 pointe au debut des valeurs BCD
                lsl.w       #2,D6                   ;multiplie D6 par 4
                adda.l      D6,A6                   ;A6 pointe sur l'octet 1 de la valeur BCD de la table bcdtbl_5
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 1
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 2
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 3
                abcd        -(A6),-(A5)             ;ajoute la valeur BCD au resultat octet 4

;                           convertion BCD en String
            
.to8_tostring   move.l      8(A7),A6                ;A6 pointe sur le buffer de sortie
                move.l      chr_hextobcd,D7         ;D6 contient la valeur BCD
                
                move.w      12(A7),D6               ;D6 contient le flag d'affichage des zero non significatif
                bne         .to8_affzero            ;si D6 <> false

                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 8 
                bne         .to8_tostring8          ;si Digit8 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 7
                bne         .to8_tostring7          ;si Digit7 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 6
                bne         .to8_tostring6          ;si Digit6 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits à droite de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 5
                bne         .to8_tostring5          ;si Digit5 <> 0 alors l'afficher
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 4
                bne         .to8_tostring4          ;si Digit4 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 3
                bne         .to8_tostring3          ;si Digit3 <> 0 alors l'afficher
                rol.w       #4,D7                   ;rotation de 4 bits de la valeur BCD
                move.b      D7,D6                   ;D6 = D7
                andi.b      #$0F,D6                 ;D6 = valeur du digit 2
                bne         .to8_tostring2          ;si Digit2 <> 0 alors l'afficher
                bra         .to8_tostring1          ;sinon afficher que le digit 1            

.to8_affzero    swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible 
                rol.w       #4,D7                   ;traitement Digit 8
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring8  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 7
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring7  addi.b      #$30,D6 
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 6
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring6  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 5
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring5  addi.b      #$30,D6
                move.b      D6,(A6)+
                swap        D7                      ;inversion deux octets poids forts avec les deux octets poids faible
                rol.w       #4,D7                   ;traitement Digit 4
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring4  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 3
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring3  addi.b      #$30,D6
                move.b      D6,(A6)+
                rol.w       #4,D7                   ;traitement Digit 2
                move.b      D7,D6
                andi.b      #$0F,D6
.to8_tostring2  addi.b      #$30,D6
                move.b      D6,(A6)+
.to8_tostring1  rol.w       #4,D7                   ;traitement Digit 1
                move.b      D7,D6
                andi.b      #$0F,D6
                addi.b      #$30,D6
                move.b      D6,(A6)+
                move.b      #$00,(A6)               ;ajout du 0 terminal
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts
                
                

				
				SECTION BSS
				

chr_dtacharset:	DS.B        44                      ;buffer pour la DTA
chr_charaddr:	DS.L		1						;adresse de sauvegarde des charsets
chr_stringbcd   DS.B        10                      ;contient la convertion bcd en chaine de caractere
chr_hextobcd    DS.B        4                       ;conversion binaire en BCD


                SECTION DATA

chr_carytable:	DC.W		0,1280,2560,3840,5120,6400,7680,8960,10240      ;offset d'adresse écran em multiple de 8 lignes
				DC.W		11520,12800,14080,15360,16640,17920,19200,20480
				DC.W		21760,23040,24320,25600,26880,28160,29440,30720
chr_bcdtbl_1    DC.B        $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$10,$11 ;valeurs decimale du premier digit
                DC.B        $12,$13,$14,$15
chr_bcdtbl_2    DC.W        $00,$0016,$0032,$0048,$0064,$0080,$0096,$0112   ;valeurs decimales du deuxieme digit
                DC.W        $0128,$0144,$0160,$0176,$0192,$0208,$0224,$0240
chr_bcdtbl_3    DC.W        $00,$0256,$0512,$0768,$1024,$1280,$1536,$1792   ;valeurs decimales du troisieme digit
                DC.W        $2048,$2304,$2560,$2816,$3072,$3328,$3584,$3840
chr_bcdtbl_4    DC.L        $00,$00004096,$00008192,$00012288,$00016384,$00020480   ;valeurs decimales du quatrième digit
                DC.L        $00024576,$00028672,$00032768,$00036864,$00040960
                DC.L        $00045056,$00049152,$00053248,$00057344,$00061440
chr_bcdtbl_5    DC.L        $00,$00065536,$00131072,$00196608,$00262144,$00327680   ;valeurs decimales du cinquièmes digit
                DC.L        $00393216,$00458752,$00524288,$00589824,$00655360
                DC.L        $00720896,$00786432,$00851968,$00917504,$00983040
chr_bcdtbl_6    DC.L        $00,$01048576,$02097152,$03145728,$04194304,$05242880   ;valeurs decimales du sixième digit
                DC.L        $06291456,$07340032,$08388608,$09437184,$10485760
                DC.L        $11534336,$12582912,$13631488,$14680064,$15728640
chr_bcdtbl_7    DC.L        $00,$16777216,$33554432,$50331648,$67108864,$83886080   ;valeurs decimales du septième digit

                
