# Plot a histogram.

# Copyright (C) 2025 Embecosm Limited <www.embecosm.com>
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# The GNU plot configuration to go with scan-stack.sh

# Use CSV input with a header row
set datafile separator ","
set key autotitle columnhead

# Plot output.
if ("X".outf eq "X") {
    set terminal qt size xpx,ypx position 0,0 font 'Muli,14'
} else {
    set terminal pngcairo size xpx,ypx font 'Muli,14' fontscale fontscale
    set output outf
}

# General plot configuration
set style data histograms
set style histogram rowstacked
set boxwidth 0.75 relative
set key outside invert
set title title font 'Muli,21'

set linetype  1 lc rgb "#004586"
set linetype  2 lc rgb "#ff420e"
set linetype  3 lc rgb "#ffd320"
set linetype  4 lc rgb "#579d1c"
set linetype  5 lc rgb "#7e0021"
set linetype  6 lc rgb "#83caff"
set linetype  7 lc rgb "#314004"
set linetype  8 lc rgb "#aecf00"
set linetype  9 lc rgb "#4b1f6f"
set linetype 10 lc rgb "#ff950e"
set linetype 11 lc rgb "#c5000b"
set linetype 12 lc rgb "#0084d1"
set style fill solid 1.0 border -1
set border 3

#X access set up
set xlabel xcol
set xtics out nomirror rotate by 45 scale 0.5 \
    offset 0, graph -0.04

# Y access set up
set ylabel ycol
set yrange [0:]
set ytics out autofreq nomirror format "%.0f"
set mytics 5
set grid ytics lw 2

# Now the plot
plot for [c=2:graphcols] csvf using c:xticlabels(1)