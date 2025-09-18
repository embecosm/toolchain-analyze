#!/bin/bash -e

# Script to count commits in one year

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# The general premise is that this counts commits that are in one branch, but not
# another for a repository.  It has the general form

set -u

usage () {
    echo "Usage ${cmd}"
    cat <<EOF
  <dir>     : top directory of checked out repository
  <year>    : include all commits in this year
  [<args>]  : optional list of directories for which commits are wanted

<args> are optional, and if missing, all commits in the repo are considered.
EOF
}

if [[ $# -lt 2 ]]
then
    usage >&2
    exit 1
fi

# Get args
gitdir="$(realpath $1)"
shift
year="$1"
shift
args="$*"

cmd=$0

# Repo to work in
cd "${gitdir}" > /dev/null 2>&1

num=$(git log --oneline --no-merges --since-as-filter="${year}-01-01" \
	  --until="${year}-12-31" ${args} | wc -l --total=only)
echo "${num}"
