#!/bin/sh
#编译并写入mbr
nasm -I ./boot/include/ -o ./build/mbr.bin ./boot/mbr.s
dd if=./build/mbr.bin of=../../hd60M.img bs=512 count=1 conv=notrunc

#编译并写入loader
nasm -I ./boot/include/ -o ./build/loader.bin ./boot/loader.s
dd if=./build/loader.bin of=../../hd60M.img bs=512 count=4 seek=2  conv=notrunc

#编译mian
gcc-4.4 -I ./lib/kernel -I ./lib/ -I ./kernel/ -fno-builtin  -c -o ./build/main.o ./kernel/main.c -m32 

#编译pirnt
nasm -f elf -o build/print.o lib/kernel/print.s
#编译kernel
nasm -f elf -o build/kernel.o kernel/kernel.s

#编译interrupt
gcc-4.4 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin -o build/interrput.o -m32 kernel/interrupt.c

#编译init
gcc-4.4 -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin -o build/init.o kernel/init.c


#链接成内核
ld -m elf_i386 -Ttext 0x00001500 -e main -o build/kernel.bin  build/main.o build/kernel.o build/init.o build/interrput.o build/print.o


#写入内核
dd if=./build/kernel.bin of=../../hd60M.img bs=512 count=200 seek=9  conv=notrunc

#清除build文件夹内所有的编译好的二进制文件
rm -rf build/*
    