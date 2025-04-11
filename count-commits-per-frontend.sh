#!/bin/bash

# Script to count commits in each LLVM release and year per front end.

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

./count-commits.sh "Clang" clang clang-tools-extra
mv commits-per-release.csv commits-per-release-per-frontend.csv
mv commits-per-year.csv    commits-per-year-per-frontend.csv

./count-commits.sh "Flang" flang flang-rt
mergecsv commits-per-release-per-frontend.csv commits-per-release.csv
mergecsv commits-per-year-per-frontend.csv    commits-per-year.csv

./count-commits.sh "LLD" lld
mergecsv commits-per-release-per-frontend.csv commits-per-release.csv
mergecsv commits-per-year-per-frontend.csv    commits-per-year.csv

./count-commits.sh "LLDB" lldb
mergecsv commits-per-release-per-frontend.csv commits-per-release.csv
mergecsv commits-per-year-per-frontend.csv    commits-per-year.csv

trimcsv commits-per-release-per-frontend.csv
trimcsv commits-per-year-per-frontend.csv

rm -f ${tmpf}
