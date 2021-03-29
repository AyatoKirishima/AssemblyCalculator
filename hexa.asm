;-----------------------------------------------------------------------
;	Projet D'Assembleur
;	BAGGIO-KOST Franck
;	MULLER Léane
;-----------------------------------------------------------------------CODE segment

PILE SEGMENT PARA STACK 'PILE'
        DW 512 DUP(00)                                                  ;DW = Allocates and optionally initializes a word (2 bytes) of storage for each initializer. Can also be used as a type specifier anywhere a type is legal. DW is a synonym of WORD.
PILE  ENDS


DONNEE SEGMENT															;Partie affichage
	_title_1		DB	    'Calculatrice format hexadecimal',10,'$'
	;_title_2		DB	    'text',10,'$'
	;_title_3		DB	    'text',10,'$'
	;_title_4		DB	    'text',10,'$'
	;_title_5		DB  	'text',10,'$'
	;_title_6		DB	    'text',10,'$'
	_menu			DB	    ' 1:(+) 2:(-) 3:(x) 4:(/) ',10,' Tapez le numero de votre operation: $'
	
	_qn1			DB  	'   n1 = $'
	_qn2			DB  	'   n2 = $'
	_r_add			DB  	'   n1 + n2 = $'
	_r_sub			DB  	'   n1 - n2 = $'
	_r_mul			DB  	'   n1 x n2 = $'
	_r_div			DB  	'   n1 / n2 = $'
	_error          DB      10,' Erreur division par 0 $',10
	_quit			DB  	10,'  > Quitter (o/n)? $'
	_ascii 			DB	    '0123456789ABCDEF'
    ;10 = retour à la ligne = \n
DONNEE  ENDS

CODE    SEGMENT
;-----------------------------------------------------------------------PROCEDURE DE RETOUR A LA LIGNE	
	RETURN PROC NEAR
		PUSH        AX													;save the register value, insert in order
		PUSH        DX													;save the register value, insert in order
		MOV         DL,10
		MOV         AH,2
		INT         21H
		POP         DX													;take back reg value, take from reverse because push POP function is stack
		POP         AX													;take back reg value, take from reverse because push POP function is stacks
		RET																;quit procedure
	RETURN ENDP															;fin de procedure

;-----------------------------------------------------------------------PROCEDURE DE SCANNER D'UN HEXADECIMAL
; Le résultat est socké dans la variable AL
; Code hexa touche entrée = F0H
; Sinon la valeur de la touche est entrée

	SCANHEX PROC NEAR
		ASSUME CS:CODE,DS:DONNEE,SS:PILE
		
		_eti_getch: 													;on définit l'étiquette "getch" (obtenir un caractère saisit au clavier)
			MOV	        AH,8 											;l'interruption 21 est utilisée pour l'aquisition d'un caractère sans echo // réécriture
			INT	        21H
			CMP	        AL,13 											;Comparer AL et la valeur du retour chariot
			JNE	        _eti_num										;Saut à l'adresse indiquée si non-égalité : soit AL <> 13
			;Sinon si AL=13 :
			MOV	        AL,0F0h 										;AL prend pour valeur F0H (la touche entrée)
			JMP	        _eti_out										;sortir de la fonction
			
		_eti_num: 														;On définit l'etiquette _eti_num
			CMP	        AL,'0' 											;On compare AL au code ascii '0'
			JB	        _eti_getch										;Si AL<0 on demande de resaisie (JB :Saut à l'adresse indiquée si CF=1)
			;Si AL>=0					
			CMP	        AL,'9' 											;On compare AL au code ascii '9'
			JA	        _eti_alpha_maj									;Si AL>9, alors c'est un texte majuscule (JA = Saut à l'adresse indiquée si CF=0)
			;Sinon si AL est compris dans l'intervalle [0,9]
			SUB	        AL,'0'											;AL prend la valeur AL-0
			JMP	        _eti_out										;on sort de la fonction		
			
		_eti_alpha_maj: 												;On définit l'étiquette pour l'alphabet majuscule
			CMP	        AL,'A' 											;On compare AL au code ascii de A
			JB	        _eti_getch										;Si AL<A on demande la resaisie
			;Si AL>=A					
			CMP	        AL,'F' 											;On compare AL au code ascii de F
			JA	        _eti_alpha										;Si AL>F alors le texte est en minuscule
			;Sinon si AL est compris dans l'intervalle [A,F]
			SUB     	AL,'A'-10										;AL prends la valeur AL +10 - 'A'
			JMP	        _eti_out										;on sort de la fonction	
		
		_eti_alpha: 													;On définit l'étiquette pour l'alphabet (min)
			CMP	        AL,'a' 											;On compare Al au code ascii de 'a'
			JB	        _eti_getch										;Si AL<a alors on demande une resaisie
			;Si AL>=a					
			CMP	        AL,'f' 											;On compare Al au code ascii de 'f'
			JA	        _eti_getch										;Si AL>f alors on demande une resaisie
			;Sinon si AL est compris dans l'intervalle [a,f]
			SUB	        AL,'a'-10										;AL prend la valeur AL + 10 - 'a'
			JMP	        _eti_out	
			
		_eti_out: 
			RET 														;Arrêt de la procédure
	SCANHEX ENDP 
	
