;                     SOUS PROGRAMME GESTILES
;              Gestion des tiles-map et tiles-set



;           /--------------------------------------------/
;           /           STRUCTURE D'UNE TILESMAP         /
;           /--------------------------------------------/

tlm_nbtilesW    EQU         0                       ;(w)nombres total de tiles en largeur de la tilesmap
tlm_nbtilesH    EQU         2                       ;(w)nombre total de tiles en hauteur de la tilesmap
tlm_sztilesW    EQU         4                       ;(b)taille en pixel d'un tile en largeur
tlm_sztilesH    EQU         5                       ;(b)taille en pixel d'un tile en hauteur
tlm_nbtiles     EQU         6                       ;(w)nombre de tiles de valeur différentes utilisés dans la map
tlm_reserve     EQU         8                       ;(w)réservé pour futur utilisation

tlm_mapsize     EQU         10                      ;(w)taille de la map en tiles (ou en octets pour une map de 8xX)
tlm_1sttileX    EQU         12                      ;(w)position à l'écran en X (pixel) du premier tile
tlm_1sttileY    EQU         14                      ;(w)position à l'écran en Y (pixel) du premier tile
tlm_tilestartX  EQU         16                      ;(w)Valeur X(tile) du premier tile de la tilesmap à afficher
tlm_tilestartY  EQU         18                      ;(w)Valeur Y(tile) du premier tile de la tilesmap à afficher
tlm_tilesWidth  EQU         20                      ;(b)Valeur Largeur (tile) affiché à l'écran
tlm_tilesHeight EQU         21                      ;(b)Valeur Hauteur (tile) affiché à l'écran

tlm_tilesmap    EQU         22                      ;(l)adresse en mémoire de la tilesmap
tlm_tileset     EQU         26                      ;(l)adresse en mémoire de sauvegarde du tileset
tlm_tilesprop   EQU         30                      ;(l)adresse en mémoire des propriétés du premier tile
tlm_tilesscreen EQU         34                      ;(l)adresse en memoire des positions des tiles dans la zone d'affichage
tlm_linetileid  EQU         38                      ;(l)adresse en mémoire des id de tiles en debut de chaque ligne

;           /--------------------------------------------/
;           /              STRUCTURE D'UN TILE           /
;           /--------------------------------------------/

tlm_tilepropsize EQU        8                       ;taille de la structure propriété d'un tile

tlm_tileaddr    EQU         0                       ;(l)adresse du tile dans le tileset
tlm_tileprop1   EQU         4                       ;(b)Propriété 1 du tile
tlm_tileprop2   EQU         5                       ;(b)Propriété 2 du tile
tlm_tileprop3   EQU         6                       ;(b)Propriété 3 du tile
tlm_tiletrans   EQU         7                       ;(b)si tile doit être affiché avec transparence


                SECTION TEXT



;        /---------------------------------------------------/
;        /       ouverture du fichier de defintion de la     /
;        /     tilesmap TLM et du fichier des tileset TLS    /
;        /   parametre sur la pile :                         /
;        /          nom et chemin d'accés au fichier tlm     /
;        /          nom et chemin d'accés au fichier tls     /
;        /   retourne:                                       /
;        /          0 si pas d'erreur, sinon -1              /    
;        /---------------------------------------------------/

_STX_loadtilesmap:
;       /-------- chargement du fichier tilemap tlm ---------/
                movem.l     D5-D7/A6-A4,minit_saveregs
                move.l      4(A7),D6                ;D6 contient l'adresse de la chaine de caractere du chemin du fichier tlm
                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                move.w      #$FFFF,tlm_error        ;charge tlm_error avec -1 (valeur erreur)
                tst.l       tlm_tilesmap(A6)        ;si contenu de tlm_tilesmap <> 0
                bne         .tlmld_end              ;alors une tilesmap est déja chargée

;          Fixe la valeur du tampon DTA

                M_fsetdta	#tlm_dtatiles			;fixe l'adresse du tampon DTA pour la tilemap
				
;       Recherche du fichier de definition de la tilesmap tlm avec D6

                M_fsfirst	#0,D6					;acces lecture/ecriture, D6=pointe sur le nom du fichier
				move.w      D0,tlm_error            ;valeur de l'erreur
                bne         .tlmld_end              ;alors le fichier n'existe pas
                
;          ouverture du fichier de tilesmap tlm

                M_fopen		#0,D6					;lecture seul, D6 pointe sur le nom du fichier
				tst.w       D0                      ;si D0<0
                bmi         .tlmld_end              ;alors erreur d'ouverture
                move.w      D0,tlm_fhandle          ;sinon stock le handle du fichier
                
;         lecture des 10 octets de propriétés de la tilesmap (entete)

                M_fread		#tlm_properties,#10,tlm_fhandle	;adresse des propriéte de la tilemap,nombre d'octet à lire, handle du fichier
				
;         reservation mémoire pour stockage de la tilesmap 
 
                move.w      tlm_nbtilesW(A6),D7     ;Largeur de la tilesmap
                mulu        tlm_nbtilesH(A6),D7     ;D7 contient la taille en octet de la tilesmap
                move.w      D7,tlm_mapsize(A6)      ;taille de la map en tiles (ou en octet si tile de 8 en largeur)
                
;           si tile de 16*X
                
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tile != 16
                bne         .tlmld_map8             ;alors aller à (.tlmld_map8)
                add.w       D7,D7                   ;multipli par deux le nombre de tile contenu dans D7 car codé sur 2 octets
                
.tlmld_map8     clr.l       D6                      ;effacement de D6
                move.w      tlm_nbtiles(A6),D6      ;D6 contient le nombre de tiles de valeur différentes constituant la tilesmap
                lsl.w       #3,D6                   ;D6*8 contient le nombre d'octet utilisés par les propriétés des tiles
                move.l      D7,D5                   ;Met D7 dans D5
                add.l       D6,D5                   ;D5 contient le nombre d'octet à réserver pour la tilesmap + les propriétés des tiles      

                M_malloc	D5						;demande D5 octets de memoire
				tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .tlmld_closetlm         ;branchement pour fermeture du fichier
                move.w      #0,tlm_error            ;pas d'erreur rencontrée
                move.l      D0,tlm_tilesmap(A6)     ;sinon sauvegarde l'adresse du debut de la tilesmap
                add.l       D7,D0                   ;ajoute le nombre d'octet occupé par la tilesmap
                move.l      D0,tlm_tilesprop(A6)    ;addresse des propriété du premier tile
                
;          lecture de la tilesmap + propriétés des tiles et mise en mémoire
               
                M_fread		tlm_tilesmap(A6),D5,tlm_fhandle	;adresse de debut de la tilesmap, nombre d'octet à lire, handle du fichier
				
;          fermeture du fichier de tilesmaps   

.tlmld_closetlm M_fclose	tlm_fhandle				;handle du fichier à fermer
				                
;          initialisation des valeurs de positionnement

                move.w      #0,tlm_1sttileX(A6)     ;coordonnée X(pixel) du premier tile à l'écran
                move.w      #0,tlm_1sttileY(A6)     ;coordonnée Y(pixel) du premier tile à l'écran
                move.w      #0,tlm_tilestartX(A6)   ;coordonnée X(tile) du premier tile de la tilemap à afficher
                move.w      #0,tlm_tilestartY(A6)   ;coordonnée Y(tile) du premier tile de la tilemap à afficher
                move.b      #0,tlm_tilesWidth(A6)   ;largeur de tile à afficher
                move.b      #0,tlm_tilesHeight(A6)  ;hauteur de tile à afficher
                
;       /-------- chargement du fichier tilemap tls ---------/

                move.l      8(A7),D6                ;D6 contient l'adresse de la chaine de caractere du chemin du fichier tls

