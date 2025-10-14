#!/bin/bash

# Script to count commits in all years.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    echo "Usage: ${cmd}"
    cat <<EOF
  <name>      : Description of this run for reporting
  <colname>   : Name of the column in the CSV file
  <dir>       : Top directory of checked out repository
  <csvfile>   : CSV file where the results should go
  <years>     : Space separated list of years
  [<args>]    : Optional list of directories for which commits are wanted

  Note. <rels> is a single argument, so will typically need quoting.
EOF
}

cmd="$0"
tooldir="$(cd $(dirname ${cmd}) && echo $PWD)"

if [[ $# -lt 5 ]]
then
    usage >&2
    exit 1
fi

name=$1
shift
colname=$1
shift
gitdir="$(realpath $1)"
shift
csvf="$(realpath $1)"
shift
years="$1"
shift
args="$*"

# Commits per year
echo "Getting data for ${name}"
printf "%s,%s\n" "LLVM release" "# commits" > ${csvf}

for y in ${years}
do
    num=$(${tooldir}/count-commits-one-year.sh ${gitdir} "${y}" ${args})
    printf "%s,%d\n" "${y}" ${num} >> ${csvf}
    echo -n "."
done

echo