;-----------------------------------------------------------------------
;Stockage du résultat de la fonction dans BX
;Utilise AX via la fonction SCANHEX
	SCANINT PROC NEAR
		PUSH		AX													;Sauvegarde le registre d'AX dans la pile
		PUSH		CX													;Sauvegarde le registre de CX dans la pile
		PUSH		DX													;Sauvegarde le registre de DX dans la pile	
			MOV	BX,0 													;On initialise le registre BX à 0
			MOV	CH,4													;Mettre la partie haute du registre CX à 4
		_si_SCANHEX: 													;On définit les instructions pour l'étiquette _si_SCANHEX
			CALL		SCANHEX 										;On appelle la procédure SCANHEX
			CMP 		AL,0F0h  										;On compare la partie basse du registre AX à la valeur qui définit le retour chariot
			JE 			_si_out   										;Si la condition précédente est réalisée, on effection l'étiquette _si_out
			;Ajout d'AL dans BX
			MOV	        CL,4 											;La partie basse du registre prends la valeur 4
			SAL         BX,CL											;On effectue un décalage à gauche de 4 bits
		    ADD         BL,AL 											;On ajoute la valeur décalée à BL
			;Affichage de la lettre correspondante :
			PUSH	    BX 												;On sauvegarde le registre BX
			LEA		    BX,_ascii 										;BX "pointe" le début du tableau ascii
			XLAT 														;/!\ Cette fonction assure la conversion ascii decimal
				MOV		    DL,AL 										;Ici on utilise l'interruption 2 pour afficher uniquement un caractère
				MOV		    AH,2  
				INT		    21H    										;Interruption
			POP	        BX 												;On récupère la valeur de BX déjà stockée
			;On définit les conditions de la boucle
			DEC         CH												;CH = CH-1 (décrémentation)
			CMP         CH,0 											;on compare CH avec 0
			JNE         _si_SCANHEX 									;Si la condition n'est pas égale, on éxecute l'étiquette _si_scanHex
		_si_out: 														;On définit l'étiquette _si_out // si scan out
			POP         DX 												;On récupère les valeurs des registres DX, CX et AX
			POP         CX		
			POP         AX
			RET															;On stoppe là
	SCANINT ENDP
	
	;Entrée dans DX
	PRINTINT PROC NEAR
			PUSH        AX 												;On sauvegarde le contenu des registres AX, BX, CX et DX
			PUSH        BX
			PUSH        CX
			PUSH        DX
			PUSH        DX
		
			LEA         BX,_ascii 										;BX pointe sur le début du tableau _ascii
			MOV         CH,0 											;On affecte 0 pour à la partie haute du registre CX
		
		_pi_prINT_byte:													;On définit l'étiquette
			MOV         AL,DH  											;AL prends la valeur de DH
			MOV         CL,4   											;On définit dans CL le nombre de bits à décaler
			shr         AL,CL 											;On effectue un décalage à droite par le nombre CL
			XLAT      													;On réalise on conversion décimale ascii
			;XLAT permet de remplacer le contenu du registre AL par un octet de la «tablesource».
				MOV         DL,AL 										;On utilise la fonction 2 pour l'affichage d'un seul caractère
				MOV         AH,2   
				INT         21H
			MOV         AL,DH 
		    AND         AL,0fh
			XLAT
				MOV         DL,AL
				MOV         AH,2
				INT         21H
			
			CMP         CH,0 											;On compare CH avec 0
			JNZ         _pi_fin											;Cette ligne permet de continuer l'exécution à l'emplacement mémoire _pi_fin
			
			POP         DX
			MOV         DH,DL
			INC         CH 												;INC = incrémenter	
			JMP         _pi_prINT_byte
		
		_pi_fin:
			POP         DX
			POP         CX
			POP         BX
			POP         AX
			RET
	PRINTINT ENDP

