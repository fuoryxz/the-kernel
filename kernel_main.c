

#include <stdint.h>
#include <stddef.h>

static uint16_t* const VGA_MEMORY = (uint16_t*) 0xB8000;
static const int VGA_WIDTH = 80;
static const int VGA_HEIGHT = 25;

static int cursor_row = 0;
static int cursor_col = 0;

static inline uint8_t vga_color(uint8_t fg, uint8_t bg) {
    return fg | bg << 4;
}

static inline uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t) c | (uint16_t) color << 8;
}

void terminal_clear(uint8_t color) {
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            VGA_MEMORY[y * VGA_WIDTH + x] = vga_entry(' ', color);
        }
    }
}

void terminal_putc(char c, uint8_t color) {
    if (c == '\n') {
        cursor_col = 0;
        cursor_row++;
        return;
    }
    VGA_MEMORY[cursor_row * VGA_WIDTH + cursor_col] = vga_entry(c, color);
    cursor_col++;
    if (cursor_col >= VGA_WIDTH) {
        cursor_col = 0;
        cursor_row++;
    }
    if (cursor_row >= VGA_HEIGHT) {
        cursor_row = 0; 
    }
}

void terminal_print(const char* str, uint8_t color) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        terminal_putc(str[i], color);
    }
}


void kernel_main(void) {
    uint8_t color = vga_color(15 /* белый */, 1 /* синий фон */);
    terminal_clear(color);
    terminal_print("Moy Kernel zagruzilsya uspeshno!\n", color);
    terminal_print("Rezhim: 32-bit protected mode, Multiboot.\n", color);
    terminal_print("Sleduyushiy shag: GDT, IDT, klaviatura, pamyat...\n", color);

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
