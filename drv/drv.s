.exportzp	Frags
.export		DrvFrags
.export		Device
.export		Octave
.export		NoteN
.export		Volume
.export		Tone
.export		Freq_L
.export		Freq_H
.export		drv_main
.export		drv_init
.export		drv_sndreq

.include	"drv.inc"

;-----------------------------------------------------------------------
; Zeropage works
;-----------------------------------------------------------------------
.zeropage

Frags:			.res	MAX_TRACK	;通常のフラグ
EnvFrags:		.res	MAX_TRACK	;エンベロープのフラグ
LenCtr:			.res	MAX_TRACK	;音長カウンタ
GateCtr:		.res	MAX_TRACK	;ゲートカウンター
Work:			.res	4

;-----------------------------------------------------------------------
; Non Zeropage works
;-----------------------------------------------------------------------
.bss

Device:			.res	MAX_TRACK	;トラックで使用している音源
Ptr_L:			.res	MAX_TRACK	;再生箇所のアドレスL
Ptr_H:			.res	MAX_TRACK	;再生箇所のアドレスH
Octave:			.res	MAX_TRACK	;オクターブ
NoteN:			.res	MAX_TRACK	;ノートナンバー
DefLen:			.res	MAX_TRACK	;デフォルト音長
Length:			.res	MAX_TRACK	;音長
Gate:			.res	MAX_TRACK	;上位2bit 使用中のゲートコマンド 下位5bit ゲートコマンドの値
TrVolume:		.res	MAX_TRACK	;トラック音量
Volume:			.res	MAX_TRACK	;音量
Tone:			.res	MAX_TRACK	;音色
Freq_L:			.res	MAX_TRACK	;周波数L
Freq_H:			.res	MAX_TRACK	;周波数H
RefFreq_L:		.res	MAX_TRACK	;音程エンベロープ値を加算する前の周波数L
RefFreq_H:		.res	MAX_TRACK	;音程エンベロープ値を加算する前の周波数H
RefNoteN:		.res	MAX_TRACK	;ノートエンベロープ値を加算する前のノートナンバー
RefTone:		.res	MAX_TRACK	;音色エンベロープ値を加算する前の音色
PrevFreq_L:		.res	MAX_TRACK	;前回レジスタに書き込んだ周波数L（音源ごとに保存）
PrevFreq_H:		.res	MAX_TRACK	;前回レジスタに書き込んだ周波数H（音源ごとに保存）
KeyShift:		.res	MAX_TRACK	;キーシフト値
Detune:			.res	MAX_TRACK	;デチューン値
InfLoopAddr_L:	.res	MAX_TRACK	;無限ループの戻り先L
InfLoopAddr_H:	.res	MAX_TRACK	;無限ループの戻り先H
SSwpEnd:		.res	MAX_TRACK	;ソフトウェアスイープの終了音程（+-半音単位）
SSwpDelay:		.res	MAX_TRACK	;ソフトウェアスイープのディレイ
SSwpDepth:		.res	MAX_TRACK	;ソフトウェアスイープの一回に加算する値
SSwpRate:		.res	MAX_TRACK	;ソフトウェアスイープで何フレームおきに加算するか
SSwpEndFreq_L:	.res	MAX_TRACK	;ソフトウェアスイープの終了周波数L
SSwpEndFreq_H:	.res	MAX_TRACK	;ソフトウェアスイープの終了周波数H
SSwpCtr:		.res	MAX_TRACK	;ソフトウェアスイープのカウンタ
VEnvAddr_L:		.res	MAX_TRACK	;音量エンベロープのアドレスL
VEnvAddr_H:		.res	MAX_TRACK	;音量エンベロープのアドレスH
VEnvPos:		.res	MAX_TRACK	;音量エンベロープの現在位置
VEnvCtr:		.res	MAX_TRACK	;音量エンベロープのカウンタ
VEnvDelay:		.res	MAX_TRACK	;音量エンベロープのディレイ
FEnvAddr_L:		.res	MAX_TRACK	;音程エンベロープ以下省略
FEnvAddr_H:		.res	MAX_TRACK
FEnvPos:		.res	MAX_TRACK
FEnvCtr:		.res	MAX_TRACK
FEnvDelay:		.res	MAX_TRACK
NEnvAddr_L:		.res	MAX_TRACK	;ノートエンベロープ
NEnvAddr_H:		.res	MAX_TRACK
NEnvPos:		.res	MAX_TRACK
NEnvCtr:		.res	MAX_TRACK
NEnvDelay:		.res	MAX_TRACK
TEnvAddr_L:		.res	MAX_TRACK	;音色エンベロープ
TEnvAddr_H:		.res	MAX_TRACK
TEnvPos:		.res	MAX_TRACK
TEnvCtr:		.res	MAX_TRACK
TEnvDelay:		.res	MAX_TRACK
HSwpReg:		.res	MAX_TRACK	;ハードウェアスイープレジスタに書き込む値
HEnvReg:		.res	MAX_TRACK	;ハードウェアエンベロープレジスタに書き込む値
LoopDepth:		.res	MAX_TRACK	;ループ深度

LoopN:		.res	MAX_TRACK * MAX_LOOP	;残りループ回数
LoopAddr_L:	.res	MAX_TRACK * MAX_LOOP	;ループの戻り先L
LoopAddr_H:	.res	MAX_TRACK * MAX_LOOP	;ループの戻り先H

DrvFrags:		.res	1	;ドライバ全体のフラグ
SpdCtr:			.res	1	;速度カウンタ
SpdFreq:		.res	1	;速度カウンタに加算する値
ProcTr:			.res	1	;処理中のトラック
SeqAddr_L:		.res	1	;シーケンス情報のアドレスL
SeqAddr_H:		.res	1	;シーケンス情報のアドレスH
.ifdef SS5B
SS5BTone:		.res	3
SS5BHWEnv:		.res	3	;ハードウェアエンベロープが有効なら1無効なら0
.endif

;00～6b	:o0c～o8b	音長デフォ
;6c	:r		休符（音長デフォ）
;6d	:[x		ループ開始
;6e	:]		ループ終了
;6f	::		ループ途中終了
;70	:qx		ゲートタイム（音長-nの方式。他と排他）
;70	:ux		ゲートタイム（音長nの方式。他と排他）
;70	:Qx		ゲートタイム（音長n/8の方式。他と排他）
;73	:kx		キーシフト相対指定
;74	:Kx		キーシフト絶対指定
;75	:&		次の音がタイ・スラーになる
;76	:@x		音色指定
;77	:tx		フレームスキップ値。コンパイラでテンポから計算
;78 :@p		指定した曲番号のデータを再生
;79	:@vx	音量エンベロープ指定（外部定義）
;7a :@v*	音量エンベロープ停止
;7b	:@fx	音程エンベロープ指定（外部定義）
;7c :@f*	音程エンベロープ停止
;7d	:@nx	ノートエンベロープ指定（外部定義）
;7e :@n*	ノートエンベロープ停止
;7f	:		トラック終了
;80～eb	:o0c～o8b	音長指定
;ec	:r		休符（音長指定）
;ed :L		無限ループ
;ee	:lx		デフォ音長
;ef	:vx		ボリューム絶対指定（0～15）
;f0	:v+-x	ボリューム相対指定（-15～15）
;f1	:@tx	音色エンベロープ指定（外部定義）
;f2	:@t*	音色エンベロープ停止
;f3	:@dx	デチューン
;f4	:hsx		ハードウェアスイープ
;f5	:hex		ハードウェアエンベロープ
;f6	:sx		ソフトウェアスイープ
;f7	:s*		ソフトウェアスイープ無効
;f8	:r-		エンベロープ無効
;f9	:w		メモリ書き込み
;fa	:\x	サブルーチン


; ------------------------------------------------------------------------
; main
; ------------------------------------------------------------------------
.code