;-----------------------------------------------------------------------PROGRAMME ADDITION	

	PROG_ADDITION PROC NEAR
		PUSH        AX 													;Sauvegarder les valeurs des registres AX, BX, CX, DX, dans la pile
		PUSH        BX
		PUSH        CX
		PUSH        DX

		;Le nombre 1 est stocké dans CX
		LEA 		DX,_qn1  											;On utilise l'interruption 9 pour afficher le message _qn1
		MOV 		AH,9
		INT 		21H
		CALL 		SCANINT 											;On fait appel a la fonction SCANINT
		MOV 		CX,BX    											;On écrit la valeur de sortie de SCANINT dans BX
		CALL 		RETURN    											;On effectue un appel de la fonction retoutr ligne

		;Le nombre 2 est stocké dans DX
		LEA 		DX,_qn2  											;On utilise l'interruption 9 pour afficher le message _qn2
		MOV 		AH,9
		INT 		21H
		CALL 		SCANINT  											;On appele la fonction SCANINT qui lit les nombres entrés par le clavier
		CALL 		RETURN     											;On applique un retour a la ligne

		;Affichage résultat et "traitement"
		LEA 		DX,_r_add  											;On affiche le résultat de l'addition avec l'interuption 9
		MOV 		AH,9 
		INT 		21H
		
		MOV 		DX,0  												;On intialise le registre DX à 0     
		ADD 		CX,BX 												;On fait la somme de nombres déja saisis par le clavier par la commande add
		ADC 		DX,0  												;ADC = Addition avec le carry flag : donc ici on ajoute le carry 
		CALL 		PRINTINT 											;On fait appel à la fonction PRINTINT pour afficher la resultat
		MOV 		DX,CX     
		CALL 		PRINTINT 											;On fait appel à la fonction  PRINTINT pour afficher le résultat
		CALL 		RETURN
		
		POP 		DX 													;On récupère les valeurs des registres DX,CX,BX et AX
		POP 		CX
		POP 		BX
		POP 		AX
		RET
	PROG_ADDITION ENDP

;-----------------------------------------------------------------------PROGRAMME SOUSTRACTION
	
	PROG_SOUSTRACTION PROC NEAR
		PUSH 	AX  													;Sauvegarder les valeurs des registres AX, BX, CX, DX, dans la pile
		PUSH 	BX
		PUSH	CX
		PUSH 	DX
		
		;Le nombre 1 est stocké dans CX
			LEA 	DX,_qn1 											;On utilise l'interruption 9 pour afficher le message _qn1
			MOV 	AH,9
			INT 	21H
			CALL 	SCANINT 											;On fait appel a la fonction SCANINT
			MOV 	CX,BX    											;On écrit la valeur de sortie de SCANINT dans CX
			CALL 	RETURN    											;On effectue un appel de la fonction retour à la ligne
	
		;Le nombre 2 est stocké dans BX
			LEA 	DX,_qn2 											;On utilise l'interruption 9 pour afficher le message _qn2
			MOV 	AH,9
			INT 	21H
			CALL 	SCANINT 											;On appele la fonction SCANINT qui lit les nombres entrés par le clavier
			CALL 	RETURN    											;On applique un retour a la ligne
			
		;Affichage résultat et "traitement"
			LEA 	DX,_r_sub 											;On affiche le message _r_sub
			MOV 	AH,9
			INT 	21H
			MOV 	DX,0   												;On initialise le registre DX a 0
			SUB 	CX,BX  												;On soustrait BX de CX et le resultat se trouvera dans CX
			JNS 	_ps_jumpOver 										;JNS = JUMP IF NOT SIGN

		;En cas de résultat négatif
			MOV 	DL,'-' 												;On affiche un seul caractère grâce à l'interruption 2
			MOV 	AH,2   
			INT 	21H
			NEG 	CX 													;On effectue un complément à 2 à la variable CX
		_ps_jumpOver: 
			MOV 	DX,CX 												;On stocke le contenu de cx dans dx pour pouvoir l'afficher à l'aide de PRINTINT
			CALL 	PRINTINT
			CALL 	RETURN												;Toujours le retour à la ligne, je ne l'idiquerai plus par la suite :))
		
		POP 	DX 														;On récupère de la pile les valeurs des registres DX,CX,BX et AX 
		POP 	CX
		POP 	BX
		POP 	AX
		RET
	PROG_SOUSTRACTION ENDP
		
