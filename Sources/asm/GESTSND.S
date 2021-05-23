;                          SOUS PROGRAMME GESTSND
;              Gestion des effet audio du Yamaha 2149 et DMA Sound



snd_play1addr       EQU         0                   ;(L)pointeur d'adresse des données à lire pour le player 1
snd_play1addrstd    EQU         4                   ;(L)compteur de lecture pour le player 1
snd_play1loop       EQU         8                   ;(B)flag de lecture en boucle pour le player 1 
snd_play2loop       EQU         9                   ;(B)flag de lecture en boucle pour le player 2
snd_play2addrstd    EQU         10                  ;(L)compteur de lecture pour le player 2
snd_play2addr       EQU         14                  ;(L)pointeur d'adresse des données à lire pour le player 2
snd_play3addr       EQU         18                  ;(L)pointeur d'adresse des données à lire pour le player 3
snd_play3addrstd    EQU         22                  ;(L)compteur de lecture pour le player 3
snd_play3loop       EQU         26                  ;(B)flag de lecture en boucle pour le player 3

snd_dma_datalenght  EQU         0                   ;(L) longueur des données 
snd_dma_MonoStereo  EQU         4                   ;(B) Mono($80) ou stereo($00)
snd_dma_frequence   EQU         5                   ;(B) Frequence d'echantilonage

                SECTION TEXT


;        /-----------------------------------------------/
;        /       Initialisation des données audio        /
;        /-----------------------------------------------/

snd_initsoundeffect:
                move.l      #0,snd_save6890lmonitor ;met à 0 la mémoire de mémorisation du vecteur 68901monitor
                lea         snd_effectdata,A0       ;pointe sur le buffer de données des 3 players d'effet
                move.l      #0,snd_play1addr(A0)    ;effacement vecteur player 1
                move.l      #0,snd_play2addr(A0)    ;effacement vecteur player 2
                move.l      #0,snd_play3addr(A0)    ;effacement vecteur player 3
                move.b      #false,snd_play1loop(A0) ;pas de lecture en loop player 1
                move.b      #false,snd_play2loop(A0) ;pas de lecture en loop player 2
                move.b      #false,snd_play3loop(A0) ;pas de lecture en loop player 3
                
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg8,ym_RegSelect(A0)  ;registre de volume canal A
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal A
                move.b      #ymv_Reg9,ym_RegSelect(A0)  ;registre de volume canal B
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal B
                move.b      #ymv_Reg10,ym_RegSelect(A0) ;registre de volume canal C
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal C             
                move.b      #ymv_Reg7,ym_RegSelect(A0)  ;registre multifonction
                move.b      #$F8,ym_RegData(A0)     ;désactive le mixage du generateur de bruit
                rts
                


;        /-----------------------------------------------/
;        /       Déinitialisation des données audio        /
;        /-----------------------------------------------/

snd_uninitsoundeffect:
                movem.l     A0,minit_saveregs
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg8,ym_RegSelect(A0)  ;registre de volume canal A
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal A
                move.b      #ymv_Reg9,ym_RegSelect(A0)  ;registre de volume canal B
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal B
                move.b      #ymv_Reg10,ym_RegSelect(A0) ;registre de volume canal C
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal C
                move.w      #dam_StopSound,da_BaseAddr+da_SoundDmaCtrl      ;stop to play sample
                cmp.l       #0,snd_save6890lmonitor     ;si egal à 0
                beq         .snduninointersample        ;pas de routine d'interruption
                lea         mf_BaseAddr,A6              ;A6 pointe sur le MFP
                andi.w      #$FF7F,mf_IERA_Reg(A6)      ;met à 0 le bit 7 car interruption impossible
                andi.w      #$FF7F,mf_IMRA_Reg(A6)      ;met à 0 le bit 7 car interruption impossible
                andi.w      #$FF7F,mf_AER_Reg(A6)       ;met à 0 le bit 7 car ecran couleur
                andi.w      #$FF7F,mf_DDR_Reg(A6)       ;met à 0 le bit 7 car bit en entrée
                move.l      snd_save6890lmonitor,vec_68901monitor
                move.l      #0,snd_save6890lmonitor     ;met à 0 la mémoire de mémorisation du vecteur 68901monitor     
.snduninointersample:
                movem.l     minit_saveregs,A0
                rts
                
                

;        /-----------------------------------------------/
;        /   Coupe les sons du generateur audio ym2140   /
;        /-----------------------------------------------/
                
