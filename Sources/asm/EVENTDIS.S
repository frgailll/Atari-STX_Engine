

;           Definition du contenu d'un evenement

evnt_idsender   EQU         $00                                         ;Id de l'emetteur
evnt_value      EQU         $02                                         ;valeur de l'evenement
evnt_param1     EQU         $04                                         ;parametre 1 de l'evenement (optionel)
evnt_param2     EQU         $06                                         ;parametre 2 de l'evenement (optionel)

;           caractéristique d'un evenement 

evnt_size       EQU         $0A                                         ;taille en octet d'un evenement en mémoire
evnt_stacksize  EQU         30*evnt_size                                ;taille de la pile
evnt_maxid      EQU         15                                          ;nombre maximum d'utilisateur

                
                SECTION TEXT
                

;           /-------------------------------------------------/
;           /    Initialisation du dispatcher d'evenement     /
;           /-------------------------------------------------/

evnt_initdispatcher:
                move.l      #evnt_stack,evnt_stackpt                    ;initialise le pointeur de pile sur l'adresse de la pile
                lea         evnt_userpt,A0                              ;pointe sur le debut des pointeurs d'evenement des utilisateurs
                move.w      #evnt_maxid,D1                              ;contient le nombre d'utilisateur max
.evnt_initusrpt move.l      #0,(A0)+                                    ;initialise à 0 les pointeurs d'evenement utilisateur
                subi.w      #1,D1                                       ;decrement D1
                bne         .evnt_initusrpt                             ;si D1 > 0, continuer à initialiser les pointeurs d'evenements utilisateur
                move.w      #0,evnt_nbuser                              ;initialise le nombre d'utilisateur
                rts
                


;           /-------------------------------------------------/
;           /      Enregistrement d'un nouvel utilisateur     /
;           /                                                 /
;           /   retourne:                                     /
;           /               numero d'Id, sinon -1 si erreur   /
;           /-------------------------------------------------/

_STX_regevent:
                movem.l     D7/A6,minit_saveregs
                move.w      evnt_nbuser,D7                              ;D7 contient le nombre d'utilisateur en cours
                cmp.w       #evnt_maxid,D7                              ;si D7 <> evnt_maxid (nombre d'utilisateur max)
                bne         .evnt_giveid                                ;fournir un id
                move.w      #$FFFF,D0                                   ;sinon D0 = -1
                bra         .evnt_endreg                                ;quitter
.evnt_giveid    move.w      D7,D0                                       ;mettre dans D0 le nombre d'utilisateur en cours (id)
                lsl.w       #2,D7                                       ;multiplie D7 par 4
                lea         evnt_userpt,A6                              ;A6 pointe sur les pointeurs d'evenement des utilisateurs
                move.l      #evnt_stack,(A6,D7.W)                       ;initialise le pointeur de l'utilisateur avec l'adresse du stack d'evenement
                addi.w      #1,evnt_nbuser                              ;incrementer le nombre d'utilisateur en cours (id)
.evnt_endreg    movem.l     minit_saveregs,D7/A6
                rts
                
                

;           /-------------------------------------------------/
;           /      Envoi d'un evenement dans le dispatcher    /
;           /                                                 /
;           /   parametres:                                   /
;           /               numero d'Id de l'emetteur         /
;           /               valeur de l'evenement             /
;           /                                                 /
;           /-------------------------------------------------/

_STX_sendevent:
                movem.l     D6-D7/A5-A6,minit_saveregs
                lea         evnt_stackpt,A6
                move.l      (A6),A5
                move.w      4(A7),D7                                    ;recuperation de l'id utilisateur
                move.w      D7,(A5)+                                    ;stocke l'id de l'emetteur du message
                move.w      6(A7),D7                                    ;recupére l'evenement sur la pile
                move.w      D7,(A5)+                                    ;stocke l'evenement
                move.w      #0,(A5)+                                    ;parametre 1 de l'evenement à 0
                move.l      #0,(A5)+                                    ;parametre 2 de l'evenement à 0
                move.l      A5,D7                                       ;met A5 dans D7
                move.l      #evnt_stack,D6                              ;met l'adresse de la pile dans D6
                sub.l       D6,D7                                       ;soustrait l'adresse pointé par A5 (D7) avec l'adresse de debut du stack d'evenement (D6)
                cmp.w       #evnt_stacksize,D7                          ;si D7 < à la taille maximal du stack d'evenement
                blt         .endsendevent                               ;aller à .endsend
                move.l      #evnt_stack,A5                              ;sinon reinitialise le pointeur d'evenement au debut du stack d'evenement 
.endsendevent   move.l      A5,(A6)                                     ;remet le pointeur d'evenement dans evnt_stackpt
                movem.l     minit_saveregs,D6-D7/A5-A6
                rts
                