.proc drv_main
		lda DrvFrags
		and #DRV_IS_PROC
		bne start
		rts
	start:
		lda DrvFrags
		ora #DRV_IS_PROC
		sta DrvFrags
		ldx #LAST_TRACK
		jsr pretrack	;トラック処理の前に毎フレームやる処理をここでやる
		lda SpdCtr
		clc
		adc SpdFreq
		php
		sta SpdCtr
		lda DrvFrags
		and #DRV_SKIP_DIR
		bne acc			;加速の場合
		plp
		bcs env		;SpdFreqを足していって桁上がりしたらスキップ
		ldx #LAST_TRACK
		jsr track		;トラック処理
		jmp env
	acc:
		plp
		bcc single		;桁上がりしたら二重処理
		ldx #LAST_TRACK
		jsr track		;トラック処理
		ldx #LAST_TRACK
		jsr envelope
		ldx #LAST_TRACK
		jsr pretrack
		lda DrvFrags
		ora #DRV_DOUBLE
		sta DrvFrags
	single:
		ldx #LAST_TRACK
		jsr track		;トラック処理
	env:
		ldx #LAST_TRACK
		jsr envelope	;エンベロープと書き込み処理は毎フレームやる
	iend:
		lda DrvFrags
		ora #DRV_IS_PROC
		and #DRV_DOUBLE_CLR
		sta DrvFrags
		rts
.endproc

;ドライバ初期化
.proc drv_init
		;変数初期化
		lda #%00111111
		sta $4000
		sta $4004
		lda #%00001000
		sta $4001
		sta $4005
		lda #%11111111
		sta $4008
		lda #%00001111
		sta $4015
.ifdef MMC5
		lda #%00111111
		sta $5000
		sta $5004
		lda #%00000011
		sta $5015
.endif
.ifdef SS5B
		lda #0
		sta SS5BTone + 0
		sta SS5BTone + 1
		sta SS5BTone + 2
		sta SS5BHWEnv + 0
		sta SS5BHWEnv + 1
		sta SS5BHWEnv + 2
		lda #$7
		sta $c000
		lda #%00111000
		sta $e000
.endif
		lda #0
		sta SpdCtr
		sta ProcTr
		lda #0
		sta SpdFreq
		sta SpdCtr
		
		lda DrvFrags
		ora #DRV_IS_PROC
		sta DrvFrags
		rts
.endproc

;トラック初期化
.proc track_init
		lda #0
		sta Volume, x
		sta InfLoopAddr_L, x
		sta InfLoopAddr_H, x
		sta Gate, x
		sta KeyShift, x
		sta Detune, x
		sta VEnvCtr, x
		sta VEnvPos, x
		sta EnvFrags, x
		sta Tone, x
		sta RefTone, x
		lda #1
		sta LenCtr, x
		sta GateCtr, x
		lda #FRAG_LOAD | FRAG_SIL
		sta Frags, x
		lda #FRAG_ENV_DIS
		sta EnvFrags, x
		lda #24
		sta DefLen, x
		lda Device, x
		cmp #4
		bne @N
		lda #0
		jmp @E
	@N:
		lda #15
	@E:
		sta TrVolume, x
		lda #%00001000
		sta HSwpReg, x
		lda #%00110000
		sta HEnvReg, x
		rts
.endproc

;サウンド要求
.proc drv_sndreq
		sta Work
		sta SeqAddr_L
		stx Work + 1
		stx SeqAddr_H
		tya
		asl
	load:
		tay
		lda (Work), y
		clc
		adc Work
		sta Work + 2
		iny
		lda (Work), y
		adc Work + 1
		sta Work + 1
		lda Work + 2
		sta Work
		ldx #0			;ここからポインタ初期化
		ldy #0
		;lda (Work), y
		;sta Work + 2	;最大トラック数
		;iny
	loop:
		;cpx Work + 2	;最大トラック番号以降は未使用トラック
		;bcs nouse
		lda #$ff
		cmp (Work), y	;トラック番号を比較
		beq nouse		;$ffならこれ以降は未使用
		iny
		lda (Work), y
		sta Device, x	;音源番号を取得して保存
		iny
		lda (Work), y
		clc
		adc SeqAddr_L
		sta Ptr_L, x	;トラックの開始アドレスを保存
		iny
		lda (Work), y
		adc SeqAddr_H
		sta Ptr_H, x
		jsr track_init	;トラック初期化
		jmp next
	nouse:
		lda Frags, x	;使っているトラックならスルー
		and #FRAG_KEYON | FRAG_KEYOFF | FRAG_LOAD
		bne @N
		lda #FRAG_END
		sta Frags, x
		lda #$ff
		sta Device, x	;$ffを入れて処理しないようにしておく
	@N:
		inx
		cpx #MAX_TRACK
		bcc loop
		jmp def
	next:
		inx
		iny
		cpx #MAX_TRACK
		bcc loop
	def:
		iny				;トラック終端を飛ばす
		ldx #0
	@L:
		lda (Work), y
		sta DefLen, x	;デフォルト音長を保存
		inx
		cpx #MAX_TRACK
		bcc @L

		rts
.endproc


.proc pretrack
	start:
		lda Frags, x
		and #FRAG_END
		beq frag
		dex
		bpl start
		rts
	frag:
		lda Frags, x
		;ロードフラグを立てる
		ora #FRAG_LOAD
		;キーオン・キーオフ・書き込み無効フラグを降ろす
		and #FRAG_KEYON_CLR & FRAG_KEYOFF_CLR & FRAG_WRITE_DIS_CLR
		sta Frags, x
		dex
		bpl start
		rts
.endproc
; ------------------------------------------------------------------------
; トラック処理
; ------------------------------------------------------------------------
.proc track
	start:
		lda Frags, x
		and #FRAG_END
		beq len			;終了フラグが立っていなければ処理へ
		dex
		bpl start		;xがマイナスになったら全トラック終了
	end1:
		rts
	len:
		stx ProcTr
		lda LenCtr, x
		cmp #1
		beq seq				;音長カウンタが1になったらシーケンスのロード
	gate:					;音長カウンタが1でなければゲート処理へ
		lda GateCtr, x
		cmp #1
		bne cnt				;ゲートカウンタが1でなければカウント処理へ
		lda Frags, x		;ゲートカウンタが1になったらキーオフ
		ora #FRAG_KEYOFF
		and #FRAG_KEYON_CLR	& FRAG_KEYON_DIS_CLR
		sta Frags, x
		jmp cnt				;キーオフしたら終了
	seq:
		jsr loadseq
		lda Frags, x
		and #FRAG_LOAD		;ロードフラグが立っていれば続けてロード
		bne seq
		lda Frags, x
		and #FRAG_END
		beq note			;終了フラグが立っていなければ処理へ
		dex
		bpl start
		rts
	note:
		jsr procnote
		jmp end
	cnt:
		lda LenCtr, x
		beq end
		dec LenCtr, x
		lda GateCtr, x
		beq end
		dec GateCtr, x
	end:
		dex
		bpl start
		rts
.endproc


