
	.export		NMI_main
	.import		drv_main
	
	.import		__cc
	.import		__ss
	.import		__mm
	.import		__hh


.segment	"LOWCODE"
;===============================================================
;			nmi_main(void);
;---------------------------------------------------------------
;	Summary :		NMI main Routine
;	Arguments :		None
;	Return :		None
;	Modifies :		None
;	Useage :		Please write this address to interrupt vector
;---------------------------------------------------------------
;	《メモ》
;	・NMI割り込みは、PPU関連の操作を先にやる
;	　PPUへのアクセスは、垂直同期帰還中にしかできないため。
;	・キーの読み込みも、NMI割り込みで行う。
;	　キー読み込み中に音源ドライバーが割り込むと、キー読み込みに失敗するため。
;===============================================================
.proc	NMI_main

;---------------------------------------
;register push
;---------------------------------------
	pha
	tya
	pha
	txa
	pha

;---------------------------------------
; Call sound driver main routine
;---------------------------------------

	;---------------
	;サウンドドライバ呼出し

	jsr	drv_main

;---------------------------------------
; Count-up
;---------------------------------------
Count:
@cc:
	inc	__cc
	lda	__cc
	cmp	#60
	bne	@exit
	lda	#0
	sta	__cc

@ss:
	ldx	__ss
	cpx	#$59
	beq	@ss_1
	inx
	stx	__ss
	txa
	and	#$0F
	cmp	#$0A
	bne	@exit
	txa
	clc
	adc	#6
	sta	__ss
	bne	@exit
@ss_1:
	lda	#0
	sta	__ss

@mm:
	ldx	__mm
	cpx	#$59
	beq	@mm_1
	inx
	stx	__mm
	txa
	and	#$0F
	cmp	#$0A
	bne	@exit
	txa
	clc
	adc	#6
	sta	__mm
	bne	@exit
@mm_1:
	lda	#0
	sta	__mm

@hh:
	inc	__hh

@exit:

;---------------------------------------
;register pop
;---------------------------------------
	pla
	tax
	pla
	tay
	pla

	rti
.endproc
