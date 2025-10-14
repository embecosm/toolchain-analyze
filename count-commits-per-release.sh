#!/bin/bash -e

# Script to count commits in each release of a project

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

# Create the data (optional)
colname="${nameuc} release"
if ${getdata}
then
    # Create the list of current releases, along with branch prefix and suffix
    source "${tooldir}/gen-rels-${namelc}.sh"
    ${tooldir}/count-commits-all-releases.sh "${title}" "${colname}" \
        "${repodir}" "${csvf}" "${prefix}" "${rels}" "${suffix}" ${args}
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
