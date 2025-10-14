#!/bin/bash -e

# Script to count commits in each front-end per release.

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
default_xmm=243.9
default_ymm=109.2

source ${tooldir}/get-args.sh

# Now the information about the back ends
source "get-${namelc}-${split}.sh"

# Temporary CSV file
tmpf=$(mktemp --tmpdir ccpfXXXX.csv)

# Get the data for each backend
cols="1"
nextcol="2"
graphcols="1"
isfirst=true
for f in ${splitlist}
do
    subname=$(echo "$f" | cut -f1 -d:)
    subtitle=$(echo "$f" | cut -f2 -d: | tr '#' ' ')
    subdirs=$(echo "$f" | cut -f3 -d: | tr ',' ' ')
    descr="${namelc}-${split}-${subname}"
    dsname=${tooldir}/datasets/commits-per-release-${descr}.csv
    imgname=${tooldir}/graphs/commits-per-release-${descr}.png

    # Generating data is optional
    if ${getdata}
    then
	${tooldir}/count-commits-per-release.sh -r ${repodir} -n ${namelc} \
	    -g ${remote} \
	    -t "${nameuc} commits per release (${subtitle})" \
	    -d  ${dsname} -i ${imgname} --no-plot --args "${subdirs}"
	sed -i -e "1s|# commits|${subtitle}|" ${dsname}

	# Merge data.
	if ${isfirst}
	then
	    rm -f ${csvf}
	    cp ${dsname} ${csvf}
	else
	    csvtool paste ${csvf} ${dsname} -o ${tmpf}
	    mv ${tmpf} ${csvf}
	fi
    fi

    # Update useful lists
    cols="${cols},${nextcol}"
    nextcol=$((nextcol + 2))
    graphcols=$((graphcols + 1))

    # No longer the first iteration
    isfirst=false
done

# Trim unwanted columns if we are generating data
if ${getdata}
then
    csvtool col ${cols} ${csvf} -o ${tmpf}
    mv ${tmpf} ${csvf}
fi

rm -f ${tmpf}

# Plot the graph (optional)
if ${doplot}
then
    echo "Plotting graph"
    xpx=$(python3 -c "print(int(${xmm} / 25.4 * ${dpi}))")
    ypx=$(python3 -c "print(int(${ymm} / 25.4 * ${dpi}))")

    gnuplot ${persist} \
	    -e "csvf='${csvf}'" \
	    -e "outf='${outf}'" \
	    -e "xcol='GCC Release'" \
	    -e "ycol='# commits'" \
	    -e "xpx=${xpx}" \
	    -e "ypx=${ypx}" \
	    -e "fontscale=${fontscale}" \
	    -e "title='${title}'" \
	    -e "graphcols='${graphcols}'" \
	    ${tooldir}/plot-histogram.gnuplot
fi
