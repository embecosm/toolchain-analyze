# Script to source to set up arguments

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# The followings variable must be set up before the usage function will work
# correctly.
# - cmd: the name of the command
# - default_title_prefix: the prefix of the default title for the graph
# - default_data_prefix: the prefix of the default data file
# - default_image_prefix: the prefix of the default image file
# - default_xmm: Default image X size in mm
# - default_ymm: Default image Y size in mm

usage () {
    echo "Usage: ${cmd}"
    cat <<EOF
    -r | --repo <dir>             : top directory of repostory (required)
    -n | --name <string>          : name of the project (required)
    -s | --split <string>         : name of the split if needed (e.g 'frontend')
    [-t | --title <string>]       : title for the graph (default see below)
    [-g | --git-remote <string>]  : name of the git remote (default "origin")
    [-d | --data-file <file>]     : file for the generated CSV data (default
    	                            see below)
    [-i | --image-file <file>]    : file for the generated PNG graph (default
                                    see below)
    [-l | --logdir]               : log directory (default "logs")
    [--get-data | --no-get-data]  : whether or not to get data (default
                                    --get-data)
    [--plot | --no-plot]          : whether or not to plot (default --plot)
    [--args <list>]               : space separated list of subdirectories
                                    within the repository to examine
    [--year-start <year>]         : initial year (default 2000)
    [--year-end <year>]           : final year (default current year)
    [--xmm <val>]                 : X-dimension of the plot in mm (default
                                    see below)
    [--ymm <val>]                 : Y-dimension of the plot in mm (default
                                    see below)
    [--dpi <val>]                 : DPI of the plot (default 300)
    [--fontscale <val>]           : Scaling factor for fonts on the graph
                                    (default 1.714)
    [-h | --help]                 : print this help and exit.

Defaults for some parameters are derived from other parameters.  In general
the suffix "-<name>" is used or "-<name>-<split>" in the case of split data
analysis.
EOF
    echo "- default title is ${default_title_prefix} per <name> release"
    echo "- default data file is datasets/${default_data_prefix}-<suffix>.csv"
    echo "- default image file is graphs/${default_image_prefix}-<suffix>.csv"
    echo "- default image dimensions ${default_xmm}mm x ${default_ymm}mm"
    echo
    cat <<EOF
Not all scripts require a split name, so if it is empty, the field is not used
in names.

If the image file is set to "", then the graph will be displayed on the
screen.  The font scale is a matter or trial and error to get something that
looks good.  Log file names are automatically generated, with a timestamp in
the name.
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
logdir=${tooldir}/logs
remote="origin"

csvf=
outf=UNSPECIFIED

getdata=true
doplot=true
args=""
ystart=2000
yend=$(date +%Y)

xmm=${default_xmm}
ymm=${default_ymm}
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

	-l|--logdir)
	    logdir="$(realpath $1)"
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

if [[ "x${split}" == "x" ]]
then
    suffix="${namelc}"
else
    suffix="${namelc}-${split}"
fi

# Create defaults if necessary.
if [[ "x${title}" == "x" ]]
then
    title="${default_title_prefix} per ${nameuc} release"
fi

if [[ "x${csvf}" == "x" ]]
then
    csvf="${tooldir}/datasets/${default_data_prefix}-per-release-${suffix}.csv"
fi

# The use of the string "UNSPECIFIED" is because the empty string is a valid
# setting for the output file.  A side effect is that if the user specifies the
# string "UNSPECIFIED" as the output file, they will get the default file name.
if [[ "x${outf}" == "xUNSPECIFIED" ]]
then
    outf="${tooldir}/graphs/${default_image_prefix}-${suffix}.png"
fi

# Derived argument
persist=
if [[ "x${outf}" == "x" ]]
then
    persist="-persist"
fi

