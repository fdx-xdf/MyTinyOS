nasm -I include/ -o mbr.bin mbr.s
dd if=./mbr.bin of=../../../hd60M.img bs=512 count=1 conv=notrunc

nasm -I include/ -o loader.bin loader.s
dd if=./loader.bin of=../../../hd60M.img bs=512 count=4 seek=2 conv=notrunc