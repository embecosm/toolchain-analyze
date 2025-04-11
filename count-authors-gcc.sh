#!/bin/bash

# Script to count authors (individual and corporate) in each GCC release.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    cat <<EOF
Usage ./count-authors-gcc.sh <name> [<dirs>]
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
gnutopdir="$(dirname ${topdir})/gnu"
gccdir=${gnutopdir}/gcc
binutilsdir=${gnutopdir}/binutils-gdb
glibcdir=${gnutopdir}/glibc
tooldir="${topdir}/toolchain-analyze"

# Need to work in the GCC repo
cd ${gccdir}

# Create the list of years
years=$(seq 1988 2025)

# Common general use domains.
doms_common="gmail\.com\|nondot\.org\|yahoo\..*\|hotmail\..*\|outlook\..*\|gmx\..*"

# Useful temporary file
tmpf1=$(mktemp capf1XXXX-gcc.csv)

# Authors per year
echo -n "Authors per year for ${name}"
resf="${tooldir}/authors-per-year-gcc.csv"
logf="${tooldir}/authors-per-year-detail-${name}-gcc.log"
printf "%s,%s\n" "Year" "${name}" > ${resf}

for y in ${years}
do
    git log --no-merges --since-as-filter="${y}-01-01" --until="${y}-12-31" \
	--pretty="format:%an" ${args} | sort | uniq -c | sort -n -k1 | \
	grep -v "CVS to SVN Conversion" > ${tmpf1}
    echo "Year ${y}" >> ${logf}
    cat ${tmpf1} >> ${logf}
    num=$(wc -l --total=only ${tmpf1})
    printf "%s-12-31,%d\n" "${y}" ${num} >> ${resf}
    echo -n "."
done
echo

# Domains per year (as a proxy for corporates).  We separate out domains
# with a single contributor as non-corporate.
echo -n "Domains per year for ${name}"
resf="${tooldir}/domains-per-year-gcc.csv"
logf="${tooldir}/domains-per-year-detail-${name}-gcc.log"
echo "Year,${name} single user, ${name} multi-user" > ${resf}

# All the years
for y in ${years}
do
    # Find single user and multi-user domains
    git log --no-merges --since-as-filter="${y}-01-01" \
        --until="${y}-12-31" --pretty="format:%ae" ${args} > ${tmpf1}
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
