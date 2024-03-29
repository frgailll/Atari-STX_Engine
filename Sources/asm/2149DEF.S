;      ADRESSES DES REGISTRES DU SOUND SHIP AUDIO YM2140



;          Adresse de base du Yamaha

ym_BaseAddr         EQU     $FF8800             ;adresse de base du YM2149 � charger dans un registre d'adresse

;    Offset Adresse des Registres du Yamaha

ym_RegSelect        EQU     $00                 ;selection du registre bits 0 � 4 (1 octet)
ym_RegData          EQU     $02                 ;valeur � attribuer au registre selectionn� bits 0 � 7 (1 octet)


; Donn�es de selection des registres 

ymv_Reg0            EQU     $00                 ;poid faible valeur de p�riode Canal A bits 0 � 7
ymv_Reg1            EQU     $01                 ;poid fort valeur de p�riode Canal A bits 0 � 3
ymv_Reg2            EQU     $02                 ;poid faible valeur de p�riode Canal B bits 0 � 7
ymv_Reg3            EQU     $03                 ;poid fort valeur de p�riode Canal B bits 0 � 3
ymv_Reg4            EQU     $04                 ;poid faible valeur de p�riode Canal C bits 0 � 7
ymv_Reg5            EQU     $05                 ;poid fort valeur de p�riode Canal C bits 0 � 3
ymv_Reg6            EQU     $06                 ;valeur p�riode du g�n�rateur de bruit bits 0 � 4
ymv_Reg7            EQU     $07                 ;registre multi-fonctions bits 0 � 7
ymv_Reg8            EQU     $08                 ;amplitude Canal A bits 0 � 4
ymv_Reg9            EQU     $09                 ;amplitude Canal B bits 0 � 4
ymv_Reg10           EQU     $0A                 ;amplitude Canal C bits 0 � 4
ymv_Reg11           EQU     $0B                 ;poid faible valeur periode g�n�rateur d'enveloppe bits 0 � 7
ymv_Reg12           EQU     $0C                 ;poid fort valeur periode g�n�rateur d'enveloppe bits 0 � 7
ymv_Reg13           EQU     $0D                 ;selection forme de l'enveloppe bits 0 � 3
ymv_Reg14           EQU     $0E                 ;Port A - multiples donn�es bits 0 � 7
ymv_Reg15           EQU     $0F                 ;Port B - donn�es ports parall�le Centronics bits 0 � 7
