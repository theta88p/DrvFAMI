.importzp	Frags
.import		IsProc
.import		Device
.import		Octave
.import		NoteN
.import		Volume
.import		Tone
.import		Freq_L
.import		Freq_H
.import		PrevFreq_L
.import		PrevFreq_H
.import		palette
.import		__mm
.import		__ss
.import		__cc

.export 	dsp_init
.export 	dsp_main
.export		sync

.include 	"drv.inc"


.zeropage

sync:			.res	1
DspWork:		.res	4

.bss

PAFreq_L:		.res	3
PAFreq_H:		.res	3
PANote:			.res	3	;エンベロープ適用後ノートナンバー（DSP用）
PAOctave:		.res	3	;エンベロープ適用後オクターブ（DSP用）

DMA = $0700

CH1 = 0
CH2 = CH1 + 28
CH3 = CH2 + 28
CH4 = CH3 + 24
CH5 = CH4 + 16
TIME = CH5 + 12

CH1KEY		=	DMA + 0
CH1VOL1		=	DMA + 4
CH1VOL2		=	DMA + 8
CH1DUTY		=	DMA + 12
CH1OCT		=	DMA + 16
CH1NOTE		=	DMA + 20
CH1SHARP	=	DMA + 24

CH2KEY		=	DMA + CH2 + 0
CH2VOL1		=	DMA + CH2 + 4
CH2VOL2		=	DMA + CH2 + 8
CH2DUTY		=	DMA + CH2 + 12
CH2OCT		=	DMA + CH2 + 16
CH2NOTE		=	DMA + CH2 + 20
CH2SHARP	=	DMA + CH2 + 24

CH3KEY		=	DMA + CH3 + 0
CH3VOL1		=	DMA + CH3 + 4
CH3VOL2		=	DMA + CH3 + 8
CH3OCT		=	DMA + CH3 + 12
CH3NOTE		=	DMA + CH3 + 16
CH3SHARP	=	DMA + CH3 + 20

CH4KEY		=	DMA + CH4 + 0
CH4VOL1		=	DMA + CH4 + 4
CH4VOL2		=	DMA + CH4 + 8
CH4TONE		=	DMA + CH4 + 12

CH5KEY		=	DMA + CH5 + 0
CH5VOL1		=	DMA + CH5 + 4
CH5VOL2		=	DMA + CH5 + 8

TIMEMM1		=	DMA + TIME + 0
TIMEMM2		=	DMA + TIME + 4
TIMESS1		=	DMA + TIME + 8
TIMESS2		=	DMA + TIME + 12
TIMECC1		=	DMA + TIME + 16
TIMECC2		=	DMA + TIME + 20

YPOS1 = $2F
YPOS2 = $4F
YPOS3 = $6F
YPOS4 = $8F
YPOS5 = $A7

TIME_XPOS = $98
TIME_YPOS = $18

.code

