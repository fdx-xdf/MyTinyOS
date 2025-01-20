;主引导程序 
;------------------------------------------------------------
SECTION MBR vstart=0x7c00        ;起始地址  0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00       ;初始化栈
    ;这个时候 ds = es = ss = 0 栈指针指向MBR开始位置
   mov ax,0xb800
   mov gs,ax
   ;初始化段寄存器

    ;ah = 0x06 al = 0x00 想要调用int 0x06的BIOS提供的中断对应的函数 即向上移动即完成清屏功能
    ;cx dx 分别存储左上角与右下角的左边 详情看int 0x06函数调用
    mov ax,0x0600
    mov bx,0x700

    ;(CL,CH) = 窗口左上角的(X,Y)位置
    ;(DL,DH) = 窗口右下角的(X,Y)位置
    mov cx,0
    mov dx,0x184f
    
    ;调用BIOS中断
    int 0x10 

    ;;;;;;;;;    下面这三行代码是获取光标位置    ;;;;;;;;;
    ;.get_cursor获取当前光标位置,在光标位置处打印字符.
   mov ah, 3		; 输入: 3号子功能是获取光标位置,需要存入ah寄存器
   mov bh, 0		; bh寄存器存储的是待获取光标的页号

   int 0x10		; 输出: ch=光标开始行,cl=光标结束行
			; dh=光标所在行号,dl=光标所在列号

    ;  打印字符串  
    ;新增功能 直接操作显存部分
    ;预设输出FDX   OS

    
    mov byte [gs:0x00],'F' ;低位字节储存ascii字符 小端储存内存顺序相反
    mov byte [gs:0x01],0xA4    ;背景储存在第二个字节 含字符与背景属性
    
    mov byte [gs:0x02],'D' 
    mov byte [gs:0x03],0xA4
    
    mov byte [gs:0x04],'X' 
    mov byte [gs:0x05],0xA4
    
    mov byte [gs:0x06],' ' 
    mov byte [gs:0x07],0xA4

    mov byte [gs:0x08],' ' 
    mov byte [gs:0x09],0xA4

    mov byte [gs:0x0A],' ' 
    mov byte [gs:0x0B],0xA4
    
    mov byte [gs:0x0C],'O' 
    mov byte [gs:0x0D],0xA4
    
    mov byte [gs:0x0E],'S' 
    mov byte [gs:0x0F],0xA4


    jmp $		; 死循环

    ;字符串声明 db == define byte dw == define word ascii一个字符占一个字节
    message db "1 MBR" 

    ;预留两个字节 其余空余的全部用0填满 为使检测当前扇区最后两字节为0x55 0xaa 检测是否为有效扇区
    ;510 = 512字节-2预留字节  再减去（当前位置偏移量-段开始位置偏移量）求出来的是剩余空间
    times 510 - ($ - $$) db 0 
    db 0x55,0xaa



