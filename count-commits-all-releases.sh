#!/bin/bash

# Script to count commits in all releases.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    echo "Usage ${cmd}"
    cat <<EOF
  <name>      : Description of this run for reporting
  <colname>   : Name of the column in the CSV file
  <dir>       : Top directory of checked out repository
  <csvfile>   : CSV file where the results should go
  <prefix>    : Prefix to turn a release into a branch name
  <rels>      : Space separated list of release branches
  <suffix>    : Suffix to turn a release into a branch name
  [<args>]    : Optional list of directories for which commits are wanted

  Note. <rels> is a single argument, so will typically need quoting.
EOF
}

cmd="$0"
tooldir="$(cd $(dirname ${cmd}) && echo $PWD)"

if [[ $# -lt 7 ]]
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
prefix="$1"
shift
rels="$1"
shift
suffix="$1"
shift
args="$*"

# Commits per release
echo "Getting data for ${name}"
printf "%s,%s\n" "${colname}" "# commits" > ${csvf}

prev_br=
for r in ${rels}
do
    br="${prefix}${r}${suffix}"
    num=$(${tooldir}/count-commits-one-release.sh ${gitdir} "${br}" \
        "${prev_br}" ${args})
    printf "%s,%d\n" "${r}" ${num} >> ${csvf}
    prev_br="${br}"
    echo -n "."
done

echo
