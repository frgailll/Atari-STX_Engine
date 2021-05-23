;      ADRESSES DES DIFFERENTS VECTEURS D'INTERRUPTION DU 68000 ET DU 68901



;interruption du Motorola MC68000
vec_68000nmi        EQU     $7C                 ;interruption 68000 de niveau 7 non masquable (reset)
vec_68000mfc        EQU     $78                 ;interruption 68000 généré par le MFC68901 de niveau 6
vec_68000vbl        EQU     $70                 ;interruption 68000 généré par la vbl de niveau 4
vec_68000hbl        EQU     $68                 ;interruption 68000 généré par la hbl de niveau 2

;interruption du Motorola MFC68901 de niveau 6 sur le MC68000
vec_68901monitor    EQU     $13C                ;Detection d'un moniteur monochrme niveau 15
vec_68901ring       EQU     $138                ;Detection sonnerie sur RS232 niveau 14
vec_68901timerA     EQU     $134                ;généré par le timer A (libre) niveau 13
vec_68901rsinfull   EQU     $130                ;tampon de reception RS232 plein niveau 12
vec_68901rsinerror  EQU     $12C                ;erreur de reception rs232 niveau 11
vec_68901rsoutfree  EQU     $128                ;tampon d'émission RS232 vide niveau 10
vec_68901rsouterror EQU     $124                ;erreur de transmission RS232 niveau 9
vec_68901timerB     EQU     $120                ;généré par timer B (hbl compteur) niveau 8
vec_68901contdma    EQU     $11C                ;controleur de disque DMA niveau 7
vec_68901acia       EQU     $118                ;ACIA 6850 midi et clavier niveau 6
vec_68901timerC     EQU     $114                ;généré par le timer C (horloge système 200 Hz) niveau 5
vec_68901timerD     EQU     $110                ;généré par le timer D (horloge RS232) niveau 4
vec_68901contvideo  EQU     $10C                ;contorleur vidéo (fin d'opération) niveau 3
vec_68901rscts      EQU     $108                ;CTS de l'E/S RS232 niveau 2
vec_68901rsdcd      EQU     $104                ;DCD de l'E/S RS232 niveau 1
vec_68901busycentro EQU     $100                ;ligne BUSY de l'interface parallèle