;-----------------------------------------------------------------------PROGRAMME MULTIPLICATION

	PROG_MULTIPLICATION PROC NEAR
		;La source de la multiplication est : dx:ax = ax * sourcee
		PUSH	 AX 													;On sauvegarde les valeurs des registres AX,BX,CX et DX
		PUSH 	BX
		PUSH 	CX
		PUSH 	DX
		
		;Le nombre 1 est stocké dans CX
			LEA 	DX,_qn1 											;On affiche le premier message de saisie via la fonction 9
			MOV 	AH,9
			INT 	21H
			CALL 	SCANINT 											;On appelle la fonction SCANINT pour afficher le résultat
			MOV 	CX,BX    											;On stocke la valeur saisie dans le registre CX
			CALL 	RETURN 

		;Le 2e nombre est stocké dans DX
			LEA 	DX,_qn2 											;On utilise l'interruption 9 pour afficher le message _qn2
			MOV 	AH,9
			INT 	21H
			CALL	SCANINT 											;On utlise la procédure SCANINT pour la 2e valeur
			CALL 	RETURN    ;faire un retour ligne

		;Affichage résultat et "traitement"
			LEA 	DX,_r_mul 											;On affiche le message _r_mul
			MOV 	AH,9
			INT 	21H
			MOV 	AX,CX 												;On écrit le contenu de CX dans AX
			MUL 	BX    												;mul bx <=>  dx:ax = ax * bx
			CALL	PRINTINT 											;On appelle la fonction PRINTINT pour afficher le resultat
			MOV 	DX,AX 												;On stocke le resultat dans ax pour pouvoir l'afficher ensuite
			CALL	PRINTINT
			CALL 	RETURN
		
		POP 	DX 														;On récupère les valeurs des registres DX,CX,BX et AX 
		POP 	CX
		POP 	BX
		POP 	AX
		RET
	PROG_MULTIPLICATION ENDP
	
;-----------------------------------------------------------------------PROGRAMME DIVISION

	PROG_DIVISION PROC NEAR
		;DIV SRC -> DX:AX / SRC >> q = AX , r = DX
		PUSH 	AX 													;On sauvegarde les valeurs des registres AX, BX, CX et DX
		PUSH 	BX
		PUSH 	CX
		PUSH 	DX
		
		;Le 1e nombre est stocké dans CX
			LEA 	DX,_qn1 												;On affiche le message _r_div avec l'interruption 9
			MOV 	AH,9
			INT 	21H
			CALL 	SCANINT 												;Saisie de la 1ere valeur 
			MOV 	CX,BX    												;On sauvegarde la valeur saisie dans cx
			CALL 	RETURN 
		;Le 2e nombre est stocké dans DX
			LEA 	DX,_qn2 												;Saisie de la 2e valeur 
			MOV 	AH,9
            ;MOV    AH,9
			INT 	21H
			CALL 	SCANINT 
            CMP     DX,0                                                  ;On compare DX à 0
			CALL 	RETURN
		;Affichage résultat et "traitement"
			LEA 	DX,_r_div 												;On affiche le message _r_div avec l'interruption 9
			MOV 	AH,9
			INT 	21H
			
			MOV 	DX,0  													;On initalise DX à 0 
			MOV 	AX,CX 													;AX prend la valeur de CX
			DIV 	BX 														;Division de bx <=> DX:AX / bx >> q = AX , r = DX
			MOV 	DX,AX 													;On stocke le résultat de la division dans DX
			CALL 	PRINTINT 												;On utilise PRINTINT pour afficher le résultat
			CALL 	RETURN 
		
		POP 	DX  														;On récupère les valeurs des registres DX,CX,BX et AX 
		POP 	CX
		POP 	BX
		POP 	AX
		RET
	PROG_DIVISION ENDP
	
