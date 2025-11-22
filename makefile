arch ?= x86_64
kernel := build/hys-kernel-$(arch).bin
iso := build/hys-cute-$(arch).iso

arch_dir := arch/$(arch)

linker_script := $(arch_dir)/linker.ld
grub_cfg := $(arch_dir)/grub.cfg
asm_src = $(wildcard $(arch_dir)/*.asm)
asm_obj = $(patsubst $(arch_dir)/%.asm, build/arch/$(arch)/%.o, $(asm_src))

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles
	@rm -r build/isofiles

$(kernel) : $(linker_script) $(asm_obj)
	@echo "Making $(arch)"
	@x86_64-elf-ld -n -T $(linker_script) -o $(kernel) $(asm_obj)

build/arch/$(arch)/%.o: $(arch_dir)/%.asm
	@mkdir -p $(shell dirname $@)
	@x86_64-elf-as $< -o $@
