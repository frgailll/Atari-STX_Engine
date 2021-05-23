;      ADRESSES DES REGISTRES DU SOUND SHIP AUDIO YM2140



;          Adresse de base du Yamaha

ym_BaseAddr         EQU     $FF8800             ;adresse de base du YM2149 à charger dans un registre d'adresse

;    Offset Adresse des Registres du Yamaha

ym_RegSelect        EQU     $00                 ;selection du registre bits 0 à 4 (1 octet)
ym_RegData          EQU     $02                 ;valeur à attribuer au registre selectionné bits 0 à 7 (1 octet)


; Données de selection des registres 

ymv_Reg0            EQU     $00                 ;poid faible valeur de période Canal A bits 0 à 7
ymv_Reg1            EQU     $01                 ;poid fort valeur de période Canal A bits 0 à 3
ymv_Reg2            EQU     $02                 ;poid faible valeur de période Canal B bits 0 à 7
ymv_Reg3            EQU     $03                 ;poid fort valeur de période Canal B bits 0 à 3
ymv_Reg4            EQU     $04                 ;poid faible valeur de période Canal C bits 0 à 7
ymv_Reg5            EQU     $05                 ;poid fort valeur de période Canal C bits 0 à 3
ymv_Reg6            EQU     $06                 ;valeur période du générateur de bruit bits 0 à 4
ymv_Reg7            EQU     $07                 ;registre multi-fonctions bits 0 à 7
ymv_Reg8            EQU     $08                 ;amplitude Canal A bits 0 à 4
ymv_Reg9            EQU     $09                 ;amplitude Canal B bits 0 à 4
ymv_Reg10           EQU     $0A                 ;amplitude Canal C bits 0 à 4
ymv_Reg11           EQU     $0B                 ;poid faible valeur periode générateur d'enveloppe bits 0 à 7
ymv_Reg12           EQU     $0C                 ;poid fort valeur periode générateur d'enveloppe bits 0 à 7
ymv_Reg13           EQU     $0D                 ;selection forme de l'enveloppe bits 0 à 3
ymv_Reg14           EQU     $0E                 ;Port A - multiples données bits 0 à 7
ymv_Reg15           EQU     $0F                 ;Port B - données ports parallèle Centronics bits 0 à 7
