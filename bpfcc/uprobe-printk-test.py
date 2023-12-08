#!/usr/bin/python3

from bcc import BPF
from time import sleep

bpf_text="""
#include <linux/sched.h>

int printForRoot(struct pt_regs *ctx){
    char command[16] = {};
    uid_t uid = bpf_get_current_uid_gid() & 0xffffffff;

    //another bpf helper to read a string in userland
    bpf_probe_read_user_str(&command, sizeof(command), (void *)PT_REGS_RC(ctx));
    bpf_trace_printk("uid=%d command=%s", uid, command);
    return 0;
}
"""

b = BPF(text=bpf_text)
b.attach_uretprobe(name="/tmp/bash", sym="readline", fn_name="printForRoot")

sleep(9999)
