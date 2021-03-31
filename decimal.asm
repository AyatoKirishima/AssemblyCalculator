;-----------------------------------------------------------------------
; Partie en décimal
;-----------------------------------------------------------------------

PILE_D SEGMENT PARA STACK 'PILE_D'
        DW 512 DUP(00)                                                  ;DW = Allocates and optionally initializes a word (2 bytes) of storage for each initializer. Can also be used as a type specifier anywhere a type is legal. DW is a synonym of WORD.
PILE_D  ENDS


DONNEE_D segment
    _title_1_D		DB	'Calculatrice format decimal' ,10,'$'
;	_title_2		DB	'title',10,'$'
;	_title_3		DB	'title',10,'$'
;	_title_4		DB	'title',10,'$'
;	_title_5		DB	'title',10,'$'
	_menu_D			DB	' 1:(+) 2:(-) 3:(x) 4:(/)',10,' Entrez le numero de votre operation: $'
	
	_qn1D			DB  	'   n1 = $'
	_qn2D			DB  	'   n2 = $'
	_r_addD			DB  	'   n1 + n2 = $'
	_r_subD			DB  	'   n1 - n2 = $'
	_r_mulD			DB  	'   n1 x n2 = $'
	_r_divD			DB  	'   n1 / n2 = $'
	_q_dz			DB	    'Erreur : Division par zero$'
	_fished			DB		10,'			  ___======____=---=)',10,'			/T            \_--===)',10,'			L \ (@)   \~    \_-==)',10,'			  \      / )J≈    \-=)',10,'			  \\___/  )JJ≈    \)',10,'			   \_____/JJJ≈      \',10,'			  / \  , \J≈≈      \',10,'			  (-\)\=|  \≈~        L__',10,'			  (\\)  ( -\)_            ==__',10,'			   \V    \-\) ===_____  J\   \\',10,'  			       \V)     \_) \   JJ J\)',10,'			                      /J JT\JJJJ)',10,'			                      (JJJ| \UUU)',10,'			                      (UU)	',10,'				              ___',10,'				You got fished !			',10							

	
	_quit_D			DB	    '  > Quitter (o/n)? $'
	ok		        DB 	    13
	del		        DB	    8
	delete	        DB	    8,' ',8,'$'

	_title_1		DB	    'Calculatrice format hexadecimal',10,'$'
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
DONNEE_D ENDS


CODE_D segment 
RETURN_D PROC FAR
		PUSH    AX
		PUSH    DX
		MOV     DL,10
		MOV     AH,2
		INT     21H
		POP     DX
		POP     AX
		RET
RETURN_D ENDP
SCANINT_D	PROC FAR ;Procédure de lecture de caractère + vérification caractère entré
	;output DI
	ASSUME CS:CODE_D,DS:DONNEE_D, SS:PILE_D
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		
		MOV     DI,0
		MOV     CX,4
		SIread_char:
			MOV     AH,8
			INT     21H
			
			CMP     AL,del
			JE      SIaction_del
			CMP     AL,ok
			JE      SIaction_ok
			CMP     CX,0
			JE      SIread_char
			CMP     AL,'0'
			JB      SIread_char
			CMP     AL,'9'
			JA      SIread_char
			MOV     DL,AL
			MOV     AH,2
			INT     21H
			SUB     AL,'0'
			;DI=number  AL=DIgit
			MOV     bl,AL	;bl=DIgit
			MOV     AX,10	
			MUL     DI		;DX:AX=DI x 10
			ADD     AL,BL	;AX = AX + DIgit
			MOV     DI,AX
			;DI=number
			DEC     CX
			
		JMP SIread_char
		
	SIaction_del:
		CMP     CX,4
		JNB     SIread_char
		LEA     DX,delete
		MOV     ah,9
		INT     21H
		;DI=number
		MOV     DX,0
		MOV     AX,DI
		MOV     BX,10
		DIV     BX		;DX:AX DIV BX => AX (MOD => DX)
		MOV     DI,AX	;DI <= DI DIv 10
		
		INC     CX
		JMP     SIread_char
	
	SIaction_ok:
		CMP     CX,4
		JNE     SIfin
		MOV     DL,'0'
		MOV     AH,2
		INT     21H	
		
	SIfin:
		POP     DX
		POP     CX
		POP     BX
		POP     AX
		RET
SCANINT_D	ENDP

PRINTINT16	PROC FAR
	;input DI
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		
		MOV     CX,0
		MOV     AX,DI
		MOV     BX,10
		
	PI16calc_DIgits:
		MOV     DX,0
		DIV     BX
		PUSH    DX
		INC     CX
		CMP     AX,0
		JNE     PI16calc_DIgits
	
	PI16aff_DIgits:
		POP     DX
		ADD     DL,'0'
		MOV     AH,2
		INT     21H
		LOOP    PI16aff_DIgits
		
		POP     DX
		POP     CX
		POP     BX
		POP     AX
		RET
