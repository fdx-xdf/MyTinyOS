TI_GDT equ  0
RPL0  equ   0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

section .data
put_int_buffer    dq    0     ; 定义8字节缓冲区用于数字到字符的转换

[bits 32]
section .text
;--------------------------------------------
;put_str 通过put_char来打印以0字符结尾的字符串
;--------------------------------------------
;输入：栈中参数为打印的字符串
;输出：无

global put_str
put_str:
    push ebx
    push ecx
    xor ecx, ecx
    mov ebx, [esp + 12]     ;3*4=12,获取参数地址
.goon:
    mov cl, [ebx]       ;获取字符
    cmp cl, 0           ;与结束符对比
    jz .str_over
    push ecx
    call put_char
    add esp, 4          ;平栈
    inc ebx             ;下一个字符
    jmp .goon
.str_over:
    pop ecx
    pop ebx
    ret


;------------------------   put_char   -----------------------------
;功能描述:把栈中的1个字符写入光标所在处
;-------------------------------------------------------------------   
global put_char ;导出函数
put_char:
    pushad	   ;备份32位寄存器环境,8个寄存器全部备份
    ;需要保证gs中为正确的视频段选择子,为保险起见,每次打印时都为gs赋值
    mov ax, SELECTOR_VIDEO	       ; 不能直接把立即数送入段寄存器
    mov gs, ax

;;;;;;;;;  获取当前光标位置 ;;;;;;;;;
   ;先获得高8位
    mov dx, 0x3d4   ;索引寄存器
    mov al, 0x0e     ;用于提供光标位置的高8位
    out dx, al      

    mov dx, 0x3d5   ;通过读写数据端口0x3d5来获得或设置光标位置 
    in al, dx       ;得到了光标位置的高8位
    mov ah, al      ;高八位放到ah寄存器

    ;再获得低8位
    mov dx, 0x3d4   ;索引寄存器
    mov al, 0x0f     ;用于提供光标位置的高8位
    out dx, al      

    mov dx, 0x3d5   ;通过读写数据端口0x3d5来获得或设置光标位置 
    in al, dx       ;得到了光标位置的高8位

    ;将光标存入bx
    mov bx, ax	
    ;下面这行是在栈中获取待打印的字符
    mov ecx, [esp + 36]   ;八个32位寄存器+1个32位返回地址 4*9=36
    cmp cl, 0xd				  ;CR是0x0d,LF是0x0a
    jz .is_carriage_return
    cmp cl, 0xa
    jz .is_line_feed

    cmp cl, 0x8				  ;BS(backspace)的asc码是8 退格符
    jz .is_backspace
    jmp .put_other	   
;;;;;;;;;;;;;;;;;;

 .is_backspace:		      
;;;;;;;;;;;;       backspace的一点说明	     ;;;;;;;;;;
; 当为backspace时,本质上只要将光标移向前一个显存位置即可.后面再输入的字符自然会覆盖此处的字符
; 但有可能在键入backspace后并不再键入新的字符,这时在光标已经向前移动到待删除的字符位置,但字符还在原处,
; 这就显得好怪异,所以此处添加了空格或空字符0
    dec bx                      ; 退格
    shl bx, 1                   ; 光标位置是用2字节表示,将光标值乘2,表示对应显存中的偏移字节
    mov byte [gs:bx], 0x20      ; 将待删除的字节补为0或空格皆可
    inc bx
    mov byte [gs:bx], 0x07      ; 高字节属性
    shr bx,1                    ; 变会光标位置
    jmp .set_cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 .put_other:
    shl bx, 1
    mov [gs:bx], cl     ; 字符存在ecx, 但是只需cl就可以表示
    inc bx
    mov byte [gs:bx], 0x07      ; 高字节属性
    shr bx, 1			; 恢复老的光标值
    inc bx				; 下一个光标值
    cmp bx, 2000		   
    jl .set_cursor		; 显示是80*25的 
                        ; 若光标值小于2000,表示未写到显存的最后,则去设置新的光标值
                        ; 若超出屏幕字符数大小(2000)则换行处理

.is_line_feed:		    ; 是换行符LF(\n)
.is_carriage_return:	; 是回车符CR(\r)
    					; 这两种都是把光标移到下一行行首就行了。
    xor dx, dx
    mov ax, bx				  ; ax是被除数的低16位.
    mov si, 80				  ; 一行80个字节
    div si
    sub bx, dx				  ; 光标值减去除80的余数便是取整

    add bx, 80                ; 换行
    cmp bx, 2000              ; 判断是否滚屏
    jl .set_cursor


