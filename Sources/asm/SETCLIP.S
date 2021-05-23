;                   SOUS-PROGRAMME SETCLIPPING
;              permet de fixer les limites d'affichage
;                            des sprites


;liste des parametres entrants et sortants
;  D1=coordonnee X minimum
;  D2=coordonnee X maximum
;  D3=coordonnee Y minimum
;  D4=coordonnee Y maximum
;  retour D0=0 mauvais parametre X et Y
;         D0=1 parametre X correcte et mauvais parametre Y
;         D0=2 parametre Y correcte et mauvais parametre X
;         D0=3 parametre X et Y correctes



clipxmin        EQU       0                     ;valeur minimum clip X
clipxminmod     EQU       2
outclipxmin     EQU       4
clipxmax        EQU       6                     ;valeur maximum clip X
clipxmaxmod     EQU       8
outclipxmax     EQU       10
clipymin        EQU       12                    ;valeur minimum clip Y
outclipymin     EQU       14
clipymax        EQU       16                    ;valeur maximum clip Y
outclipymax     EQU       18


                SECTION TEXT


;        /---------------------------------------------------/
;        /       Initialisation des valeurs de clipping      /
;        /     sur toute la largeur et hauteur de l'écran    /
 ;       /---------------------------------------------------/

initscreenclipping:
                lea         clipvalues,A1
                move.w      #0,clipxmin(A1)
                move.w      #0,clipxminmod(A1)
                move.w      #-15,outclipxmin(A1)
                move.w      #319,clipxmax(A1)
                move.w      #304,clipxmaxmod(A1)
                move.w      #319,outclipxmax(A1)
                move.w      #0,clipymin(A1)
                move.w      #-15,outclipymin(A1)
                move.w      #184,clipymax(A1)
                move.w      #199,outclipymax(A1)
                rts



;        /---------------------------------------------------/
;        /       Fixe les nouvelles valeurs de clipping      /
;        /   parametre sur la pile :                         /
;        /          Coordonnée X minimum                     /
;        /          Coordonnée X maximum                     /
;        /          Coordonnée Y minimum                     /
;        /          Coordonnée Y maximum                     /  
;        /---------------------------------------------------/

_STX_setscreenclipping:

                movem.l     D1-D5/A6,minit_saveregs ;sauvegarde des registres modifiés
                
;           recuperation des paramètres sur la pile
             
                move.w      4(A7),D1                ;recuperation valeur posxmin sur la pile
                move.w      6(A7),D2                ;recuperation valeur posxmax sur la pile
                move.w      8(A7),D3                ;recuperation valeur posymin sur la pile
                move.w      10(A7),D4               ;recuperation valeur posymax sur la pile

;           Calcul des parametres de l'axe des X

                moveq       #0,D0                   ;efface D0 valeur de retour
                tst.w       D1                      
                blt         .paramclipy             ;si posxmin < 0
                cmpi.w      #319,D2                 ;compare 319 a posxmax
                bhi         .paramclipy             ;si posxmax > 319
                cmp.w       D2,D1                   ;compare posxmax a posxmin
                bhi         .paramclipy             ;si posxmin > posxmax
                lea         clipvalues,A6           ;Pointe au debut des valeurs du clipping
                move.w      D2,clipxmax(A6)         ;clipxmax = posxmax
                move.w      D2,outclipxmax(A6)      ;outclipxmax = posxmax
                andi.w      #$FFF0,D2               ;posxmax = posxmax  & $FFF0
                move.w      D2,clipxmaxmod(A6)      ;clipxmaxmod = posxmax
                move.w      D1,clipxmin(A6)         ;clipxmin = posxmin
                move.w      D1,D5                   ;D5 = posxmin
                andi.w      #$FFF0,D1               ;posxmin = posxmin & $FFF0
                move.w      D1,clipxminmod(A6)      ;clipxminmod = posxmin
                subi.w      #15,D5                  ;posxmin = posxmin-15
                move.w      D5,outclipxmin(A6)      ;outclipxmin = posxmin
                or.l        #$1,D0                  ;met bit 1 a 1 de D0 car parametre X ok

;        Calcul des parametres de l'axe des Y

.paramclipy:    tst.w       D3                      ;compare 0 a posymin
                blt         .setclipend             ;si posymin < 0
                cmpi.w      #199,D4                 ;compare posymax a 199
                bhi         .setclipend             ;si posymax > 199
                cmp.w       D4,D3                   ;compare posymax a posymin
                bhi         .setclipend             ;si posymin > posymax
                lea         clipvalues,A6           ;pointe au debut des valeurs de clipping
                move.w      D3,clipymin(A6)         ;clipymin = posymin
                move.w      D4,outclipymax(A6)      ;outclipymax = posymax
                subi.w      #15,D3                  ;posymin = posymin - 15
                move.w      D3,outclipymin(A6)      ;outclipymin = posymin
                subi.w      #15,D4                  ;posymax = posymax - 15
                move.w      D4,clipymax(A6)         ;clipymax = posymax
                or.l        #$2,D0                  ;met le bit 2 de D0 a 1 car parametre Y ok
.setclipend:    movem.l     minit_saveregs,D1-D5/A6 ;restitution des registres modifiés
                rts



              SECTION BSS
              
clipvalues:     DS.W        10
                