_STX_mutesound:
                movem.l     A0,minit_saveregs
                lea         snd_effectdata,A0       ;pointe sur le buffer de données des 3 players d'effet
                move.l      #0,snd_play1addr(A0)    ;effacement vecteur player 1
                move.l      #0,snd_play2addr(A0)    ;effacement vecteur player 2
                move.l      #0,snd_play3addr(A0)    ;effacement vecteur player 3
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg8,ym_RegSelect(A0)  ;registre de volume canal A
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal A
                move.b      #ymv_Reg9,ym_RegSelect(A0)  ;registre de volume canal B
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal B
                move.b      #ymv_Reg10,ym_RegSelect(A0) ;registre de volume canal C
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal C             
                movem.l     minit_saveregs,A0
                rts


;        /-----------------------------------------------/
;        /       Fixe la fréquence du timer D pour la    /
;        /          restitution des effets audio         /
;        /  parametres:                                  /
;        /              valeur diviseur                  /
;        /              valeur compteur                  /
;        /-----------------------------------------------/

_STX_setsoundtimer:
                movem.l     D7/A6,minit_saveregs
                lea         mf_BaseAddr,A6          ;A6 pointe sur le MFP
                move.w      mf_TCDCR_Reg(A6),D7     ;D7 contient la configuration des diviseurs des timers C et D
                andi.w      #$00F8,D7               ;met les bits 0 à 2 à 0
                move.w      D7,mf_TCDCR_Reg(A6)     ;stoppe le timer D
                or.w        4(A7),D7                ;nouvelle valeur de division du timer D
                move.w      6(A7),mf_TDDR_Reg(A6)   ;nouvelle valeur du compteur du timer D
                move.w      D7,mf_TCDCR_Reg(A6)     ;nouvelle valeur du diviseur du timer D et redemarrage du timer D
                ori.w       #$10,mf_IMRB_Reg(A6)    ;autorise l'interruption du timer D
                ori.w       #$10,mf_IERB_Reg(A6)    ;autorise l'interruption du timer D
                movem.l     minit_saveregs,D7/A6
                rts
               
               
               
;        /-----------------------------------------------/
;        /      Chargement d'un fichier d'effet audio    /
;        /                  AEF ou ADS                   /
;        /  parametres:                                  /
;        /              nom et chemin du fichier         /
;        /  retourne :                                   /
;        /              adresse de stockage en mémoire   /
;        /              si erreur retourne 0             /
;        /-----------------------------------------------/   
            
_STX_loadsoundeffect:
_STX_loaddmasample:
                movem.l     D7-D5,minit_saveregs
                move.l      4(A7),D6                ;contient le pointeur sur le fichier audio
                move.w      #$FFFF,D0               ;D0 = -1 (erreur)
                
;          Fixe la valeur du tampon DTA

                M_fsetdta	#snd_dtaaef 			;adresse du tampon DTA des fichiers audios
				                
;       Recherche du fichier d'effet audio dans D6

                M_fsfirst	#0,D6					;acces lecture/ecriture, D6 pointe sur le nom du fichier
				tst.w       D0                      ;si D0<0
                bne         .snd_loadend            ;alors le fichier n'existe pas
                
;       reservation mémoire pour stockage du fichier

                M_malloc	snd_dtaaef+26			;taille du fichier à mettre en memoire
				tst.l       D0                      ;erreur d'allocation ? d0<0
                bmi         .snd_loadend            ;branchement pour fermeture du fichier
                move.l      D0,D5                   ;sauvegarde adresse de stockage dans D5

;          ouverture du fichier audio

                M_fopen		#0,D6					;ouverture en lecture seul, D6 pointe sur le nom du fichier
				tst.w       D0                      ;si D0<0
                bmi         .snd_loadend            ;alors erreur d'ouverture
                move.w      D0,D7                   ;D7 = le handle du fichier
                
;         lecture et stockage en mémoires des octets

                M_fread		D5,snd_dtaaef+26,D7		;D5=adresse de stockage, nombre de fichier à lire, D7=handle du fichier
				
;         fermeture du fichier d'effet audio   

                M_fclose	D7						;handle du fichier à fermer
				                
                move.l      D5,D0                   ;pas d'erreur
                bra         .snd_loadok             ;aller à .snd_loadok

.snd_loadend    clr.l       D0
.snd_loadok     movem.l     minit_saveregs,D7-D5
                rts
             


