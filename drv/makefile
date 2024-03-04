#DEBUG = 1

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

#---------------
#;  Archiver
AR      = $(TOOL_PASS)ar65
ARFLAGS = a

#---------------
#;  Linker
LINKER  = $(TOOL_PASS)ld65
LD_NSF_FLAGS = -C $(CFG_NSF_FILE) -L$(LIB_PASS) -v -m $(MAP_NSF_FILE) -vm --dbgfile $(DBG_NSF_FILE) -o
LD_DSP_FLAGS = -C $(CFG_DSP_FILE) -L$(LIB_PASS) -v -m $(MAP_DSP_FILE) -vm --dbgfile $(DBG_DSP_FILE) -o

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
	$(AS) drv.s $(ASFLAGS) -D MMC5=1 -o drv_mmc5.o 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)
	@echo [Assemble] : drv.s >>$(ERRLOG_FILE)
	$(AS) drv.s $(ASFLAGS) -D VRC6=1 -o drv_vrc6.o 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)


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

#---------------
#; リンカーの設定
CFG_NSF_FILE   =	nsf.cfg
MAP_NSF_FILE   =	drv.map
DBG_NSF_FILE   =	drv.dbg

ifdef DEBUG
CFG_DSP_FILE   =	nesd.cfg
else
CFG_DSP_FILE   =	nes.cfg
endif
MAP_DSP_FILE   =	dsp.map
DBG_DSP_FILE   =	dsp.dbg

#---------------
#; ソースファイル
MAIN_NSF_FILES =	main_nsf.o		\
					nsf.o			\
					crt0_nsf.o		\
					data_nsf.o		\

ifdef DEBUG

MAIN_DSP_FILES =	ines.o			\
					crt0_nes.o		\
					nmi_main_nes.o	\
					irq_main.o		\
					main_nes.o		\
					drv.o			\
					data_dbg.o		\
					dsp.o			\

else

MAIN_DSP_FILES =	ines.o			\
					crt0_nes.o		\
					nmi_main_nes.o	\
					irq_main.o		\
					main_nes.o		\
					drv.o			\
					data_nes.o		\
					dsp.o			\

endif

.PHONY: all clean


#---------------
#; build of main program

ifdef DEBUG

all : dsp.nes

dsp.nes : $(MAIN_DSP_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LD_DSP_FLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

else

all : drv.bin drv_mmc5.bin drv_vrc6.bin dsp.bin

drv.bin : drv.o $(MAIN_NSF_FILES)
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LD_NSF_FLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

drv_mmc5.bin : drv_mmc5.o $(MAIN_NSF_FILES)
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LD_NSF_FLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

drv_vrc6.bin : drv_vrc6.o $(MAIN_NSF_FILES)
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LD_NSF_FLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

dsp.bin : $(MAIN_DSP_FILES) $(CHR_FILES) 
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LD_DSP_FLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

endif


#---------------
#; Crean up
clean:
	@$(RM) *.nes		#NESファイルは、消さないでおく。
	@$(RM) *.bak
	@$(RM) *.map
	@$(RM) *.lst
	@$(RM) *.o

	@$(RM) $(LOG_FILE)
	@$(RM) $(ERRLOG_FILE)
	@$(RM) $(BLDLOG_FILE)
