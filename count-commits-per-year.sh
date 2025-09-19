#!/bin/bash -e

# Script to count commits in each project year.

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

set -u

usage () {
    echo "Usage: ${cmd}"
    cat <<EOF
    -r | --repo <dir>             : top directory of repostory (required)
    -n | --name <string>          : name of the project (required)
    [-t | --title <string>]       : title for the graph (default <name>)
    [-d | --data-file <file>]     : file for the generated CSV data (default
    	                            "datasets/commits-per-year-<name>.csv"
    [-i | --image-file <file>]    : file for the generated PNG graph (default
                                    "graphs/commits-per-year-<name>.png")
    [--get-data | --no-get-data]  : Whether or not to get data (default get
                                    data)
    [--plot | --no-plot]          : Whether or not to plot (default plot)
    [--args <list>]               : space separated list of subdirectories
                                    within the repository to examine
    [--year-start <year>]         : initial year (default 2000)
    [--year-end <year>]           : final year (default current year)
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
title=

csvf=
outf=UNSPECIFIED

getdata=true
doplot=true
args=""
ystart=2000
yend=$(date +%Y)

xmm=119.0
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

	-t|--title)
	    shift
	    title="$1"
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

	--args)
	    shift
	    args="$1"
	    ;;

	--year-start)
	    shift
	    ystart=$1
	    ;;

	--year-end)
	    shift
	    yend=$1
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
    title="Commits per ${nameuc} year"
fi

if [[ "x${csvf}" == "x" ]]
then
    csvf="${tooldir}/datasets/commits-per-year-${namelc}.csv"
fi

# The use of the string "UNSPECIFIED" is because the empty string is a valid
# setting for the output file.  A side effect is that if the user specifies the
# string "UNSPECIFIED" as the output file, they will get the default file name.
if [[ "x${outf}" == "xUNSPECIFIED" ]]
then
    outf="${tooldir}/graphs/commits-per-year-${namelc}.png"
fi

# Derived argument
persist=
if [[ "x${outf}" == "x" ]]
then
    persist="-persist"
fi

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