.proc dsp_main
	start:
		;時間表示
		lda #10
		sta DspWork
		lda __cc
		jsr rem
		adc #$30
		sta TIMECC2 + 1
		tya
		adc #$30
		sta TIMECC1 + 1
		lda __cc
		bne ch01				;0になった（繰り上がった）時だけ書き換える
		lda __ss
		jsr rem
		adc #$30
		sta TIMESS2 + 1
		tya
		adc #$30
		sta TIMESS1 + 1
		lda __ss
		bne ch01
		lda __mm
		jsr rem
		clc
		adc #$30
		sta TIMEMM2 + 1
		tya
		adc #$30
		sta TIMEMM1 + 1
	;----------------ch1----------------
	ch01:
		lda #0
		sta DspWork
		jsr gettrack
		cmp #1
		beq @exec
		jmp ch02
	@exec:
		lda Frags, x
		and #FRAG_SIL
		beq @keyon
		lda #$ff
		sta CH1KEY + 0
		lda #$88
		sta CH1VOL1 + 3
		lda #$90
		sta CH1VOL2 + 3
		jmp ch02
	;発音中の場合
	@keyon:
		lda PAFreq_H + 0
		cmp Freq_H, x
		bne @f2n
		lda PAFreq_L + 0
		cmp Freq_L, x
		bne @f2n
		lda PAOctave + 0
		sta DspWork + 2
		lda PANote + 0
		sta DspWork + 3
		jmp @note
	@f2n:
		jsr freq2note
		lda DspWork + 2
		sta PAOctave + 0
		lda DspWork + 3
		sta PANote + 0
		lda Freq_L, x
		sta PAFreq_L + 0
		lda Freq_H, x
		sta PAFreq_H + 0
	@note:
		lda DspWork + 3
		tay
		lda halftone, y
		bne @half
		lda #$ff
		sta CH1SHARP + 0			;シャープ記号
		lda DspWork + 3
		cmp #4
		beq @sqr
		cmp #11
		beq @sqr
		lda #$5d
		jmp @write
	@sqr:
		lda #$5c
	@write:
		sta CH1KEY + 1			;ハイライト鍵盤の形
		jmp @pos
	@half:
		lda #$5e
		sta CH1KEY + 1			;ハイライト鍵盤の形
		lda #YPOS1 + 8
		sta CH1SHARP + 0		;シャープ記号
	;鍵盤の位置計算
	@pos:
		lda #0
		ldy DspWork + 2
	@L:
		clc
		adc #21
		dey
		bne @L
		adc #$30
		ldy DspWork + 3
		adc posmap, y
		sta CH1KEY + 3			;ハイライト鍵盤の位置
		lda #YPOS1 + 16
		sta CH1KEY + 0
	;音量バー
	;@volume:
		lda Volume, x
		cmp #15
		bcc @next1
		lda #$ff
		sta CH1VOL1 + 0
		jmp @spr2
	@next1:
		clc
		lda Volume, x
		adc #$88
		sta CH1VOL1 + 3		;音量バー隠しのスプライト位置1
		lda #YPOS1
		sta CH1VOL1 + 0
	@spr2:
		lda Volume, x
		cmp #9
		bcc @next2
		lda #$ff
		sta CH1VOL2 + 0
		jmp @duty
	@next2:
		lda Volume, x
		clc
		adc #$90
		sta CH1VOL2 + 3		;音量バー隠しのスプライト位置2
		lda #YPOS1
		sta CH1VOL2 + 0
	;Duty
	@duty:
		lda Tone, x
		clc
		adc #$2b
		sta CH1DUTY + 1		;Duty比のスプライト形状
	;ノートナンバー表示
	;@notenum:
		lda DspWork + 2
		clc
		adc #$30
		sta CH1OCT + 1		;オクターブ番号
		lda charmap, y
		sta CH1NOTE + 1		;音名

	;----------------ch2----------------
	ch02:
		lda #1
		sta DspWork
		jsr gettrack
		cmp #1
		beq @exec
		jmp ch03
	@exec:
		lda Frags, x
		and #FRAG_SIL
		beq @keyon
		lda #$ff
		sta CH2KEY + 0
		lda #$88
		sta CH2VOL1 + 3
		lda #$90
		sta CH2VOL2 + 3
		jmp ch03
	;発音中の場合
	@keyon:
		lda PAFreq_H + 1
		cmp Freq_H, x
		bne @f2n
		lda PAFreq_L + 1
		cmp Freq_L, x
		bne @f2n
		lda PAOctave + 1
		sta DspWork + 2
		lda PANote + 1
		sta DspWork + 3
		jmp @note
	@f2n:
		jsr freq2note
		lda DspWork + 2
		sta PAOctave + 1
		lda DspWork + 3
		sta PANote + 1
		lda Freq_L, x
		sta PAFreq_L + 1
		lda Freq_H, x
		sta PAFreq_H + 1
	@note:
		lda DspWork + 3
		tay
		lda halftone, y
		bne @half
		lda #$ff
		sta CH2SHARP + 0			;シャープ記号
		lda DspWork + 3
		cmp #4
		beq @sqr
		cmp #11
		beq @sqr
		lda #$5d
		jmp @write
	@sqr:
		lda #$5c
	@write:
		sta CH2KEY + 1			;ハイライト鍵盤の形
		jmp @pos
	@half:
		lda #$5e
		sta CH2KEY + 1			;ハイライト鍵盤の形
		lda #YPOS2 + 8
		sta CH1SHARP + 0		;シャープ記号
	;鍵盤の位置計算
	@pos:
		lda #0
		ldy DspWork + 2
	@L:
		clc
		adc #21
		dey
		bne @L
		adc #$30
		ldy DspWork + 3
		adc posmap, y
		sta CH2KEY + 3			;ハイライト鍵盤の位置
		lda #YPOS2 + 16
		sta CH2KEY + 0
	;音量バー
	;@volume:
		lda Volume, x
		cmp #15
		bcc @next1
		lda #$ff
		sta CH2VOL1 + 0
		jmp @spr2
	@next1:
		clc
		lda Volume, x
		adc #$88
		sta CH2VOL1 + 3		;音量バー隠しのスプライト位置1
		lda #YPOS2
		sta CH2VOL1 + 0
	@spr2:
		lda Volume, x
		cmp #9
		bcc @next2
		lda #$ff
		sta CH2VOL2 + 0
		jmp @duty
	@next2:
		lda Volume, x
		clc
		adc #$90
		sta CH2VOL2 + 3		;音量バー隠しのスプライト位置2
		lda #YPOS2
		sta CH2VOL2 + 0
	;Duty
	@duty:
		lda Tone, x
		clc
		adc #$2b
		sta CH2DUTY + 1		;Duty比のスプライト形状
	;ノートナンバー表示
	;@notenum:
		lda DspWork + 2
		clc
		adc #$30
		sta CH2OCT + 1		;オクターブ番号
		lda charmap, y
		sta CH2NOTE + 1		;音名

	;----------------ch3----------------
	ch03:
		lda #2
		sta DspWork
		jsr gettrack
		cmp #1
		beq @exec
		jmp ch04
	@exec:
		lda Frags, x
		and #FRAG_SIL
		beq @keyon
		lda #$ff
		sta CH3KEY + 0
		lda #YPOS3
		sta CH3VOL1 + 0
		sta CH3VOL2 + 0
		jmp ch04
	;発音中の場合
	@keyon:
		lda PAFreq_H + 2
		cmp Freq_H, x
		bne @f2n
		lda PAFreq_L + 2
		cmp Freq_L, x
		bne @f2n
		lda PAOctave + 2
		sta DspWork + 2
		lda PANote + 2
		sta DspWork + 3
		jmp @note
	@f2n:
		jsr freq2note
		lda DspWork + 2
		sta PAOctave + 2
		lda DspWork + 3
		sta PANote + 2
		lda Freq_L, x
		sta PAFreq_L + 2
		lda Freq_H, x
		sta PAFreq_H + 2
	@note:
		lda DspWork + 3
		tay
		lda halftone, y
		bne @half
		lda #$ff
		sta CH3SHARP + 0			;シャープ記号
		lda DspWork + 3
		cmp #4
		beq @sqr
		cmp #11
		beq @sqr
		lda #$5d
		jmp @write
	@sqr:
		lda #$5c
	@write:
		sta CH3KEY + 1			;ハイライト鍵盤の形
		jmp @pos
	@half:
		lda #$5e
		sta CH3KEY + 1			;ハイライト鍵盤の形
		lda #YPOS3 + 8
		sta CH1SHARP + 0		;シャープ記号
	;鍵盤の位置計算
	@pos:
		lda #0
		ldy DspWork + 2
		dey						;三角波は1オクターブ低く表示
	@L:
		clc
		adc #21
		dey
		bne @L
		adc #$30
		ldy DspWork + 3
		adc posmap, y
		sta CH3KEY + 3			;ハイライト鍵盤の位置
		lda #YPOS3 + 16
		sta CH3KEY + 0
	;音量バー
	;@volume:
		lda #$ff
		sta CH3VOL1 + 0
		sta CH3VOL2 + 0
	;ノートナンバー表示
	@notenum:
		lda DspWork + 2
		clc
		adc #$2f			;三角波は1オクターブ低く表示
		sta CH3OCT + 1		;オクターブ番号
		lda charmap, y
		sta CH3NOTE + 1		;音名

	;----------------ch4----------------
	ch04:
		lda #3
		sta DspWork
		jsr gettrack
		cmp #1
		beq @exec
		jmp ch05
	@exec:
		lda Frags, x
		and #FRAG_SIL
		beq @keyon
		lda #YPOS4
		sta CH4VOL1 + 0
		sta CH4VOL2 + 0
		lda #$ff
		sta CH4KEY + 0
		jmp ch05
	;発音中の場合
	@keyon:
		lda #YPOS4 + 8
		sta CH4KEY + 0			;ハイライト鍵盤を表示
	;鍵盤の位置計算
	@pos:
		lda #$0f
		sec
		sbc NoteN, x
		sta DspWork
		lda #0
		ldy #8
	@L:
		clc
		adc DspWork
		dey
		bne @L
		adc #$58
		sta CH4KEY + 3			;ハイライト鍵盤の位置
	;音量バー
	;@volume:
		lda Volume, x
		cmp #15
		bcc @next1
		lda #$ff
		sta CH4VOL1 + 0
		jmp @spr2
	@next1:
		clc
		lda Volume, x
		adc #$60
		sta CH4VOL1 + 3		;音量バー隠しのスプライト位置1
		lda #YPOS4
		sta CH4VOL1 + 0
	@spr2:
		lda Volume, x
		cmp #9
		bcc @next2
		lda #$ff
		sta CH4VOL2 + 0
		jmp @tone
	@next2:
		lda Volume, x
		clc
		adc #$68
		sta CH4VOL2 + 3		;音量バー隠しのスプライト位置2
		lda #YPOS4
		sta CH4VOL2 + 0
	;音色
	@tone:
		lda Tone, x
		bne @p
		lda #$43
		sta CH4TONE + 1
		jmp ch05
	@p:
		lda #$45
		sta CH4TONE + 1
	
	;----------------ch5----------------
	ch05:
		lda #4
		sta DspWork
		jsr gettrack
		cmp #1
		beq @exec
		jmp end
	@exec:
		lda $4015
		and #%00010000					;DPCM再生bitを直接読む
		bne @keyon
		lda #YPOS5
		sta CH5VOL1 + 0
		sta CH5VOL2 + 0
		lda #$ff
		sta CH5KEY + 0
		jmp end
	;発音中の場合
	@keyon:
		lda #YPOS5 + 8
		sta CH5KEY + 0				;ハイライト鍵盤を表示
	;鍵盤の位置計算
	@pos:
		lda #$0f
		sec
		sbc NoteN, x
		sta DspWork
		lda #0
		ldy #8
	@L:
		clc
		adc DspWork
		dey
		bne @L
		adc #$58
		sta CH5KEY + 3				;ハイライト鍵盤の位置
		lda #$ff
		sta CH5VOL1 + 0				;音量バー隠しのスプライト非表示1
		sta CH5VOL2 + 0				;音量バー隠しのスプライト非表示2
	end:
		rts
