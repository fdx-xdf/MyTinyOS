#定义一大堆变量，实质就是将需要多次重复用到的语句定义一个变量方便使用与替换
BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
AS = nasm
CC = gcc-4.4
LD = ld
LIB = -I lib/ -I lib/kernel/ -I lib/user/ -I kernel/ -I device/ -I thread/
# HD60M_PATH=/home/john/bochs-gdb/hd60M.img
HD60M_PATH=/home/john/bochs/hd60M.img
ASFLAGS = -f elf -g 
CFLAGS = -Wall $(LIB) -c -fno-builtin -W -Wstrict-prototypes \
         -Wmissing-prototypes -m32 -g
#-Wall warning all的意思，产生尽可能多警告信息，-fno-builtin不要采用内部函数，
#-W 会显示警告，但是只显示编译器认为会出现错误的警告
#-Wstrict-prototypes 要求函数声明必须有参数类型，否则发出警告。-Wmissing-prototypes 必须要有函数声明，否则发出警告
LDFLAGS= -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map -m elf_i386
OBJS=$(BUILD_DIR)/main.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/init.o $(BUILD_DIR)/memory.o \
	$(BUILD_DIR)/interrupt.o $(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/list.o\
	$(BUILD_DIR)/print.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/string.o $(BUILD_DIR)/bitmap.o \
	$(BUILD_DIR)/switch.o $(BUILD_DIR)/sync.o $(BUILD_DIR)/console.o\

######################编译两个启动文件的代码#####################################
boot:$(BUILD_DIR)/mbr.o $(BUILD_DIR)/loader.o
$(BUILD_DIR)/mbr.o:boot/mbr.s
	$(AS) -I boot/include/ -o build/mbr.o boot/mbr.s
	
$(BUILD_DIR)/loader.o:boot/loader.s
	$(AS) -I boot/include/ -o build/loader.o boot/loader.s

######################编译C内核代码###################################################
$(BUILD_DIR)/main.o:kernel/main.c
	$(CC) $(CFLAGS) -o $@ $<	
# $@表示规则中目标文件名的集合这里就是$(BUILD_DIR)/main.o  $<表示规则中依赖文件的第一个，这里就是kernle/main.c 
$(BUILD_DIR)/thread.o:thread/thread.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/sync.o:thread/sync.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/init.o:kernel/init.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/interrupt.o:kernel/interrupt.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/timer.o:device/timer.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/console.o:device/console.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/debug.o:kernel/debug.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/list.o:lib/kernel/list.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/bitmap.o:lib/kernel/bitmap.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/string.o:lib/string.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/memory.o:kernel/memory.c
	$(CC) $(CFLAGS) -o $@ $<
###################编译汇编内核代码#####################################################
$(BUILD_DIR)/kernel.o:kernel/kernel.s 
	$(AS) $(ASFLAGS) -I lib/ -o $@ $<

$(BUILD_DIR)/print.o:lib/kernel/print.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/switch.o:thread/switch.s
	$(AS) $(ASFLAGS) -o $@ $<


##################链接所有内核目标文件##################################################
$(BUILD_DIR)/kernel.bin:$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^
# $^表示规则中所有依赖文件的集合，如果有重复，会自动去重

.PHONY:mk_dir hd clean build all boot gdb_symbol	#定义了7个伪目标
mk_dir:
	if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi 
#判断build文件夹是否存在，如果不存在，则创建

hd:
	dd if=build/mbr.o of=$(HD60M_PATH) count=1 bs=512 conv=notrunc && \
	dd if=build/loader.o of=$(HD60M_PATH) count=4 bs=512 seek=2 conv=notrunc && \
	dd if=$(BUILD_DIR)/kernel.bin of=$(HD60M_PATH) bs=512 count=200 seek=9 conv=notrunc
	
clean:
	@cd $(BUILD_DIR) && rm -f ./* && echo "remove ./build all done"
#-f, --force忽略不存在的文件，从不给出提示，执行make clean就会删除build下所有文件

build:$(BUILD_DIR)/kernel.bin
	
#执行build需要依赖kernel.bin，但是一开始没有，就会递归执行之前写好的语句编译kernel.bin

gdb_symbol:
	objcopy --only-keep-debug $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/kernel.sym

all:mk_dir boot build hd gdb_symbol
#make all 就是依次执行mk_dir build hd
