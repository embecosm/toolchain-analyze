#!/bin/bash

# Script to analyze pull-requests in the GitHub LLVM project repository.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    cat <<EOF
Usage ./analyze-prs.sh
EOF
}

topdir="$(dirname $(cd $(dirname $0) && echo $PWD))"
llvmdir="${topdir}/llvm-project"
tooldir="${topdir}/toolchain-analyze"
srcf=${tooldir}/comment-source.txt
resf=${tooldir}/comments.csv
awkf=${tooldir}/average-comments.awk

# Need to work in the LLVM repo.
cd ${llvmdir}

# Generate results. We save the intermediate file, since it takes a while to
# generate and we can then use it for other analysis.
#
# NOTE. You will need to have set up an authentication token
#
#   export GH_TOKEN=...
gh pr list -L 1000000 -s closed --json id,createdAt,closedAt,state,comments \
   -q '.. | .id?,.createdAt?,.closedAt?,.state?' | \
    grep -v '^$' > ${srcf}
gawk -f ${awkf} < ${srcf} > ${resf}
