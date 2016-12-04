*=$0801
; BASIC runnable stub, handy snippet!
	.word ss,2005
	.null $9e,^init;will be sys 4096
	ss	.word 0 
init  	LDX #$00
; Clear the screen
 -      LDA #$20 
	STA $0400,x
        STA $0500,x
        STA $0600,x
        STA $0700,x
 ;  Clear colour memory
        LDA #$01
        STA $D900,x
        STA $DA00,x
        STA $DB00,x
        STA $DBE0,x
        INX
        BNE -
 	SEI 
 	LDA $DC0D
 	LDA $DD0D
        JSR $1000 ; init music
      	LDA #$1F
        STA $DC0D    ;CIA1: CIA Interrupt Control Register
       	STA $DD0D    ;CIA2: CIA Interrupt Control Register
        LDA #$1B
        STA $D011    ;VIC Control Register 1
	LDA #$01
        STA $D01A    ;VIC Interrupt Mask Register (IMR)
	LDA #$06
	STA $D020    ;Border Color
	LDA #$00
        STA $D021    ;Background Color 0
        LDA #$00
        STA $D012    ;Raster Position
        LDA #<start
        STA $FFFE    ;IRQ
        LDA #>start
        STA $FFFF    ;IRQ
        LDX #<nmi
        LDY #>nmi
        STX $FFFA    ;NMI
        STY $FFFB    ;NMI
        LDA #$35
        LDX #$FF
        STA $01
 	TXS 
        INC $D019    ;VIC Interrupt Request Register (IRR)
       	LDA $DC0D    ;CIA1: CIA Interrupt Control Register
        LDA $DD0D    ;CIA2: CIA Interrupt Control Register
        CLI 
-	JMP -



start   STA nexta+1
        STX nextx+1
        STY nexty+1
        LDA #$00
        STA $D020
        STA $D021
 	JSR $1003
 	JSR scroller
        LDA #$1B
        STA $D011    ;VIC Control Register 1
        LDX #<next
        LDY #>next
        LDA #$32
        STX $FFFE    ;IRQ
        STY $FFFF    ;IRQ
        STA $D012    ;Raster Position
        INC $D019    ;VIC Interrupt Request Register (IRR)
nexta        LDA #$00
nextx        LDX #$00
nexty        LDY #$00
 nmi       RTI 
 
 next STA nexta1+1
 	STX nextx1+1
 	STY nexty1+1
  	LDA xpos ; store the current xpos in $D016
 	STA $D016
 	LDA #$00
 	STA $D021
 	STA $D020
  	LDX #<start
 	LDY #>start
 	LDA #$00
 	STX $FFFE
 	STY $FFFF
 	STA $D012
 	INC $D019
 nexta1 LDA #$00
 nextx1 LDX #$00
 nexty1 LDY #$00
 	RTI
 	
scroller   LDA xpos
        CLC 
	SBC speed ; Subtract speed from xpos
	BCC +
	STA xpos	; if carry set (value is minus) then reset to zero
        RTS 

+	AND #$07 ; Make sure the value is between 0 and 7
        STA xpos
	LDX #$00
;  Scroll the first line of the screen
-	LDA $0401,x
	STA $0400,x
	INX
	CPX #$27
	BNE -
        LDA gettext+1
        CLC 
        ADC #$01	; add one to the gettext location
        STA gettext+1
        BCC gettext
        INC gettext+2
gettext	LDA scrolltext
        BNE +	; If a zero is detected in the scrolltext, loop
        LDX #<scrolltext
        LDY #>scrolltext
        STX gettext+1
        STY gettext+2
        JMP gettext	
 + 	STA $0427
 	RTS
 xpos .byte 0
 speed .byte 2
scrolltext 
.enc screen 
.text "     welcome to this simple 1x1 scroller, your next challenge is to create a 1x2 scroller!!!   stay tuned....   "
.byte 0
*=$1000
 .binary "music.prg",2