.endproc

;DspWorkに音源番号を入れて実行すると
;アクティブな音源があるかどうかを調べて
;aに結果、xにトラック番号を入れて返す
.proc gettrack
		ldx #0
	@L:
		lda Device, x
		cmp DspWork
		beq @N
		bcs false			;目的の番号より大きくなったら打ち切る
		inx
		jmp @M
	@N:
		lda Frags, x
		and #FRAG_END | FRAG_WRITE_DIS
		beq true
		inx
	@M:
		cpx #MAX_TRACK
		bcc @L
		jmp false
	true:
		lda #1
		rts
	false:
		lda #0
		rts
.endproc


.proc dsp_init
		;描画停止
		lda #$80
		sta $2000
		lda #$06
		sta $2001
		;転送先OAMアドレスに0を設定
		lda #$00
		sta $2003
		;スプライトDMAの初期化
		lda #$00
		ldx #$00
	init:
		sta DMA, x
		dex
		bne init
		;スプライト転送
		lda #$07
		sta $4014
		;BG描画
		lda #$20
		sta $2006
		lda #$00
		sta $2006
		ldx #$80
	black1:
		sta $2007
		dex
		bne black1
		lda #$0a
		ldx #$20
	border1:
		sta $2007
		dex
		bne border1
		lda #$02
		ldx #$60
		ldy #$03
	blue:
		sta $2007
		dex
		bne blue
		dey
		bne blue
		lda #$03
		ldx #$20
	border2:
		sta $2007
		dex
		bne border2
		lda #$00
		ldx #$a0
	black2:
		sta $2007
		dex
		bne black2
		;FCDSP
		lda #$20
		sta $2006
		lda #$66
		sta $2006
		ldx #$04
	fcdsp:
		stx $2007
		inx
		cpx #$0a
		bcc fcdsp
		;:
		lda #$20
		sta $2006
		lda #$75
		sta $2006
		lda #$3a
		sta $2007
		lda #$20
		sta $2006
		lda #$78
		sta $2006
		lda #$3a
		sta $2007
		;ch01
		lda #$20
		sta $2006
		lda #$c6
		sta $2006
		ldx #$0b
	@L1:
		stx $2007
		inx
		cpx #$0e
		bcc @L1
		jsr pulse
		lda #$20
		sta $2006
		lda #$e6
		sta $2006
		lda #$44
		sta $2007
		lda #$21
		sta $2006
		lda #$06
		sta $2006
		jsr key
		;ch02
		lda #$21
		sta $2006
		lda #$46
		sta $2006
		lda #$0b
		sta $2007
		lda #$0e
		sta $2007
		lda #$0f
		sta $2007
		jsr pulse
		lda #$21
		sta $2006
		lda #$66
		sta $2006
		lda #$44
		sta $2007
		lda #$21
		sta $2006
		lda #$86
		sta $2006
		jsr key
		;ch03
		lda #$21
		sta $2006
		lda #$c6
		sta $2006
		lda #$0b
		sta $2007
		lda #$10
		sta $2007
		lda #$11
		sta $2007
		lda #$02
		sta $2007
		ldx #$1a
	@L2:
		stx $2007
		inx
		cpx #$20
		bcc @L2
		lda #$28
		sta $2007
		lda #$29
		sta $2007
		sta $2007
		lda #$21
		sta $2006
		lda #$e6
		sta $2006
		lda #$44
		sta $2007
		lda #$22
		sta $2006
		lda #$06
		sta $2006
		jsr key
		;ch04
		lda #$22
		sta $2006
		lda #$46
		sta $2006
		lda #$0b
		sta $2007
		lda #$12
		sta $2007
		lda #$13
		sta $2007
		lda #$02
		sta $2007
		sta $2007
		lda #$28
		sta $2007
		lda #$29
		sta $2007
		sta $2007
		lda #$22
		sta $2006
		lda #$66
		sta $2006
		ldx #$20
	@L3:
		stx $2007
		inx
		cpx #$24
		bcc @L3
		lda #$02
		sta $2007
		lda #$5b
		ldx #$10
	@L4:
		sta $2007
		dex
		bne @L4
		;ch05
		lda #$22
		sta $2006
		lda #$a6
		sta $2006
		lda #$0b
		sta $2007
		lda #$14
		sta $2007
		lda #$15
		sta $2007
		lda #$02
		sta $2007
		sta $2007
		lda #$28
		sta $2007
		lda #$29
		sta $2007
		sta $2007
		lda #$22
		sta $2006
		lda #$c6
		sta $2006
		ldx #$24
	@L5:
		stx $2007
		inx
		cpx #$28
		bcc @L5
		lda #$02
		sta $2007
		lda #$5b
		ldx #$10
	@L6:
		sta $2007
		dex
		bne @L6

		;パレット設定
		lda #$3f
		sta $2006
		lda #$00
		sta $2006
		ldx #$00
	pal:
		lda palette, x
		sta $2007
		inx
		cpx #$20
		bcc pal
		;属性設定
		lda #$23
		sta $2006
		lda #$c0
		sta $2006
		lda #$55
		ldx #8
	attr:
		sta $2007
		dex
		bne attr
		lda #$00
		ldx #$18
	@L1:
		sta $2007
		dex
		bne @L1
		
		ldx #2
		lda #$00
		sta $2007
		sta $2007
		lda #$80
		sta $2007
		lda #$a0
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		lda #$00
		sta $2007

		lda #$00
		sta $2007
		sta $2007
		lda #$88
		sta $2007
		lda #$aa
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		lda #$00
		sta $2007
		
		lda #$00
		ldx #$08
	@L3:
		sta $2007
		dex
		bne @L3
		;スプライト
	sprite:
		;非表示にするもの
		lda #$ff
		sta CH1KEY + 0
		sta CH1SHARP + 0
		sta CH2KEY + 0
		sta CH2SHARP + 0
		sta CH3KEY + 0
		sta CH3SHARP + 0
		sta CH4KEY + 0
		sta CH5KEY + 0

		;ch1
		lda #YPOS1
		sta CH1VOL1 + 0
		sta CH1VOL2 + 0
		sta CH1DUTY + 0
		
		lda #YPOS1 + 8
		sta CH1OCT + 0
		sta CH1NOTE + 0
		
		lda #$02
		sta CH1VOL1 + 1
		sta CH1VOL2 + 1
		
		lda #$30
		sta CH1OCT + 1
		lda #$3e
		sta CH1NOTE + 1
		lda #$3b
		sta CH1SHARP + 1
		
		lda #$01
		sta CH1DUTY + 2
		sta CH1OCT + 2
		sta CH1NOTE + 2
		sta CH1SHARP + 2

		lda #$88
		sta CH1VOL1 + 3
		lda #$90
		sta CH1VOL2 + 3
		
		lda #$a8
		sta CH1DUTY + 3
		lda #$37
		sta CH1OCT + 3
		lda #$3f
		sta CH1NOTE + 3
		lda #$47
		sta CH1SHARP + 3
		
		;ch2
		lda #YPOS2
		sta CH2VOL1 + 0
		sta CH2VOL2 + 0
		sta CH2DUTY + 0
		
		lda #YPOS2 + 8
		sta CH2OCT + 0
		sta CH2NOTE + 0
		
		lda #$02
		sta CH2VOL1 + 1
		sta CH2VOL2 + 1
		
		lda #$30
		sta CH2OCT + 1
		lda #$3e
		sta CH2NOTE + 1
		lda #$3b
		sta CH2SHARP + 1
		
		lda #$01
		sta CH2DUTY + 2
		sta CH2OCT + 2
		sta CH2NOTE + 2
		sta CH2SHARP + 2

		lda #$88
		sta CH2VOL1 + 3
		lda #$90
		sta CH2VOL2 + 3
		
		lda #$a8
		sta CH2DUTY + 3
		lda #$37
		sta CH2OCT + 3
		lda #$3f
		sta CH2NOTE + 3
		lda #$47
		sta CH2SHARP + 3
		
		;ch3
		lda #YPOS3
		sta CH3VOL1 + 0
		sta CH3VOL2 + 0
		
		lda #YPOS3 + 8
		sta CH3OCT + 0
		sta CH3NOTE + 0
		
		lda #$02
		sta CH3VOL1 + 1
		sta CH3VOL2 + 1
		
		lda #$30
		sta CH3OCT + 1
		lda #$3e
		sta CH3NOTE + 1
		lda #$3b
		sta CH3SHARP + 1
		
		lda #$01
		sta CH3OCT + 2
		sta CH3NOTE + 2
		sta CH3SHARP + 2

		lda #$88
		sta CH3VOL1 + 3
		lda #$90
		sta CH3VOL2 + 3
		
		lda #$37
		sta CH3OCT + 3
		lda #$3f
		sta CH3NOTE + 3
		lda #$47
		sta CH3SHARP + 3

		;ch4
		lda #YPOS4
		sta CH4VOL1 + 0
		sta CH4VOL2 + 0
		sta CH4TONE + 0
		
		lda #$5f
		sta CH4KEY + 1
		lda #$02
		sta CH4VOL1 + 1
		sta CH4VOL2 + 1
		
		lda #$01
		sta CH4TONE + 2
		
		lda #$60
		sta CH4VOL1 + 3
		lda #$68
		sta CH4VOL2 + 3
		lda #$78
		sta CH4TONE + 3
		
		;ch5
		lda #YPOS5
		sta CH5VOL1 + 0
		sta CH5VOL2 + 0
		
		lda #$5f
		sta CH5KEY + 1
		lda #$02
		sta CH5VOL1 + 1
		sta CH5VOL2 + 1
		
		lda #$60
		sta CH5VOL1 + 3
		lda #$68
		sta CH5VOL2 + 3
		
		;Time
		lda #TIME_YPOS
		sta TIMEMM1 + 0
		sta TIMEMM2 + 0
		sta TIMESS1 + 0
		sta TIMESS2 + 0
		sta TIMECC1 + 0
		sta TIMECC2 + 0
		lda #$30
		sta TIMEMM1 + 1
		sta TIMEMM2 + 1
		sta TIMESS1 + 1
		sta TIMESS2 + 1
		sta TIMECC1 + 1
		sta TIMECC2 + 1
		lda #$01
		sta TIMEMM1 + 2
		sta TIMEMM2 + 2
		sta TIMESS1 + 2
		sta TIMESS2 + 2
		sta TIMECC1 + 2
		sta TIMECC2 + 2
		
		lda #TIME_XPOS + 0
		sta TIMEMM1 + 3
		lda #TIME_XPOS + 8
		sta TIMEMM2 + 3
		lda #TIME_XPOS + 24
		sta TIMESS1 + 3
		lda #TIME_XPOS + 32
		sta TIMESS2 + 3
		lda #TIME_XPOS + 48
		sta TIMECC1 + 3
		lda #TIME_XPOS + 56
		sta TIMECC2 + 3
		
		;スプライト転送
		lda #$07
		sta $4014
		;スクロール値の設定
		lda #$00
		sta $2005
		lda #$00
		sta $2005
		;描画開始
		lda #$80
		sta $2000
		lda #$1e
		sta $2001
	rts
