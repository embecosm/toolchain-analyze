# Script to generate data for GCC

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# Generates the list of releases plus the prefix and suffix to turn a release
# into a branch name

rels="2.95"
rels="${rels} $(seq -s ' ' -f '3.%.0f' 0 4)"
rels="${rels} $(seq -s ' ' -f '4.%.0f' 0 9)"
rels="${rels} $(seq -s ' ' -f '%.0f' 5 15)"

prefix="remotes/${remote}/releases/gcc-"
suffix=""
