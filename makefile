
CC = gcc
AS = nasm
LD = ld

CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-pie -Wall -Wextra -c
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib

all: kernel.bin

boot.o: boot.asm
	$(AS) $(ASFLAGS) boot.asm -o boot.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) kernel.c -o kernel.o

kernel.bin: boot.o kernel.o linker.ld
	$(LD) $(LDFLAGS) -o kernel.bin boot.o kernel.o

iso: kernel.bin grub.cfg
	mkdir -p isodir/boot/grub
	cp kernel.bin isodir/boot/kernel.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o mykernel.iso isodir

run: kernel.bin
	qemu-system-i386 -kernel kernel.bin

clean:
	rm -rf *.o kernel.bin isodir mykernel.iso

.PHONY: all iso run clean
