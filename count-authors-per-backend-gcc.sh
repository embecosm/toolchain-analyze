#!/bin/bash

# Script to count commits in each GCC release and year per back end.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

tmpf=$(mktemp ccpfXXXX.csv)

mergecsv () {
    csvtool paste $1 $2 -o ${tmpf}
    mv ${tmpf} ${1}
}

trimcsva() {
    csvtool col 1,2,4,6,8 $1 -o ${tmpf}
    mv ${tmpf} ${1}
}

trimcsvd() {
    csvtool col 1,3,6,9,12 $1 -o ${tmpf}
    mv ${tmpf} ${1}
}

# $1 is architecture name
archfiles() {
    cd ${gccdir}
    find . -name "*$1*" -type d | sed -e 's|^\./||g'
}

topdir="$(dirname $(cd $(dirname $0) && echo $PWD))"
gnutopdir="$(dirname ${topdir})/gnu"
gccdir=${gnutopdir}/gcc

./count-authors-gcc.sh "All-Arm" $(archfiles aarch64) $(archfiles arm)
mv authors-per-year-gcc.csv authors-per-year-per-backend-gcc.csv
mv domains-per-year-gcc.csv domains-per-year-per-backend-gcc.csv

./count-authors-gcc.sh "RISC-V" $(archfiles riscv)
mergecsv authors-per-year-per-backend-gcc.csv authors-per-year-gcc.csv
mergecsv domains-per-year-per-backend-gcc.csv domains-per-year-gcc.csv

trimcsva authors-per-year-per-backend-gcc.csv
trimcsvd domains-per-year-per-backend-gcc.csv

rm -f ${tmpf}
