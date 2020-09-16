/*******************
Build File for Stata Example Project

Sam Wallach Hanson
September 2020
********************/

/**********************
Imports most recent data
***********************/
capture program drop import_and_save
program define import_and_save
	
	* Import and save the most updated version available of us-states.csv
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv", clear
	save "$datadir/raw_states.dta", replace
	
end

/*******************************
Maybe we're going to need to separate months out, because we're doing enough that
Leaving it all as one big file would take too much time. Idk man coming up
with examples is hard
********************************/
capture program drop monthly_files
program define monthly_files

	use "$datadir/raw_states.dta", clear
	
	gen month = substr(date, 1, 7)
	replace month = subinstr(month, "-", "_", 1)
	*look how convenient tempfiles are!
	tempfile base
	save `base', replace

	
	* local var levels now has every month
	levelsof month, local(levels)
	
	foreach level of local levels {
		
		use `base', clear
		keep if month == "`level'"
		save "$datadir/nyt_covid_data_`level'", replace
		
	}

end

/***********************
For the time being your prof only cares about August
Also just going to assume the data is perfect for the time being
************************/
capture program drop august_clean
program define august_clean

	use "$datadir/nyt_covid_data_2020_08.dta"
	sort state date
	
	by state: gen daily_deaths = deaths[_n] - deaths[_n - 1]
	by state: gen daily_cases = cases[_n] - cases[_n - 1]
	
	save "$datadir/nyt_cleaned_2020_08.dta", replace
	
end




/********************
main program runs the programs in build.do
this is called in main.do
pick and choose which functions in build
you want to run by commenting stuff out here
rather than in confusing comment blocks
*********************/
capture program drop build_main
program define build_main
	
	* import data, save monthly datasets
	import_and_save
	
	monthly_files
	
	august_clean

end