;        /-----------------------------------------------/
;        /     liberation d'un fichier d'effet audio     /
;        /                  AEF ou DMA                   /
;        /                                               /
;        /  parametres:                                  /
;        /              adresse de stockage en mémoire   /
;        /-----------------------------------------------/

_STX_unloadsoundeffect:
_STX_unloaddmasample:
                movem.w     D7,minit_saveregs
                move.l      4(A7),D7                ;recupére l'adresse de stockage des données
                M_mfree		D7						;D7=debut adresse memoire à liberer
				movem.w     minit_saveregs,D7
                rts
             
 
 
;        /-----------------------------------------------/
;        /        Active le player1 avec l'adresse       /
;        /               des données audio               /
;        /  parametres:                                  /
;        /              adresse des données audio        /
;        /              mode loop si true                /
;        /-----------------------------------------------/  

_STX_playsound1:    
                movem.l     D7/A0,minit_saveregs
                lea         snd_effectdata,A0
                move.l      #0,snd_play1addr(A0)        ;met à 0 pour arreter la lecture en cas d'interruption
                move.w      8(sp),D7                    ;D7 = loop
                move.b      D7,snd_play1loop(A0)        ;stocke D7
                move.l      4(sp),snd_play1addr(A0)     ;met l'adresse des octets à lire dans snd_play1addr               
                move.l      4(sp),snd_play1addrstd(A0)
                movem.l     minit_saveregs,D7/A0
                rts



;        /-----------------------------------------------/
;        /                  Stop le player 1             /
;        /-----------------------------------------------/
 
_STX_Stopsound1:
                movem.l     A0,minit_saveregs
                lea         snd_effectdata,A0       ;pointe sur le buffer de données des 3 players d'effet
                move.l      #0,snd_play1addr(A0)    ;effacement vecteur player 1
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg8,ym_RegSelect(A0)  ;registre de volume canal A
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal A
                movem.l     minit_saveregs,A0
                rts
                


;        /-----------------------------------------------/
;        /        Active le player2 avec l'adresse       /
;        /               des données audio               /
;        /  parametres:                                  /
;        /              adresse des données audio        /
;        /              mode loop si true                /
;        /-----------------------------------------------/  

_STX_playsound2:    
                movem.l     D7/A0,minit_saveregs
                lea         snd_effectdata,A0
                move.l      #0,snd_play2addr(A0)    ;met à 0 pour arreter la lecture en cas d'interruption
                move.w      8(sp),D7                ;D7 = loop
                move.b      D7,snd_play2loop(A0)    ;stocke D7
                move.l      4(sp),snd_play2addr(A0) ;met l'adresse des octets à lire dans snd_play1addr               
                move.l      4(sp),snd_play2addrstd(A0)
                movem.l     minit_saveregs,D7/A0
                rts
            


;        /-----------------------------------------------/
;        /                  Stop le player 2             /
;        /-----------------------------------------------/

_STX_stopsound2:
                movem.l     A0,minit_saveregs
                lea         snd_effectdata,A0       ;pointe sur le buffer de données des 3 players d'effet
                move.l      #0,snd_play2addr(A0)    ;effacement vecteur player 1
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg9,ym_RegSelect(A0)  ;registre de volume canal B
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal B
                movem.l     minit_saveregs,D7/A0
                rts
                
                

;        /-----------------------------------------------/
;        /        Active le player3 avec l'adresse       /
;        /               des données audio               /
;        /  parametres:                                  /
;        /              adresse des données audio        /
;        /              mode loop si true                /
;        /-----------------------------------------------/  

_STX_playsound3:    
                movem.l     D7/A0,minit_saveregs
                lea         snd_effectdata,A0
                move.l      #0,snd_play3addr(A0)    ;met à 0 pour arreter la lecture en cas d'interruption
                move.w      8(sp),D7                ;D7 = loop
                move.b      D7,snd_play3loop(A0)    ;stocke D7
                move.l      4(sp),snd_play3addr(A0) ;met l'adresse des octets à lire dans snd_play1addr               
                move.l      4(sp),snd_play3addrstd(A0)
                movem.l     minit_saveregs,D7/A0
                rts
            


;        /-----------------------------------------------/
;        /                  Stop le player 3             /
;        /-----------------------------------------------/

_STX_stopsound3:
                movem.l     A0,minit_saveregs
                lea         snd_effectdata,A0       ;pointe sur le buffer de données des 3 players d'effet
                move.l      #0,snd_play3addr(A0)    ;effacement vecteur player 1
                lea         ym_BaseAddr,A0          ;pointe sur le YM2149
                move.b      #ymv_Reg10,ym_RegSelect(A0)  ;registre de volume canal B
                move.b      #$00,ym_RegData(A0)     ;met à 0 le volume du canal B
                movem.l     minit_saveregs,D7/A0
                rts



