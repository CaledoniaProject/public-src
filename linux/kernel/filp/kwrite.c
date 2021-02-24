#include <linux/module.h>
#include <linux/ptrace.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/slab.h>
#include <linux/user.h>
#include <linux/fs.h>
#include <asm/uaccess.h>
#include <linux/security.h>
#include <linux/unistd.h>
#include <linux/notifier.h>
#include <linux/version.h>

struct file *file_open(const char *path, int flags, int rights)
{
	struct file *filp = NULL;
	mm_segment_t oldfs = get_fs();

	set_fs(KERNEL_DS);
	filp = filp_open(path, flags, rights);
	set_fs(oldfs);

	if (IS_ERR(filp))
	{
		pr_info("flip_open(): %ld", PTR_ERR(filp));
		filp = NULL;
	}
	return filp;
}

void file_close(struct file *file)
{
	filp_close (file, NULL);
}

int file_read(struct file *file, unsigned long long offset, 
	unsigned char *data, unsigned int size)
{
	mm_segment_t oldfs = get_fs();
	int ret;

	set_fs(KERNEL_DS);
	ret = vfs_read(file, data, size, &offset);
	set_fs(oldfs);
	return ret;
}

int file_write(struct file* file, unsigned long long offset, unsigned char* data, unsigned int size) 
{
	mm_segment_t oldfs = get_fs();
	int ret;

	set_fs(KERNEL_DS);
	ret = vfs_write(file, data, size, &offset);
	set_fs(oldfs);

	return ret;
}

static void __exit cleanup(void)
{

}

static int __init startup(void)
{
	struct file *file = filp_open("/tmp/abc/def", O_CREAT | O_RDWR, 0600);
	if (file != NULL)
	{
		file_write (file, 0, "abc", 3);
		file_close (file);
	}

	return 0;
}

module_init(startup);
module_exit(cleanup);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("User1");

