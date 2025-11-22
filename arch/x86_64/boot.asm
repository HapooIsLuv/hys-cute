.section .multiboot_header
.align 8
.header_start:
  .equ MAGIC_NUM, 0xe85250d6
  .equ ARCH, 0 # protected mode i386
  .equ HEADER_LENGTH, (.header_start - .header_end)
  .equ CKSUM, 0x100000000 - (MAGIC_NUM + ARCH + HEADER_LENGTH)

  .long MAGIC_NUM
  .long ARCH
  .long HEADER_LENGTH
  .long CKSUM

  .align 8
  # end tag
  .word 0
  .word 0
  .long 8
.header_end:

.section .bss
stack_bottom:
.skip 64
stack_top:

.equ VGA_BUF, 0xb8000

.global _start
.section .text
.type _start, @function
.code32
_start:
  #set up the stack
  mov $stack_top, %esp
  call ck_multiboot
  call ck_cpuid
  call ck_long_mode

  movl $0x2f4b2f4f, VGA_BUF
  hlt
err: # put ERR: and then the al register
  movl $0x4f524f45, VGA_BUF
  movl $0x4f3a4f52, VGA_BUF + 4
  movl $0x4f204f20, VGA_BUF + 8
  movb %al, VGA_BUF + 12
  hlt

ck_multiboot:
  cmp $0x36d76289, %eax
  jne .no_multiboot
  ret
.no_multiboot:
  mov $'0', %al
  jmp err

ck_cpuid:
  .equ EFLAGS_ID, 1 << 21 # if this bit can be flipped, the cpuid instruction is available!
  pushfl
  pop %eax

  mov %eax, %ecx # save the original value for comparison
  xor $EFLAGS_ID, %eax

  push %eax # save to eflags
  popfl
  pushfl # restore the eflags
  pop %eax

  push %ecx
  popfl

  xor %ecx, %eax
  jnz .cpuid_supported
  .not_supported:
    mov $'1', %al
    jmp err
  .cpuid_supported:
    ret

ck_long_mode:
  .equ CPUID_EXTENSIONS,   0x80000000
  .equ CPUID_EXT_FEATURES, 0x80000001
  .equ CPUID_EDX_EXT_FEAT_LM, 1 << 29 # if this is set, it supports long mode

  .query_long_mode:
    mov $CPUID_EXTENSIONS, %eax
    cpuid
    cmp $CPUID_EXT_FEATURES, %eax
    jb .no_long_mode
    ret

    mov $CPUID_EXT_FEATURES, %eax
    cpuid
    test $CPUID_EDX_EXT_FEAT_LM, %edx
    jz .no_long_mode
    ret
  .no_long_mode:
    mov $'2', %al
    jmp err