; ------------------------------------------------------------------------
; シーケンスデータのロード
; ------------------------------------------------------------------------
.proc loadseq
		lda Ptr_L, x
		sta Work
		lda Ptr_H, x
		sta Work + 1
	l00:
		ldy #0
		lda (Work), y
		
		cmp #$6c	;音長なしノート
		bcs l6c
		sta NoteN, x
		lda Frags, x
		and #FRAG_KEYON_DIS
		bne @N
		lda Frags, x
		ora #FRAG_KEYON					;キーオンフラグを立てる
		sta Frags, x
	@N:
		;キーオン無効・ロードフラグを降ろす
		lda Frags, x
		and #FRAG_KEYON_DIS_CLR & FRAG_LOAD_CLR
		sta Frags, x
		lda EnvFrags, x
		and #FRAG_ENV_DIS_CLR	;エンベロープ無効フラグを降ろす
		sta EnvFrags, x
		lda DefLen, x
		sta Length, x
		lda #1
		jsr addptr
		rts
	l6c:
		cmp #$6c	;休符
		bne l6d
		lda Frags, x
		ora #FRAG_KEYOFF						;キーオフフラグを立てる
		;キーオン無効・ロードフラグを降ろす
		and #FRAG_KEYON_DIS_CLR & FRAG_LOAD_CLR
		sta Frags, x
		lda DefLen, x
		sta Length, x
		lda #1
		jsr addptr
		rts
	l6d:
		cmp #$6d	;ループ開始
		bne l6e
		inc LoopDepth, x
		jsr loopoffset
		sty Work + 2
		ldy #1
		lda (Work), y
		ldy Work + 2
		sta LoopN, y
		lda #2
		jsr addptr
		lda Ptr_L, x
		sta LoopAddr_L, y
		lda Ptr_H, x
		sta LoopAddr_H, y
		rts
	l6e:
		cmp #$6e	;ループ終了
		bne l6f
		jsr loopoffset
		lda LoopN, y		;yだと直接decできない
		sec
		sbc #1
		sta LoopN, y
		beq @E2
		cmp #1				;ループ回数が1になったらループ終了＋１を保存しておく
		beq @E3
		lda LoopAddr_L, y
		sta Ptr_L, x
		lda LoopAddr_H, y
		sta Ptr_H, x
		rts
	@E2:
		dec LoopDepth, x	;ループを抜けたら深度減算
		lda #1
		jsr addptr
		rts
	@E3:
		lda #1
		jsr addptr
		lda Ptr_L, x
		pha
		lda LoopAddr_L, y
		sta Ptr_L, x
		pla
		sta LoopAddr_L, y
		lda Ptr_H, x
		pha
		lda LoopAddr_H, y
		sta Ptr_H, x
		pla
		sta LoopAddr_H, y
		rts
	l6f:
		cmp #$6f	;ループ途中終了
		bne l70
		jsr loopoffset
		lda LoopN, y
		cmp #2
		bcs @E
		lda #0
		sta LoopN, y
		lda LoopAddr_L, y
		sta Ptr_L, x
		lda LoopAddr_H, y
		sta Ptr_H, x
		dec LoopDepth, x	;ループを抜けたら深度減算
		rts
	@E:
		lda #1
		jsr addptr
		rts
	l70:
		cmp #$70	;ゲート
		bne l73
		ldy #1
		lda (Work), y
		sta Gate, x
		lda #2
		jsr addptr
		rts
	l73:
		cmp #$73	;相対キーシフト(k)
		bne l74
		ldy #1
		lda (Work), y
		clc
		adc KeyShift, x
		sta KeyShift, x
		lda #2
		jsr addptr
		rts
	l74:
		cmp #$74	;絶対キーシフト(K)
		bne l75
		ldy #1
		lda (Work), y
		sta KeyShift, x
		lda #2
		jsr addptr
		rts
	l75:
		cmp #$75	;タイ・スラー
		bne l76
		lda Frags, x
		ora #FRAG_KEYON_DIS				;キーオン無効フラグを立てる
		sta Frags, x
		lda #1
		jsr addptr
		rts
	l76:
		cmp #$76	;音色指定
		bne l77
		lda EnvFrags, x
		and #FRAG_TENV_CLR	;音色エンベロープを解除
		sta EnvFrags, x
		lda Device, x
		cmp #DEV_2A03_DPCM	;DPCMトラックなら
		beq @D
.ifdef SS5B
		cmp #DEV_SS5B_SQR3 + 1
		bcs @N
		cmp #DEV_SS5B_SQR1
		bcc @N
		lda #$7
		sta $c000
		ldy #1
		lda (Work), y
		sta $e000
		ldy #2
		lda (Work), y
		sta SS5BTone + 0
		ldy #3
		lda (Work), y
		sta SS5BTone + 1
		ldy #4
		lda (Work), y
		sta SS5BTone + 2
		lda #5
		jsr addptr
		rts
	@N:
