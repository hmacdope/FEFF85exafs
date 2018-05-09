
# Content of the COMMON folder

This directory contains routines that are used by several modules.

Input/output routines:

* `chopen.f` - checks whether file was successfully opened
* `wlog.f` - writes string on screen and into the log file
* `head.f`  - routines to write header information
* `rdhead.f` - routines to read header information
* `itoken.f` - produces integer for each keyword in feff.inp
* `padlib.f` - PAD library written by M. Newville
* `str2dp.f` - additional routines to work with PAD format
* `str.f` - routines to deal with strings
* `rdpot.f` - read information from pot.pad
* `rdxsph.f` - read information from phase.pad
* `isnum.f` - tests whether a string can be a number
* `nxtunt.f` - returns the value of the next unopened unit number

Miscellaneous routines:

* `fixdsp.f` - fixes up the dirac spinor components for fine grid
* `fixdsx.f` - fixes up the dirac spinor components for fine grid
* `fixvar.f` - fixes up potential and density for fine grid
* `getorb.f` - gets atomic orbital data for chosen element
* `getxk.f` - gets k vector value for given energy
* `pertab.f` - periodic table: symbols and weights for each element
* `pijump.f` - removes jumps of 2*pi in phases
* `setkap.f` - set initial state ang mom and quantum number kappa
* `xx.f`  - returns x grid point on logarithmic radial grid 


The LICENSE for PAD library routines is included in the
[`padlib.f`](padlib.f) file.

All other routines in this directory are covered by the [LICENSE](../HEADERS/license.h)

# Simple static analysis

To make HTML files explaining data I/O for each fortran source file, do

	../src> ftnchek -mkhtml *.f

# Call graph

![call graph for the COMMON folder](tree/COMMON.png)
