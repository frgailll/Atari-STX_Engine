;      			ADRESSES DES REGISTRES DE L'AUDIO DMA


da_BaseAddr         EQU     $FF8900	

da_SoundDmaCtrl     EQU     0               ;(W) Registre de control de l'audio DMA
da_FbaseAddrHi		EQU		2				;(W) Frame base adresse haute (bits 21-16)
da_FbaseAddrMi		EQU		4				;(W) Frame base adresse milieu (bits 15-8)
da_FbaseAddrLo		EQU		6				;(W) Frame base adresse basse (bits 7-1)
da_FaddrCountHi	    EQU     8				;(W) Frame adresse compteur haut (bits 21-16)
da_FaddrCountMi     EQU     10				;(W) Frame adresse compteur milieu (bits 15-8)
da_FaddrCountLo	    EQU		12				;(W) Frame adresse compteur bas (bits 7-1)
da_FaddrEndHi		EQU		14				;(W) Frame adresse fin haute (bits 21-16)
da_FaddrEndMi		EQU		16				;(W) Frame adresse fin milieu (bits 15-8)
da_FaddrEndLo		EQU		18				;(W) Frame adresse fin basse (bits 7-1)
da_SoundModeCtrl	EQU		32				;(W) Sound mode control


;			Masques pour le registre SoundModeCtrl

dam_Sound_Mono			EQU		$10			;audio mono
dam_Sound_Stereo		EQU		$00			;audio stereo
dam_SampleRate_6258		EQU		$00			;rate de 6258 Hz (pas sur Falcon)
dam_SampleRate_12517	EQU		$01			;rate de 12517 Hz
dam_SampleRate_25033	EQU		$02			;Rate de 25033 Hz
dam_SampleRate_50066	EQU		$03			;Rate de 50066 Hz


;			Masques pour le registre SoundDmaCtrl

dam_StopSound			EQU		$00			;stop la lecture en cours
dam_PlaySound			EQU		$01			;demarre la lecture
dam_RepeatSound			EQU		$03			;repete la lecture jusque stop