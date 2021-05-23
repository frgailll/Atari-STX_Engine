;      ADRESSES DES REGISTRES DU SHIFTER



;          Adresse de base du shifter

shf_BaseAddr        EQU     $FF8200             ;adresse de base du blitter à charger dans un registre d'adresse

;    Offset Adresse des Registres du shifter

shf_HighMemVideo    EQU     $00                 ;base haute memoire vidéo, les bit 15 à 8 sont à 0 (2 octets)
shf_MidlMemVideo    EQU     $02                 ;base milieu mémoire vidéo, les bit 15 à 8 sont à 0 (2 octets)
shf_HighAddVideo    EQU     $04                 ;(R/- st, R/W ste) base haute compteur d'adresse vidéo, les bit 15 à 8 sont à 0 (2 octets)
shf_MidAddVideo     EQU     $06                 ;(R/- st, R/W ste) base milieu compteur d'adresse vidéo, les bit 15 à 8 sont à 0 (2 octets)
shf_LowAddVideo     EQU     $08                 ;(R/- st, R/W ste) base basse compteur d'adresse vidéo, les bit 15 à 8 sont à 0, le bit 0 est à 0 (2 octets)    
shf_SyncVideo       EQU     $0A                 ;Mode de synchronisation externe, interne 50Hz - 60Hz (1 octet)      
shf_LowMemVideo     EQU     $0C                 ;(ste) base basse mémoire vidéo, les bit 15 à 8 sont à 0, le bit 0 est à 0 (2 octets)
shf_LineWideOffset  EQU     $0E                 ;(ste) nombre de mot à ajouter ou a supprimer pour un scrolling vertical, les bit 15 à 8 sont à 0 (2 octets)
shf_FineScrollH     EQU     $64                 ;(ste) nombre de decalage en pixel (valeur 0 à 15), les bits 15 à 4 sont à 0 (2 octets)
shf_RegColor_0      EQU     $40                 ;Registre pour la couleur 0, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_1      EQU     $42                 ;Registre pour la couleur 1, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_2      EQU     $44                 ;Registre pour la couleur 2, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_3      EQU     $46                 ;Registre pour la couleur 3, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_4      EQU     $48                 ;Registre pour la couleur 4, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_5      EQU     $4A                 ;Registre pour la couleur 5, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_6      EQU     $4C                 ;Registre pour la couleur 6, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_7      EQU     $4E                 ;Registre pour la couleur 7, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_8      EQU     $50                 ;Registre pour la couleur 8, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_9      EQU     $52                 ;Registre pour la couleur 9, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_10     EQU     $54                 ;Registre pour la couleur 10, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_11     EQU     $56                 ;Registre pour la couleur 11, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_12     EQU     $58                 ;Registre pour la couleur 12, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_13     EQU     $5A                 ;Registre pour la couleur 13, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_14     EQU     $5C                 ;Registre pour la couleur 14, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
shf_RegColor_15     EQU     $5E                 ;Registre pour la couleur 15, (8-9-10(11 ste) rouge, 4-5-6(7 ste) vert, 0-1-2(3 ste) bleu)(2 octets)
sfh_RezVideo        EQU     $60                 ;Resolution vidéo (1 octet)



; Mask de registre

shfm_50HzSync       EQU     $02                 ;Valeur pour Synchronisation interne à 50Hz (shf_SyncVideo)
shfm_60HzSync       EQU     $00                 ;Valeur pour Synchronisation interne à 60Hz (shf_SyncVideo)    
shfm_4planRez       EQU     $00                 ;resolution de 320 x 200 Pixels (16 couleurs)
shfm_2planRez       EQU     $01                 ;resolution de 640 x 200 Pixels (4 couleurs)
shfm_1planRez       EQU     $02                 ;resolution de 640 x 400 Pixels Monochrome



