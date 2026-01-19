#!/bin/sh

set -xe
objdump -b binary -D -M intel -m i8086 boot2.bin --adjust-vma=0x7e00
