; boot.asm — Multiboot-заголовок и точка входа ядра
; Собирается NASM'ом в формат ELF32, чтобы GRUB мог загрузить наше ядро

MBALIGN     equ  1 << 0              ; выравнивать загружаемые модули по страницам
MEMINFO     equ  1 << 1              ; передать ядру карту памяти
MAGIC       equ  0x1BADB002          ; магическое число, которое ищет загрузчик (GRUB)
FLAGS       equ  MBALIGN | MEMINFO
CHECKSUM    equ -(MAGIC + FLAGS)

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; Стек ядра — 16 КБ
section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top   ; настраиваем стек
    cli                  ; отключаем прерывания на время инициализации

    call kernel_main     ; передаём управление в C-код ядра

    cli
.hang:
    hlt
    jmp .hang
