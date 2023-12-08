#!/bin/bash

set -ex

nasm -o boot.bin boot.asm
qemu-system-x86_64 boot.bin