PRINTINT16 ENDP ;Tout ce qui est affichage (notamment au niveau des résultats)
;16bits : ADDITION SOUSTRACTION DIVISION
PRINTINT32	PROC FAR
	PUSH    AX
	PUSH    BX
	PUSH    CX
	PUSH    DX
	PUSH    SI
	PUSH    DI
	;input SI:DI
		MOV     DX,SI
		MOV     AX,DI
		MOV     BX, 10000
		DIV     BX ;=> 4 DIgits bas=DX ;; 4hauts=AX
		
		MOV     SI,AX	;save the hi party
		MOV     AX,DX	;load the low in AX
		
		MOV     CX,0
		MOV     BX,10
	;sur bas
	PI32bas:
		MOV     DX,0
		DIv     BX
		PUSH    DX
		INC     CX
		;while  AX!0 ou (si!0 et CX<4)
		CMP     AX,0
		JNE     PI32bas
		CMP     CX,4
		jae     _PI32haut
		CMP     SI,0
		JNE     PI32bas
	
	_PI32haut:
		MOV     AX,si
		PI32haut:
			CMP     AX,0
			JE      PI32aff
			MOV     DX,0
			DIV     BX
			PUSH    DX
			INC     CX
			JMP     PI32haut
	
	PI32aff:
		POP     DX
		add     DL,'0'
		MOV     AH,2
		INT     21H
		LOOP    PI32aff
	POP     DI
	POP     SI
	POP     DX
	POP     CX
	POP     BX
	POP     AX
	RET
PRINTINT32 ENDP ;32 bits : Multiplication 
PROG_ADDITION_D PROC FAR
		PUSH    AX
		PUSH    DX
		PUSH    SI
		PUSH    DI
	
        ;Le nombre 1 est stocké dans SI
		LEA 		DX,_qn1D  											;On utilise l'interruption 9 pour afficher le message _qn1D
		MOV 		AH,9
		INT 		21H
		CALL        SCANINT_D
		MOV         SI,DI
        CALL        RETURN_D

		;Le nombre 2 est stocké dans DI
		LEA 		DX,_qn2D  											;On utilise l'interruption 9 pour afficher le message _qn2D
		MOV 		AH,9
		INT 		21H
		CALL        SCANINT_D 
        CALL        RETURN_D
	;result	  
		LEA         DX,_r_addD
        MOV         AH,9
        INT         21H
        ADD         DI,SI
		CALL        PRINTINT16
		CALL        RETURN_D
		
		POP     DI
		POP     SI
		POP     DX
		POP     AX
		RET
PROG_ADDITION_D ENDP

PROG_SOUSTRACTION_D PROC FAR
		PUSH    AX
		PUSH    DX
		PUSH    SI
		PUSH    DI
    ;Le nombre 1 est stocké dans SI
			LEA 	DX,_qn1D											;On utilise l'interruption 9 pour afficher le message _qn1
			MOV 	AH,9
			INT 	21H
			CALL    SCANINT_D
    		MOV     si,DI    										
			CALL 	RETURN_D    											;On effectue un appel de la fonction retour à la ligne
	
		;Le nombre 2 est stocké dans DI
			LEA 	DX,_qn2D 											;On utilise l'interruption 9 pour afficher le message _qn2
			MOV 	AH,9
			INT 	21H
			CALL    SCANINT_D 											
			CALL 	RETURN_D    
    ;resultat
        LEA         DX,_r_subD
        MOV         AH,9
        INT         21H
		SUB         SI,DI
		JNS         _ps_jumpOver
		;resultat negatif
			MOV     DL,'-' 
			MOV     AH,2   
			INT     21H
			NEG     SI
		_ps_jumpOver: 
			MOV     DI,SI
			CALL    PRINTINT16
			CALL    RETURN_D
		
		POP     DI
		POP     SI
		POP     DX
		POP     AX
		RET
PROG_SOUSTRACTION_D ENDP

