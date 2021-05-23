
;       /-------------------------------------------/
;       /                                           /
;       /                Macros Gemdos              /
;       /                                           /
;       /-------------------------------------------/

    macro   M_modesuper                         ;passage en mode superviseur (affecte A1,D1,D0)
            clr.l       -(sp)                   ;0 pour passage en superviseur
            move.w      #$20,-(sp)              ;code gemdos
            trap        #1                      ;interruption
            addq.l      #6,sp                   ;correction de la pile
            move.l      D0,\1                   ;sauvgarde l'adresse de la pile utilisateur
    endm
    
    macro   M_modeuser                          ;retour au mode utilisateur (affecte A1,D1,D0)
            move.l      \1,-(sp)                ;adresse pile utilisateur
            move.w      #$20,-(sp)              ;code gemdos
            trap        #1                      ;interruption
            addq.l      #6,sp                   ;correction de la pile
    endm
       
    macro   M_malloc                            ;reservation mémoire, D0=adresse mémoire réservée, si erreur D0<0
            move.l      \1,-(sp)                ;nombre d'octets de memoire à réserver
            move.w      #$48,-(sp)              ;numero de la fonction MALLOC
            trap        #1                      ;appel de la fonction
            addq.l      #6,sp                   ;correction de la pile
    endm
    
    macro   M_mfree                             ;liberation de mémoire
            move.l      \1,-(sp)                ;adresse de la zone mémoire à libérer
            move.w      #$49,-(sp)              ;numero fonction MFREE
            trap        #1                      ;appel de la fonction
            addq.l      #6,sp                   ;correction de la pile
    endm
    
     macro  M_fsetdta                           ;fixe le nouveau tampon DTA
            move.l      \1,-(sp)                ;adresse du tampon DTA
            move.w      #$1A,-(sp)              ;numero fonction FSETDTA
            trap        #1                      ;appel de la fonction
            addq.l      #6,sp                   ;correction de la pile
    endm
    
    macro   M_fsfirst                           ;recherche d'un fichier, si D0=0 le fichier est trouvé
            move.w      \1,-(sp)                ;Attribut d'accés (0->lecture/ecriture, 1->lecture seul, voir autre attibut dans compendium)
            move.l      \2,-(sp)                ;pointeur sur le nom du fichier avec zero terminal
            move.w      #$4E,-(sp)              ;numero de la fonction FSFIRST
            trap        #1                      ;appel de la fonction
            addq.l      #8,sp                   ;correction de la pile
    endm
    
    macro   M_fopen                             ;ouverture d'un fichier, si erreur D0<0, sinon D0=handle du fichier
            move.w      \1,-(sp)                ;mode d'ouverture du fichier, 0->lecture seul, 1->ecriture seul, 2->lecture/ecriture
            move.l      \2,-(sp)                ;pointeur sur le nom du fichier
            move.w      #$3D,-(sp)              ;valeur fonction FOPEN
            trap        #1                      ;appel de la fonction
            addq.l      #8,sp                   ;corrige la pile
    endm
    
    macro   M_fread                             ;lecture d'un nombre d'octet d'un fichier, D0=nombre d'octet lu
            move.l      \1,-(sp)                ;adresse de stockage des données lues
            move.l      \2,-(sp)                ;nombre d'octet à lire
            move.w      \3,-(sp)                ;handle du fichier
            move.w      #$3F,-(sp)              ;numero de la fonction FREAD
            trap        #1                      ;appel de la fonction
            add.l       #12,sp                  ;correction de la pile
    endm
    
    macro   M_fseek                             ;permet de se deplacer dans un fichier
            move.w      \1,-(sp)                ;mode de deplacement (0=depuis le debut, 1=offset depuis la position courante, 2=offset positif depuis la fin du fichier
            move.w      \2,-(sp)                ;Handle du fichier
            move.l      \3,-(sp)                ;offset de deplacement
            move.w      #$42,-(sp)              ;code de la fonction FSEEK
            trap        #1                      ;execution de la focntion
            add.l       #10,sp                  ;correction de la pile
    endm
    
    macro   M_fclose                            ;fermeture d'un fichier ouvert
            move.w      \1,-(sp)                ;handle du fichier
            move.w      #$3E,-(sp)              ;numero fonction FCLOSE
            trap        #1                      ;appel de la fonction
            addq.l      #4,sp                   ;correction de la pile
    endm
    
    
    
    macro   M_pterm                             ;termine un processus en liberant toutes les ressources
            clr.w       -(sp)                   ;appel Fonction PTERM
            trap        #1                      ;appel de l'interruption
    endm
    
    macro   M_cconws                            ;sort une chaine de caractère terminée par 0 à la position du curseur
            move.l      \1,-(sp)                ;adresse de la chaine de caractere
            move.w      #9,-(sp)                ;appel Fonction CCONWS
            trap        #1                      ;appel de l'interruption
            addq.l      #6,sp                   ;correction de la pile
    endm



;       /-------------------------------------------/
;       /                                           /
;       /                Macros Xbios               /
;       /                                           /
;       /-------------------------------------------/
	
	macro   M_setpalette                        ;charge les 16 couleurs d'une palette
            move.l      \1,-(sp)                ;adresse de debut des donnees de la palette
            move.w      #6,-(sp)                ;numero de la fontion SETPALETTE
            trap        #14                     ;appel de la fontion
            addq.l      #6,sp                   ;correction de la pile
    endm
    
    macro   M_setcolor                          ;change une couleur ou retourne la valeur d'une couleur
            move.w      \1,-(sp)                ;valeur de la couleur (RVB) ou -1 pour lire la valeur de la couleur
            move.w      \2,-(sp)                ;numero de la couleur
            move.w      #7,-(sp)                ;numero fonction SETCOLOR
            trap        #14                     ;interruption
            addq.l      #6,sp                   ;correction de la pile 
    endm
    
    macro   M_phybase                           ;retourne l'adresse de l'écran physique dans D0
            move.w      #2,-(sp)                ;numéro fonction PHYBASE
            trap        #14                     ;appel de l'interruption
            addq.l      #2,sp                   ;correction de la pile
    endm
    
    macro   M_logbase                           ;retourne l'adresse de l'écran logique dans D0
            move.w      #3,-(sp)                ;numéro fonction LOGBASE
            trap        #14                     ;appel de l'interruption
            addq.l      #2,sp                   ;correction de la pile
    endm
    
    macro   M_setscreen                         ;change la résolution et les adresses des écrans logique et physique
            move.w      \1,-(sp)                ;valeur resolution (0=320x200, 1=640x200, 2=640x400), -1 pour conserver la résolution en cours
            move.l      \2,-(sp)                ;adresse de l'écran physique (Xbios2)
            move.l      \3,-(sp)                ;adresse de l'écran logique (Xbios3)
            move.w      #5,-(sp)                ;numero de la fonction SETSCREEN
            trap        #14                     ;interruption
            add.l       #12,sp                  ;correction de la pile
    endm
    
    macro   M_random                            ;retourne une valeur aléatoire sur 24 bits dans D0
            move.w      #17,-(sp)               ;numero fonction RANDOM
            trap        #14                     ;appel de l'interruption
            addq.l      #2,sp                   ;correction de la pile
    endm
    
    macro   M_vsync                             ;attente de la VBL
            move.w      #37,-(sp)               ;numero fonction VSYNC
            trap        #14                     ;appel de l'interruption
            addq.l      #2,sp                   ;correction de la pile
    endm
    
    macro	M_kbdvbase							;retourne dans D0 le vecteur du clavier
			move.w      #34,-(sp)              	;Numéro fonction KBDVBASE
            trap        #14                    	;Execution de la fonction
            addq.l      #2,sp                  	;Correction de la pile
	endm
	
	macro	M_blitmode							;change le mode de blit (software ou hardware) ou retourne le mode actuel
			move.w		\1,-(sp)				; 0 = mode software, 1 = mode Hardware, -1 retourne le mode actuel
			move.w		#$40,-(sp)				;Numéro fonction BLITMODE
			trap		#14						;Execution de la fonction
			addq.l		#4,sp					;Correction de la pile
    endm

    
;       /-------------------------------------------/
;       /                                           /
;       /              Macro-programme              /
;       /                                           /
;       /-------------------------------------------/

    macro   M_getcookies                        ;macro de lecture de cookies, nescessite d'être en mode superviseur, \1 = nom du cookie à rechercher, \2 = valeur du cookie recherché
            movem.l     A1,-(A7)                ;sauvegarde A1
            move.l      #$FFFFFFFF,\2           ;initialise \2 à -1 (pas de cookies ou cookies non trouvé)
            lea         $5A0,A1                 ;A1 pointe à l'adresse contenant l'adresse de stockage des structures de cookies
            tst.l       (A1)                    ;si contenue de A1 = null (0)
            beq         .M_endcookies           ;alors pas de cookies
            move.l      (A1),A1                 ;sinon A1 pointe maintenant sur la premiere struture de cookies
.M_searchcookie:
            cmpi.l      #\1,(A1)                ;si \1(valeur immédiate)= contenue de A1 (\1 = identifiant du cookie)
            bne         .M_nextcookies
            move.l      4(A1),D0                ;stocke la valeur du cookie dans D0
            bra         .M_endcookies           

.M_nextcookies:
            addq.l      #$8,A1                  ;passe au cookie suivant
            tst.l       (A1)                    ;si contenue de A1 = null (0)
            beq         .M_endcookies           ;plus de cookies
            bra         .M_searchcookie         ;verifie le cookie suivant
    
.M_endcookies:
            movem.l     (A7)+,A1                ;restitue A1
    endm
    
    
    
    