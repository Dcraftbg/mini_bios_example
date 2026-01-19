OUTPUT_FORMAT(binary)
ENTRY(_start)
SECTIONS
{
    . = 0x7e00;
    .header :
    {
        SHORT((__binary_end - . + 511) / 512)
        /*boot_disk*/ 
        BYTE(0)
        /*boot_sectors_per_track*/ 
        SHORT(0)
        /*boot_number_of_heads*/
        SHORT(0)
    }
    .entry : {
        *(.entry)
    }
    .text :
    {
        *(.text*)
    }

    .rodata :
    {
        *(.rodata*)
    }

    .data :
    {
        *(.data*)
        *(COMMON)
        *(.bss*)
    }
    __binary_end = .;
}
