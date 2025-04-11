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

archlist="RISCV"

./count-authors.sh "All-Arm" $(archfiles AArch64) $(archfiles ARM)
mv authors-per-release.csv authors-per-release-per-backend.csv
mv domains-per-release.csv domains-per-release-per-backend.csv
mv authors-per-year.csv authors-per-year-per-backend.csv
mv domains-per-year.csv domains-per-year-per-backend.csv

for arch in ${archlist}
do
    ./count-authors.sh "${arch}" $(archfiles ${arch})
    mergecsv authors-per-release-per-backend.csv authors-per-release.csv
    mergecsv domains-per-release-per-backend.csv domains-per-release.csv
    mergecsv authors-per-year-per-backend.csv authors-per-year.csv
    mergecsv domains-per-year-per-backend.csv domains-per-year.csv
done

trimcsva authors-per-release-per-backend.csv
trimcsvd domains-per-release-per-backend.csv
trimcsva authors-per-year-per-backend.csv
trimcsvd domains-per-year-per-backend.csv

rm -f ${tmpf}
