# Script to get front end data for GCC

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# For each front-end, we have the label to use for the front-end and the list
# of sub-directories to examine.  The parent script will then break these out.

# Source, don't execute this file!

splitlist="ada:Ada:gnattools,libada,gcc/ada \
	   c-family:C/C++:c++tools,libcc1,libcpp,gcc/c,gcc/c-family,gcc/cp \
	   cobol:Cobol:libgcobol,gcc/cobol \
	   d:D:gcc/d \
	   fortran:Fortran:libgfortran,gcc/fortran \
	   go:Go:gotools,libgo,gcc/go \
	   modula2:Modula2:libgm2,gcc/m2 \
	   ojbc-family:Objective#C/C++:libobjc,gcc/objc,gcc/objcp \
	   rust:Rust:libgrust,gcc/rust"
