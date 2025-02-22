#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
#include "memory.h"
#include "thread.h"
#include "console.h"
#include "keyboard.h"
#include "tss.h"
#include "syscall-init.h"
#include "ide.h"
#include "fs.h"

/*负责初始化所有模块 */
void init_all() {
   put_str("init_all\n");
   idt_init();       // 初始化中断
   mem_init();	      // 初始化内存管理系统
   thread_init();    // 初始化线程相关结构
   timer_init();     // 时钟初始化
   console_init();   // 控制台初始化最好放在开中断之前
   keyboard_init();  // 键盘初始化
   tss_init();       // tss初始化
   syscall_init();   // syscall初始化
   ide_init();       // ide初始化
   filesys_init();   // 文件系统初始化
}