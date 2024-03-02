MAKE_NSF = 1
TOOL_PASS =	
INC_PASS = 
LIB_PASS =

########################################
#;	LOG files
########################################

LOG_FILE    =	comlog.txt
ERRLOG_FILE =	errlog.txt
BLDLOG_FILE =	buildlog.txt



########################################
#;	Define of build tools & option
########################################

#---------------
#;  MML Compiler (for Music & SE data)
MC      = $(TOOL_PASS)
MCFLAGS =

#---------------
#;  C Compiler
CC      = $(TOOL_PASS)cl65
CFLAGS  = -t none --listing $*.lst --list-bytes 255 -g -c -o

#---------------
#;  Assembler
AS      = $(TOOL_PASS)ca65
ASFLAGS = -t none --listing $*.lst --list-bytes 255 -g
ASFLAGS1 = -t none --listing $*.lst --list-bytes 255 -g -D MMC5=1 -o drv_mmc5.o
ASFLAGS2 = -t none --listing $*.lst --list-bytes 255 -g -D VRC6=1 -o drv_vrc6.o

#---------------
#;  Archiver
AR      = $(TOOL_PASS)ar65
ARFLAGS = a

#---------------
#;  Linker
LINKER  = $(TOOL_PASS)ld65
LDFLAGS = -C $(CFG_FILE) -L$(LIB_PASS) -v -m $(MAP_FILE) -vm --dbgfile $(DBG_FILE) -o

#---------------
#;  File delete
RM      = rm -f

#---------------
#;  File copy
CP      = copy



#===============================
#; 依存関係（ヘッダーファイル等を、依存関係に追加するために、定義）

%.o : %.s $(INC_FILES)			#;".inc"ファイルが更新された場合は、.sは、全部アセンブルする。
	@echo [Assemble] : $< >>$(ERRLOG_FILE)
	$(AS) $(ASFLAGS) $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)
	@echo [Assemble] : drv.s >>$(ERRLOG_FILE)
	$(AS) drv.s $(ASFLAGS1) 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)
	@echo [Assemble] : drv.s >>$(ERRLOG_FILE)
	$(AS) drv.s $(ASFLAGS2) 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)


%.s : %.mml $(DMC_FILES)		#;".dmc"ファイルが更新された場合は、.mmlは、全部コンパイルする。
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(LOG_FILE)
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(ERRLOG_FILE)
	$(MC) $(MCFLAGS) $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

#---------------------------------------
#;	Header files
#---------------------------------------

#---------------
#; アセンブリ言語用ヘッダー
INC_FILES =	drv.inc		\
			data.bin	\

#---------------
#; ⊿ＰＣＭファイル
DMC_FILES =	


#---------------------------------------
#;	Library files
#---------------------------------------

LIB_FILES =	



########################################
#;	Build process
########################################

ifdef MAKE_NSF

#---------------
#; リンカーの設定
CFG_FILE   =	nsf.cfg
MAP_FILE   =	drv.map
DBG_FILE   =	drv.dbg

#---------------
#; ソースファイル
MAIN_FILES =	main_nsf.o		\
				nsf.o			\
				crt0_nsf.o		\
				data_nsf.o		\

.PHONY: all clean

#---------------
#; build of main program
all : drv.bin drv_mmc5.bin drv_vrc6.bin

drv.bin : drv.o $(MAIN_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LDFLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

drv_mmc5.bin : drv_mmc5.o $(MAIN_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LDFLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

drv_vrc6.bin : drv_vrc6.o $(MAIN_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LDFLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

else

#---------------
#; リンカーの設定
CFG_FILE   =	nesa.cfg
MAP_FILE   =	test.map
DBG_FILE   =	test.dbg

#---------------
#; ソースファイル
MAIN_FILES =	ines.o	\
		crt0_nes.o		\
		nmi_main_nes.o	\
		irq_main.o		\
		main_nes.o		\
		drv.o			\
		data_nes.o		\
		dsp.o		\

dsp.bin : $(MAIN_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LDFLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

endif

#---------------
#; Crean up
clean:
#	@$(RM) *.nes		#NESファイルは、消さないでおく。
	@$(RM) *.bak
	@$(RM) *.map
	@$(RM) *.lst
	@$(RM) *.o

	@$(RM) $(LOG_FILE)
	@$(RM) $(ERRLOG_FILE)
	@$(RM) $(BLDLOG_FILE)