PROG_MULTIPLICATION_D PROC FAR
		;mul source ->>  DX:AX = AX * source
		PUSH    AX
		PUSH    DX
		PUSH    SI
		PUSH    DI	

    ;Le nombre 1 est stocké dans CX
			LEA 	DX,_qn1D											;On affiche le premier message de saisie via la fonction 9
			MOV 	AH,9
			INT 	21H
			CALL 	SCANINT_D 											;On appelle la fonction SCANINT pour afficher le résultat
			MOV 	SI,DI   											;On stocke la valeur saisie dans le registre CX
			CALL 	RETURN_D

		;Le 2e nombre est stocké dans DX
			LEA 	DX,_qn2D											;On utilise l'interruption 9 pour afficher le message _qn2
			MOV 	AH,9
			INT 	21H
			CALL	SCANINT_D 											;On utlise la procédure SCANINT pour la 2e valeur
			CALL 	RETURN_D                                            ;faire un retour à la ligne

	;resultat
        LEA     DX,_r_mulD
        MOV     AH,9
        INT     21H
		MOV     AX,SI
		MUL     DI ;=> DX:AX = AX * DI
		MOV     SI,DX
		MOV     DI,AX
		CALL    PRINTINT32
		CALL    RETURN_D
		
		POP     DI
		POP     SI
		POP     DX
		POP     AX
		RET
PROG_MULTIPLICATION_D ENDP

PROG_DIVISION_D PROC FAR
	PUSH    AX
	PUSH    CX
	PUSH    DX
	PUSH    DI
	PUSH    SI	
        
        ;Le 1e nombre est stocké dans SI
			LEA 	DX,_qn1D 												;On affiche le message _r_div avec l'interruption 9
			MOV 	AH,9
			INT 	21H
			CALL    SCANINT_D
    		MOV     SI,DI
            CALL    RETURN_D
		;Le 2e nombre est stocké dans DI
			LEA 	DX,_qn2D 												;Saisie de la 2e valeur 
			MOV 	AH,9
			INT 	21H
            CALL    SCANINT_D
            CALL    RETURN_D
        ;Affichage du résultat
            LEA     DX,_r_divD
            MOV     AH,9
            INT     21H

	;DIv by zero
		CMP     DI,0
		JNE     PDIv_overDIvZero
		LEA     DX,_q_dz
		MOV     AH,9
		INT 	21H
		LEA 	DX,_fished
		MOV		AH,9
		INT     21h
		JMP     PDIv_fin
	Pdiv_overdivZero: ;calcul des résultats
		MOV     DX,0
		MOV     AX,SI
		DIV     DI ;DIV DI ->> DX:AX / DI >> q = AX , r = DX
		MOV     SI,DI
		MOV     DI,AX
		CALL    PRINTINT16
		;partie après la virgule
		CMP     DX,0
		JE      PDIv_fin
		;CALL    RETURN_D

		PUSH    DX
		MOV     DL,'.'
		MOV     AH,2
		INT     21h
		POP     DX
		
		MOV CX,2
		PDIV_vir:
			MOV     AX,10
			MUL     DX
			DIV     SI
			MOV     DI,AX
			CALL    PRINTINT16
			LOOP    PDIV_vir
	
	PDIv_fin:
		CALL    RETURN_D
		POP     SI
		POP     DI
		POP     DX
		POP     CX
		POP     AX
		RET
PROG_DIVISION_D ENDP

PROG_D    PROC FAR
        ASSUME CS:CODE_D;ds:DONNEE_D;ss:PILE_D
        MOV     AX,DONNEE_D
        MOV     DS,AX
		
		;affichage de l'entete
				MOV     AH,9
				LEA     DX,_title_1_D
				INT     21H
                CALL    RETURN_D
;				LEA DX,_title_2
;				INT 21h
;				LEA DX,_title_3
;				INT 21h
;				LEA DX,_title_4
;				INT 21h
;				LEA DX,_title_5
;				INT 21h
			
		_p_menu_D:;afichage du menu			
				MOV     AH,9
				LEA     DX,_menu_D
				INT     21h
			;choix
				MOV     AH,1
				INT     21h
				CALL    RETURN_D
			;test selection
		_p_addition_D:
				CMP     AL,'1'
				JNE     _p_soustraction_D
				CALL    PROG_ADDITION_D
				JMP     _p_repeat_D
		_p_soustraction_D:
				CMP     AL,'2'
				JNE     _p_multiplication_D
				CALL    PROG_SOUSTRACTION_D
				JMP     _p_repeat_D
		_p_multiplication_D:
				CMP     AL,'3'
				JNE     _p_division_D
				CALL    PROG_MULTIPLICATION_D
				JMP     _p_repeat_D
		_p_division_D:
				CMP     AL,'4'
				JNE     _p_menu_D
				CALL    PROG_DIVISION_D
				JMP     _p_repeat_D
	
		_p_repeat_D:
			MOV     AH,9
			LEA     DX, _quit_D
			INT     21h
			;saisie d'une reponse
			MOV     AH,1
			INT     21h
			CALL    RETURN_D
			;traitement
			CMP     AL,'n'
			JE      _p_menu_D
			CMP     AL,'o'
			JNE     _p_repeat_D
		
		_p_end_D:
			MOV	    AX,4c00h ;Retour au dos
			INT	    21H
		
PROG_D  ENDP
CODE_D ENDS
END  PROG_D