.endif
		ldy #1
		lda (Work), y
		sta Tone, x
		sta RefTone, x		;音色番号を保存（音色エンベロープ解除用）
		lda #2
		jsr addptr
		rts
	@D:
		ldy #1
		lda (Work), y
		sta $4012
		ldy #2
		lda (Work), y
		sta $4013
		lda #3
		jsr addptr
		rts
	l77:
		cmp #$77	;フレームスキップ加算値（テンポ）
		bne l78
		ldy #1
		lda (Work), y
		beq @dec
		lda DrvFrags
		ora #DRV_SKIP_DIR
		jmp @next
	@dec:
		lda DrvFrags
		and #DRV_SKIP_DIR_CLR
	@next:
		sta DrvFrags
		ldy #2
		lda (Work), y
		sta SpdFreq
		lda #3
		jsr addptr
		rts
	l78:
		cmp #$78	;指定した曲番号のデータを再生
		bne l79
		ldy #1
		lda (Work), y
		tay
		lda SeqAddr_L
		ldx SeqAddr_H
		jsr drv_sndreq
		ldx ProcTr
		lda #2
		jsr addptr
		rts
	l79:
		cmp #$79			;音量エンベロープ。引数はアドレスL、アドレスH、ディレイ
		bne l7a
		lda EnvFrags, x
		ora #FRAG_VENV		;フラグを立てる
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta VEnvAddr_L, x
		ldy #2
		lda (Work), y
		sta VEnvAddr_H, x
		ldy #3
		lda (Work), y
		sta VEnvDelay, x
		lda #1
		sta VEnvCtr, x
		lda #1
		sta VEnvPos, x
		clc
		lda VEnvAddr_L, x	;相対アドレスを絶対アドレスに直す
		adc SeqAddr_L
		sta VEnvAddr_L, x
		lda VEnvAddr_H, x
		adc SeqAddr_H
		sta VEnvAddr_H, x
		lda #4
		jsr addptr
		rts
	l7a:
		cmp #$7a			;音量エンベロープのクリア
		bne l7b
		lda EnvFrags, x
		and #FRAG_VENV_CLR	;フラグを降ろす
		sta EnvFrags, x
		lda TrVolume, x
		sta Volume, x		;音量を戻す
		lda #1
		jsr addptr
		rts
	l7b:
		cmp #$7b			;音程エンベロープ。引数はアドレスL、アドレスH、ディレイ
		bne l7c
		lda EnvFrags, x
		ora #FRAG_FENV		;フラグを立てる
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta FEnvAddr_L, x
		ldy #2
		lda (Work), y
		sta FEnvAddr_H, x
		ldy #3
		lda (Work), y
		sta FEnvDelay, x
		lda #1
		sta FEnvCtr, x
		lda #1
		sta FEnvPos, x
		clc
		lda FEnvAddr_L, x	;相対アドレスを絶対アドレスに直す
		adc SeqAddr_L
		sta FEnvAddr_L, x
		lda FEnvAddr_H, x
		adc SeqAddr_H
		sta FEnvAddr_H, x
		lda #4
		jsr addptr
		rts
	l7c:
		cmp #$7c			;音程エンベロープのクリア
		bne l7d
		lda EnvFrags, x
		and #FRAG_FENV_CLR	;フラグを降ろす
		sta EnvFrags, x
		lda #1
		jsr addptr
		rts
	l7d:
		cmp #$7d			;ノートエンベロープ。引数はアドレスL、アドレスH、ディレイ
		bne l7e
		lda EnvFrags, x
		ora #FRAG_NENV		;フラグを立てる
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta NEnvAddr_L, x
		ldy #2
		lda (Work), y
		sta NEnvAddr_H, x
		ldy #3
		lda (Work), y
		sta NEnvDelay, x
		lda #1
		sta NEnvCtr, x
		lda #1
		sta NEnvPos, x
		clc
		lda NEnvAddr_L, x	;相対アドレスを絶対アドレスに直す
		adc SeqAddr_L
		sta NEnvAddr_L, x
		lda NEnvAddr_H, x
		adc SeqAddr_H
		sta NEnvAddr_H, x
		lda #4
		jsr addptr
		rts
	l7e:
		cmp #$7e			;ノートエンベロープのクリア
		bne l7f
		lda EnvFrags, x
		and #FRAG_NENV_CLR	;フラグを降ろす
		sta EnvFrags, x
		lda #1
		jsr addptr
		rts
	l7f:
		cmp #$7f	;トラック終了
		bne leb
		clc
		lda InfLoopAddr_L, x			;無限ループアドレスが設定されていればジャンプ
		bne @N
		lda InfLoopAddr_H, x
		beq @E
	@N:
		lda InfLoopAddr_L, x
		sta Ptr_L, x
		lda InfLoopAddr_H, x
		sta Ptr_H, x
		rts
	@E:
		lda Frags, x
		ora #FRAG_END					;エンドフラグを立てる
		and #FRAG_LOAD_CLR				;ロードフラグを降ろす
		sta Frags, x
		rts
	leb:
		cmp #$ec	;音長ありノート
		bcs lec
		sec
		sbc #$80
		sta NoteN, x
		lda Frags, x
		and #FRAG_KEYON_DIS
		bne @N
		lda Frags, x
		ora #FRAG_KEYON					;キーオンフラグを立てる
		sta Frags, x
	@N:
		;キーオン無効・ロードフラグを降ろす
		lda Frags, x
		and #FRAG_KEYON_DIS_CLR & FRAG_LOAD_CLR
		sta Frags, x
		lda EnvFrags, x
		and #FRAG_ENV_DIS_CLR	;エンベロープ無効フラグを降ろす
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta Length, x
		lda #2
		jsr addptr
		rts
	lec:
		cmp #$ec	;音長あり休符
		bne led
		lda Frags, x
		ora #FRAG_KEYOFF						;キーオフフラグを立てる
		;キーオン無効・ロードフラグを降ろす
		and #FRAG_KEYON_DIS_CLR & FRAG_LOAD_CLR
		sta Frags, x
		ldy #1
		lda (Work), y
		sta Length, x
		lda #2
		jsr addptr
		rts
	led:
		cmp #$ed	;無限ループ開始
		bne lee
		lda #1
		jsr addptr
		lda Ptr_L, x
		sta InfLoopAddr_L, x
		lda Ptr_H, x
		sta InfLoopAddr_H, x
		rts
	lee:
		cmp #$ee	;デフォ音長
		bne lef
		ldy #1
		lda (Work), y
		sta DefLen, x
		lda #2
		jsr addptr
		rts
	lef:
		cmp #$ef	;ボリューム絶対指定
		bne lf0
		ldy #1
		lda (Work), y
		sta TrVolume, x
		lda #2
		jsr addptr
		rts
	lf0:
		cmp #$f0	;ボリューム相対指定
		bne lf1
		ldy #1
		lda (Work), y
		clc
		adc TrVolume, x
		bpl @P
		lda #0
	@P:
		sta TrVolume, x
		lda #2
		jsr addptr
		rts
	lf1:
		cmp #$f1			;音色エンベロープ。引数はアドレスL、アドレスH、ディレイ
		bne lf2
		lda EnvFrags, x
		ora #FRAG_TENV		;フラグを立てる
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta TEnvAddr_L, x
		ldy #2
		lda (Work), y
		sta TEnvAddr_H, x
		ldy #3
		lda (Work), y
		sta TEnvDelay, x
		lda #1
		sta TEnvCtr, x
		lda #1
		sta TEnvPos, x
		clc
		lda TEnvAddr_L, x	;相対アドレスを絶対アドレスに直す
		adc SeqAddr_L
		sta TEnvAddr_L, x
		lda TEnvAddr_H, x
		adc SeqAddr_H
		sta TEnvAddr_H, x
		lda #4
		jsr addptr
		rts
	lf2:
		cmp #$f2			;音色エンベロープのクリア
		bne lf3
		lda EnvFrags, x
		and #FRAG_TENV_CLR	;フラグを降ろす
		sta EnvFrags, x
		lda RefTone, x
		sta Tone, x			;音色番号を戻す
		lda #1
		jsr addptr
		rts
	lf3:
		cmp #$f3			;デチューン
		bne lf4
		ldy #1
		lda (Work), y
		sta Detune, x
		lda #2
		jsr addptr
		rts
	lf4:
		cmp #$f4			;ハードウェアスイープ
		bne lf5
		ldy #1
		lda (Work), y
		sta HSwpReg, x
		lda #2
		jsr addptr
		rts
	lf5:
		cmp #$f5			;ハードウェアエンベロープ
		bne lf6
.ifdef SS5B
		lda Device, x
		cmp #DEV_SS5B_SQR3 + 1
		bcs @N
		cmp #DEV_SS5B_SQR1
		bcc @N
		sec
		sbc #DEV_SS5B_SQR1
		tax
		ldy #1
		lda (Work), y
		sta SS5BHWEnv, x
		bne @E
		ldx ProcTr
		rts
	@E:
		ldx ProcTr
		lda #$0b
		sta $c000
		ldy #2
		lda (Work), y
		sta $e000
		lda #$0c
		sta $c000
		ldy #3
		lda (Work), y
		sta $e000
		lda #$0d
		sta $c000
		ldy #4
		lda (Work), y
		sta $e000
		lda #5
		jsr addptr
	@N:
.endif
		ldy #1
		lda (Work), y
		sta HEnvReg, x
		lda #2
		jsr addptr
		rts
	lf6:
		cmp #$f6	;ソフトウェアスイープ
		bne lf7				;引数は終了周波数（+-半音単位）、Delay、Speed。開始周波数はノートの方を変更する。
		lda EnvFrags, x
		ora #FRAG_SSWP		;フラグを立てる
		sta EnvFrags, x
		ldy #1
		lda (Work), y
		sta SSwpEnd, x
		ldy #2
		lda (Work), y
		sta SSwpDelay, x
		ldy #3
		lda (Work), y
		bpl @N0				;speed値がマイナスだったら
		sta SSwpRate, x		;その値をRate、Depthを1とする
		lda #1
		sta SSwpDepth, x
		jmp @N1
	@N0:					;プラスだったら
		sta SSwpDepth, x	;その値をDepth、Rateを0とする
		lda #0
		sta SSwpRate, x
	@N1:
		lda #0
		sta SSwpCtr, x		;カウンタリセット
		lda SSwpEnd, x
		bmi @neg			;変化方向がプラスならDepthをマイナスにする。マイナスなら何もしない
		lda SSwpDepth, x
		eor #$ff
		clc
		adc #1
		sta SSwpDepth, x
	@neg:
		lda #4
		jsr addptr
		rts
	lf7:
		cmp #$f7			;ソフトウェアスイープのクリア
		bne lf8
		lda EnvFrags, x
		and #FRAG_SSWP_CLR	;フラグを降ろす
		sta EnvFrags, x
		lda #1
		jsr addptr
		rts
	lf8:
		cmp #$f8			;エンベロープ無効
		bne lf9
		lda EnvFrags, x
		ora #FRAG_ENV_DIS	;エンベロープ無効フラグを立てる
		sta EnvFrags, x
		lda #1
		jsr addptr
		rts
	lf9:
		cmp #$f9			;メモリ書き込み
		bne lfa
		ldy #1
		lda (Work), y
		sta Work + 2
		ldy #2
		lda (Work), y
		sta Work + 3
		ldy #3
		lda (Work), y
		ldy #0
		sta (Work + 2), y
		lda #4
		jsr addptr
		rts
	lfa:
		cmp #$fa	;サブルーチン
		bne lend
		lda #3
		jsr addptr
		ldy #1
		lda (Work), y
		sta Work + 2
		iny
		lda (Work), y
		sta Work + 3
		inc LoopDepth, x
		jsr loopoffset
		lda LoopN, y
		clc
		adc #1
		sta LoopN, y
		lda Ptr_L, x
		sta LoopAddr_L, y
		lda Ptr_H, x
		sta LoopAddr_H, y
		clc
		lda Work + 2
		adc SeqAddr_L
		sta Ptr_L, x
		lda Work + 3
		adc SeqAddr_H
		sta Ptr_H, x
		rts
	lend:
		rts
