#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <ext2fs/ext2fs.h>
#include <et/com_err.h>

ext2_filsys current_fs = NULL;
ext2_ino_t  root, cwd;

void help()
{
    puts("Usage: undelete -d /dev/sda1 -o /tmp/dump -i 11111");
    exit(1);
}

int main (int argc, char **argv)
{
    errcode_t retval = 0;
    char *buf = NULL, *device = NULL, *output = NULL;
    ext2_file_t e2file;
    int blocksize = sizeof(struct struct_ext2_filsys), bytesRead = 0, ino = 0, opt = 0, fd = -1;

    while ((opt = getopt(argc, argv, "d:o:i:")) != -1)
    {
        switch (opt)
        {
        case 'd':
            device = optarg;
            break;
        case 'o':
            output = optarg;
            break;   
        case 'i':
            ino = atoi(optarg);
            break;
        default:            
            help();
            break;      
        }
    }

    if (! device || ! output || ino <= 0)
    {
        help();
    }

    retval = ext2fs_open(device, EXT2_FLAG_SOFTSUPP_FEATURES, 0, 0, unix_io_manager, &current_fs);
    if (retval)
    {
        com_err(__func__, retval, "while trying to open device %s", device);
        return 1;
    }

    fd = open(output, O_WRONLY | O_CREAT, 0666);
    if (fd == -1)
    {
        com_err(__func__, retval, "while trying to open %s for writing", output);
        return 1;
    }

    retval = ext2fs_file_open(current_fs, ino, 0, &e2file);
    if (retval)
    {
        com_err(__func__, retval, "while trying to read inode");
        return 1;
    }

    retval = ext2fs_get_mem(blocksize, &buf);
    if (retval)
    {
        com_err(__func__, retval, "while allocating memory");
        return 1;
    }

    while (1)
    {
        retval = ext2fs_file_read(e2file, buf, blocksize, &bytesRead);
        if (retval)
        {
            com_err(__func__, retval, "while reading file");
            return 1;
        }

        if (bytesRead == 0)
        {
            break;
        }

        if (write(fd, buf, bytesRead) != bytesRead)
        {
            com_err(__func__, retval, "while writing file");
            return 1;
        }
    }

    close(fd);
    if (buf)
        ext2fs_free_mem(&buf);

    ext2fs_close(current_fs);
    ext2fs_free(current_fs);
    return 0;
}