.endproc

.proc pulse
		lda #$02
		sta $2007
		ldx #$16
	@L2:
		stx $2007
		inx
		cpx #$1a
		bcc @L2
		lda #$02
		sta $2007
		sta $2007
		lda #$28
		sta $2007
		lda #$29
		sta $2007
		sta $2007
		lda #$02
		sta $2007
		lda #$2a
		sta $2007
		rts
.endproc

.proc key
		ldx #$46
	@L:
		stx $2007
		inx
		cpx #$5b
		bcc @L
		rts
.endproc

;a % DspWork
.proc rem
		ldy #0
	@L:
		cmp DspWork
		bcc end
		sec
		sbc DspWork
		iny
		jmp @L
	end:
		rts
.endproc


.proc freq2note
		lda Freq_H, x
		bne start
		lda Freq_L, x
		bne start
		rts
	start:
		ldy #0
		lda #0
		lda Freq_L, x
		sta DspWork
		lda Freq_H, x
		sta DspWork + 1
		bne @L
		lda DspWork
		cmp #$0b					;オクターブ9以上はo8b固定
		bcc @o9
		cmp #$1b					;オクターブ8以上は別処理
		bcc @o8
		jmp @L
	@o9:
		lda #8
		sta DspWork + 2
		lda #$0d
		sta DspWork + 3
		rts
	@o8:
		lda #8
		sta DspWork + 2
		lda DspWork
		sec
		sbc #$0d
		tay
		lda Freq_Note_H, y
		sta DspWork + 3
		rts
	@L:
		lda DspWork + 1
		bne @E
		lda DspWork
		cmp #$35				;レジスタ値が$34(52)より小さくなるまでオクターブを上げる
		bcs @E
		jmp next
	@E:
		lsr DspWork + 1
		ror DspWork
		iny
		jmp @L
	next:
		sty DspWork + 2			;7-上げた数がオクターブ
		lda #7
		sec
		sbc DspWork + 2
		sta DspWork + 2
		lda DspWork
		sec
		sbc #$1b				;レジスタ値1b(27)がo8bなのでそれを0とする
		tay
		lda Freq_Note, y
		sta DspWork + 3
		rts
.endproc

.rodata
;ノートナンバーを位置に変換するテーブル
posmap:
	.byte	$00, $01, $03, $04, $06, $09, $0A, $0C, $0D, $0F, $10, $12

;ノートナンバーを文字に変換するテーブル
charmap:
	.byte	$3E, $3E, $3F, $3F, $40, $41, $41, $42, $42, $3C, $3C, $3D

;半音判別用のテーブル
halftone:
	.byte	0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0

;逆引きテーブル
;o7b~07cまでのレジスタ値から音階を引ける
Freq_Note:
	.byte	$0b, $0a, $0a, $09, $09, $08, $08, $07, $07, $06, $06, $06, $05, $05, $04, $04
	.byte	$03, $03, $03, $02, $02, $01, $01, $01, $00, $00, $00, $00

Freq_Note_H:
	.byte	$0b, $0a, $09, $08, $07, $06, $05, $04
	.byte	$04, $03, $02, $02, $01, $00, $00, $00
