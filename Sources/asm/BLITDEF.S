;      ADRESSES DES REGISTRES DU BLITTER


;          Adresse de base du blitter

blt_BaseAddr        EQU       $FF8A00           ;adresse de base du blitter à charger dans un registre d'adresse

;    Offsset Adresse des Registres du blitter

blt_Halftone        EQU       $00               ;memoire de demi-teinte Halftone pour motif (2 octets)
blt_SrcXinc         EQU       $20               ;registre source X increment (2 octets)
blt_SrcYinc         EQU       $22               ;registre source Y increment (2 octets)
blt_SrcAddr         EQU       $24               ;adresse de la source à déplacer (4 octets)
blt_EndMask1        EQU       $28               ;mask de début de bloc (2 octets)
blt_EndMask2        EQU       $2A               ;mask de milieu de bloc (2 octets)
blt_EndMask3        EQU       $2C               ;mask de fin de bloc (2 octets)
blt_DstXinc         EQU       $2E               ;registre destination X increment (2 octets)
blt_DstYinc         EQU       $30               ;registre destination Y increment (2 octets)
blt_DstAddr         EQU       $32               ;adresse de destination de la source qui sera déplacée (4 octets)
blt_Xcount          EQU       $36               ;nombre de mot contenu dans une ligne (2 octets)
blt_Ycount          EQU       $38               ;nombre de ligne à traiter (2 octets)
blt_Hop             EQU       $3A               ;halftone operations (0 à 3) (1 octet)
blt_Op              EQU       $3B               ;operation logique (0 à 15) entre source et destination (1 octet)
blt_LineNum         EQU       $3C               ;control démarrage blitter, démarrage demi-teinte, partage de cycles (1 octet)
blt_Skew            EQU       $3D               ;nombre de rotation (0 à 15) pour alignement au bit (1 octet)

; Mask de registre

bltm_LineNumSmudge  EQU         $20             ;demarre la copie à la ligne indiquée par blt_LineNum (0-15)
bltm_LineNumHog     EQU         $40             ;Pas de partage du bus avec le processeur tous les 64 Cycles
bltm_LineNumBusy    EQU         $80             ;Demarre le blitter, en lecture indique si le blitter est occupé
bltm_SkewNfsr       EQU         $40             ;No Final Source Read
bltm_SkewFxsr       EQU         $80             ;Force eXtra Source Reader




              SECTION DATA
              
;           Valeur du mask 1

blt_LeftMask:   DC.W      $FFFF
                DC.W      $7FFF
                DC.W      $3FFF
                DC.W      $1FFF
                DC.W      $0FFF
                DC.W      $07FF
                DC.W      $03FF
                DC.W      $01FF
                DC.W      $00FF
                DC.W      $007F
                DC.W      $003F
                DC.W      $001F
                DC.W      $000F
                DC.W      $0007
                DC.W      $0003
                DC.W      $0001
                DC.W      $0000

;           Valeur du mask 3

blt_RightMask:  DC.W      $0000
                DC.W      $8000
                DC.W      $C000
                DC.W      $E000
                DC.W      $F000
                DC.W      $F800
                DC.W      $FC00
                DC.W      $FE00
                DC.W      $FF00
                DC.W      $FF80
                DC.W      $FFC0
                DC.W      $FFE0
                DC.W      $FFF0
                DC.W      $FFF8
                DC.W      $FFFC
                DC.W      $FFFE
                DC.W      $FFFF

;sauvegarde de l'adresse de la pile utilisateur

blt_SavePile:   DS.L      1
              