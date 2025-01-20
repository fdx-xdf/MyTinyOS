nasm -I ./boot/include/ -o ./boot/mbr.bin ./boot/mbr.s
dd if=./boot/mbr.bin of=../../hd60M.img bs=512 count=1 conv=notrunc

nasm -I ./boot/include/ -o ./boot/loader.bin ./boot/loader.s
dd if=./boot/loader.bin of=../../hd60M.img bs=512 count=4 seek=2  conv=notrunc


nasm -f elf -o lib/kernel/print.o lib/kernel/print.s    
gcc-4.4 -I ./lib/kernel -c -o ./kernel/main.o ./kernel/main.c -m32 
ld ./kernel/main.o ./lib/kernel/print.o -Ttext 0xc0001500 -e main -o ./kernel/kernel.bin -m elf_i386
dd if=./kernel/kernel.bin of=../../hd60M.img bs=512 count=200 seek=9  conv=notrunc
