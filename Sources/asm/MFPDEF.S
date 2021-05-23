;      ADRESSES DES REGISTRES DU MFP 68901


;          Adresse de base du MFP

mf_BaseAddr         EQU     $FFFA00             ;adresse de base du MFP à charger dans un registre d'adresse

;    Offset Adresse des Registres du Yamaha

mf_GPIP_Reg         EQU     $00                 ;registre général d'Entrée Sortie bits 0 à 7 (2 octets)
mf_AER_Reg          EQU     $02                 ;determine si l'interruption du GPIP est actif sur front montant ou descendant bits 0 à 7 (2 octets)
mf_DDR_Reg          EQU     $04                 ;defini le sense des données du GPIP bits à 0 7 (2 octets)
mf_IERA_Reg         EQU     $06                 ;active ou déactive separement les interruptions 1 à 8 bit 0 à 7 (2 octets)
mf_IERB_Reg         EQU     $08                 ;active ou déactive separement les interruptions 9 à 16 bit 0 à 7 (2 octets)
mf_IPRA_Reg         EQU     $0A                 ;annule une des interruptions 1 à 8 manuellement ou automatiquement bits 0 à 7 (2 octets)
mf_IPRB_Reg         EQU     $0C                 ;annule une des interruptions 9 à 16 manuellement ou automatiquement bits 0 à 7 (2 octets)
mf_ISRA_Reg         EQU     $0E                 ;active ou déactive le déclenchements de multi-interruption 1 à 8 bits 0 à 7 (2 octets)
mf_ISRB_Reg         EQU     $10                 ;active ou déactive le déclenchements de multi-interruption 9 à 16 bits 0 à 7 (2 octets)
mf_IMRA_Reg         EQU     $12                 ;permet de masquer les interruptions 1 à 8 bits 0 à 7 (2 octets)
mf_IMRB_Reg         EQU     $14                 ;permet de masquer les interruptions 9 à 16 bits 0 à 7 (2 octets)
mf_VR_Reg           EQU     $16                 ;registre de vecteur bits 4 à 7, bit 3 = bit S (2 octets)

mf_TACR_Reg         EQU     $18                 ;mode de fonctionnement du timer A et pré-diviseur bits 0 à 3. bit 4 = reset timer (2 octets)
mf_TBCR_Reg         EQU     $1A                 ;mode de fonctionnement du timer B et pré-diviseur bits 0 à 3. bit 4 = reset timer (2 octets)
mf_TCDCR_Reg        EQU     $1C                 ;mode de fonctionnement du timer C et D et pré-diviseur bits 4 à 6 timer C, bit 0 à 2 timer D (2 octets)
mf_TADR_Reg         EQU     $1E                 ;registre de donnée du decompteur du timer A bits 0 à 7 (2 octets)
mf_TBDR_Reg         EQU     $20                 ;registre de donnée du decompteur du timer B bits 0 à 7 (2 octets)
mf_TCDR_Reg         EQU     $22                 ;registre de donnée du decompteur du timer C bits 0 à 7 (2 octets)
mf_TDDR_Reg         EQU     $24                 ;registre de donnée du decompteur du timer D bits 0 à 7 (2 octets)

mf_SCR_Reg          EQU     $26                 ;Caractère de synchronisation bit 0 à 7 (2 octets)
mf_UCR_Reg          EQU     $28                 ;registre de controle USART bit 1 à 7 (2 octets)
mf_RSR_Reg          EQU     $2A                 ;registre de status de reception bits 0 à 7 (2 àctets)
mf_TSR_Reg          EQU     $2C                 ;registre de status de transmission bits 0 à 7 (2 octets)
mf_UDR_Reg          EQU     $2E                 ;registre de donnée USART (2 octets)

;horloge MFP 2,4576 MHz