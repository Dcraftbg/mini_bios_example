struc Boot2Header
    .sector_count resw 1
    .boot_disk resb 1
    .boot_sectors_per_track resw 1
    .boot_number_of_heads resw 1
    .entry resb 0
endstruc
