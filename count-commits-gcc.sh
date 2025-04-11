#!/bin/bash

# Script to count commits in each GCC tool chain year.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# Here we have to work with separate repositories
set -u

usage () {
    cat <<EOF
Usage ./count-commits.sh <name> <dirs>
EOF
}

if [[ $# -lt 1 ]]
then
    usage
    exit 1
fi

name=$1
shift
args="$*"

topdir="$(dirname $(cd $(dirname $0) && echo $PWD))"
gnutopdir="$(dirname ${topdir})/gnu"
gccdir=${gnutopdir}/gcc
binutilsdir=${gnutopdir}/binutils-gdb
glibcdir=${gnutopdir}/glibc
tooldir="${topdir}/toolchain-analyze"

# Create the list of years
years=$(seq 1988 2025)

# Commits per year
echo -n "GNU tool chain commits per year for ${name}"
resf="${tooldir}/commits-per-year-gcc.csv"
printf "%s,%s,%s,%s\n" "Year" "GCC" "Binutils/GDB" "Glibc" > ${resf}

for y in ${years}
do
    cd ${gccdir}
    num1=$(git log --oneline --no-merges --since-as-filter="${y}-01-01" \
              --until="${y}-12-31" ${args} | wc -l --total=only)
    cd ${binutilsdir}
    num2=$(git log --oneline --no-merges --since-as-filter="${y}-01-01" \
              --until="${y}-12-31" ${args} | wc -l --total=only)
    cd ${glibcdir}
    num3=$(git log --oneline --no-merges --since-as-filter="${y}-01-01" \
              --until="${y}-12-31" ${args} | wc -l --total=only)
    printf "%s-12-31,%d,%d,%d\n" "${y}" ${num1} ${num2} ${num3} >> ${resf}
    echo -n "."
done
echo