;           /-------------------------------------------------/
;           /       Envoi d'un evenement avec parametres      /
;           /               dans le dispatcher                /
;           /                                                 /
;           /   parametres:                                   /
;           /               numero d'Id de l'emetteur         /
;           /               valeur de l'evenement             /
;           /               parametre 1                       /
;           /               parametre 2                       /
;           /                                                 /
;           /-------------------------------------------------/
                
_STX_sendeventex:
                movem.l     D6-D7/A5-A6,minit_saveregs
                lea         evnt_stackpt,A6
                move.l      (A6),A5
                move.w      4(A7),D7                                    ;recuperation de l'id utilisateur
                move.w      D7,(A5)+                                    ;stocke l'id de l'emetteur du message
                move.w      6(A7),D7                                    ;recupére l'evenement
                move.w      D7,(A5)+                                    ;stocke l'evenement
                move.w      8(A7),D7                                    ;recupère parametre 1
                move.w      D7,(A5)+                                    ;stocke le paramatre 1
                move.l      10(A7),D7                                   ;recupère parametre 2
                move.l      D7,(A5)+                                    ;stocke le parametre 2 de l'evenement 
                move.l      A5,D7                                       ;met A5 dans D7
                move.l      #evnt_stack,D6                              ;met l'adresse de la pile dans D6
                sub.l       D6,D7                                       ;soustrait l'adresse pointé par A5 (D7) avec l'adresse de debut du stack d'evenement (D6)
                cmp.w       #evnt_stacksize,D7                          ;si D7 < à la taille maximal du stack d'evenement
                blt         .endsendeventx                              ;aller à .endsend
                move.l      #evnt_stack,A5                              ;sinon reinitialise le pointeur d'evenement au debut du stack d'evenement 
.endsendeventx  move.l      A5,(A6)                                     ;remet le pointeur d'evenement dans evnt_stackpt
                movem.l     minit_saveregs,D6-D7/A5-A6
                rts



;           /-------------------------------------------------/
;           /    lecture d'un evenement dans le dispatcher    /
;           /                                                 /
;           /   parametres:                                   /
;           /               numero d'Id de l'utilisateur      /
;           /               adresse stockage valeur de        /
;           /               l'evenement                       /
;           /                                                 /
;           /   retourne:   true si un evenement est lu       /
;           /-------------------------------------------------/

_STX_getevent:  movem.l     D3-D7/A4-A6,minit_saveregs
                move.b      #false,D0                                   ;initialise D0 à pas d'evenement
                move.w      4(A7),D7                                    ;id de l'utilisateur
                move.w      D7,D6                                       ;D6 = id de l'utilisateur
                lsl.w       #2,D7                                       ;multiplie D7 par 4
                lea         evnt_userpt,A6                              ;A6 pointe sur le debut des pointeurs de stack d'evenement des utilisateur       
                move.l      (A6,D7.W),A5                                ;A5 pointe sur l'adresse du pointeur du stack d'evenement de l'utilisateur en cours
                move.l      #evnt_stack,D5                              ;met l'adresse de la pile dans D5
                
.getnextget     move.b      #false,D3                                   ;id utilisateur <> id emetteur
                lea         evnt_stackpt,A4                             ;A4 pointe sur l'adresse de stockage du pointeur d'evenement
                move.l      (A4),A4                                     ;A4 pointe sur l'adresse du pointeur d'evenement
                cmpa.l      A5,A4                                       ;si pointeur d'evenemnt de l'utilisateur = pointeur d'evenement du stack
                beq         .endgetevent                                ;alors plus d'evenement à lire
                
                cmp.w       evnt_idsender(A5),D6                        ;si l'id de l'evenement = id de l'utilisateur en cours
                bne         .nextgetevnt                                ;traiter l'evenement suivant
                move.b      #true,D3                                    ;flag id utilisateur = id emetteur

.nextgetevnt    move.l      6(A7),A4                                    ;A4 pointe sur l'adresse de stockage de la valeur de l'evenement
                move.w      evnt_value(A5),(A4)                         ;sinon mettre la valeur de l'evenement à l'adresse de stockage de la valeur pointé par A4
                adda.l      #evnt_size,A5                               ;incremente le pointeur d'evenement de la taille de l'evenement      
                move.l      A5,D4                                       ;met A5 dans D7
                sub.l       D5,D4                                       ;soustrait l'adresse pointé par A5 (D7) avec l'adresse de debut du stack d'evenement (D6)
                cmp.w       #evnt_stacksize,D4                          ;si D7 < à la taille maximal du stack d'evenement
                blt         .savegetevent                               ;aller à .savegetevent
                move.l      #evnt_stack,A5                              ;sinon reinitialise le pointeur d'evenement au debut du stack d'evenement 
