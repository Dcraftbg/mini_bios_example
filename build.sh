#!/bin/sh

set -xe


mkdir -p bin
mkdir -p bin/boot1
mkdir -p bin/boot2

nasm -f bin boot1/boot1.nasm -o bin/boot1.bin
nasm -f elf32 boot2/src/entry.nasm -o bin/boot2/entry.o
i686-linux-gnu-gcc -fno-pie -O2 -c boot2/src/main.c -o bin/boot2/main.o
i686-linux-gnu-ld bin/boot2/main.o bin/boot2/entry.o -T boot2/linker.ld -o bin/boot2.bin

cat bin/boot1.bin bin/boot2.bin > bin/boot.bin

qemu-system-x86_64 -drive format=raw,file=bin/boot.bin \
        -no-reboot --no-shutdown \
        -d int -D qemu.log