.endproc


; ------------------------------------------------------------------------
; ノート関係の処理
; ------------------------------------------------------------------------
.proc procnote
		lda Length, x
		sta LenCtr, x
		lda Frags, x
		and #FRAG_KEYON		;キーオンでない場合
		beq next
		lda Gate, x
		and #%00111111
		sta Work
		lda Gate, x
		and #%11000000
		cmp #%01000000
		beq @G0				;上位2bitが01ならq
		cmp #%10000000
		beq @G1				;10ならu
		cmp #%11000000
		beq @G2				;11ならQ
		lda LenCtr, x
		sta GateCtr, x
		jmp next
	@G0:					;ゲートタイム設定
		lda LenCtr, x
		sec
		sbc Work
		sta GateCtr, x
		jmp next
	@G1:
		lda Work
		sta GateCtr, x
		jmp next
	@G2:
		ldy Work
		lda LenCtr, x
		jsr ndiv8
		sta GateCtr, x
	next:
		lda Frags, x		;キーオフの場合これ以降は処理しない
		and #FRAG_KEYOFF
		bne end1
		lda Frags, x
		and #FRAG_KEYON	;キーオンされていない
		bne @N
		lda EnvFrags, x
		and #FRAG_SSWP | FRAG_FENV	;かつスイープか音程エンベロープ有効
		beq @N
		lda RefNoteN, x				;かつノートが前回と同じならこれ以降は処理しない
		cmp NoteN, x				;（ノート分割した時処理が途中で途切れるため）
		beq end1
	@N:
		lda NoteN, x
		clc
		adc KeyShift, x		;キーシフト値を加算
		sta NoteN, x
		sta RefNoteN, x		;ノートナンバーを記憶
		lda Device, x
		cmp #DEV_2A03_NOISE	;ノイズとDPCM以外は周波数計算へ
		beq rem
		cmp #DEV_2A03_DPCM
		beq rem
.ifdef SS5B
		cmp #DEV_SS5B_SQR3 + 1
		bcs @N2
		cmp #DEV_SS5B_SQR1
		bcc @N2
		sec
		sbc #DEV_SS5B_SQR1
		tay
		lda SS5BTone, y
		beq @N2
		lda NoteN, x
		and #$1f
		sta Work
		lda #$1f
		sec
		sbc Work
		sta NoteN, x
		sta RefNoteN, x
		jmp end1
	@N2:
.endif
		jmp calcoct
	rem:
		lda NoteN, x
		and #$0f
		sta Work
		lda #$0f
		sec
		sbc Work
		sta NoteN, x
		sta RefNoteN, x
	end1:
		rts
	calcoct:
		lda NoteN, x		;周波数計算
		jsr calcfreq		;WorkとWork + 1に入って帰ってくる
	last:
		lda Detune, x		;0でなければデチューン値を加算
		beq end2
		bmi neg
		clc
		adc Work
		sta Work
		bcc end2
		inc Work + 1
		jmp end2
	neg:
		clc
		adc Work
		sta Work
		bcs end2
		dec Work + 1
	end2:
		lda Work
		sta Freq_L, x
		sta RefFreq_L, x
		lda Work + 1
		sta Freq_H, x
		sta RefFreq_H, x
		rts
.endproc


;ノートナンバーから周波数を計算する
;a=ノートナンバー
.proc calcfreq
		ldy #0
	oct:
		cmp #12
		bcc load
		sec
		sbc #12
		iny
		jmp oct
	;@N:
		;dey				;ノートナンバー0は-1オクターブなので1オクターブ下げる
		;bpl load
		;ldy #0			;マイナスになったらゼロに
	load:
		pha				;周波数テーブルから周波数を取得
		tya
		sta Octave, x
		pla
		asl a
		tay
		lda Device, x
		cmp #DEV_VRC6_SAW
		beq saw
		cmp #DEV_SS5B_SQR1
		bcs ss5b
		lda Freq_Tbl, y
		sta Work
		lda Freq_Tbl + 1, y
		sta Work + 1
		jmp calc
	saw:
.ifdef	VRC6
		lda Freq_Saw, y
		sta Work
		lda Freq_Saw + 1, y
		sta Work + 1
		jmp calc
.endif
	ss5b:
.ifdef SS5B
		inc Octave, x	;5Bは-1オクターブから
		lda Freq_5B, y
		sta Work
		lda Freq_5B + 1, y
		sta Work + 1
		jmp calc
.endif
	calc:
		ldy Octave, x	;オクターブから周波数を計算する
	@L:
		beq end
		lsr Work + 1
		ror Work
		dey
		jmp @L
	end:
		rts
.endproc


; ------------------------------------------------------------------------
; エンベロープ処理
; ------------------------------------------------------------------------
.proc envelope
	start:
		lda Frags, x
		and #FRAG_END
		beq env			;終了フラグが立っていなければ処理へ
		dex
		bpl start		;xがマイナスになったら全トラック終了
	end1:
		ldx #LAST_TRACK
		jmp interrupt		;割り込み処理に移行
	env:
		stx ProcTr
		lda EnvFrags, x
		and #FRAG_ENV_DIS	;エンベロープ無効フラグが立っていたら音量処理へ
		bne vol
	@N0:
		lda EnvFrags, x
		and #FRAG_VENV
		beq @N1
		jsr volenv
	@N1:
		lda EnvFrags, x
		and #FRAG_NENV
		beq @N2
		jsr noteenv
	@N2:
		lda EnvFrags, x
		and #FRAG_SSWP
		beq @N3
		jsr ssweep
	@N3:
		lda EnvFrags, x
		and #FRAG_FENV
		beq @N4
		jsr freqenv
	@N4:
		lda EnvFrags, x
		and #FRAG_TENV
		beq @N5
		jsr toneenv
	@N5:
		lda EnvFrags, x
		and #FRAG_VENV
		beq vol				;音量エンベロープ無効なら音量処理へ
		jmp last			;そうでなければ次のトラックへ
	vol:
		lda Frags, x
		and #FRAG_KEYON		;キーオンされていたら音量をトラック音量にする
		bne trv
		lda Frags, x
		and #FRAG_KEYOFF	;キーオフされていたら無音に
		beq last
		lda #0
		sta Volume, x
		jmp sil
	trv:
		lda TrVolume, x
		sta Volume, x
		lda Frags, x		;音量が0でなければ無音フラグを降ろす
		and #FRAG_SIL_CLR
		sta Frags, x
		bne last
	sil:
		lda Frags, x		;音量が0なら無音フラグを立てる
		ora #FRAG_SIL
		sta Frags, x
	last:
		dex
		bmi end		;xがマイナスになったら全トラック終了
		jmp envelope
	end:
		lda #$ff
		sta Work + 2		;発音トラックがあるか判定する変数をリセット
		ldx #LAST_TRACK
		jmp interrupt		;割り込み処理に移行
.endproc


