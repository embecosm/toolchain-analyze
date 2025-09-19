# Script to get front end data for GCC

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# For each back-end, we have the label to use for the back-end and the list
# of sub-directories to examine.  The parent script will then break these out.

# Source, don't execute this file!

# Master list
splitlist="arm:Arm/AArch64:gcc/config/aarch64,gcc/config/arm \
           arc:ARC:gcc/config/arc \
           avr:AVR:gcc/config/avr \
           bfin:Blackfin:gcc/config/bfin \
           c6x:C6000:gcc/config/c6x \
           epiphany:Epiphany:gcc/config/epiphany \
           fr30:FR:gcc/config/fr30 \
           frv:FR-V:gcc/config/frv \
           ft32:FT32:gcc/config/ft32 \
           gcn:GCN:gcc/config/gcn \
           h8300:H8/300:gcc/config/h8300 \
           x86:x86/x86\\\\\\\\_64:gcc/config/i386 \
           ia64:Itanium:gcc/config/ia64 \
           iq2000:iQ2000:gcc/config/iq2000 \
           m32:M32C/M32R:gcc/config/m32c,gcc/config/m32r \
           mcore:M-CORE:gcc/congif/mcore \
           microblaze:MicroBlaze:gcc/config/microblaze \
	   mips:MIPS:gcc/config/mips \
	   mmix:MMIX:gcc/config/mmix \
	   mn10300:MN10300:gcc/config/mn10300 \
	   moxie:Moxie:gcc/config/moxie \
	   msp430:MSP430:gcc/config/msp430 \
	   nds32:NDS32:gcc/config/nds32 \
	   nvptx:NVIDIA#PTX:gcc/config/nvptx \
	   or1k:OpenRISC:gcc/config/or1k \
	   pa:PA-RISC:gcc/config/pa \
	   pdp11:PDP-11:gcc/config/pdp11 \
	   pru:TI#PRU:gcc/config/pru \
	   riscv:RISC-V:gcc/config/riscv \
	   rl78:RL78:gcc/config/rl78 \
	   rs6000:RS/6000:gcc/config/rs6000 \
	   rx:Renesas#RX:gcc/config/rx \
	   s390:System/390:gcc/config/s390 \
	   sh:SuperH:gcc/config/sh \
	   sparc:SPARC:gcc/config/sparc \
	   stormy16:Xstormy16:gcc/config/stormy16 \
	   v850:V850:gcc/config/v850 \
	   vax:VAX:gcc/config/vax \
	   visium:VISIUMCORE:gcc/config/visium \
	   xtensa:Xtensa:gcc/config/xtensa"

splitlist="arm:Arm/AArch64:gcc/config/aarch64,gcc/config/arm \
           avr:AVR:gcc/config/avr \
           x86:x86/x86\\\\\\\\_64:gcc/config/i386 \
	   riscv:RISC-V:gcc/config/riscv \
	   rs6000:RS/6000:gcc/config/rs6000 \
	   rl78:RL78:gcc/config/rl78 \
           m32c:M32C:gcc/config/m32c \
           epiphany:Epiphany:gcc/config/epiphany"