;        /-----------------------------------------------/
;        /        Player 1,2 et 3 en interruption        /
;        /-----------------------------------------------/                
                
GFXST_SOUND:    movem.l     D2-D4/A0-A2,-(A7)
                lea         snd_effectdata,A0       ;pointe sur le vecteur d'adresse des données des players
                lea         ym_BaseAddr,A2          ;A0 pointe sur le yamaha 2149

;----------------- traitement de la lecture du player 1 -----------------------
                
                tst.l       snd_play1addr(A0)       ;si vecteur = 0
                beq         .gfxst_player2          ;pas de données à lire,voir lecture player 2               
                move.l      snd_play1addr(A0),A1    ;A1 pointe sur les données à lire du player 1               
.gfxst_loop1:   move.b      (A1)+,D2                ;D2 contient le nombre d'octet à lire
                tst.b       D2                      ;si pas d'octet à lire (D2 = 0)
                beq         .gfxst_nowork1          ;aller à .gfxst_nowork1
                cmpi.b      #$FF,D2                 ;si D2 <> $FF 
                bne         .gfxst_readcmd1         ;alors traiter les données en .gfxst_readcmd1
                cmpi.b      #true,snd_play1loop(A0) ;sinon si snd_play1loop <> true
                bne         .gfxst_stop1            ;alors stopper la lecture en .gfxst_stop1
                move.l      snd_play1addrstd(A0),A1 ;sinon recharger A1 avec l'adresse de debut
                bra         .gfxst_loop1            ;reprendre la lecture au début
.gfxst_stop1    move.l      #0,snd_play1addr(A0)    ;effacer le vecteur d'adresse de données du player
                bra         .gfxst_player2          ;passer au player suivant
                
.gfxst_readcmd1 move.b      (A1)+,D3                ;lecture data = valeur du registre  
                andi.b      #$0F,D3                 ;D3 contient le numéro du registre (supprime la lettre du canal)
                move.b      (A1)+,D4                ;D4 contient la valeur de la donnée
                move.b      D3,ym_RegSelect(A2)     ;selection du regitre à controler
                move.b      D4,ym_RegData(A2)       ;valeur à attribuer au registre
                subq.b      #2,D2                   ;decremente le nombre de données à lire de 2
                tst.b       D2                      ;si D2 <> 0
                bne         .gfxst_readcmd1         ;traiter la commande suivante  
.gfxst_nowork1  move.l      A1,snd_play1addr(A0)    ;sauvegarde l'adresse courante de lecture
                bra         .gfxst_player2          ;voir lecture player 2
 
;----------------- traitement de la lecture du player 2 -----------------------

.gfxst_player2: tst.l       snd_play2addr(A0)       ;si vecteur = 0
                beq         .gfxst_player3          ;pas de données à lire,voir lecture player 3  
                move.l      snd_play2addr(A0),A1    ;A1 pointe sur les données à lire du player 2
.gfxst_loop2    move.b      (A1)+,D2                ;D2 contient le nombre d'octet à lire
                tst.b       D2                      ;si pas d'octet à lire (D2 = 0)
                beq         .gfxst_nowork2          ;aller à .gfxst_nowork2
                cmpi.b      #$FF,D2                 ;si D2 <> $FF 
                bne         .gfxst_readcmd2         ;alors traiter les données en .gfxst_readcmd2
                cmpi.b      #true,snd_play2loop(A0) ;sinon si snd_play1loop <> true
                bne         .gfxst_stop2            ;alors stopper la lecture en .gfxst_stop1
                move.l      snd_play2addrstd(A0),A1 ;sinon recharger A1 avec l'adresse de debut
                bra         .gfxst_loop2            ;reprendre la lecture au début
.gfxst_stop2    move.l      #0,snd_play2addr(A0)    ;effacer le vecteur d'adresse de données du player
                bra         .gfxst_player3          ;passer au player suivant
                
