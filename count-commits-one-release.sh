#!/bin/bash -e

# Script to count commits in one release.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# The general premise is that this counts commits that are in one branch, but not
# another for a repository.  It has the general form

# 

set -u

usage () {
    echo "Usage ${cmd}"
    cat <<EOF
  <dir>     : Top directory of checked out repository
  <br1>     : Include all commits in this branch, but not <br2>
  <br2>     : Exclude all commits in this branch
  [<args>]  : Optional list of directories for which commits are wanted

If <br2> is empty, then no commits from <br1> are excluded. <args> are
optional, and if missing, all commits in the repo are considered.
EOF
}

if [[ $# -lt 3 ]]
then
    usage >&2
    exit 1
fi

# Get args
gitdir="$(realpath $1)"
shift
br1="$1"
shift
br2="$1"
shift
args="$*"

cmd=$0

# Repo to work in
cd "${gitdir}" > /dev/null 2>&1

# First release is special
if [[ "x${br2}" == "x" ]]
then
    num=$(git log --oneline --no-merges "${br1}" ${args} | \
	      wc -l --total=only)
else
    num=$(git log --oneline --no-merges "${br1}" ^"${br2}" ${args} | \
	      wc -l --total=only)
fi
echo "${num}"
