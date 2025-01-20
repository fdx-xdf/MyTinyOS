nasm -I include/ -o loader.bin loader.s
dd if=./loader.bin of=../../../hd60M.img bs=512 count=1 seek=2 conv=notrunc