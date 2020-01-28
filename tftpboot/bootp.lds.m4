OUTPUT_FORMAT(elf32-littlearm)
OUTPUT_ARCH(arm)
ENTRY(code_start)

PHDRS
{
	text		PT_LOAD AT(M4_CODE_ADDR) FLAGS(5);
}

SECTIONS
{
    . = M4_CODE_ADDR;
    .text : {
       . = ALIGN(4);
     } : text,
}