.gfxst_readcmd2 move.b      (A1)+,D3                ;lecture data = valeur du registre          
                andi.b      #$0F,D3                 ;D3 contient le numéro du registre (supprime la lettre du canal)
                move.b      (A1)+,D4                ;D4 contient la valeur de la donnée
                move.b      D3,ym_RegSelect(A2)     ;selection du regitre à controler
                move.b      D4,ym_RegData(A2)       ;valeur à attribuer au registre
                subq.b      #2,D2                   ;decremente le nombre de données à lire de 2
                tst.b       D2                      ;si D2 <> 0
                bne         .gfxst_readcmd2         ;traiter la commande suivante  
.gfxst_nowork2  move.l      A1,snd_play2addr(A0)    ;sauvegarde l'adresse courante de lecture
                bra         .gfxst_player3          ;voir lecture player 3

;----------------- traitement de la lecture du player 3 -----------------------

.gfxst_player3: tst.l       snd_play3addr(A0)       ;si vecteur = 0
                beq         .gfxst_noplay           ;pas de données à lire,fin 
                move.l      snd_play3addr(A0),A1    ;A1 pointe sur les données à lire du player 2
.gfxst_loop3    move.b      (A1)+,D2                ;D2 contient le nombre d'octet à lire
                tst.b       D2                      ;si pas d'octet à lire (D2 = 0)
                beq         .gfxst_nowork3          ;aller à .gfxst_nowork3
                cmpi.b      #$FF,D2                 ;si D2 <> $FF 
                bne         .gfxst_readcmd3         ;alors traiter les données en .gfxst_readcmd2
                cmpi.b      #true,snd_play3loop(A0) ;sinon si snd_play1loop <> true
                bne         .gfxst_stop3            ;alors stopper la lecture en .gfxst_stop1
                move.l      snd_play3addrstd(A0),A1 ;sinon recharger A1 avec l'adresse de debut
                bra         .gfxst_loop3            ;reprendre la lecture au début
.gfxst_stop3    move.l      #0,snd_play3addr(A0)    ;effacer le vecteur d'adresse de données du player
                bra         .gfxst_noplay           ;fin 
                
.gfxst_readcmd3 move.b      (A1)+,D3                ;lecture data = valeur du registre          
                andi.b      #$0F,D3                 ;D3 contient le numéro du registre (supprime la lettre du canal)
                move.b      (A1)+,D4                ;D4 contient la valeur de la donnée
                move.b      D3,ym_RegSelect(A2)     ;selection du regitre à controler
                move.b      D4,ym_RegData(A2)       ;valeur à attribuer au registre
                subq.b      #2,D2                   ;decremente le nombre de données à lire de 2
                tst.b       D2                      ;si D2 <> 0
                bne         .gfxst_readcmd3         ;traiter la commande suivante  
.gfxst_nowork3  move.l      A1,snd_play3addr(A0)    ;sauvegarde l'adresse courante de lecture             

.gfxst_noplay   movem.l     (A7)+,D2-D4/A0-A2
                andi.w      #$FFEF,mf_BaseAddr+mf_ISRB_Reg  ;mise à 0 du bit 4 pour marquer la fin de l'interruption
                rte
                


;        /-----------------------------------------------/
;        /   Active le player audio DMA avec l'adresse   /
;        /               des données audio               /
;        /  parametres:                                  /
;        /              adresse des données audio        /
;        /              mode loop si true                /
;        /-----------------------------------------------/  

_STX_playdmasample:
                movem.l     D6-D7/A5-A6,minit_saveregs
                lea         da_BaseAddr,A5          ;pointe sur le DMA Sound
                move.l      4(sp),A6                ;pointe sur le debut du fichier
                move.l      4(sp),D7
                addq.l      #6,D7                   ;D7 = adresse de debut des echantillons
                move.l      D7,D6                   ;D6 = D7 = adresse de debut des echantillons
                move.w      D7,da_FbaseAddrLo(A5)   ;stocke les bits 0 à 7 de l'adresse basse de debut
                lsr.l       #8,D7                   ;decale D7 de 8 bits à droite
                move.w      D7,da_FbaseAddrMi(A5)   ;stocke les bits 15 à 8 de l'adresse milieu de debut
                lsr.w       #8,D7                   ;decale D7 de 8 bits à droite
                move.w      D7,da_FbaseAddrHi(A5)   ;stocke les bits 24 à 16 de l'adresse haute de debut
                
                add.l       (A6),D6                 ;D6 = adresse de fin des echantillons
                addi.l      #1,D6                   ;D6 = adresse de fin de lecture
                move.w      D6,da_FaddrEndLo(A5)    ;stocke les bits 0 à 7 de l'adresse basse de fin
                lsr.l       #8,D6                   ;decale D7 de 8 bits à droite
                move.w      D6,da_FaddrEndMi(A5)    ;stocke les bits 15 à 8 de l'adresse milieu de fin
                lsr.w       #8,D6                   ;decale D7 de 8 bits à droite
                move.w      D6,da_FaddrEndHi(A5)    ;stocke les bits 24 à 16 de l'adresse haute de fin
                
                move.b      snd_dma_MonoStereo(A6),D7   ;lecture du format de l'audio (mono, stereo) (bit 7)
                or.b        snd_dma_frequence(A6),D7    ;lecture frequence d'echantillonage et positionne les bits 0 et 1
                move.w      D7,da_SoundModeCtrl(A5)     ;stocke le format de l'audio et la frequence d'echantillonage dans le registre de controle
                
                cmpi.b      #true,8(sp)
                bne         .dmasmplnoloop
                move.w      #dam_RepeatSound,da_SoundDmaCtrl(A5)  ;commnde play en boucle
                bra         .dmasmplend