;-----------------------------------------------------------------------PROGRAMME PRINCIPAL
	
	PROG PROC NEAR
		ASSUME CS:code,DS:DONNEE,SS:pile
		; Initialisation
			MOV	        AX,DONNEE 										;On initialise le segment DONNEE
			MOV	        DS,AX
			
			;Ici, on s'occupe de l'affichage de l'entête,
				MOV AH,9
				LEA DX,_title_1
				INT 21H
				CALL RETURN
			;	LEA DX,_title_2
			;	INT 21H
			;	CALL RETURN
			;	LEA DX,_title_3
			;	INT 21H
			;	LEA DX,_title_4
			;	INT 21H
			;	LEA DX,_title_5
			;	INT 21H
			;	LEA DX,_title_6
			;	INT 21H
			
		;Ici, c'est l'affichage du menu qui est concerné
		_p_menu:;afichage du menu			
				MOV         AH,9
				LEA         DX,_menu
				INT         21H
			;On choisit l'opération a effectuer :
				MOV         AH,1 										;Ici : 1 car on ne demande qu'un seul caracère qui est un nombre
				INT         21H
				CALL        RETURN
			;Puis on teste la selection pour vérifier que l'utilisateur n'entre pas n'importe quoi ._.
		_p_addition:
				CMP         AL,'1'										;Si le nombre entré est > 1
				JNE         _p_soustraction								;On va à l'étiquette du menu suivante
				CALL        PROG_ADDITION								;Sinon, on lance le programme d'addition
				JMP         _p_repeat									;Une fois terminé, on demande si on souhaite recommencer la boucle pour effectuer de nouveau un calcul
		_p_soustraction:
				CMP         AL,'2'										;Si le nombre entré est > 2
				JNE         _p_multiplication							;On va à l'étiquette du menu suivante
				CALL        PROG_SOUSTRACTION							;Sinon, on lance le programme de soustraction
				JMP         _p_repeat									;Une fois terminé, on demande si on souhaite recommencer la boucle pour effectuer de nouveau un calcul
		_p_multiplication:
				CMP         AL,'3'										;Si le nombre entré est > 3
				JNE         _p_division									;On va à l'étiquette du menu suivante
				CALL        PROG_MULTIPLICATION							;Sinon, on lance le programme de multiplication
				JMP         _p_repeat									;Une fois terminé, on demande si on souhaite recommencer la boucle pour effectuer de nouveau un calcul
		_p_division:
				CMP 		AL,'4'										;Si le nombre entré est > 4
				JNE 		_p_menu										;On retourne au menu : plus d'opérations après ça
				CALL 		PROG_DIVISION								;Sinon, on lance le programme de division
				JMP 		_p_repeat									;Une fois terminé, on demande si on souhaite recommencer la boucle pour effectuer de nouveau un calcul
	
		_p_repeat:
			MOV         AH,9
			LEA         DX, _QUIT
			INT         21H
			;Saisie d'une réponse
			MOV         AH,1
			INT         21H
			CALL        RETURN
			;Traitement de la réponse
			CMP         AL,'n'
			JE          _P_MENU
			CMP         AL,'o'
			JNE         _P_REPEAT
		
		_p_end:
			MOV			AX,4C00H ;Retour au dos
			INT			21H
	PROG  	ENDP
CODE ENDS
END PROG