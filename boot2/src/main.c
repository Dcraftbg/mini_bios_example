#include <stdint.h>
#include <stddef.h>
enum {
    VGA_COLOR_BLACK,
    VGA_COLOR_BLUE,
    VGA_COLOR_GREEN,
    VGA_COLOR_CYAN,
    VGA_COLOR_RED,
    VGA_COLOR_MAGENTA,
    VGA_COLOR_BROWN,
    VGA_COLOR_LIGHT_GREY,
    VGA_COLOR_DARK_GREY,
    VGA_COLOR_LIGHT_BLUE,
    VGA_COLOR_LIGHT_GREEN,
    VGA_COLOR_LIGHT_CYAN,
    VGA_COLOR_LIGHT_RED,
    VGA_COLOR_LIGHT_MAGENTA,
    VGA_COLOR_LIGHT_BROWN,
    VGA_COLOR_WHITE
};
#define VGA_ADDR 0xB8000 
#define vga_entry(c, fg, bg) ((c) | ((fg) << 8) | ((bg) << 12))

void main(void) {
    uint16_t* vga = (uint16_t*)VGA_ADDR;
    const char* str = "Hello World from C land";
    size_t idx = 0;
    while(*str) vga[idx++] = vga_entry(*str++, VGA_COLOR_GREEN, 0);
}