.dmasmplnoloop  move.w      #dam_PlaySound,da_SoundDmaCtrl(A5)    ;commnde play une fois              
.dmasmplend     movem.l     minit_saveregs,D6-D7/A5-A6
                rts



;        /-----------------------------------------------/
;        /           Stop le player audio DMA            /
;        /-----------------------------------------------/ 

_STX_stopdmasample:
                move.w      #dam_StopSound,da_BaseAddr+da_SoundDmaCtrl      ;stop to play sample
                rts



;        /-----------------------------------------------/
;        /     Initialise une routine d'interruption     / 
;        /     appelée en fin de lecture des sample      /
;        /-----------------------------------------------/

_STX_setdmasampleinterrupt:
                movem.l     A6,minit_saveregs
                move.l      vec_68901monitor,snd_save6890lmonitor
                move.l      #GFXST_DMAINTERRUPT,vec_68901monitor    ;vecteur d'interruption
                lea         mf_BaseAddr,A6              ;A6 pointe sur le MFP
                andi.w      #$FF7F,mf_AER_Reg(A6)       ;met à 0 le bit 7 car ecran couleur (0)
                andi.w      #$FF7F,mf_DDR_Reg(A6)       ;met à 0 le bit 7 car bit en entrée (0)
                ori.w       #$0080,mf_IERA_Reg(A6)      ;met à 1 le bit 7 car interruption possible (0)
                ori.w       #$0080,mf_IMRA_Reg(A6)      ;met à 1 le bit 7 car interruption possible
                movem.l     minit_saveregs,A6
                rts
 
 

;        /-----------------------------------------------/
;        /      supprime la routine d'interruption       / 
;        /     appelée en fin de lecture des sample      /
;        /-----------------------------------------------/

_STX_removedmasampleinterrupt:
                movem.l     A6,minit_saveregs
                lea         mf_BaseAddr,A6              ;A6 pointe sur le MFP
                andi.w      #$FF7F,mf_IERA_Reg(A6)      ;met à 0 le bit 7 car interruption impossible
                andi.w      #$FF7F,mf_IMRA_Reg(A6)      ;met à 0 le bit 7 car interruption impossible
                andi.w      #$FF7F,mf_AER_Reg(A6)       ;met à 0 le bit 7 car ecran couleur
                andi.w      #$FF7F,mf_DDR_Reg(A6)       ;met à 0 le bit 7 car bit en entrée
                move.l      snd_save6890lmonitor,vec_68901monitor
                move.l      #0,snd_save6890lmonitor     ;met à 0 la mémoire de mémorisation du vecteur 68901monitor
                movem.l     minit_saveregs,A6
                rts
 


;        /-----------------------------------------------/
;        /     Routine d'Interruption appelée a chaque   /
;        /        fin de lecteure des sample audio       /
;        /-----------------------------------------------/
                
GFXST_DMAINTERRUPT:   
                jsr         _STX_dmasampleendframe      ;appel de la routine d'interruption dans le programme C           
                andi.w      #$FF7F,mf_BaseAddr+mf_ISRA_Reg  ;mise à 0 du bit 7 pour marquer la fin de l'interruption
                rte

 

 
                SECTION BSS
                
                
snd_dtaaef:     DS.B        44                      ;buffer pour la DTA
snd_effectdata: DS.W        25                      ;buffer de données pour les 3 players d'effet
snd_save6890lmonitor:  
                DS.L        1                       ;sauvegarde de l'adresse d'interruption du vecteur 68901monitor