;屏幕行范围是0~24,滚屏的原理是将屏幕的1~24行搬运到0~23行,再将第24行用空格填充
.roll_screen:				  ; 若超出屏幕大小，开始滚屏
    cld     
    mov ecx, 960				  ; 一共有2000-80=1920个字符要搬运,共1920*2=3840字节.一次搬4字节,共3840/4=960次 
    mov esi, 0xb80a0			  ; 第1行行首
    mov edi, 0xb8000			  ; 第0行行首
    rep movsd

;;;;;;;将最后一行填充为空白
    mov ebx, 3840			  ; 最后一行首字符的第一个字节偏移= 1920 * 2
    mov ecx, 80				  ;一行是80字符(160字节),每次清空1字符(2字节),一行需要移动80次
.cls:
    mov word [gs:ebx], 0x0720		  ;0x0720是黑底白字的空格键
    add ebx, 2
    loop .cls 

    mov bx,1920				  ;将光标值重置为1920,最后一行的首字符.
    
 .set_cursor:  
;将光标设为bx值
;;;;;;; 1 先设置高8位 ;;;;;;;;
    mov dx, 0x3d4   ;索引寄存器
    mov al, 0x0e     ;用于提供光标位置的高8位
    out dx, al      

    mov dx, 0x3d5   ;通过读写数据端口0x3d5来获得或设置光标位置 
    mov al, bh      ;高八位给到al
    out dx, al      ;写过去


;;;;;;;再设置低8位 ;;;;;;;;
    mov dx, 0x3d4   ;索引寄存器
    mov al, 0x0f    ;用于提供光标位置的高8位
    out dx, al      

    mov dx, 0x3d5   ;通过读写数据端口0x3d5来获得或设置光标位置 
    mov al, bl      ;低八位给到al
    out dx, al      ;写过去
;结束
.put_char_done: 
   popad
   ret


;--------------------   将小端字节序的数字变成对应的ascii后，倒置   -----------------------
;输入：栈中参数为待打印的数字
;输出：在屏幕上打印16进制数字,并不会打印前缀0x,如打印10进制15时，只会直接打印f，不会是0xf
;------------------------------------------------------------------------------------------
global put_int
put_int:
    pushad
    mov ebp, esp
    mov eax, [ebp + 9*4]    ;拿到参数
    mov edx, eax
    mov edi, 7      ; 指定在put_int_buffer中初始的偏移量
    mov ecx, 8		; 32位数字中,16进制数字的位数是8个
    mov ebx, put_int_buffer

;将32位数字按照16进制的形式从低位到高位逐个处理,共处理8个16进制数字
.16based_4bits:		        ; 每4位二进制是16进制数字的1位,遍历每一位16进制数字
    and edx, 0x0000000F	    ; 解析16进制数字的每一位。and与操作后,edx只有低4位有效
    cmp edx, 9			    ; 数字0～9和a~f需要分别处理成对应的字符
    jg .is_A2F 
    add edx, '0'			; ascii码是8位大小。add求和操作后,edx低8位有效。
    jmp .store
.is_A2F:
    sub edx, 10              ;A~F 减去10 所得到的差,再加上字符A的ascii码,便是A~F对应的ascii码
    add edx, 'A'

;将每一位数字转换成对应的字符后,按照类似“大端”的顺序存储到缓冲区put_int_buffer
;高位字符放在低地址,低位字符要放在高地址,这样和大端字节序类似,只不过咱们这里是字符序.
.store:
; 此时dl中应该是数字对应的字符的ascii码
    mov [ebx+edi], dl	
    dec edi             ; 原来是小端，现在是大端，所以要逆着表示
    shr eax, 4          ; 下一个数字
    mov edx, eax
    loop .16based_4bits

;现在put_int_buffer中已全是字符,打印之前,
;把高位连续的字符去掉,比如把字符000123变成123
.ready_to_print:
   inc edi			       ; 此时edi退减为-1(0xffffffff),加1使其为0
.skip_prefix_0:  
    cmp edi,8			    ; 若已经比较第9个字符了，表示待打印的字符串为全0 
    je .full0 
;找出连续的0字符, edi做为非0的最高位字符的偏移
.go_on_skip: 
    mov cl, [put_int_buffer + edi]
    inc edi
    cmp cl, '0'
    je .skip_prefix_0
    dec edi			       ;edi在上面的inc操作中指向了下一个字符,若当前字符不为'0',要恢复edi指向当前字符		       
    jmp .put_each_num

.full0:
    mov cl,'0'	    ; 输入的数字为全0时，则只打印0,并且此时edi为8
.put_each_num:
    push ecx        ; 此时cl中为打印字符
    call put_char
    add esp, 4
    inc edi         ; 指向下一个
    mov cl, [put_int_buffer+edi]	
    cmp edi, 8
    jl .put_each_num

    popad
    ret


