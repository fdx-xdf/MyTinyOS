#include "shell.h"
#include "stdio.h"
#include "file.h"
#include "debug.h"
#include "syscall.h"
#include "string.h"
#include "buildin_cmd.h"

char cwd_cache[64] = {0};

#define cmd_len 128 // 最大支持键入128个字符的命令行输入
static char cmd_line[cmd_len] = {0};
#define MAX_ARG_NR 16 // 加上命令名外,最多支持15个参数

/* 输出提示符 */
void print_prompt(void)
{
    printf("[rabbit@localhost %s]$ ", cwd_cache);
}

/* 从键盘缓冲区中最多读入count个字节到buf。*/
static void readline(char *buf, int32_t count)
{
    ASSERT(buf != NULL && count > 0);
    char *pos = buf;
    while (read(stdin_no, pos, 1) != -1 && (pos - buf) < count)
    { // 在不出错情况下,直到找到回车符才返回
        switch (*pos)
        {
            /* 找到回车或换行符后认为键入的命令结束,直接返回 */
        case '\n':
        case '\r':
            *pos = 0; // 添加cmd_line的终止字符0
            putchar('\n');
            return;

        case '\b':
            if (buf[0] != '\b')
            {          // 阻止删除非本次输入的信息
                --pos; // 退回到缓冲区cmd_line中上一个字符
                putchar('\b');
            }
            break;
        /* ctrl+l 清屏 */
        case 'l' - 'a':
            /* 1 先将当前的字符'l'-'a'置为0 */
            *pos = 0;
            /* 2 再将屏幕清空 */
            clear();
            /* 3 打印提示符 */
            print_prompt();
            /* 4 将之前键入的内容再次打印 */
            printf("%s", buf);
            break;

        /* ctrl+u 清掉输入 */
        case 'u' - 'a':
            while (buf != pos)
            { // 从后向前删除缓冲区中cmd_line中的键入内容
                putchar('\b');
                *(--pos) = 0;
            }
            break;

        /* 非控制键则输出字符 */
        default:
            putchar(*pos);
            pos++;
        }
    }
    printf("readline: can`t find enter_key in the cmd_line, max num of char is 128\n");
}

char *argv[MAX_ARG_NR];              // argv必须为全局变量，为了以后exec的程序可访问参数
char final_path[MAX_PATH_LEN] = {0}; // 用于洗路径时的缓冲
int32_t argc = -1;

/* 分析字符串cmd_str中以token为分隔符的单词,将各单词的指针存入argv数组 */
static int32_t cmd_parse(char *cmd_str, char **argv, char token){
    ASSERT(cmd_str != NULL);
    int32_t arg_idx = 0;
    while (arg_idx < MAX_ARG_NR)
    {
        argv[arg_idx] = NULL;
        arg_idx++;
    }
    char *next = cmd_str;
    int32_t argc = 0;
    /* 外层循环处理整个命令行 */
    while (*next){
        /* 去除命令字或参数之间的空格 */
        while (*next == token)
            next++;
        /* 处理最后一个参数后接空格的情况,如"ls dir2 " */
        if (*next == 0)
            break;
        argv[argc] = next;
        /* 内层循环处理命令行中的每个命令字及参数 */
        while (*next && *next != token)
            next++;

        /* 如果未结束(是token字符),使tocken变成0 */
        // 到这里 *next肯定是tocken了
        if (*next)
            *next++ = 0;

        /* 避免argv数组访问越界,参数过多则返回0 */
        if (argc > MAX_ARG_NR)
            return -1;

        argc++;
    }
    return argc;
}

/* 简单的shell */
void my_shell(void)
{
    cwd_cache[0] = '/';
    
    while (1)
    {
        print_prompt();
        memset(cmd_line, 0, cmd_len);
        readline(cmd_line, cmd_len);
        if (cmd_line[0] == 0)
        { // 若只键入了一个回车
            continue;
        }
        argc = -1;
        argc = cmd_parse(cmd_line, argv, ' ');
        if (argc == -1)
        {
            printf("num of arguments exceed %d\n", MAX_ARG_NR);
            continue;
        }

        if (!strcmp("ls", argv[0]))
        {
            buildin_ls(argc, argv);
        }
        else if (!strcmp("cd", argv[0]))
        {
            if (buildin_cd(argc, argv) != NULL)
            {
                memset(cwd_cache, 0, MAX_PATH_LEN);
                strcpy(cwd_cache, final_path);
            }
        }
        else if (!strcmp("pwd", argv[0]))
        {
            buildin_pwd(argc, argv);
        }
        else if (!strcmp("ps", argv[0]))
        {
            buildin_ps(argc, argv);
        }
        else if (!strcmp("clear", argv[0]))
        {
            buildin_clear(argc, argv);
        }
        else if (!strcmp("mkdir", argv[0]))
        {
            buildin_mkdir(argc, argv);
        }
        else if (!strcmp("rmdir", argv[0]))
        {
            buildin_rmdir(argc, argv);
        }
        else if (!strcmp("rm", argv[0]))
        {
            buildin_rm(argc, argv);
        }
        else
        {
            printf("external command\n");
        }
        printf("\n");
    }
    PANIC("my_shell: should not be here");
}