;ソフトウェアスイープ
.proc ssweep
		lda Frags, x
		and #FRAG_KEYON
		bne keyon
		lda DrvFrags
		and #DRV_DOUBLE
		beq start
		rts
	keyon:
		lda NoteN, x
		clc
		adc SSwpEnd, x			;スイープ終了周波数を計算
		jsr calcfreq
		lda Work
		sta SSwpEndFreq_L, x
		lda Work + 1
		sta SSwpEndFreq_H, x
		lda SSwpDelay, x
		clc						;カウンタにディレイ値を加算
		adc SSwpCtr, x
		sta SSwpCtr, x
		rts
	start:
		lda SSwpCtr, x
		beq exec				;カウンタが0でなければデクリメントして抜ける
		dec SSwpCtr, x
		rts
	exec:
		lda SSwpDepth, x
		bmi @M
		lda RefFreq_L, x			;周波数に加算
		clc
		adc SSwpDepth, x
		sta RefFreq_L, x
		bcc detect
		inc RefFreq_H, x
		jmp detect
	@M:							;マイナス値の場合
		lda RefFreq_L, x			;周波数に加算
		clc
		adc SSwpDepth, x
		sta RefFreq_L, x
		bcs detect
		dec RefFreq_H, x
	detect:
		lda SSwpEnd, x			;終了判定
		bpl pos
		lda SSwpEndFreq_H, x	;変化がマイナス方向の場合
		cmp RefFreq_H, x
		bcc end					;終了値より大きくなったら終了
		bne next				;終了値より小さかったら次へ
		lda RefFreq_L, x
		cmp SSwpEndFreq_L, x			;下位バイトも比較
		bcc next
		jmp end
	pos:
		lda SSwpEndFreq_H, x			;変化がプラス方向の場合
		cmp RefFreq_H, x
		bcc next				;終了値より大きかったら次へ
		bne end					;終了値より小さくなったら終了（レジスタ値が小さい方が高いので）
		lda SSwpEndFreq_L, x
		cmp RefFreq_L, x
		bcc next
		jmp end
	next:
		lda RefFreq_L, x
		sta Freq_L, x
		lda RefFreq_H, x
		sta Freq_H, x
		lda SSwpRate, x			;Rateをカウンタに代入して抜ける
		sta SSwpCtr, x
		rts
	end:
		lda SSwpEndFreq_L, x	;終了値を代入
		sta RefFreq_L, x
		sta Freq_L, x
		lda SSwpEndFreq_H, x
		sta RefFreq_H, x
		sta Freq_H, x
		rts
.endproc


;音量エンベロープ
.proc volenv
		lda VEnvAddr_L, x
		sta Work + 2
		lda VEnvAddr_H, x
		sta Work + 3
		lda Frags, x
		and #FRAG_KEYOFF
		bne keyoff
		lda Frags, x
		and #FRAG_KEYON
		bne keyon
		lda DrvFrags
		and #DRV_DOUBLE
		beq other
		rts
	keyon:
		lda #1
		sta VEnvPos, x		;キーオン位置に移動
		clc
		adc VEnvDelay, x	;ディレイを加算
		sta VEnvCtr, x
		jmp other
	keyoff:
		ldy #0
		lda (Work + 2), y
		and #%10000000		;ヘッダ1個目に最上位ビットが立っていたらキーオフ無効
		bne other
		ldy #1
		lda (Work + 2), y
		sta VEnvPos, x		;キーオフ位置に移動
		jmp get
	other:
		lda VEnvCtr, x
		cmp #2
		bcs end				;カウンタが2以上ならカウントして終了
		cmp #0				;カウンタが0になったらrts
		beq ret
		lda VEnvPos, x
		ldy #1
		cmp (Work + 2), y
		bne get				;ヘッダ2番目（キーオフ位置）に達したら
		ldy #0				;ヘッダ1番目（ループ位置）に戻る
		lda (Work + 2), y
		and #%01111111		;最上位ビットを消す
		sta VEnvPos, x
	get:
		lda VEnvPos, x
		asl a
		tay
		lda (Work + 2), y	;アドレスにあるデータを取得（音量）
		sta Volume, x		;いったん保存
		iny
		lda (Work + 2), y	;アドレスにあるデータを取得（フレーム数）
		sta VEnvCtr, x		;カウンタに代入
		beq @S				;カウンタが0ならエンベロープ位置を移動しない
		inc VEnvPos, x		;エンベロープ位置移動
	@S:
		lda Volume, x
		beq frag			;0ならこれ以降処理しない
		sta Work
		lda #0
		sta Work + 1
		ldy TrVolume, x		;トラックボリュームを掛ける
		bne @N
		sta Volume, x
		jmp frag
	@N:
		iny
	@L:
		clc
		adc Work
		bcc @C
		inc Work + 1
	@C:
		dey
		bne @L
		sta Work
		lsr Work + 1		;16で割る
		ror Work
		lsr Work + 1
		ror Work
		lsr Work + 1
		ror Work
		lsr Work + 1
		ror Work
		lda Work
		sta Volume, x
		lda Frags, x		;無音フラグを降ろす
		and #FRAG_SIL_CLR
		sta Frags, x
		bne ret
	frag:
		lda Frags, x
		ora #FRAG_SIL		;0なら無音フラグを立てる
		sta Frags, x
		jmp ret
	end:
		dec VEnvCtr, x
	ret:
		rts
.endproc


;音程エンベロープ
.proc freqenv
		lda FEnvAddr_L, x
		sta Work + 2
		lda FEnvAddr_H, x
		sta Work + 3
		lda Frags, x
		and #FRAG_KEYOFF
		bne keyoff
		lda Frags, x
		and #FRAG_KEYON
		bne keyon
		lda DrvFrags
		and #DRV_DOUBLE
		beq other
		rts
	keyon:
		lda #1
		sta FEnvPos, x		;キーオン位置に移動
		clc
		adc FEnvDelay, x	;ディレイを加算
		sta FEnvCtr, x
		jmp other
	keyoff:
		ldy #0
		lda (Work + 2), y
		and #%10000000		;ヘッダ1個目に最上位ビットが立っていたらキーオフ無効
		bne other
		ldy #1
		lda (Work + 2), y
		sta FEnvPos, x		;キーオフ位置に移動
		jmp get
	other:
		lda FEnvCtr, x
		cmp #2
		bcs end				;カウンタが2以上ならカウントして終了
		cmp #0				;カウンタが0になったらrts
		beq ret
		lda FEnvPos, x
		ldy #1
		cmp (Work + 2), y
		bne get				;ヘッダ2番目（キーオフ位置）に達したら
		ldy #0				;ヘッダ1番目（ループ位置）に戻る
		lda (Work + 2), y
		and #%01111111		;最上位ビットを消す
		sta FEnvPos, x
	get:
		lda FEnvPos, x
		asl a
		tay
		lda (Work + 2), y	;アドレスにあるデータを取得
		eor #$ff
		clc
		adc #1				;符号反転
		bmi neg				;負の値だったら
		clc
		adc RefFreq_L, x	;周波数に加算
		sta Freq_L, x
		lda RefFreq_H, x
		adc #0
		sta Freq_H, x
		jmp next
	neg:
		clc
		adc RefFreq_L, x	;周波数に加算
		sta Freq_L, x
		lda RefFreq_H, x
		sbc #0
		sta Freq_H, x
	next:
		iny
		lda (Work + 2), y	;アドレスにあるデータを取得（フレーム数）
		sta FEnvCtr, x		;カウンタに代入
		beq @S				;カウンタが0ならエンベロープ位置を移動しない
		inc FEnvPos, x		;エンベロープ位置移動
	@S:
		rts
	end:
		dec FEnvCtr, x
	ret:
		rts
.endproc


;ノートエンベロープ
.proc noteenv
		lda NEnvAddr_L, x
		sta Work + 2
		lda NEnvAddr_H, x
		sta Work + 3
		lda Frags, x
		and #FRAG_KEYOFF
		bne keyoff
		lda Frags, x
		and #FRAG_KEYON
		bne keyon
		lda DrvFrags
		and #DRV_DOUBLE
		beq other
		rts
	keyon:
		lda #1
		sta NEnvPos, x		;キーオン位置に移動
		clc
		adc NEnvDelay, x	;ディレイを加算
		sta NEnvCtr, x
		jmp other
	keyoff:
		ldy #0
		lda (Work + 2), y
		and #%10000000		;ヘッダ1個目に最上位ビットが立っていたらキーオフ無効
		bne other
		ldy #1
		lda (Work + 2), y
		sta NEnvPos, x		;キーオフ位置に移動
		jmp get
	other:
		lda NEnvCtr, x
		cmp #2
		bcs end				;カウンタが2以上ならカウントして終了
		cmp #0				;カウンタが0になったらrts
		beq ret
		lda NEnvPos, x
		ldy #1
		cmp (Work + 2), y
		bne get				;ヘッダ2番目（キーオフ位置）に達したら
		ldy #0				;ヘッダ1番目（ループ位置）に戻る
		lda (Work + 2), y
		and #%01111111		;最上位ビットを消す
		sta NEnvPos, x
	get:
		lda NEnvPos, x
		asl a
		pha
		lda Device, x
		cmp #DEV_2A03_NOISE
		beq @N
		cmp #DEV_2A03_DPCM
		beq @N
