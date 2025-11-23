arch ?= x86_64
kernel := build/hys-kernel-$(arch).bin
iso := build/hys-cute-$(arch).iso

arch_dir := src/arch/$(arch)

linker_script := $(arch_dir)/linker.ld
linker_flags := -T $(linker_script) -z noexecstack
grub_cfg := $(arch_dir)/grub.cfg
asm_src = $(wildcard $(arch_dir)/*.asm)
asm_obj = $(patsubst $(arch_dir)/%.asm, build/arch/$(arch)/%.o, $(asm_src))

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -r build
	@cargo clean

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles
	@rm -r build/isofiles

rust_kernel = target/hys-os-$(arch)/release/libhys_os.a
$(kernel) : $(linker_script) $(asm_obj)
	@echo "Making $(arch) kernel"
	@cargo build --release
	@x86_64-elf-ld -n $(linker_flags) -o $(kernel) $(asm_obj) $(rust_kernel)

build/arch/$(arch)/%.o: $(arch_dir)/%.asm
	@mkdir -p $(shell dirname $@)
	@x86_64-elf-as $< -o $@
