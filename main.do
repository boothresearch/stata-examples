/*********************
Genius Econ Project: main file

Stata example for RP workshop 2020. 
See arguments below for code running instructions.
This program is way over-commented, 
when you're writing your own code 
comment a bit less.

Sam Wallach Hanson
September 2020
**********************/

clear
set more off

* Set your seed plz
set seed 12345

/*******************
Arguments: From the command line, run do main.do "build/x" "analysis/x"
EG: do main.do build x will run build, but not analysis

Run code with arguments so that you don't
have to change actual code to do different things.
In this case, the args just determine if you're running
the build, analysis, or both
********************/

local build_indicator = lower("`1'")
local analysis_indicator = lower("`2'")

/********************
Global Environment Variables:
Less typing for you in the future,
you'll only ever need to edit these
if directory names change
*********************/
global root "`c(pwd)'"
global datadir "$root/data"
global figdir "$root/fig"
global codedir "$root/code"

/********************
Other Globals:
The one I included here is
*********************/
global graphconfig "plotregion(fcolor(white) lcolor(white) m(tiny)) graphregion(fcolor(white) lcolor(white))"


/********************
Call in build and analysis programs
*********************/
do "$codedir/build.do"
do "$codedir/analysis.do"

/********************
Run the Programs you want
*********************/

if "`build_indicator'" == "build" {
	build_main
}
if "`analysis_indicator'" == "analysis" {
	analysis_main
}

/***********************
CLEANUP: Everything is short for this project, so we can
remove monthly data files from our machine to save space
************************/
*cd "$datadir"
*!rm nyt*.dta