.ifdef SS5B
		cmp #DEV_SS5B_SQR3 + 1
		bcs @N2
		cmp #DEV_SS5B_SQR1
		bcc @N2
		sec
		sbc #DEV_SS5B_SQR1
		tay
		lda SS5BTone, y
		beq @N2
		jmp @N
	@N2:
.endif
		pla
		tay
		lda (Work + 2), y	;アドレスにあるデータを取得
		clc
		adc RefNoteN, x		;ノートナンバーに加算
		sta NoteN, x
		jsr calcfreq		;周波数計算
		lda Work
		sta RefFreq_L, x
		sta Freq_L, x
		lda Work + 1
		sta RefFreq_H, x
		sta Freq_H, x
		lda NEnvPos, x
		asl a
		tay
		jmp last
	@N:
		pla
		tay
		lda (Work + 2), y	;アドレスにあるデータを取得
		eor #$ff			;反転して加算
		clc
		adc #1
		clc
		adc RefNoteN, x
		sta NoteN, x
	last:
		iny
		lda (Work + 2), y	;アドレスにあるデータを取得（フレーム数）
		sta NEnvCtr, x		;カウンタに代入
		beq @S				;カウンタが0ならエンベロープ位置を移動しない
		inc NEnvPos, x		;エンベロープ位置移動
	@S:
		rts
	end:
		dec NEnvCtr, x
	ret:
		rts
.endproc


;音色エンベロープ
.proc toneenv
		lda TEnvAddr_L, x
		sta Work + 2
		lda TEnvAddr_H, x
		sta Work + 3
		lda Frags, x
		and #FRAG_KEYOFF
		bne keyoff
		lda Frags, x
		and #FRAG_KEYON
		bne keyon
		lda DrvFrags
		and #DRV_DOUBLE
		beq other
		rts
	keyon:
		lda #1
		sta TEnvPos, x		;キーオン位置に移動
		clc
		adc TEnvDelay, x	;ディレイを加算
		sta TEnvCtr, x
		jmp other
	keyoff:
		ldy #0
		lda (Work + 2), y
		and #%10000000		;ヘッダ1個目に最上位ビットが立っていたらキーオフ無効
		bne other
		ldy #1
		lda (Work + 2), y
		sta TEnvPos, x		;キーオフ位置に移動
		jmp get
	other:
		lda TEnvCtr, x
		cmp #2
		bcs end				;カウンタが2以上ならカウントして終了
		cmp #0				;カウンタが0になったらrts
		beq ret
		lda TEnvPos, x
		ldy #1
		cmp (Work + 2), y
		bne get				;ヘッダ2番目（キーオフ位置）に達したら
		ldy #0				;ヘッダ1番目（ループ位置）に戻る
		lda (Work + 2), y
		and #%01111111		;最上位ビットを消す
		sta TEnvPos, x
	get:
		lda TEnvPos, x
		asl a
		tay
		lda (Work + 2), y		;アドレスにあるデータを取得
		clc
		sta Tone, x			;代入
		iny
		lda (Work + 2), y		;アドレスにあるデータを取得（フレーム数）
		sta TEnvCtr, x		;カウンタに代入
		beq @S				;カウンタが0ならエンベロープ位置を移動しない
		inc TEnvPos, x		;エンベロープ位置移動
	@S:
		rts
	end:
		dec TEnvCtr, x
	ret:
		rts
.endproc


; ------------------------------------------------------------------------
; 割り込み処理
; ------------------------------------------------------------------------
.proc interrupt
	start:
		stx ProcTr
		lda Frags, x
		and #FRAG_END | FRAG_SIL	;現在のトラックが無音の場合、後のトラックの発音処理をする
		bne exec
	@L:
		lda Device, x
		inx
		cmp Device, x
		bne iend0
		lda Frags, x
		ora #FRAG_WRITE_DIS			;無音でない場合は、後のトラックを書き込み無効に
		sta Frags, x
		jmp @L						;同じ音源の間繰り返す
	exec:
		cpx #LAST_TRACK
		beq iend2					;最終トラックなら何もしない
		lda Device, x
		inx
		cmp Device, x				;後のトラックと音源が違う場合なにもしない
		bne iend0
		lda Work + 2
		and #FRAG_END | FRAG_SIL	;発音しているトラックがない場合なにもしない
		bne iend
		dex
		lda Frags, x
		ora #FRAG_WRITE_DIS			;それ以外は現在のトラックをレジスタ書き込み無効にする
		sta Frags, x
		jmp iend2
	iend0:
		lda #$ff
		sta Work + 2				;音源が変わったらリセット
	iend:
		ldx ProcTr					;トラック番号を元に戻して復帰
	iend2:
		lda Frags, x
		and Work + 2
		sta Work + 2
		dex
		bpl start
	end:
		ldx #LAST_TRACK
		jmp writereg				;全部終わったらレジスタ書き込みへ
.endproc


; ------------------------------------------------------------------------
; レジスタ書き込み
; ------------------------------------------------------------------------
.proc writereg
	start:
		lda Frags, x
		and #FRAG_END
		bne next		;終了フラグが立っていたら次トラックへ
		lda Frags, x
		and #FRAG_WRITE_DIS
		beq exec		;レジスタ書き込み無効フラグが立っていたら終了処理へ
		jmp writereg_end
	next:
		dex
		bpl start		;xがマイナスになったら全トラック終了
	end1:
		rts
	exec:
		stx ProcTr
		lda Device, x
	sqr0:
		cmp #DEV_2A03_SQR1
		bne sqr1
		ldy #0
		jmp writesqr
	sqr1:
		cmp #DEV_2A03_SQR2
		bne tri
		ldy #4
		jmp writesqr
	tri:
		cmp #DEV_2A03_TRI
		bne noi
		lda Freq_L, x
		sta $400a
		lda Freq_H, x
		sta $400b
		lda #%10000000
		ora Volume, x
		sta $4008
		jmp writereg_end
	noi:
		cmp #DEV_2A03_NOISE
		bne pcm
		lda Volume, x
		ora #%00110000
		sta $400c
		lda Tone, x
		clc
		ror a
		ror a
		ora NoteN, x
		sta $400e
		lda #%11111000
		sta $400f
		jmp writereg_end
	pcm:
		cmp #DEV_2A03_DPCM
		bne vrc6_0
		lda Frags, x
		and #FRAG_KEYON | FRAG_KEYOFF	;キーオンもキーオフもたっていなければ終了
		beq end
		lda Frags, x
		and #FRAG_KEYOFF	;キーオフが立っていたら再生終了
		bne stop
		lda NoteN, x
		sta $4010
		lda Volume, x
		beq @N
		sta $4011
	@N:
		lda #%00001111
		sta $4015
		lda #%00011111
		sta $4015
		jmp writereg_end
	stop:
		lda #%00001111
		sta $4015
		jmp writereg_end
	vrc6_0:
.ifdef VRC6
		cmp #DEV_VRC6_SQR1
		bne vrc6_1
		ldy #$90
		jmp write_vrc6
	vrc6_1:
		cmp #DEV_VRC6_SQR2
		bne vrc6_2
		ldy #$a0
		jmp write_vrc6
	vrc6_2:
		cmp #DEV_VRC6_SAW
		bne mmc5_0
		ldy #$b0
		jmp write_vrc6
