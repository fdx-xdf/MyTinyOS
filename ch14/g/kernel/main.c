#include "print.h"
#include "init.h"
#include "fs.h"
#include "stdio.h"
#include "string.h"
#include "ide.h"
#include "super_block.h"

int main(void)
{
    put_str("I am kernel\n");
    init_all();
    uint32_t fd = sys_open("/file1", O_RDWR);
    printf("open /file1, fd:%d\n", fd);
    char buf[64] = {0};
    int read_bytes = sys_read(fd, buf, 18);
    printf("1_ read %d bytes:\n%s\n", read_bytes, buf);

    memset(buf, 0, 64);
    read_bytes = sys_read(fd, buf, 6);
    printf("2_ read %d bytes:\n%s", read_bytes, buf);

    memset(buf, 0, 64);
    read_bytes = sys_read(fd, buf, 6);
    printf("3_ read %d bytes:\n%s", read_bytes, buf);

    printf("________  SEEK_SET 0  ________\n");
    sys_lseek(fd, 0, SEEK_SET);
    memset(buf, 0, 64);
    read_bytes = sys_read(fd, buf, 24);
    printf("4_ read %d bytes:\n%s", read_bytes, buf);

    sys_close(fd);
    printf("%x\n",(uint32_t)cur_part->sb->block_bitmap_lba);
    printf("%x\n",(uint32_t)cur_part->sb->inode_bitmap_lba);
    printf("%x\n",(uint32_t)cur_part->sb->inode_table_lba);
    printf("%x\n",(uint32_t)cur_part->sb->data_start_lba);
    while (1)
        ;
    return 0;
}