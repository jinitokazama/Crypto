; Jin Byoun
; TCSS 371
; This program encrypts a string of words using an encryption algorithm and cypherkey and also decrypts messages using a decryption algorithm and cypherkey

    .ORIG x3000;
        LD   R3, NEGENTER    ; Load value of -x0A
        LD   R4, DECIDER     ; Load value of -D

; Prompt for encryption or decryption
	LEA R0, PROMPT       
        PUTS                 ; Prints prompt
	GETC                 ; Gets character to encrypt or decrypt
        OUT
        STI  R0, DECISION    ; Store E or D in x3100

; Prompt for key
        LEA R0, KEY          
        PUTS                 ; Prints key prompt
        GETC                 ; Gets key from user
        OUT                  
        STI  R0, CYPHERKEY   ; Store Key in x3101

; Prompt for message input 
        LEA R0, MESSAGEPROMPT    
        PUTS                 ; Prints message prompt
        LD R1, INPUT         ; R1 holds value at x3102
USERIN  GETC
        OUT
        ADD R2, R0, R3       ; Check for end of line
        BRz DECIDE           ; If end of line finish inputting to now encrypt or decrypt
	STR R0, R1, #0       ; Store the input value
        ADD R1, R1, #1       ; Increment the memory pointer
        BR USERIN            ; Keep repeating until a enter is spotted

; Decide whether to encrypt or decrypt based off value in address x3100
DECIDE  LDI  R5, DECISION    ; Load in value of E or D
        ADD R5, R5, R4       ; Add ascii value, if zero encrypt, if positive decrypt
        BRz DEC              ; Go Encrypt
        BRp ENC              ; Go Decrypt

; Encrypt
ENC	LD  R1, INPUT        ; Load in address of INPUT String
	LD  R3, RESULT       ; Load in value of result message
	LD  R4, VALUE        ; Load in -48 to add to ascii value
ENC2    LDR R2, R1, #0       ; Load in next character of INPUT String
        BRz PRINT            ; If end of line, print out results
 	JSR TOGGLE           ; Toggle bits for encryption
        LDI  R6, CYPHERKEY   ; Load in value of key
        ADD R6, R6, R4       ; Add in zero ascii to get number value
        ADD R2, R2, R6       ; Add to move over ascii value
        STR R2, R3, #0       ; Store value at memory address
        ADD R1, R1, #1       ; Increment memory pointer for input
        ADD R3, R3, #1       ; Increment memory pointer for Result
        BR ENC2	             ; Loop until done

; Decrypt
DEC	LD R1, INPUT         ; Load in address of string message
	LD R3, RESULT        ; Load in address of empty result message at first
	LD R4, VALUE         ; Load in -48 to add to ascii value
DEC2    LDR R2, R1, #0       ; Load in next character
        BRz PRINT            ; If end of line, print out results
	LDI  R6, CYPHERKEY   ; Load in value of key
        ADD R6, R6, R4       ; Add in zero ascii to get number value
	NOT R6, R6           ; Find negative
	ADD R6, R6, #1       ; find negative
        ADD R2, R2, R6       ; Subtract
	JSR TOGGLE           ; Toggle bits for encryption
	STR R2, R3, #0       ; Store value at memory address
        ADD R1, R1, #1       ; Increment memory pointer for input
        ADD R3, R3, #1       ; Increment memory pointer for Result
        BR DEC2	             ; Loop until done

; Toggle Bits routine
TOGGLE  AND R5, R2, #1       ; Toggle lowest order bit, determine if it is 1 or 0  to toggle
        BRp MINUS1           ; Toggle to 0 if lowest order bit is 1
        BRz PLUS1            ; Toggle to 1 if lowest order bit is 0
	
MINUS1  ADD R2, R2, #-1
        RET

PLUS1   ADD R2, R2, #1
        RET

; Prints the new message stored at x3117
PRINT  	LD R0, RESULT
        PUTS	 
        HALT    

VALUE          .FILL #-48     ; -48 to get true number value from ascii
DECIDER        .FILL #-68     ; -68 or -D
NEGENTER       .FILL xFFF6    ; -xOA or negative enter

PROMPT         .STRINGZ "Type (E)ncrypt/(D)ecrypt: "
KEY            .STRINGZ "\nEnter encryption key(1-9): "
MESSAGEPROMPT  .STRINGZ "\nEnter message (20 char limit): "

DECISION       .FILL x3100
CYPHERKEY      .FILL x3101
INPUT          .FILL x3102
RESULT	       .FILL x3117      
    .END

