/**********************
Quick Slide examples. This is not a cohesive project, but a series of singular
functions for demonstration during slide presentation

Sam Wallach Hanson
***********************/

/*
This sets a global equal to the first argument
of the overall program call: for our purposes 
it defines which half of the slow code we run
*/
global input_int `1'

* global for easy graph configuration
global graphconfig "plotregion(fcolor(white) lcolor(white) m(tiny)) graphregion(fcolor(white) lcolor(white))"

/**********************
Example of a Program
This is just an example program, 
to show the syntax and how it's called (in slide_examples_main)
***********************/
capture program drop this_is_a_program
program define this_is_a_program
	
	clear
	
	set obs 10
	
	gen x = _n
	sum x, d

end

/*************************************************
* Sorts on ID and rank variable, keeps max rank for given ID
*************************************************/
capture program drop sorted_drop
program define sorted_drop

	syntax, id(string) ranker(string)

	gsort `id' -`ranker'
	by `id': gen sorted_drop_var = _n
	keep if sorted_drop_var == 1
	drop sorted_drop_var

end


/*********************
Calling a common function example
Showing why it's usefule to have commonly used functions
stored in programs
**********************/
capture program drop sorted_drop_use
program define sorted_drop_use

	clear
	set obs 10
	
	gen x = 1 if _n > 5
	replace x = 0 if x != 1
	gen y = runiform()
	
	*first call: note arguments in strings
	sorted_drop, id("x") ranker("y")
	
	list
	
	clear
	set obs 100
	
	gen x = 1 if _n > 50
	replace x = 0 if x != 1
	
	gen y = 0
	replace y = 1 if _n <= 25 | _n > 75
	
	gen z = runiform()
	
	sorted_drop, id("x y") ranker("z")
	
	list 
	
end


/***************************
This simulates slow code, functions that take a while to run
but that might not be necessary to run every time. In this case, 
the task has also been split in half, as if both halves could be run 
without dependency on each other. These two halves can then be run in 
"parallel" the the slide_examples.sh file. If you don't have access to that
sh file, the code is:

#!/bin/sh

stata -b slide_examples.do 1 &
stata -b slide_examples.do 2 &

Which runs both halves of the code at the same time, cutting run time in half!
****************************/

capture program drop slow_code
program define slow_code
	if $input_int == 1 {
		sleep 10000
	}
	else if $input_int == 2 {
		sleep 10000
	}
end

/*********************
Scatter template function example
**********************/
capture program drop scatter_template
program define scatter_template

	syntax, xvar(string) yvar(string)
	
	twoway (scatter y x), $graphconfig

end


/**********************
Scatter function example
***********************/
capture program drop run_scatters
program define run_scatters

	clear
	set obs 10
	gen x = _n
	gen y = runiform()
	scatter_template, xvar(x) yvar(y)
	
	
	clear
	set obs 100
	gen x = _n
	gen y = runiform()
	scatter_template, xvar(x) yvar(y)
end




/**********************
Main File, where we choose which examples to run
***********************/
capture program drop slide_examples_main
program define slide_examples_main
	
	* for ease of reading you can also have short comments here about
	* what programs you're calling do
	
	* creates a list, 1-10 in each observation
	*this_is_a_program
	
	* sorted drop example on 2 different datasets
	*sorted_drop_use
	
	*slow code simulator
	if "$input_int" == "1" | "$input_int" == "2" {
		*slow_code
	}
	
	* demonstrate the usefulness of fig template files
	*run_scatters
end

/***********************
Tests go here
************************/


/*******************
This is an example of how to write a Stata test function
********************/
capture program drop sorted_drop_test
program define sorted_drop_test

	import delimited "`c(pwd)'/test/sorted_drop_input_1.csv", clear
	sorted_drop, id("x") ranker("y")
	
	assert _N == 1
	assert x[1] == 1
	assert y[1] == 100
	
	di "SORTED DROP TEST PASSED"
	
end


/********************
Main file for running all tests
*********************/
capture program drop slide_examples_test_main
program define slide_examples_test_main

	sorted_drop_test

end

*slide_examples_test_main
*slide_examples_main
