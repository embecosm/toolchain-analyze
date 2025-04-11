#!/bin/bash

# Script to count authors (individual and corporate) in each LLVM release.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# This file is part of the Embecosm GNU toolchain build system for RISC-V.

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    cat <<EOF
Usage ./count-authors.sh <name> [<dirs>]
EOF
}

if [[ $# -lt 2 ]]
then
    usage
    exit 1
fi

name=$1
shift
args="$*"

topdir="$(dirname $(cd $(dirname $0) && echo $PWD))"
llvmdir="${topdir}/llvm-project"
tooldir="${topdir}/toolchain-analyze"

# Need to work in the LLVM repo
cd ${llvmdir}

# Create the list of current releases
rels="$(seq -s ' ' -f '1.%.0f' 1 9)"
rels="${rels} $(seq -s ' ' -f '2.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '3.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' 4 20)"

rels="$(seq -s ' ' -f '1.%.0f' 1 3)"

# Create the list of years
years=$(seq 2001 2025)
years=$(seq 2023 2025)

# Useful temporary files
tmpf1=$(mktemp capf1XXXX.csv)

# Domains per year (as a proxy for corporates).  We separate out domains
# with a single contributor as non-corporate.
doms_common="gmail\.com\|yahoo\..*\|hotmail\..*\|outlook\..*\|gmx\..*"
echo -n "Domains per year "
resf="${tooldir}/domains-per-year.csv"
logf="${tooldir}/domains-per-year-detail-${name}.log"
echo "Year,${name} single-user, ${name} multi-user" > ${resf}

# All the years
for y in ${years}
do
    git log --no-merges --since-as-filter="${y}-01-01" --until="${y}-12-31" \
	--pretty="format:%ae" ${args} > ${tmpf1}
    nmulti=$(grep -v "${doms_common}" < ${tmpf1} | sort -u | \
		 sed -e 's/^.\+@//' | sort | uniq -c | sort -n -k 1 | \
		 grep -v '^[[:space:]]*1[[:space:]]' | \
		 sed -e 's/^[[:space:]]*[[:digit:]]\+[[:space:]]\+//' | \
		 wc -l --total=only)
    nsingle=$(grep -v "${doms_common}" < ${tmpf1} | sort -u | \
		 sed -e 's/^.\+@//' | sort | uniq -c | sort -n -k 1 | \
		 sed -n -e 's/^[[:space:]]*1[[:space:]]//p' | \
		 wc -l --total=only)
    ncommon=$(grep "${doms_common}" < ${tmpf1} | sort -u | \
		 wc -l --total=only)
    printf "%s,%d,%d\n" "${y}" $((nsingle + ncommon)) ${nmulti} >> ${resf}
    echo -n "."
done
echo

rm -f ${tmpf1}