.endif
	mmc5_0:
.ifdef MMC5
		cmp #DEV_MMC5_SQR1
		bne mmc5_1
		ldy #0
		jmp write_mmc5
	mmc5_1:
		cmp #DEV_MMC5_SQR2
		bne ss5b_0
		ldy #4
		jmp write_mmc5
.endif
	ss5b_0:
.ifdef SS5B
		cmp #DEV_SS5B_SQR1
		bne ss5b_1
		ldy #0
		jmp write_ss5b
	ss5b_1:
		cmp #DEV_SS5B_SQR2
		bne ss5b_2
		ldy #1
		jmp write_ss5b
	ss5b_2:
		cmp #DEV_SS5B_SQR3
		bne end
		ldy #2
		jmp write_ss5b
.endif
	end:
		jmp writereg_end
.endproc


;1トラック書き込み終了
.proc writereg_end
		lda Frags, x
		and #FRAG_WRITE_DIS | FRAG_SIL	;書き込み無効か無音フラグが立っていた場合
		bne frag
		ldy Device, x		;周波数の保存
		lda Freq_L, x
		sta PrevFreq_L, y
		lda Freq_H, x
		sta PrevFreq_H, y
	frag:
		;lda Frags, x
		;ora #FRAG_LOAD			;ロードフラグを立てる
		;キーオン・キーオフ・書き込み無効フラグを降ろす
		;and #FRAG_KEYON_CLR & FRAG_KEYOFF_CLR & FRAG_WRITE_DIS_CLR
		;sta Frags, x
		dex
		bmi end
		jmp writereg
	end:
		rts
.endproc


.proc writesqr
		sty Work + 2		;一旦yを保存
		lda Tone, x
		clc
		ror a
		ror a
		ror a
		sta Work
		lda HEnvReg, x
		and #%00010000		;ハードウェアエンベロープが有効なら以下を実行
		bne softenv
		lda Frags, x
		and #FRAG_KEYON
		beq hws
		lda Work
		ora HEnvReg, x
		sta $4000, y
		jmp hws
	softenv:
		lda Work
		ora #%00110000
		ora Volume, x
	r4000:
		sta $4000, y
		lda Volume, x		;音量が0ならこれ以降は処理しない
		bne hws
		jmp end
	hws:
		ldy Work + 2
		lda HSwpReg, x
		and #%10000000		;ハードウェアスイープ有効なら以下を実行
		beq r4002
		lda Frags, x
		and #FRAG_KEYON
		beq end
	r4002:
		lda HSwpReg, x
		sta $4001, y
		lda Freq_L, x
		ldy Work + 2
		sta $4002, y
		lda Frags, x
		and #FRAG_KEYON		;キーオンなら
		bne r4003
		lda Freq_H, x
		ldy Device, x
		cmp PrevFreq_H, y
		bne r4003
		jmp end
	r4003:
		ldy Work + 2
		lda #%00001000
		ora Freq_H, x
		sta $4003, y		;ここに書き込むと波形がリセットされるので注意
	end:
		jmp writereg_end
.endproc


;-----------------------------------------------------------------------
; 拡張音源
;-----------------------------------------------------------------------
;VRC6
.ifdef VRC6
.proc write_vrc6
		sty Work + 3		;yにレジスタの上位アドレスが入ってくるので保存
		lda #0
		sta Work + 2
		cpy #$b0			;sawトラックは別処理
		beq saw
	r9000:
		ldy #0
		lda Tone, x
		clc
		asl a
		asl a
		asl a
		asl a
		ora Volume, x
		sta (Work + 2), y
		jmp next
	saw:
		ldy #0
		lda Volume, x
		sta (Work + 2), y
	next:
		lda Volume, x		;音量が0ならこれ以降は処理しない
		bne r9001
		jmp end
	r9001:
		lda #1
		sta Work + 2
		lda Freq_L, x
		sta (Work + 2), y
	r9002:
		lda #2
		sta Work + 2
		lda Frags, x
		and #FRAG_KEYON		;キーオンなら
		beq @N
		lda #0				;いったん0書き込み
		sta (Work + 2), y
	@N:
		lda #%10000000
		ora Freq_H, x
		sta (Work + 2), y
	end:
		jmp writereg_end
.endproc
.endif

;MMC5
.ifdef MMC5
.proc write_mmc5
		sty Work + 2		;一旦yを保存
		lda Tone, x
		clc
		ror a
		ror a
		ror a
		ora #%00110000
		ora Volume, x
	r5000:
		sta $5000, y
		lda Volume, x		;音量が0ならこれ以降は処理しない
		bne next
		jmp end
	next:
		lda Frags, x
		and #FRAG_KEYON		;キーオンなら
		bne r5003
	r5002:
		ldy Device, x
		lda Freq_L, x
		cmp PrevFreq_L, y
		beq end
		ldy Work + 2
		sta $5002, y
		lda Freq_H, x
		ldy Device, x
		cmp PrevFreq_H, y
		bne r5003
		jmp end
	r5003:
		lda Freq_L, x
		ldy Work + 2
		sta $5002, y
		lda #%00001000
		ora Freq_H, x
		sta $5003, y		;ここに書き込むと波形がリセットされるので注意
	end:
		jmp writereg_end
.endproc
.endif

;SS5B
.ifdef SS5B
.proc write_ss5b
		tya
		clc
		adc #$08
		sta $c000
		lda SS5BHWEnv, y
		beq @N
		lda #%00010000
	@N:
		ora Volume, x
		sta $e000
		tya
		asl a
		tay
		sty $c000
		lda Freq_L, x
		sta $e000
		iny
		sty $c000
		lda Freq_H, x
		sta $e000
		lda SS5BTone, y
		beq end
		lda #$06
		sta $c000
		lda NoteN, x
		sta $e000
	end:
		jmp writereg_end
.endproc
.endif

;ポインタをa個進める
.proc addptr
		clc
		adc Ptr_L, x
		sta Ptr_L, x
		bcc @E
		inc Ptr_H, x
	@E:
		rts
.endproc


;ループ値のあるアドレスのオフセットを計算してyにセット
.proc loopoffset
		lda LoopDepth, x
		sec
		sbc #1				;深度1がメモリ0の位置なので1引く
		ldx ProcTr			;トラック0なら終了
		beq @E
	@L:
		clc
		adc #MAX_LOOP
		dex
		bne @L
	@E:
		ldx ProcTr
		tay
		rts
.endproc


;n/8 aに割る数、yにnを入れて渡す
.proc ndiv8
		sta Work + 2
		lda #0
		sta Work + 3
		lda Work + 2
	@L:
		dey
		beq @E
		clc
		adc Work + 2
		bcc @L
		inc Work + 3
		jmp @L
	@E:
		sta Work + 2
		lsr Work + 3
		ror Work + 2
		lsr Work + 3
		ror Work + 2
		lsr Work + 3
		ror Work + 2
		lda Work + 2
		rts
.endproc


.rodata
Freq_Tbl:
	.word	$1a7f
	.word	$18ff
	.word	$177f
	.word	$163d
	.word	$14f9
	.word	$13de
	.word	$12bd
	.word	$11bf
	.word	$10be
	.word	$0fbb
	.word	$0ed7
	.word	$0df6

.ifdef VRC6
Freq_Saw:
	.word	$1e6c
	.word	$1ca2
	.word	$1b18
	.word	$1991
	.word	$1815
	.word	$16ba
	.word	$1584
	.word	$144f
	.word	$1315
	.word	$1214
	.word	$1110
	.word	$1010
.endif

.ifdef SS5B
Freq_5B:
	.word	$1ab9
	.word	$1935
	.word	$17ce
	.word	$1675
	.word	$1531
	.word	$1402
	.word	$12e1
	.word	$11d4
	.word	$10d3
	.word	$0fdf
	.word	$0efc
	.word	$0e24
.endif