;       Recherche du fichier de tileset tls avec D6

                M_fsfirst	#0,D6					;acces lecture/ecriture, D6 pointe sur le nom du fichier
				move.w      D0,tlm_error            ;valeur de l'erreur
                bne         .tlmld_end              ;alors le fichier n'existe pas

;          ouverture du fichier de tileset tls

                M_fopen		#0,D6					;ouverture en lecture seul, D6 pointe sur le nom du fichier
				tst.w       D0                      ;si D0<0
                bmi         .tlmld_end              ;alors erreur d'ouverture
                move.w      D0,tlm_fhandle          ;sinon stock le handle du fichier
 
;         Calcul du nombre d'octet à réservés pour le tileset 
 
                moveq       #0,D5                   ;efface D5
                moveq       #0,D6                   ;efface D6
                move.b      tlm_sztilesH(A6),D5     ;D5 = nombre de lignes pour un tile
                move.w      tlm_nbtiles(A6),D6      ;D6 = nombre de tile différents de la tilesmap
                addq.l      #1,D6                   ;ajoute 1 car le tile de valeur 0 n'est pas prise en compte
                mulu        D6,D5                   ;D5 = D6 * D5(le nombre de ligne d'un tile)
                lsl.l       #4,D5                   ;D5 = D5 * 2(octet pour 16 pixels) * 4(nb plan)
                               
;          reservation mémoire pour stockage des tileset 
                
                M_malloc	D5						;demande D5 octets de memoire
				tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .tlmld_closetls         ;branchement pour fermeture du fichier
                move.w      #0,tlm_error            ;pas d'erreur rencontrée
                move.l      D0,tlm_tileset(A6)      ;sinon sauvegarde l'adresse du debut du tileset
                
;           lecture du fichier de tileset

                M_fread		tlm_tileset(A6),D5,tlm_fhandle	;adresse de debut des tileset, nombre d'octet à lire, handle du fichier
				                
;           fermeture du fichier de tileset  

.tlmld_closetls M_fclose	tlm_fhandle				;handle du fichier à fermer
				
;           renseigne les adresses des tiles dans les stuctures de propriétés des tiles

                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                move.l      tlm_tilesprop(A6),A5    ;A5 pointe sur la structure de propriété du premier tile (valeur 1)
                move.l      tlm_tileset(A6),A4      ;A4 pointe sur le  tiles 0 du tileset
                move.w      tlm_nbtiles(A6),D6      ;nombre de tile different ayant une structure de propriétés
                
                move.l      #0,D5
                move.b      tlm_sztilesH(A6),D5     ;nombre de ligne d'un tiles
                lsl.l       #3,D5                   ;multipli D5 par 8 (8 octest par lignes en mode 4 plans)

.tlmld_addrtls  adda.l      D5,A4                   ;ajoute la taille en octet d'un tile à A4 qui pointe sur le tile suivant
                move.l      A4,tlm_tileaddr(A5)     ;stocke l'adresse du tile 1 pointe par A4 dans la struture du premier tile pointe par A5
                adda.l      #tlm_tilepropsize,A5    ;Ajoute à A5 la taille d'une struture de propriété de tile pour pointer sur la structure suivante
                subi.w      #1,D6                   ;décrement le nombre de tiles differents
                bne         .tlmld_addrtls          ;si pas égale à 0, continuer à renseigner les adresses des propriétés

;           traitement des erreurs

.tlmld_end:     tst.w       tlm_error               ;si tlm_error < 0
                blt         .tlmld_error            ;alors erreur de chargement
                clr.w       D0                      ;efface D0 sur 16 bits
                move.b      tlm_sztilesW(A6),D0     ;D0 = largeur d'un tile en pixel
                lsr.b       #3,D0                   ;divise D0 par 8 (donc D0=1 ou 2)
                mulu        tlm_mapsize(A6),D0      ;multipli la taille en tile de la map par D0, D0 = taille en octet de la map
                bra         .tlmld_noerror          ;aller à .tlmld_noerror

.tlmld_error    move.w      tlm_error,D0            ;mettre tlm_error dans D0          
.tlmld_noerror  movem.l     minit_saveregs,D5-D7/A6-A4 
                rts


;        /-----------------------------------------------/
;        /      Sauvegarde de la tilesmap en mémoire     /
;        /   parametre sur la pile :                     /
;        /          pointeur d'adresse de la mémoire     /
;        /   retourne:                                   /
;        /          0 si sauvegarde OK, sinon -1         /
;        /-----------------------------------------------/

_STX_savetilesmap:
                movem.l     D7/A6-A4,minit_saveregs
                move.w      #$FFFF,D0               ;D0 = -1
                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                move.l      tlm_tilesmap(A6),A5     ;A5 pointe sur le debut de la tilesmap
                tst.l       4(A7)                   ;si pointeur de sauvegarde = 0
                beq         .savetlm_end            ;aller à .savetlm_end et retourner -1
                clr.w       D0                      ;efface D0 (pas d'erreur)
                move.l      4(A7),A4                ;A4 pointe sur le debut de la sauvegarde de la tilesmap
                clr.l       D7
                move.w      tlm_nbtilesW(A6),D7     ;D7 = tlm_nbtilesW (nombre de tiles en largeur)
                mulu        tlm_nbtilesH(A6),D7     ;D7 = tlm_nbtilesW x tlm_nbtilesH (nombre de tiles en hauteur)
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tiles en pixel <>16
                bne         .savetlm_8              ;aller à .savtlm_8

;           Sauvegarde tilesmap avec tiles x16

.savetlm_16     move.w      (A5)+,(A4)+             ;stocke mot tilesmap dans sauvegarde et increment les pointeurs
                subq.w      #1,D7                   ;decremente de 1 D7 (nombre de mot à sauvegarder)
                bne         .savetlm_16             ;alors aller à .savetlm_16
                bra         .savetlm_end            ;aller à .savetlm_end         

;           Sauvegarde tilesmap avec tiles x8

.savetlm_8      move.b      (A5)+,(A4)+             ;stocke octet tilesmap dans sauvegarde et increment les pointeurs
                subq.w      #1,D7                   ;decremente de 1 D7 (nombre de mot à sauvegarder)
                bne         .savetlm_8              ;alors aller à .savetlm_8

.savetlm_end    movem.l     minit_saveregs,D7/A6-A4
                rts
                
       

;        /-----------------------------------------------/
;        /    Restore de la tilesmap en mémoire suite    /
;        /                  à une sauvegarde             /
;        /   parametre sur la pile :                     /
;        /          pointeur d'adresse de la mémoire     /
;        /   retourne:                                   /
;        /          0 si restoration OK, sinon -1        /
;        /-----------------------------------------------/   
    
_STX_restoretilesmap:
                movem.l     D7/A6-A4,minit_saveregs
                move.w      #$FFFF,D0               ;D0 = -1
                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                move.l      tlm_tilesmap(A6),A5     ;A5 pointe sur le debut de la tilesmap
                tst.l       4(A7)                   ;si pointeur de sauvegarde = 0
                beq         .resttlm_end            ;aller à .resttlm_end et retourner -1
                clr.w       D0                      ;efface D0 (pas d'erreur)
                move.l      4(A7),A4                ;A4 pointe sur le debut de la sauvegarde de la tilesmap
                moveq       #0,D7
                move.w      tlm_nbtilesW(A6),D7     ;D7 = tlm_nbtilesW (nombre de tiles en largeur)
                mulu        tlm_nbtilesH(A6),D7     ;D7 = tlm_nbtilesW x tlm_nbtilesH (nombre de tiles en hauteur)
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tiles en pixel <>16
                bne         .resttlm_8              ;aller à .resttlm_8

;           Restore la tilesmap avec tiles x16

.resttlm_16     move.w      (A4)+,(A5)+             ;stocke mot sauvegarde dans tilesmap et increment les pointeurs
                subq.w      #1,D7                   ;decremente de 1 D7 (nombre de mot à sauvegarder)
                bne         .resttlm_16             ;alors aller à .resttlm_16
                bra         .resttlm_end            ;aller à .resttlm_end         

;           Restore la tilesmap avec tiles x8

.resttlm_8      move.b      (A4)+,(A5)+             ;stocke octet sauvegarde dans tilesmap et increment les pointeurs
                subq.w      #1,D7                   ;decremente de 1 D7 (nombre de mot à sauvegarder)
                bne         .resttlm_8              ;alors aller à .resttlm_8

.resttlm_end    movem.l     minit_saveregs,D7/A6-A4
                rts



;        /-----------------------------------------------/
;        /       Fourni la hauteur et la largeur de      /
;        /                  la map en tile               /
;        /-----------------------------------------------/

_STX_gettilesmapsize:
                movem.l     A5-A6,minit_saveregs
                lea         tlm_properties,A6
                move.l      4(A7),A5
                move.w      tlm_nbtilesW(A6),(A5)
                move.l      8(A7),A5
                move.w      tlm_nbtilesH(A6),(A5)
                movem.l     minit_saveregs,A5-A6
                rts



;        /-----------------------------------------------/
;        /    Destruction d'une tilesmap en mémoire      /
;        /-----------------------------------------------/
 
_STX_releasetilesmap:
uninittilesmap:
                movem.l     A6,-(A7)                ;sauvegarde de A6 sur la pile
                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                
                tst.l       tlm_tilesmap(A6)        ;si tlm_tilesmap = 0
                beq         .tlmrel_end             ;alors pas de tilesmap en mémoire
                
                M_mfree		tlm_tilesmap(A6)		;adresse de debut de memoire de la tilesmap
				move.l      #0,tlm_tilesmap(A6)     ;efface le pointeur d'adresse de la tilesmaps
                move.l      #0,tlm_tilesprop(A6)    ;efface le pointeur d'adresse des propriétés des tiles
                move.w      #0,tlm_1sttileX(A6)     ;initialise la position X de la tilesmap à l'écran
                move.w      #0,tlm_1sttileY(A6)     ;initialise la position Y de la tilesmap à l'écran
                move.w      #0,tlm_nbtilesW(A6)     ;initialisation de la largeur de la tilemap
                move.w      #0,tlm_nbtilesH(A6)     ;initialisation de la hauteur de la tilemap

                tst.l       tlm_tileset(A6)         ;si tlm_tileset = 0
                beq         .tlmrel_end             ;alors pas de tileset chargé

                M_mfree		tlm_tileset(A6)			;;adresse de debut de memoire du tileset
				move.l      #$0,tlm_tileset(A6)     ;efface le pointeur d'adresse de la sauvegarde de la tilesmaps

                tst.l       tlm_tilesscreen(A6)     ;si tlm_tilesscreen = 0
                beq         .tlmrel_end             ;alors pas de positions de tiles à l'écran calculées
                
                M_mfree		tlm_tilesscreen(A6)		;adresse de debut de memoire des position des tiles à l'écran
				move.l      #$0,tlm_tilesscreen(A6) ;efface le pointeur d'adresse des position des tiles à l'écran

                tst.l       tlm_linetileid(A6)      ;si tlm_linetileid = 0
                beq         .tlmrel_end             ;alors pas de valeur d'id de ligne des tiles
                
                M_mfree     tlm_linetileid(A6)      ;adresse de debut de mémoire des id de ligne des tiles
                move.l      #$0,tlm_linetileid(A6)  ;efface le pointeur d'adresse de debut de mémoire des id de ligne des tiles

.tlmrel_end     movem.l     (A7)+,A6                ;restitution de A6
                rts
 


;        /---------------------------------------------------/
;        /       fourni les coordonnée en tile d'un sprite   /
;        /               positionné sur la map               /
;        /   parametre sur la pile :                         /
;        /          Numéro du sprite                         /
;        /          offset de l'ancre en X pixel             /
;        /          offset de l'ancre en Y pixel             /
;        /          Adresse pour stockage valeur X tile      /
;        /          Adresse pour stockage valeur Y tile      /
;        /   retourne :                                      /
;        /          0 si pas d'erreur, sinon -1              /
;        /---------------------------------------------------/

_STX_gettilepositionfromsprite:
                movem.l     D5-D7/A6-A4,minit_saveregs
                move.w      #$FFFF,D0               ;met -1 dans D0
                moveq       #0,D6                   ;efface sur 4 octets D6
                moveq       #0,D5                   ;efface sur 4 octets D5
                move.w      4(A7),D7                ;recupération numero du sprite sur la pile

;           verifie si numéro sprite < nombre de sprite                
                
                move.w      initsp_nbsprit,D6       ;recuperation du nombre de sprite
                subi.w      #1,D6                   ;decrement de 1 car n° sprite commence à 0
                cmp.w       D6,D7                   ;si D7 > D6
                bgt         .tlm_getposspend        ;quitter et retourner -1
              
;           verifier si sprite créer et enable   

                lea         initsp_tabsprt,A6       ;A6 pointe sur l'adresse de sauvegarde de l'adresse de debut de structure des sprites
                move.l      (A6),A5                 ;A5 pointe sur le debut du bloc de structure des sprites
                lsl.w       #2,D7                   ;multipli le numero du sprite par 4
                move.l      (A5,D7.W),A4            ;A4 pointe sur la structure du sprite
                move.w      (A4),D5                 ;D1 = sp_created(poid ford) & sp_enable(poid faible)
                cmp.w       D0,D5                   ;si D5 <> $FFFF (si sp_created <> True & sp_enable <> True)
                bne         .tlm_getposspend        ;quitter et retourner -1
                
;           calcul du tile sur lequel est positionné le sprite
                
                move.w      6(A7),D6                ;récupération offset ancre en X sur la pile
                move.w      8(A7),D5                ;récupération offset ancre en y sur la pile
                add.w       sp_posx_aff(A4),D6      ;Ajoute à offset ancre en X la position en X du sprite            
                add.w       sp_posy_aff(A4),D5      ;Ajoute à offset ancre en Y la position en Y du sprite
                lea         tlm_properties,A6       ;pointe sur les propriétés de la tilesmap
                sub.w       tlm_1sttileX(A6),D6     ;retire la position en X du premier tile
                sub.w       tlm_1sttileY(A6),D5     ;retire la position en Y du premier tile
                
;           Divise la position X du sprite par la largeur d'un tile (8 ou 16)
                
                moveq       #0,D7                   ;efface sur 4 octets D7
                move.b      tlm_sztilesW(A6),D7     ;D7 contient la largeur d'un tile en pixel  
                cmpi.b      #8,D7                   ;si D7 <> 8
                bne         .tlm_getposdivv16       ;alors aller à diviser par 16
                lsr.w       #3,D6                   ;divise D6 par 8, D6 = X en tile
                bra         .tlm_getposdivh         ;continue le traitement
.tlm_getposdivv16:
                lsr.w       #4,D6                   ;divise D6 par 16, D6 = X en tile                
                
;           Divise la position Y du sprite par la hauteur d'un tile (8, 16 ou custome)

.tlm_getposdivh move.b      tlm_sztilesH(A6),D7     ;D7 contient la hauteur d'un tile en pixel
                cmpi.b      #8,D7                   ;si D7 <> 8
                bne         .tlm_getposdivh16       ;aller à division par 16
                lsr.w       #3,D5                   ;(rapide) Divise D5 par 8, D5 = Y en tile
                bra         .tlm_getposcoor         ;continuer le traitement
.tlm_getposdivh16:
                cmpi.b      #16,D7                  ;si D7 <> 16
                bne         .tlm_getposdivhcus      ;aller à division custome
                lsr.w       #4,D5                   ;(rapide) Divise D5 par 16, D5 = Y en tile
                bra         .tlm_getposcoor         ;continuer le traitement
.tlm_getposdivhcus:
                divu        D7,D5                   ;(lent 140 cycles) divise par la hauteur en pixel d'un tile, D5=position en Y tile                

.tlm_getposcoor add.w       tlm_tilestartX(A6),D6   ;ajoute la ccordonnée X du tile de début d'affichage
                add.w       tlm_tilestartY(A6),D5   ;ajoute la ccordonnée Y du tile de début d'affichage
                move.l      10(A7),A5               ;A5 pointe sur l'adresse qui recevra la valeur de X
                move.w      D6,(A5)                 ;stock X
                move.l      14(A7),A5               ;A5 pointe sur l'adresse qui recevra la valeur de Y
                move.w      D5,(A5)                 ;stock Y
                clr.w       D0                      ;pas d'erreur
.tlm_getposspend:
                movem.l     minit_saveregs,D5-D7/A6-A4
                rts



;        /---------------------------------------------------/
;        /      fourni les coordonnée en pixel d'un tile     /
;        /     positionné dans la partie visible de la map   /
;        /   parametre sur la pile :                         /
;        /          coordonnée X en tile                     /
;        /          coordonnée Y en tile                     /
;        /          Adresse pour stockage valeur X pixel     /
;        /          Adresse pour stockage valeur Y pixel     /
;        /   retourne :                                      /
;        /          -1 si tile en dehors de la zone          / 
;        /          visible, sinon 0                         /
;        /---------------------------------------------------/

_STX_getscreenpositionfromtile:
                movem.l     D5-D7/A6,minit_saveregs
                move.w      #$FFFF,D0               ;D0 = -1
                lea         tlm_properties,A6       ;A6 pointe sur les propriétés de la tilesmap
                
;           verification si dans l'écran en X 
                
                move.w      4(sp),D7                ;coordonnée X tile               
                cmp.w       tlm_tilestartX(A6),D7   ;si D7 < tlm_tilestartX (valeur de depart en X d'affichage à l'écran)
                blt         .getscrpos_end          ;en dehors de l'écran, erreur
                clr.w       D5                      ;efface D5
                move.b      tlm_tilesWidth(A6),D5   ;D5 = largeur en tile affiché à l'écran
                add.w       tlm_tilestartX(A6),D5   ;D5 = Largeur + position depart en X
                cmp.w       D5,D7                   ;si D7 > D5 (Largeur + position depart en X)
                bgt         .getscrpos_end          ;en dehors de l'écran, erreur
                
;           verification si dans l'écran en Y              

                move.w      6(sp),D6                ;coordonnée Y tile
                cmp.w       tlm_tilestartY(A6),D6   ;si D6 < tlm_tilestartY (valeur de depart en Y d'affichage à l'écran)
                blt         .getscrpos_end          ;en dehors de l'écran, erreur
                clr.w       D5
                move.b      tlm_tilesHeight(A6),D5  ;D5 = hauteur en tile affiché à l'écran
                add.w       tlm_tilestartY(A6),D5   ;D5 = hauteur + position depart en Y
                move.w      D5,D0
                cmp.w       D5,D6                   ;si D6 > D5 (Hauteur + position depart en Y)
                bgt         .getscrpos_end          ;en dehors de l'écran, erreur
                
;           calcul de la position à l'écran en pixel
                
                sub.w       tlm_tilestartX(A6),D7   ;soustraire la valeur de départ en X
                sub.w       tlm_tilestartY(A6),D6   ;soustraire la valeur de départ en Y
                clr.w       D5
                move.b      tlm_sztilesW(A6),D5
                mulu        D5,D7                   ;multipli D7 par la largeur en pixel d'un tile
                move.b      tlm_sztilesH(A6),D5
                mulu        D5,D6                   ;multipli D6 par la hauteur en pixel d'un tile
                add.w       tlm_1sttileX(A6),D7     ;ajoute à D7 la position X pixel du premier tile à l'écran
                add.w       tlm_1sttileY(A6),D6     ;ajoute à D6 la position Y pixel du premier tile à l'écran
                move.l      8(sp),A6                ;A6 pointe sur l'adresse de la variable qui va recevoir la valeur X pixel
                move.w      D7,(A6)                 ;Stocke la valeur de X pixel dans la variable pointée par A6
                move.l      12(sp),A6               ;A6 pointe sur l'adresse de la variable qui va recevoir la valeur Y pixel
                move.w      D6,(A6)                 ;Stocke la valeur de X pixel dans la variable pointée par A6
                clr.w       D0                      ;efface D0 car pas d'erreur
.getscrpos_end  movem.l     minit_saveregs,D5-D7/A6          
                rts



;        /---------------------------------------------------/
;        /     Retourne l'id du tile au coordonnée X et Y    /
;        /                                                   /
;        /   parametre sur la pile :                         /
;        /          Position X dans la map                   /
;        /          Position Y dans la map                   /
;        /   retourne :                                      /
;        /          0 si en dehors de la map, sinon l'id      /
;        /---------------------------------------------------/

_STX_gettileid:
                movem.l     D7-D6/A6,minit_saveregs
                clr.w       D0                      ;efface D0, valeur de retour si erreur
                move.w      4(A7),D7                ;D7 = TileX
                move.w      6(A7),D6                ;D6 = TileY
                lea         tlm_properties,A6       ;A6 pointe sur la table des propriétés de la map
                cmp.w       tlm_nbtilesW(A6),D7     ;si D7 > nombre de tiles en largeur de la map
                bge         .tlm_getid_end          ;alors fin
                cmp.w       tlm_nbtilesH(A6),D6     ;si D6 > nombre de tiles en hauteur de la map
                bge         .tlm_getid_end          ;alors fin   
                move.l      tlm_linetileid(A6),A6   ;A6 pointe sur la table des id des début de chacune des lignes de la map
                add.w       D6,D6                   ;multiplie D6 par 2 car table sur 2 octet
                add.w       (A6,D6.W),D7            ;D7 = id de la ligne TileY(D6) + TileX(D7) = id du tile
                move.w      D7,D0                   ;D0 = id du tile situé en TileX, TileY
.tlm_getid_end  movem.l     minit_saveregs,D7-D6/A6
                rts
                
                

;        /---------------------------------------------------/
;        /       Recupére la valeur d'un tile par rapport    /
;        /           au coordonnée du tile dans la map       /
;        /   parametre sur la pile :                         /
;        /          Position X dans la map                   /
;        /          Position Y dans la map                   /
;        /   retourne :                                      /
;        /          -1 si en dehors de la map, sinon 0       /
;        /---------------------------------------------------/

_STX_gettilevalue:
                movem.l     D7-D6/A6-A5,minit_saveregs
                clr.w       D0                      ;efface D0, valeur de retour si erreur
                move.w      4(A7),D7                ;D7 = TileX
                move.w      6(A7),D6                ;D6 = TileY
                lea         tlm_properties,A6       ;A6 pointe sur la table des propriétés de la map
                cmp.w       tlm_nbtilesW(A6),D7     ;si D7 > nombre de tiles en largeur de la map
                bge         .tlm_endgtval           ;alors fin
                cmp.w       tlm_nbtilesH(A6),D6     ;si D6 > nombre de tiles en hauteur de la map
                bge         .tlm_endgtval           ;alors fin   
                move.l      tlm_linetileid(A6),A5   ;A5 pointe sur la table des id des début de chacune des lignes de la map
                add.w       D6,D6                   ;multiplie D6 par 2 car table sur 2 octet
                add.w       (A5,D6.W),D7            ;D7 = id de la ligne TileY(D6) + TileX(D7) = id du tile
                
                move.l      tlm_tilesmap(A6),A5     ;A5 pointe sur le premier tile dans la tilesmap
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tile != 16
                bne         .tlm_map8gtval          ;alors aller à (.tlmld_map8)
                           
;           si tile de 16*X 
                
                add.w       D7,D7                   ;multipli par deux l'id du tile car valeur du tile codé du 2 octets
                move.w      (A5,D7.W),D0            ;met la valeur du tile dans D0
                movem.l     minit_saveregs,D7-D6/A6-A5 
                rts
 
;           si tile de 8*X
 
.tlm_map8gtval  move.b      (A5,D7.W),D0            ;met la valeur du tile dans D0
.tlm_endgtval   movem.l     minit_saveregs,D7-D6/A6-A5 
                rts
                


;        /---------------------------------------------------/
;        /        Modifie la valeur d'un tile par une        /
;        /                   nouvelle valeur                 /
;        /   parametre sur la pile :                         /
;        /          Coordonnée X en tile du tile de départ   /
;        /          Coordonnée Y en tile du tile de départ   /
;        /          Nouvelle valeur du tile                  /
;        /   retourne :                                      /
;        /          -1 si en dehors de la map, sinon 0       /
;        /---------------------------------------------------/

_STX_changetilevalue:
                movem.l     D7-D6/A6-A5,minit_saveregs
                move.w      #$FFFF,D0               ;D0 contient -1 en cas d'erreur
                move.w      4(A7),D7                ;recupération coordonnée X du tile dans la map            
                move.w      6(A7),D6                ;recupération coordonnée Y du tile dans la map
                lea         tlm_properties,A6       ;pointe sur les propriétés de la tilesmap
                cmp.w       tlm_nbtilesW(A6),D7     ;si D7 >= à la largeur de la map
                bge         .tlm_endchgval          ;retourner -1
                cmp.w       tlm_nbtilesH(A6),D6     ;si D6 >= hauteur de la map
                bge         .tlm_endchgval          ;retourner -1
                move.l      tlm_linetileid(A6),A5   ;A5 pointe sur la table des id des début de chacune des lignes de la map
                add.w       D6,D6                   ;multiplie D6 par 2 car table sur 2 octet
                add.w       (A5,D6.W),D7            ;D7 = id de la ligne TileY(D6) + TileX(D7) = id du tile
                
                move.l      tlm_tilesmap(A6),A5     ;A5 pointe sur le premier tile dans la tilesmap
                clr.w       D0                      ;pas d'erreur, efface D0
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tile != 16
                bne         .tlm_map8chgval         ;alors aller à (.tlm_map8chgval)
                 
 ;          si tile de 16*X 
        
                add.w       D7,D7                   ;multipli par deux le nombre de tile contenu dans D5 car codé sur 2 octets               
                move.w      8(A7),(A5,D7.W)         ;stocke la nouvelle valeur du tile
                movem.l     minit_saveregs,D7-D6/A6-A5
                rts

;           si tile de 8*X

.tlm_map8chgval clr.w       D6
                move.w      8(A7),D6
                move.b      D6,(A5,D7.W)            ;stocke la nouvelle valeur du tile    
                
.tlm_endchgval  movem.l     minit_saveregs,D7-D6/A6-A5
                rts



;        /---------------------------------------------------/
;        /    Redessine un tile suite changement de valeur   /
;        /   parametre sur la pile :                         /
;        /          Coordonnée X en tile du tile             /
;        /          Coordonnée Y en tile du tile             /
;        /   retourne :                                      /
;        /          -1 si en dehors de la map, sinon 0       /
;        /---------------------------------------------------/

_STX_redrawtile:
                movem.l     D2-D7/A1/A3/A5-A6,minit_saveregs
                move.w      #$FFFF,D0
                move.w      4(A7),D7                ;recupération coordonnée X du tile dans la map            
                move.w      6(A7),D6                ;recupération coordonnée Y du tile dans la map
                lea         tlm_properties,A6       ;pointe sur les propriétés de la tilesmap

;           verifie si tile affiché à l'écran en X

                cmp.w       tlm_tilestartX(A6),D7   ;si D7 < tlm_tilestartX (valeur de depart en X d'affichage à l'écran)
                blt         .tlm_endredrawt         ;en dehors de l'écran, erreur
                clr.l       D5                      ;efface D5
                move.b      tlm_tilesWidth(A6),D5   ;D5 = largeur en tile affiché à l'écran
                add.w       tlm_tilestartX(A6),D5   ;D5 = Largeur + position depart en X
                cmp.w       D5,D7                   ;si D7 > D5 (Largeur + position depart en X)
                bgt         .tlm_endredrawt         ;en dehors de l'écran, erreur

;           verification si tile affiché dans l'écran en Y              

                cmp.w       tlm_tilestartY(A6),D6   ;si D6 < tlm_tilestartY (valeur de depart en Y d'affichage à l'écran)
                blt         .tlm_endredrawt         ;en dehors de l'écran, erreur
                move.b      tlm_tilesHeight(A6),D5  ;D5 = hauteur en tile affiché à l'écran
                add.w       tlm_tilestartY(A6),D5   ;D5 = hauteur + position depart en Y
                cmp.w       D5,D6                   ;si D6 > D5 (Hauteur + position depart en Y)
                bgt         .tlm_endredrawt         ;en dehors de l'écran, erreur
                
;       récupération de la position écran du tile à rafraichir

                sub.w       tlm_tilestartX(A6),D7   ;soustraire la valeur de départ en X
                sub.w       tlm_tilestartY(A6),D6   ;soustraire la valeur de départ en Y
                move.b      tlm_tilesWidth(A6),D5   ;nombre de tiles en largeur affiché
                mulu        D5,D6                   ;multiplie Y par le nombre de tiles en largeur affichés
                add.w       D6,D7                   ;ajoute X à Y, D7 = id du tile dans la zone affichée
                add.w       D7,D7                   ;multiplie D7 par 2 car adressage de word
                move.l      tlm_tilesscreen(A6),A5  ;A5 pointe sur le debut de la table des position de tiles en adresse écrans
                move.l      minit_workscr,D4        ;D4 = adresse écran de travail
                move.w      (A5,D7.W),D5            ;D5 = offset adresse écran pour affichage
                add.l       D5,D4                   ;D4 = adresse écran du tile

;       recupération de la valeur du tile à redessiner
                                             
                move.l      tlm_linetileid(A6),A5   ;A5 pointe sur la table des id des début de chacune des lignes de la map
                move.w      6(A7),D6                ;D6 = coordonnée Y tile du tile à redessiner
                move.w      4(A7),D5                ;D5 = coordonnée Y tile du tile à redessiner
                add.w       D6,D6                   ;multipli D6 par 2
                add.w       (A5,D6.W),D5            ;D5 = Id du tile à redessiner
                move.l      tlm_tilesmap(A6),A5     ;A5 pointe sur le debut de la tilesmap
                cmpi.b      #16,tlm_sztilesW(A6)    ;si taille en largeur d'un tile <> 16
                bne         .tlm_rdwval8            ;alors aller à .tlm_rdwval8
                
;       processe pour un tile de largeur 16
                              
                add.w       D5,D5                   ;multiplié par 2 D5 (car valeur sur 2 octets)
                move.w      (A5,D5.W),D6            ;D6 contient la valeur du tile à redessiner
                bne         .tlm_rdwnonul16         ;si D6 = 0 (valeur du tile = 0) alors aller à .tlm_rdwnonul16
                move.l      tlm_tileset(A6),D5      ;D5 contient l'adresse du tile à valeur 0 dans le tileset
                bra         .tlm_rdwnblin16
.tlm_rdwnonul16 move.l      tlm_tilesprop(A6),A5    ;A5 pointe sur le debut de la premiere propriété
                subq.w      #1,D6                   ;soustrait 1 car adresse tile 1 dans la premiere structure
                lsl.w       #3,D6                   ;multipli par 8 (taille de la propriété d'un tile)
                move.l      tlm_tileaddr(A5,D6.W),D5;D5 contient l'adresse du tileset à dessiner
.tlm_rdwnblin16 clr.w       D3
                move.b      tlm_sztilesH(A6),D3     ;D3 contient le nombre de ligne du tile
                jsr         drawmap16               ;appel de la fonction drawmap16
                bra         .tlm_rdwusemd

;       processe pour un tile de largeur 8

.tlm_rdwval8    clr.w       D6                      ;efface D6 sur deux octets
                move.b      (A5,D5.W),D6            ;D6 contient la valeur du tile à redessiner
                bne         .tlm_rdwnonul8          ;si D6 = 0 (valeur du tile = 0), alors aller à .tlm_rdwnonul8
                move.l      tlm_tileset(A6),D5      ;D5 contient l'adresse du tile à valeur 0 dans le tileset
                bra         .tlm_rdwnbline8              
.tlm_rdwnonul8  move.l      tlm_tilesprop(A6),A5    ;A5 pointe sur le debut de la premiere propriété
                subq.w      #1,D6                   ;soustrait 1 car adresse tile 1 dans la premiere structure
                lsl.w       #3,D6                   ;multipli par 8 (taille de la propriété d'un tile)
                move.l      tlm_tileaddr(A5,D6.W),D5;D5 contient l'adresse du tileset à dessiner               
.tlm_rdwnbline8 clr.w       D3
                move.b      tlm_sztilesH(A6),D3     ;D3 contient le nombre de ligne du tile  
                move.w      4(A7),D2                ;D2 = X tile
                andi.w      #$0001,D2               ;verifie si D2 impaire
                lsl.w       #3,D2                   ;si D2 impaire, alors D2 = 8 (valeur rotation pour une map de x8)
                jsr         drawmap8                ;appel de la fonction drawmap8                

.tlm_rdwusemd   clr.w       D0                      ;efface D0, pas d'erreur
.tlm_endredrawt movem.l     minit_saveregs,D2-D7/A1/A3/A5-A6              
                rts

 
 
;        /---------------------------------------------------/
;        /       Recupére la valeur d'un tile par rapport    /
;        /                      à son id                     /
;        /   parametre sur la pile :                         /
;        /          id du tile concerné                      /
;        /   retourne :                                      /
;        /          valeur du tile, 0 si erreur              /
;        /---------------------------------------------------/
 
_STX_gettilevaluefromtileid:
                movem.l     D7/A6,minit_saveregs
                move.w      4(sp),D7                ;recupére la valeur de l'id
                clr.w       D0                      ;efface D0
                lea         tlm_properties,A6       ;pointe sur les propriétés de la tilesmap
                cmp.w       tlm_mapsize(A6),D7      ;si D7 > à la taille de la map
                bgt         .tlm_endgetvalid        ;erreur, retourner 0
                                
                cmpi.b      #16,tlm_sztilesW(A6)    ;si largeur tile != 16
                bne         .tlm_getvalid8          ;alors aller à (.tlm_getvalid8)

;           si tile de largeur 16
                               
                move.l      tlm_tilesmap(A6),A6     ;A6 pointe sur le premier tile dans la tilesmap
                add.w       D7,D7                   ;multipli par deux le nombre de tile contenu dans D7 car codé sur 2 octets
                move.w      (A6,D7.W),D0            ;met la valeur du tile dans D0
                movem.l     minit_saveregs,D7/A6
                rts
                
;           si tile de largeur 8
                
.tlm_getvalid8  move.l      tlm_tilesmap(A6),A6     ;A6 pointe sur le premier tile dans la tilesmap
                move.w      (A6,D7.W),D0            ;met la valeur du tile dans D0
.tlm_endgetvalid:
                movem.l     minit_saveregs,D7/A6
                rts
                   



;        /---------------------------------------------------/
;        /      Défini la zone affichable de la tilesmap     /
;        /         et sa position d'origine à l'écran        /
;        /   parametre sur la pile :                         /
;        /          Coordonnée X en pixel multiple de 16     /
;        /          Coordonnée Y en pixel                    /
;        /          largeur en tiles                         /
;        /          hauteur en tiles                         /
;        /---------------------------------------------------/

_STX_settilesmaparea:
                movem.l     D3-D7/A5-A6,minit_saveregs
                lea         tlm_properties,A6       ;pointe sur les propriétés de la tilesmap
                move.w      4(A7),tlm_1sttileX(A6)  ;coordonnée en X en pixel
                move.w      4(A7),tlm_drawtileX
                move.w      6(A7),tlm_1sttileY(A6)  ;coordonnée en Y en pixel
                move.w      6(A7),tlm_drawtileY
                move.w      8(sp),D7                ;largeur en tiles qui sera affichée
                move.b      D7,tlm_tilesWidth(A6)   ;sauvegarde la largeur en tile
                move.b      D7,tlm_tileWcount       ;compteur de tile en largeur
                move.w      10(sp),D7               ;hauteur en tiles qui sera affichée
                move.b      D7,tlm_tilesHeight(A6)  ;sauvegarde hauteur
                move.b      D7,tlm_tileHcount       ;compteur de tile en hauteur
                
;     reservation mémoire pour les valeurs de position des tiles à l'écran
                
                moveq       #0,D7                   ;effacement de D7
                moveq       #0,D6                   ;effacement de D6
                move.b      tlm_tilesWidth(A6),D7   ;D7 = tlm_tilesWidth
                move.b      tlm_tilesHeight(A6),D6  ;D6 = tlm_tilesHeight
                mulu        D6,D7                   ;D7 = tlm_tilesWidth x tlm_tilesHeight
                lsl.w       #2,D7                   ;multiplie D7 par 2 (reservation word)
                M_malloc	D7						;reserve D7 de mémoire
				tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .tlm_area_end           ;fin
                move.l      D0,tlm_tilesscreen(A6)  ;sauvegarde l'adresse de la zone mémoire
                
;           calcule de la position à l'écran des tiles de la zone d'affichage

                move.l      tlm_tilesscreen(A6),A5  ;A5 pointe sur le début de l'&dresse de sauvegarde des positions des tiles à l'écran
                clr.w       D4
                move.b      tlm_sztilesW(A6),D4     ;D4 = largeur en pixel d'un tile
                clr.w       D3
                move.b      tlm_sztilesH(A6),D3     ;D3= hauteur en pixel d'un tile
                
.tlm_area_line  move.w      tlm_drawtileX,D7        ;position de départ écran en X pixel du premier tiles
                and.w       #$FFF0,D7               ;D6 = X and $FFF0 (X modulo 16)
                lsr.w       #1,D7                   ;divise X par 2
                move.w      tlm_drawtileY,D6        ;position de départ écran en Y pixel du premier tiles
                lsl.w       #5,D6                   ;multiplie par 32
                move.w      D6,D5                   ;sauvegarde le resultat dans D0
                add.w       D5,D6                   ;Ajoute D0 
                add.w       D5,D6                   ;Ajoute D0
                add.w       D5,D6                   ;Ajoute D0
                add.w       D5,D6                   ;Ajoute D0
                add.w       D6,D7                   ;D7 = D6 + D7
                
                move.w      D7,(A5)+                ;sauvegarde D7 et incremente de 2 le pointeur d'adresse
                
                subq.b      #1,tlm_tileWcount       ;decremente le compteur de tile en largeur à afficher
                beq         .tlm_area_next          ;si compteur à 0, alors passer à la ligne suivante
                add.w       D4,tlm_drawtileX        ;avance de la taille en  pixels en horizontal d'un tile
                bra         .tlm_area_line          ;continue la ligne en cours

.tlm_area_next  subq.b      #1,tlm_tileHcount       ;decremente le compteur de tile en hauteur
                beq         .tlm_area_id            ;si compteur à 0, alors fin 
                move.b      tlm_tilesWidth(A6),tlm_tileWcount;reinitialise compteur de tile en largeur
                move.w      tlm_1sttileX(A6),tlm_drawtileX   ;reinitialise la valeur de départ en X pixel
                add.w       D3,tlm_drawtileY        ;incremente la positon Y en pixel du nombre de ligne par tile
                bra         .tlm_area_line          ;continue la ligne en cours

;       reservation mémoire pour les numéro d'id de debut de chaque ligne

.tlm_area_id    moveq       #0,D7                   ;efface D7 sur 4 octets
                move.w      tlm_nbtilesH(A6),D7     ;D7=nombre de tiles en hauteur
                add.l       D7,D7                   ;multiplie D7 par 2 (id de ligne codés sur 2 octets)
                M_malloc    D7                      ;reserve D7 octets de mémoire
                tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .tlm_area_end           ;fin
                move.l      D0,tlm_linetileid(A6)   ;sauvegarde l'adresse de la zone mémoire allouée

;                   création d'un tableau d'id de ligne

                move.w      tlm_nbtilesH(A6),D7     ;D7=nombre de tiles en hauteur
                move.w      tlm_nbtilesW(A6),D6     ;D7=nombre de tiles en largeur
                clr.w       D5                      ;valeur id de ligne
                clr.w       D4                      ;offset de valeur dans le tableau
                move.l      tlm_linetileid(A6),A5   ;pointe sur l'adresse du debut du tableau
.tlm_area_nxli  move.w      D5,(A5,D4.W)
                add.w       D6,D5                   ;D5 = D5 + nombre de tiles en largeur
                addq.w      #2,D4                   ;D4 avance de 2 octets
                subq.w      #1,D7                   ;decremente D7 (nombre de ligne de tiles)
                bne         .tlm_area_nxli          ;si D7 <> 0, alors passer à la ligne suivante
 
.tlm_area_end   movem.l     minit_saveregs,D3-D7/A5-A6
                rts
    




;        /---------------------------------------------------/
;        /     Dessine la tilemap depuis un tile de départ   /
;        /   parametre sur la pile :                         /
;        /          Coordonnée X en tile du tile de départ   /
;        /          Coordonnée Y en tile du tile de départ   /
;        /          largeur de la map à déssiner             /
;        /          hauteur de la map à dessiner             /
;        /---------------------------------------------------/

_STX_drawtilesmap:
                movem.l     D2-D7/A1-A6,minit_saveregs                      
                lea         tlm_properties,A6       ;A6 pointe sur l'adresse de début des propriété de la tilesmap
                move.l      tlm_tilesprop(A6),A5    ;A5 pointe sur l'adresse premiere propriété des tiles
                move.l      tlm_tilesmap(A6),A4     ;A4 pointe sur l'adresse de debut de la tilesmap
                move.l      tlm_tilesscreen(A6),A2  ;A3 pointe sur le debut de la table des position de tiles en adresse écrans
                
;       sauvegarde et initialisation des paramétres
                
                move.w      4(sp),tlm_tilestartX(A6);stocke la valeur X du tile de départ dans les propriétés de la tilemap
                move.w      6(sp),tlm_tilestartY(A6);stocke la valeur Y du tile de départ dans les propriétés de la tilemap
                move.b      tlm_tilesWidth(A6),tlm_tileWcount   ;initialise le compteur de tiles en largeur
                move.b      tlm_tilesHeight(A6),tlm_tileHcount  ;initialise le compteur de tiles en hauteur
                
;       vérification si l'affichage et dans la tilesmap en largeur

                clr.w       D6                      ;efface D6
                move.w      tlm_tilestartX(A6),D7   ;D7 = position X de depart dans la tilesmap
                move.b      tlm_tilesWidth(A6),D6   ;D6 = nombre de tiles en largeur à afficher  
                add.w       D6,D7                   ;D7 = position X dans la tilesmap + nombre de tiles en largeur à afficher
                cmp.w       tlm_nbtilesW(A6),D7     ;D7 > au nombre total de tiles en largeur de la tilesmap
                bgt         .tlm_draw_end           ;alors quitter, car affichage en dehors de la tilesmap
                
;       vérification si l'affichage et dans la tilesmap en hauteur

                clr.w       D6                      ;efface D6
                move.w      tlm_tilestartY(A6),D7   ;D7 = position Y de depart dans la tilesmap
                move.b      tlm_tilesHeight(A6),D6  ;D6 = nombre de tiles en hauteur à afficher  
                add.w       D6,D7                   ;D7 = position Y dans la tilesmap + nombre de tiles en hauteur à afficher
                cmp.w       tlm_nbtilesH(A6),D7     ;D7 > au nombre total de tiles en hauteur de la tilesmap
                bgt         .tlm_draw_end           ;alors quitter, car affichage en dehors de la tilesmap                
                                   
;       calcul du tile de départ pour la premeiere ligne

                move.w      tlm_tilestartY(A6),D7   ;tile de départ en Y
                mulu        tlm_nbtilesW(A6),D7     ;tile de départ Y x largeur en tile de la map                   
                add.w       tlm_tilestartX(A6),D7   ;ajoute le tile X de départ = id du tile de depart
                cmpi.b      #16,tlm_sztilesW(A6)    ;si taille en largeur d'un tile <> 16
                bne         .tlm_drawmap8           ;alors aller à .tlm_drawmap8
                add.w       D7,D7                   ;sinon D7 = D7*2 car valeur sur 2 octets

;       affichage d'une tilesmap avec largeur de tile de 16 pixels
                
.tlm_drawmap16  moveq       #0,D4                   ;efface D4 sur 4 octets
                move.w      (A2)+,D4                ;D4 = offset adresse écran pour affichage
                add.l       minit_workscr,D4        ;D4 = adresse écran du tile
                
                move.w      (A4,D7.W),D6            ;valeur du tile de départ dans D6
                beq         .tlm_drawnxtile16       ;si D6 = 0 (valeur du tile = 0) alors aller à .tlm_drawnxtile16 (passer au tile suivant)
                subq.w      #1,D6                   ;soustrait 1 car adresse tile 1 dans la premiere structure
                lsl.w       #3,D6                   ;multipli par 8 (taille de la propriété d'un tile)
                move.l      tlm_tileaddr(A5,D6.W),D5;D5 = adresse du tile à déssiner
                clr.w       D3
                move.b      tlm_sztilesH(A6),D3     ;nombre de ligne du tile
                jsr         drawmap16               ;appel de la fonction drawmap16
.tlm_drawnxtile16:                                  ;passe au tile suivant sur la même ligne
                subq.b      #1,tlm_tileWcount       ;decremente le compteur de tile en largeur à afficher
                beq         .tlm_drawnxtline16      ;si compteur à 0 alors passer à la ligne suivante
                addq.w      #2,D7                   ;incrementer D7 de 2 (car valeur codée sur 2 octet)
                bra         .tlm_drawmap16
.tlm_drawnxtline16:                                 ;passe à la ligne suivante
                subq.b      #1,tlm_tileHcount       ;decremente le compteur de ligne à dessiner
                beq         .tlm_draw_end           ;si compteur à 0 alors, fin, la tilemap est dessinée
                move.b      tlm_tilesWidth(A6),tlm_tileWcount;reinitialise compteur de tile en largeur        
                addq.w      #2,D7                   ;incrementer D7 de 2 (car valeur codée sur 2 octet)
                move.b      tlm_tilesWidth(A6),D3   ;D3 = largeur de tile à afficher
                add.w       D3,D3                   ;multipli D3 par 2 (car valeur codée sur 2 octets)
                sub.w       D3,D7                   ;soustraire à D7 (D7=D7-D3) pour revenir à l'id de debut de la ligne;
                add.w       tlm_nbtilesW(A6),D7     ;ajouter à D7 le nombre de tile dans une ligne de la tilesmap
                add.w       tlm_nbtilesW(A6),D7     ;ajouter à nouveau à D7 le nombre de tile dans une ligne de la tilesmap (pour passer à l'id de la ligne suivante)
                bra         .tlm_drawmap16
               
;       affichage d'une tilesmap avec largeur de tile de 8 pixels                
                              
.tlm_drawmap8   moveq       #0,D4                   ;efface D4 sur 4 octets
                move.w      (A2)+,D4                ;D4 = offset adresse écran pour affichage
                add.l       minit_workscr,D4        ;D4 = adresse écran du tile
                clr.w       D6                      ;efface D6 sur 2 octets
                move.b      (A4,D7.W),D6            ;valeur du tile de départ dans D6 
                beq         .tlm_drawnxtile8        ;si D6 = 0 (valeur du tile = 0) alors passer au tile suivant
                subq.b      #1,D6                   ;soustrait 1 car adresse tile 1 dans la premiere structure
                lsl.w       #3,D6                   ;multipli par 8 (taille de la propriété d'un tile)
                move.l      tlm_tileaddr(A5,D6.W),D5;D5 = adresse du tile à déssiner
                clr.w       D3
                move.b      tlm_sztilesH(A6),D3     ;nombre de ligne du tile
                move.w      D7,D2                   ;D7 = D2
                andi.w      #$0001,D2               ;verifie si D2 impaire
                lsl.w       #3,D2                   ;si D2 impaire, alors D2 = 8 (valeur rotation pour une map de x8)
                jsr         drawmap8                ;appel de la fonction drawmap8
.tlm_drawnxtile8:                                   ;passe au tile suivant sur la même ligne
                subq.b      #1,tlm_tileWcount       ;decremente le compteur de tile en largeur à afficher
                beq         .tlm_drawnxtline8       ;si compteur à 0, alors passer à la ligne suivante
                addq.w      #1,D7                   ;incrementer D7 de 1 (car valeur codée sur 1 octet) 
                bra         .tlm_drawmap8
.tlm_drawnxtline8:                                  ;passe à la ligne suivante
                subq.b      #1,tlm_tileHcount       ;decremente le compteur de ligne à dessiner
                beq         .tlm_draw_end           ;si compteur à 0 alors fin, la tilemap est dessinée 
                move.b      tlm_tilesWidth(A6),tlm_tileWcount;reinitialise compteur de tile en largeur        
                addq.w      #1,D7                   ;incrementer D7 de 1 (car valeur codée sur 1 octet)
                move.b      tlm_tilesWidth(A6),D3   ;D3 = largeur de tile à afficher
                sub.w       D3,D7                   ;soustraire à D7 (D7=D7-D3) pour revenir à l'id de debut de la ligne
                add.w       tlm_nbtilesW(A6),D7     ;ajouter à D7 le nombre de tile dans une ligne de la tilesmap (pour passer à l'id de la ligne suivante)
                bra         .tlm_drawmap8

.tlm_draw_end:  movem.l     minit_saveregs,D2-D7/A1-A6
                rts
                
 
 
;        /---------------------------------------------------/
;        /   Retourne la valeur de la propriété 1 d'un tile  /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /   retourne:                                       /
;        /          propriété 1 du tile                      /
;        /---------------------------------------------------/
 
_STX_gettileprop1:
                movem.l     D7/A6,minit_saveregs
                clr.b       D0                      ;efface D0
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7                  
                beq         .get_prop1end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés de la tilemap
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A6 pointe sur les propriétés du premier tiles
                move.b      tlm_tileprop1(A6,D7),D0 ;D0 contient la valeur de la propriété 1
.get_prop1end   movem.l     minit_saveregs,D7/A6
                rts
                
        
        
;        /---------------------------------------------------/
;        /     fixe la valeur de la propriété 1 d'un tile    /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /          Valeur de la propriété                   /
;        /---------------------------------------------------/
        
_STX_settileprop1:
                movem.l     D6-D7/A6,minit_saveregs
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7                  
                beq         .set_prop1end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                move.w      6(sp),D6                ;stocke la valeur de la propriété
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés de la tilemap
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A6 pointe sur les propriétés du premier tiles
                move.b      D6,tlm_tileprop1(A6,D7) ;fixe la valeur de la propriété
.set_prop1end   movem.l     minit_saveregs,D6-D7/A6
                rts
                
                
                
;        /---------------------------------------------------/
;        /   Retourne la valeur de la propriété 2 d'un tile  /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /   retourne:                                       /
;        /          propriété 2 du tile                      /
;        /---------------------------------------------------/
 
_STX_gettileprop2:
                movem.l     D7/A6,minit_saveregs
                clr.b       D0                      ;efface D0
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7      
                beq         .get_prop2end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés du tile
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A5 pointe sur les propriétés du premier tiles
                move.b      tlm_tileprop2(A6,D7),D0 ;D0 contient la valeur de la propriété 2
.get_prop2end   movem.l     minit_saveregs,D7/A6
                rts



;        /---------------------------------------------------/
;        /     fixe la valeur de la propriété 2 d'un tile    /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /          Valeur de la propriété                   /
;        /---------------------------------------------------/

_STX_settileprop2:
                movem.l     D6-D7/A6,minit_saveregs
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7                  
                beq         .set_prop2end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                move.w      6(sp),D6                ;stocke la valeur de la propriété
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés de la tilemap
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A5 pointe sur les propriétés du premier tiles
                move.b      D6,tlm_tileprop2(A6,D7) ;fixe la valeur de la propriété
.set_prop2end   movem.l     minit_saveregs,D6-D7/A6
                rts


;        /---------------------------------------------------/
;        /   Retourne la valeur de la propriété 3 d'un tile  /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /   retourne:                                       /
;        /          propriété 3 du tile                      /
;        /---------------------------------------------------/
 
_STX_gettileprop3:
                movem.l     D7/A6,minit_saveregs
                clr.b       D0                      ;efface D0
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7      
                beq         .get_prop3end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés du tile
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A5 pointe sur les propriétés du premier tiles
                move.b      tlm_tileprop3(A6,D7),D0 ;D0 contient la valeur de la propriété 3
.get_prop3end   movem.l     minit_saveregs,D7/A6
                rts



;        /---------------------------------------------------/
;        /     fixe la valeur de la propriété 2 d'un tile    /
;        /   parametre sur la pile :                         /
;        /          Valeur du tile                           /
;        /          Valeur de la propriété                   /
;        /---------------------------------------------------/

_STX_settileprop3:
                movem.l     D6-D7/A6,minit_saveregs
                move.w      4(sp),D7                ;stocke la valeur du tile dans D7                  
                beq         .set_prop3end           ;si D7 = 0 (tile avec valeur 0) alors retourner 0 
                move.w      6(sp),D6                ;stocke la valeur de la propriété
                lea         tlm_properties,A6       ;A6 pointe sur le début des propriétés de la tilemap
                subq.w      #1,D7                   ;décremente D7 de 1
                lsl.w       #3,D7                   ;multiplie D7 par 8 (propriété d'un tile est de 8 octets)
                move.l      tlm_tilesprop(A6),A6    ;A5 pointe sur les propriétés du premier tiles
                move.b      D6,tlm_tileprop3(A6,D7) ;fixe la valeur de la propriété
.set_prop3end   movem.l     minit_saveregs,D6-D7/A6
                rts



                
                SECTION BSS
                
tlm_properties  DS.W        22                      ;contient les propriétés de la tilesmap
tlm_fhandle     DS.W        1                       ;Handle du fichier 
tlm_error       DS.W        1                       ;Numero erreur 
tlm_dtatiles:   DS.B        44                      ;buffer pour la DTA

tlm_drawtileX   DS.W        1                       ;sauvegarde position X en pixel du premier tile à l'ecran 
tlm_drawtileY   DS.W        1                       ;sauvegarde position Y en pixel du premier tile à l'ecran 
tlm_tileWcount  DS.B        1                       ;compteur de tile dessinés en largeur
tlm_tileHcount  DS.B        1                       ;compteur de tile dessiné en hauteur
tlm_drawtileSTX DS.W        1                       ;sauvegarde tile de depart poxiton X (tile)
tlm_drawtileSTY DS.W        1                       ;sauvegarde tile de depart poxiton Y (tile)