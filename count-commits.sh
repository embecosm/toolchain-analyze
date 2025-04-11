#!/bin/bash

# Script to count commits in each LLVM release and year.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    cat <<EOF
Usage ./count-commits.sh <name> <dirs>
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

# Need to work in the LLVM repo.
cd ${llvmdir}

# Create the list of current releases
rels="$(seq -s ' ' -f '1.%.0f' 1 9)"
rels="${rels} $(seq -s ' ' -f '2.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '3.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' 4 20)"

# Create the list of years
years=$(seq 2001 2025)

# Commits per release
echo -n "Commits per release for ${name}"
resf="${tooldir}/commits-per-release.csv"
printf "%s,%s\n" "Release" "${name}" > ${resf}

# First release is special
num=$(git log --oneline --no-merges remotes/upstream/release/1.0.x ${args} | \
	  wc -l --total=only)
printf "%s,%d\n" "1.0" ${num} >> ${resf}
echo -n "."

# All the other releases
prev=1.0
for curr in ${rels}
do
    num=$(git log --oneline --no-merges remotes/upstream/release/${curr}.x \
	      ^remotes/upstream/release/${prev}.x ${args} | wc -l --total=only)
    printf "%s,%d\n" "${curr}" ${num} >> ${resf}
    echo -n "."
    prev=${curr}
done
echo

# Commits per year
echo -n "Commits per year for ${name}"
resf="${tooldir}/commits-per-year.csv"
printf "%s,%s\n" "Year" "${name}" > ${resf}

for y in ${years}
do
    num=$(git log --oneline --no-merges --since-as-filter="${y}-01-01" \
              --until="${y}-12-31" ${args} | wc -l --total=only)
    printf "%s-12-31,%d\n" "${y}" ${num} >> ${resf}
    echo -n "."
done
echo