.savegetevent   move.l      A5,(A6,D7.W)                                ;stocke la nouvelle valeur du pointeur d'evenemnt de l'utilisateur
                tst.b       D3                                          ;si D1 <> false (id utilisateur = id emetteur)
                bne         .getnextget                                 ;prendre l'evenement suivant                         
                move.b      #true,D0                                    ;un evenement est disponible

.endgetevent    movem.l     minit_saveregs,D3-D7/A4-A6            
                rts
                
          

;           /-------------------------------------------------/
;           /      Lecture d'un evenement avec parametres     /
;           /               dans le dispatcher                /
;           /                                                 /
;           /   parametres:                                   /
;           /               numero d'Id de l'utilisateur      /
;           /               adresse stockage valeur de        /
;           /               l'evenement                       /
;           /               adresse de stockage parametre 1   /
;           /               adresse de stockage parametre 2   /
;           /                                                 /
;           /   retourne :  true si un evenement est lu       /
;           /-------------------------------------------------/ 
 
_STX_geteventex:
                movem.l     D3-D7/A4-A6,minit_saveregs
                move.b      #false,D0                                   ;initialise D0 à pas d'evenement
                move.w      4(A7),D7                                    ;id de l'utilisateur
                move.w      D7,D6                                       ;D6 = id de l'utilisateur
                lsl.w       #2,D7                                       ;multiplie D7 par 4
                lea         evnt_userpt,A6                              ;A6 pointe sur le debut des pointeurs de stack d'evenement des utilisateur       
                move.l      (A6,D7.W),A5                                ;A5 pointe sur l'adresse du pointeur du stack d'evenement de l'utilisateur en cours
                move.l      #evnt_stack,D5                              ;met l'adresse de la pile dans D5
                
.getnextgetx    move.b      #false,D3                                   ;id utilisateur <> id emetteur
                lea         evnt_stackpt,A4                             ;A4 pointe sur l'adresse de stockage du pointeur d'evenement
                move.l      (A4),A4                                     ;A4 pointe sur l'adresse du pointeur d'evenement
                cmpa.l      A5,A4                                       ;si pointeur d'evenemnt de l'utilisateur = pointeur d'evenement du stack
                beq         .endgeteventx                               ;alors plus d'evenement à lire
                
                cmp.w       (A5)+,D6                                    ;si l'id de l'evenement = id de l'utilisateur en cours
                bne         .nextgetevntx                               ;traiter l'evenement suivant
                move.b      #true,D3                                    ;flag id utilisateur = id emetteur

.nextgetevntx   move.l      6(A7),A4                                    ;A4 pointe sur l'adresse de stockage de la valeur de l'evenement
                move.w      (A5)+,(A4)                                  ;sinon mettre la valeur de l'evenement à l'adresse de stockage de la valeur pointé par A4
                move.l      10(A7),A4                                   ;A4 pointe sur l'adresse de stockage du parametre 1 
                move.w      (A5)+,(A4)                                  ;met la valeur du parametre 1 à l'adresse de stockage de la valeur pointé par A4
                move.l      14(A7),A4                                   ;A4 pointe sur l'adresse de stockage du parametre 2
                move.l      (A5)+,(A4)                                  ;met la valeur du parametre 2 à l'adresse de stockage de la valeur pointé par A4
                move.l      A5,D4                                       ;met A5 dans D7
                sub.l       D5,D4                                       ;soustrait l'adresse pointé par A5 (D7) avec l'adresse de debut du stack d'evenement (D6)
                cmp.w       #evnt_stacksize,D4                          ;si D7 < à la taille maximal du stack d'evenement
                blt         .savegeteventx                              ;aller à .savegetevent
                move.l      #evnt_stack,A5                              ;sinon reinitialise le pointeur d'evenement au debut du stack d'evenement 
.savegeteventx  move.l      A5,(A6,D7.W)                                ;stocke la nouvelle valeur du pointeur d'evenemnt de l'utilisateur
                tst.b       D3                                          ;si D1 <> false (id utilisateur = id emetteur)
                bne         .getnextgetx                                ;prendre l'evenement suivant                         
                move.b      #true,D0                                    ;un evenement est disponible

.endgeteventx   movem.l     minit_saveregs,D3-D7/A4-A6
                rts

 
 
                SECTION BSS
                                
evnt_stackpt    DS.L        1                                           ;pointeur d'entrée des evenements
evnt_userpt     DS.L        evnt_maxid                                  ;15 pointeurs d'evenement
evnt_nbuser     DS.W        1
evnt_stack      DS.W        evnt_stacksize                              ;dimensionnement de la pile d'evenements
