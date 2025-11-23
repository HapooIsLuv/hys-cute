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
.align 4096
# these are for paging
p4_table:
  .skip 4096
p3_table:
  .skip 4096
p2_table:
  .skip 4096
stack_bottom:
.skip 64
stack_top:

.section .rodata
gdt64:
  null_segment:
  .quad 0
  code_segment:
  .equ EXECUTABLE, 1 << 43
  .equ CODE_DESCRIPTOR, 1 << 44
  .equ PRESENT_BIT, 1 << 47
  .equ LM_DESCRIPTOR, 1 << 53
  .quad EXECUTABLE | CODE_DESCRIPTOR | PRESENT_BIT | LM_DESCRIPTOR
gdt64_end:
gdt_descriptor:
  .word gdt64_end - gdt64 - 1
  .quad gdt64

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

  call set_up_paging_tables
  call enable_paging

  cli #disable interrupts
  lgdt gdt_descriptor
  .equ CODE_SEG, 0x08
  ljmp $CODE_SEG, $lm_start

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

set_up_paging_tables:
  mov $p3_table, %eax
  or $0b11, %eax # presentable & writable
  mov %eax, p4_table

  mov $p2_table, %eax
  or $0b11, %eax # presentable & writable
  mov %eax, p3_table

  mov $0, %ecx # initalize the counter value

.map_p2_table:
  mov $0x200000, %eax
  mul %ecx
  or $0b10000011, %eax # presentable & writable & huge
  mov %eax, p2_table(,%ecx,8)

  inc %ecx
  cmp $512, %ecx
  jne .map_p2_table

  ret

enable_paging:
  mov $p4_table, %eax
  mov %eax, %cr3 # the cr3 lets the CPU know where the paging tables are

  .equ CR4_PAE_ENABLE, 1 << 5
  # enable PAE
  mov %cr4, %eax
  or $CR4_PAE_ENABLE, %eax
  mov %eax, %cr4

  .equ EFER_MSR, 0xC0000080
  .equ EFER_LM_ENABLE, 1 <<8
  # set the long bit mode in the EFER MSR
  mov $EFER_MSR, %ecx
  rdmsr
  or $EFER_LM_ENABLE, %eax
  wrmsr

  .equ CR0_PG_ENABLE, 1 << 31
  # enable paging in the cr0 register
  mov %cr0, %eax
  or $CR0_PG_ENABLE, %eax
  mov %eax, %cr0

  ret

.code64
.extern kmain
lm_start:
  mov $0, %ax
  mov %ax, %ss
  mov %ax, %ds
  mov %ax, %es
  mov %ax, %fs
  mov %ax, %gs

  mov $0x2f592f412f4b2f4f, %rax
  mov %rax, VGA_BUF

  call kmain

  hlt
