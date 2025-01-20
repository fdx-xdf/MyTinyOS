;主引导程序 
;------------------------------------------------------------
%include "boot.inc"
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


    mov eax, LOADER_START_SECTOR ;loader的lba扇区号
    mov bx, LOADER_BASE_ADDR ;loader的内存地址
    mov cx,4  ;读入的扇区数  一劳永逸
    call rd_disk_m_16

   jmp LOADER_BASE_ADDR


;-------------------------------------------------------------------------------
;功能:读取硬盘n个扇区
    ;eax =lba起始地址
    ;bx = 写入的内存地址
    ;cx = 读入的扇区数
rd_disk_m_16:

;1 写入待操作数
;2 写入LBA 低24位寄存器 确认扇区
;3 device 寄存器 第4位主次盘 第6位LBA模式 改为1
;4 command 写指令
;5 读取status状态寄存器 判断是否完成工作
;6 完成工作 取出数据

    mov esi, eax
    mov di, cx  ;做备份

;读写硬盘:
;第1步：设置要读取的扇区数
    mov dx, 0x1F2
    mov al, cl
    out dx, al

    mov eax,esi	   ;恢复ax

;第2步：将LBA地址存入0x1f3 ~ 0x1f6
    ;7-0位
    mov dx, 0x1F3
    out dx, al

    ;15-8位
    mov dx, 0x1F4
    mov cl,8
    shr eax, cl ;左移8位 获得15-8位的地址
    out dx, al

    ;23-16位
    mov dx, 0x1F5
    shr eax, cl ;继续左移
    out dx, al

    shr eax, cl ;继续左移,获得24-27位
    and al, 0x0f
    or al, 0xe0 ;这两行使得24-27位得以保留，并且7-4位设置为0110，表示lba模式
    mov dx, 0x1f6
    out dx, al

;第3步：向0x1f7端口写入读命令，0x20 
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    
;第4步：检测硬盘状态
  .not_ready:
    nop ;相当于 sleep 一下
    in al,dx
    and al,0x88	   ;第4位为1表示硬盘控制器已准备好数据传输，第7位为1表示硬盘忙
    cmp al,0x08
    jnz .not_ready	   ;若未准备好，继续等。

;第5步：从0x1f0端口读数据
    mov ax, di
    mov dx,256
    mul dx      ;乘积在ax
    mov cx, ax
    
    mov dx, 0x1f0
.go_on_read:
    in ax, dx   ;读到ax
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

   times 510-($-$$) db 0
   db 0x55,0xaa


    



