#!/bin/bash

# Script to count commits in each LLVM release and year per back end.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

tmpf=$(mktemp ccpfXXXX.csv)

mergecsv () {
    csvtool paste $1 $2 -o ${tmpf}
    mv ${tmpf} ${1}
}

trimcsv() {
    csvtool col 1,2,4,6,8 $1 -o ${tmpf}
    mv ${tmpf} ${1}
}

# $1 is architecture name
archfiles() {
    files="llvm/lib/Target/${1} \
           llvm/test/*/${1} \
	   llvm/include/llvm/IR/Intrinsics*${1}.td \
	   clang/lib/Driver/Toolchains/${1}Toolchain.* \
	   clang/lib/Driver/Toolchains/Arch/${1}.*"
    if [[ -e lld/ELF/Arch/${1}.cpp ]]
    then
	files="${files} lld/ELF/Arch/${1}.cpp"
    fi
    echo "${files}"
}

archlist="AArch64 ARC ARM AVR Mips MSP430 PowerPC RISCV Sparc Xtensa"
archlist="AArch64 ARM RISCV"

./count-commits.sh "X86" $(archfiles X86)
mv commits-per-release.csv commits-per-release-per-backend.csv
mv commits-per-year.csv    commits-per-year-per-backend.csv

for arch in ${archlist}
do
    ./count-commits.sh "${arch}" $(archfiles ${arch})
    mergecsv commits-per-release-per-backend.csv commits-per-release.csv
    mergecsv commits-per-year-per-backend.csv    commits-per-year.csv
done

trimcsv commits-per-release-per-backend.csv
trimcsv commits-per-year-per-backend.csv

rm -f ${tmpf}
