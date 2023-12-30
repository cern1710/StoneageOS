# Define the assembler and the qemu command
ASM = nasm
QEMU = qemu-system-x86_64

# Define the output directory
OUT_DIR = out

# Targets
all: build run

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

build: $(OUT_DIR)
	$(ASM) src/boot.s -o $(OUT_DIR)/boot.bin
	$(ASM) src/kernel.s -o $(OUT_DIR)/kernel.bin -i src/
	dd if=/dev/zero of=$(OUT_DIR)/stoneageos.img bs=1024 count=1440
	dd if=$(OUT_DIR)/boot.bin of=$(OUT_DIR)/stoneageos.img conv=notrunc
	dd if=$(OUT_DIR)/kernel.bin of=$(OUT_DIR)/stoneageos.img bs=512 seek=1 conv=notrunc

run:
	$(QEMU) -drive format=raw,file=$(OUT_DIR)/stoneageos.img -monitor stdio -serial file:$(OUT_DIR)/log

clean:
	rm -rf $(OUT_DIR)

.PHONY: all build run clean