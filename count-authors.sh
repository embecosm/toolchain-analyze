#!/bin/bash

# Script to count authors (individual and corporate) in each LLVM release.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

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

# Create the list of years
years=$(seq 2001 2025)

# Common general use domains.
doms_common="gmail\.com\|nondot\.org\|yahoo\..*\|hotmail\..*\|outlook\..*\|gmx\..*"

# Useful temporary file
tmpf1=$(mktemp capf1XXXX.csv)

# Authors per release
echo -n "Authors per release for ${name}"
resf="${tooldir}/authors-per-release.csv"
logf="${tooldir}/authors-per-release-detail-${name}.log"
printf "%s,%s\n" "Release" "${name}" > ${resf}

# First release is special
git log --no-merges remotes/upstream/release/1.0.x --pretty="format:%an" \
    ${args} | sort | uniq -c | sort -n -k1 | \
    grep -v "CVS to SVN Conversion" > ${tmpf1}
echo "Release 1.0" > ${logf}
cat ${tmpf1} >> ${logf}
num=$(wc -l --total=only ${tmpf1})
printf "%s,%d\n" "1.0" ${num} > ${resf}
echo -n "."

# All the other releases
prev=1.0
for curr in ${rels}
do
    git log --no-merges remotes/upstream/release/${curr}.x \
	^remotes/upstream/release/${prev}.x --pretty="format:%an" ${args} | \
	sort | uniq -c | sort -n -k1 | \
	grep -v "CVS to SVN Conversion" > ${tmpf1}
    echo "Release ${curr}" >> ${logf}
    cat ${tmpf1} >> ${logf}
    num=$(wc -l --total=only ${tmpf1})
    printf "%s,%d\n" "${curr}" ${num} >> ${resf}
    echo -n "."
    prev=${curr}
done
echo
rm ${tmpf1}

# Authors per year
echo -n "Authors per year for ${name}"
resf="${tooldir}/authors-per-year.csv"
logf="${tooldir}/authors-per-year-detail-${name}.log"
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

# Domains per release (as a proxy for corporates).  We separate out domains
# with a single contributor as non-corporate.
echo -n "Domains per release for ${name}"
resf="${tooldir}/domains-per-release.csv"
logf="${tooldir}/domains-per-release-detail-${name}.log"
echo "Release,${name} single user, ${name} multi-user" > ${resf}

# First release is special
git log --no-merges remotes/upstream/release/1.0.x \
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
printf "%s,%d,%d\n" "1.0" $((nsingle + ncommon)) ${nmulti} >> ${resf}
echo -n "."

# All the other releases
prev=1.0
for curr in ${rels}
do
    # Find single user and multi-user domains
    git log --no-merges --no-merges remotes/upstream/release/${curr}.x \
	^remotes/upstream/release/${prev}.x \
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
    printf "%s,%d,%d\n" "${curr}" $((nsingle + ncommon)) ${nmulti} >> ${resf}
    echo -n "."
    prev=${curr}
done
echo

# Domains per year (as a proxy for corporates).  We separate out domains
# with a single contributor as non-corporate.
echo -n "Domains per year for ${name}"
resf="${tooldir}/domains-per-year.csv"
logf="${tooldir}/domains-per-year-detail-${name}.log"
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
