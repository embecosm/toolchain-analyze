#!/bin/bash -e

# Script to count commits in each front-end per release.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    echo "Usage: ${cmd}"
    cat <<EOF
    -r | --repo <dir>             : top directory of repostory (required)
    -n | --name <string>          : name of the project (required)
    -s | --split <string>         : name of the split (e.g 'frontend')
    [-t | --title <string>]       : title for the graph (default
                                    "Commits per <name> release")
    [-g | --git-remote <string>]  : name of the git remote (default "origin")
    [-d | --data-file <file>]     : file for the generated CSV data (default
                                    in the "datasets" directory,
    	                            "commits-per-release-<name>-<split>.csv"
    [-i | --image-file <file>]    : file for the generated PNG graph (default
                                    in the "graphs" directory
                                    "commits-per-release-<name>-<split>.png")
    [--get-data | --no-get-data]  : Whether or not to get data (default get
                                    data)
    [--plot | --no-plot]          : Whether or not to plot (default plot)
    [--xmm <val>]                 : X-dimension of the plot in mm (default
                                    119.0)
    [--ymm <val>]                 : Y-dimension of the plot in mm (default
                                    109.2)
    [--dpi <val>]                 : DPI of the plot (default 300)
    [--fontscale <val>]           : Scaling factor for fonts on the graph
                                    (default 1.714)
    [-h | --help]                 : print this help and exit.

If the image file is set to "", then the graph will be displayed on the
screen.  The font scale is a matter or trial and error to get something that
looks good.
EOF
}

# Top level directories
cmd="$0"
tooldir="$(cd "$(dirname "${cmd}")" && echo "$PWD")"

# Default arguments
repodir=
namelc=
split=
title=
remote="origin"

csvf=
outf=UNSPECIFIED

getdata=true
doplot=true
args=""

xmm=243.9
ymm=109.2
dpi=300
fontscale=1.714

set +u
until
    opt="$1"
    case ${opt} in
	-r|--repo)
	    shift
	    repodir="$(realpath $1)"
	    ;;

	-n|--name)
	    shift
	    namelc="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
	    nameuc="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
	    ;;

	-s|--split)
	    shift
	    split="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
	    ;;

	-t|--title)
	    shift
	    title="$1"
	    ;;

	-g|--git-remote)
	    shift
	    remote="$1"
	    ;;

	-d|--data-file)
	    shift
	    csvf="$(realpath $1)"
	    ;;

	-i|--image-file)
	    shift
	    if [[ "x$1" == "x" ]]
	    then
		outf=
	    else
		outf="$(realpath $1)"
	    fi
	    ;;

	--get-data)
	    getdata=true
	    ;;

	--no-get-data)
	    getdata=false
	    ;;

	--plot)
	    doplot=true
	    ;;

	--no-plot)
	    doplot=false
	    ;;

	--xmm)
	    shift
	    xmm="$1"
	    ;;

	--ymm)
	    shift
	    ymm="$1"
	    ;;

	--dpi)
	    shift
	    dpi="$1"
	    ;;

	--fontscale)
	    shift
	    fontscale="$1"
	    ;;

	-h|--help)
	    usage
	    exit 0
	    ;;

	?*)
	    echo "ERROR: Unknown argument ${opt}." >&2
	    usage >&2
	    exit 1
	    ;;

	*)
	    ;;
    esac
    [[ "x${opt}" == "x" ]]
do
    shift
done
set -u

# Mandatory arguments
if [[ "x${repodir}" == "x" ]]
then
    echo "ERROR: Repository must be specified" >&2
    exit 1
fi

if [[ "x${namelc}" == "x" ]]
then
    echo "ERROR: Name must be specified" >&2
    exit 1
fi

# Create defaults if necessary.
if [[ "x${title}" == "x" ]]
then
    title="Commits per ${nameuc} release"
fi

if [[ "x${csvf}" == "x" ]]
then
    csvf="${tooldir}/datasets/commits-per-release-${namelc}-${split}.csv"
fi

# The use of the string "UNSPECIFIED" is because the empty string is a valid
# setting for the output file.  A side effect is that if the user specifies the
# string "UNSPECIFIED" as the output file, they will get the default file name.
if [[ "x${outf}" == "xUNSPECIFIED" ]]
then
    outf="${tooldir}/graphs/commits-per-release-${namelc}-${split}.png"
fi

# Derived argument
persist=
if [[ "x${outf}" == "x" ]]
then
    persist="-persist"
fi

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
