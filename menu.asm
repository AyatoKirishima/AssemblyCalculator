;-----------------------------------------------------------------------
;	Projet D'Assembleur
;	BAGGIO-KOST Franck
;	MULLER Léane
;-----------------------------------------------------------------------
; "Programme MAIN"
;-----------------------------------------------------------------------
PILE SEGMENT PARA STACK 'PILE'
        DW 512 DUP(00)                                                  ;DW = Allocates and optionally initializes a word (2 bytes) of storage for each initializer. Can also be used as a type specifier anywhere a type is legal. DW is a synonym of WORD.
PILE  ENDS

DONNEE SEGMENT															;Partie affichage
	_main_menu			DB	    ' 1: Decimal',10,' 2: Hexadecimal ',10,' Taper le numero de votre operation: $'
	_nope				DB		'nope'
	%INCL
	;INCLUDE double.asm
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


	PROG_MAIN PROC NEAR
		ASSUME CS:code,DS:DONNEE,SS:pile
		; Initialisation
			MOV	        AX,DONNEE 										;On initialise le segment DONNEE
			MOV	        DS,AX
		;Ici, c'est l'affichage du menu qui est concerné
		_p_main_menu:;afichage du menu			
				MOV         AH,9
				LEA         DX,_main_menu
				INT         21H
			;On choisit l'opération a effectuer :
				MOV         AH,1 										;Ici : 1 car on ne demande qu'un seul caracère qui est un nombre
				INT         21H
				CALL        RETURN
			;Puis on teste la selection pour vérifier que l'utilisateur n'entre pas n'importe quoi ._.
		_p_decimal:
				CMP         AL,'1'										;Si le nombre entré est > 1
				JNE         _p_hexadecimal
				;%INCL							            ;On va à l'étiquette du menu suivante
				;INCLUDE double.asm
				;INCLUDE     D:\Projet assembleur\double.asm
				MOV     AH,9
				LEA     DX, _nope
				INT     21h
		_p_hexadecimal:
				CMP         AL,'2'										;Si le nombre entré est > 2
				JNE         _p_main_menu                						;On va à l'étiquette du menu suivante
				;CALL        PROG_HEXA							;Sinon, on lance le programme de soustraction
	
		_p_end:
			MOV			AX,4C00H ;Retour au dos
			INT			21H
	PROG_MAIN  	ENDP
CODE ENDS
END PROG_MAIN