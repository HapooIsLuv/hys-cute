ENTRY (_start)
SECTIONS
{
  . = 2M;
  .boot :
  {
    *(.multiboot_header)
  }

  .text :
  {
    *(.text)
  }

  .rodata :
  {
    *(.rodata)
  }

  .bss : 
  {
    *(COMMON)
    *(.bss)
  }
}
