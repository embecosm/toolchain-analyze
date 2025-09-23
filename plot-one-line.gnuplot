# Plot a single line category graph.

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
set title title font 'Muli,21'
set style line 1 lt 1 lc rgb "#004586" lw 5
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

# Now the plot, with labels every 3 spaces
plot csvf using 2:xtic((int($0) % 3) == 0 ? stringcolumn(1) : "") \
     notitle with lines ls 1
