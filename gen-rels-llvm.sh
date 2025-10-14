# Script to source to generate data for LLVM

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# Generates the list of releases plus the prefix and suffix to turn a release
# into a branch name

rels="$(seq -s ' ' -f '1.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '2.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '3.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '%.0f' 4 21)"

prefix="remotes/${remote}/release/"
suffix=".x"
