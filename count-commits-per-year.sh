#!/bin/bash -e

# Script to count commits in each project year.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

# Top level directories
cmd=$(basename $0)
tooldir="$(cd "$(dirname "$0")" && echo "$PWD")"

# Get the arguments
default_title_prefix="Commits"
default_data_prefix="commits-per-release"
default_image_prefix="commits-per-release"
default_xmm=119.0
default_ymm=109.2

source ${tooldir}/get-args.sh

# Create the list of years
years=$(seq ${ystart} ${yend})

# Create the data (optional)
colname="Year"
if ${getdata}
then
    ${tooldir}/count-commits-all-years.sh "${title}" "${colname}" ${repodir} \
        "${csvf}" "${years}" ${args}
fi

# Plot the graph (optional)
if ${doplot}
then
    echo "Plotting graph"
    xpx=$(python3 -c "print(int(${xmm} / 25.4 * ${dpi}))")
    ypx=$(python3 -c "print(int(${ymm} / 25.4 * ${dpi}))")

    gnuplot ${persist} \
	    -e "csvf='${csvf}'" \
	    -e "outf='${outf}'" \
	    -e "xcol='${colname}'" \
	    -e "ycol='# commits'" \
	    -e "xpx=${xpx}" \
	    -e "ypx=${ypx}" \
	    -e "fontscale=${fontscale}" \
	    -e "title='${title}'" \
	    ${tooldir}/plot-one-line.gnuplot
fi
