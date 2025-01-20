#include "string.h"
#include "global.h"
#include "debug.h" //定义了ASSERT

// 将dst起始的size个字节置为value，这个函数最常用的用法就是来初始化一块内存区域，也就是置为ASCII码为0
void memset(void *dst_, uint8_t value, uint32_t size)
{
    ASSERT(dst_ != NULL); // 判断地址是否为空
    uint8_t *dst = (uint8_t *)dst_;
    while (size-- > 0)
        *dst++ = value;
}

// 将src地址起始处size字节的数据移入dst，用于拷贝内存数据
// src起始是有数据的，所以用const void*，const修饰void*，意味着地址内的数据是只读
void memcpy(void *dst_, const void *src_, uint32_t size)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    uint8_t *dst = (uint8_t *)dst_;
    const uint8_t *src = (uint8_t *)src_;
    while (size-- > 0)
        *dst++ = *src++;
}

// 比较两个地址起始的size字节的数据是否相等，如果相等，则返回0；如果不相等，比较第一个不相等的数据，>返回1，<返回-1
int memcmp(const void *a_, const void *b_, uint32_t size)
{
    const uint8_t *a = (uint8_t *)a_;
    const uint8_t *b = (uint8_t *)b_;
    ASSERT(a != NULL || b != NULL);
    while (size-- > 0)
    {
        if (*a != *b)
        {
            return *a > *b ? 1 : -1;
        }
        a++;
        b++;
    }
    return 0;
}

// 将字符串从src拷贝到dst,并返回目的字符串的起始地址
char *strcpy(char *dst_, const char *src_)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    char *a = dst_;
    while (*src)
    {
        *dst_++ = *src_++;
    }
    return a;
}

/* 返回字符串长度 */
uint32_t strlen(const char *str)
{
    ASSERT(str != NULL);
    const char *p = str;
    while (*p++)
        ; // 1、先取*p的值来进行2的判断     2、判断*p,决定是否执行循环体     3、p++(这一步的执行并不依赖2的判断为真)
    return (p - str - 1);
}

// 比较两个字符串，若a_中的字符与b_中的字符全部相同，则返回0，如果不同，那么比较第一个不同的字符，如果a_>b_返回1，反之返回-1
int8_t strcmp(const char *a, const char *b)
{
    ASSERT(a != NULL && b != NULL);
    while (*a != 0 && *a == *b)
    {
        a++;
        b++;
    }
    /* 如果*a小于*b就返回-1,否则就属于*a大于等于*b的情况。在后面的布尔表达式"*a > *b"中,
     * 若*a大于*b,表达式就等于1,否则就表达式不成立,也就是布尔值为0,恰恰表示*a等于*b */
    return *a < *b ? -1 : *a > *b;
}

/* 从左到右查找字符串str中首次出现字符ch的地址(不是下标,是地址) */
char *strchr(const char *str, const uint8_t ch)
{
    ASSERT(str != NULL);
    while (*str)
    {
        if (*str == ch)
            return (char *)str;
        else
            str++;
    }
    return NULL;
}

/* 从后往前查找字符串str中首次出现字符ch的地址(不是下标,是地址) */
char *strrchr(const char *str, const uint8_t ch)
{
    ASSERT(str != NULL);
    const char *last_char = NULL;
    /* 从头到尾遍历一次,若存在ch字符,last_char总是该字符最后一次出现在串中的地址(不是下标,是地址)*/
    while (*str != 0)
    {
        if (*str == ch)
        {
            last_char = str;
        }
        str++;
    }
    return (char *)last_char;
}

/* 将字符串src_拼接到dst_后,将回拼接的串地址 */
char *strcat(char *dst_, const char *src_)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    char *p = dst_;
    while (*p++)
        ;
    p--;
    while ((*p++ = *src_++))
        ; // 1、*str=*src  2、判断*str     3、str++与src++，这一步不依赖2
    return dst_;
}

/* 在字符串str中查找指定字符ch出现的次数 */
uint32_t strchrs(const char *str, uint8_t ch)
{
    ASSERT(str != NULL);
    uint32_t ch_cnt = 0;
    const char *p = str;
    while (*p != 0)
    {
        if (*p == ch)
        {
            ch_cnt++;
        }
        p++;
    }
    return ch_cnt;
}
