SOURCE_PATH=src/
BUILD_PATH=build/
SCRIPTS_PATH=scripts/
RES_PATH=res/
DOSBOX_HOME=/home/$$(whoami)/dos
SIZE=`ls build/cosmo.com -l | cut -d' ' -f5`

all: $(BUILD_PATH)/cosmo.com

$(BUILD_PATH)/cosmo.com: $(SOURCE_PATH)cosmo.asm $(SOURCE_PATH)speaker_drv.asm
	@nasm $(SOURCE_PATH)cosmo.asm -o $(BUILD_PATH)cosmo.com -I$(SOURCE_PATH)
	@echo ✅ assembled: \\e[4m$(SIZE) bytes\\e[0m

gen_pal:
	@python $(SCRIPTS_PATH)gen_pal.py $(RES_PATH)palette.css 1

.PHONY: run clean

run: $(BUILD_PATH)cosmo.com
	@cp $(BUILD_PATH)cosmo.com $(DOSBOX_HOME)
	@dosbox $(BUILD_PATH)cosmo.com

clean:
	@rm -f $(BUILD_PATH)cosmo.com
