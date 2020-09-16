/*********************
Analysis file for genius econ project

Sam Wallach Hanson
September 2020
**********************/

/*************************
Figure template: makes comparitive
connected scatters between two groups
**************************/
capture program drop fig1_template
program define fig1_template
	
	syntax, inname(string) sta(string) typ(string) typ2(string)
	
	use "$datadir/`inname'.dta", clear
	
	gen day = substr(date, 9, 2)
	destring(day), replace
	
	#delimit ;

		twoway (connected `typ' day if state == "Illinois") (connected `typ' day if state == "`sta'"), 
		legend(order(1 "Illinois" 2 "`sta'") col(2)) 
		ytitle("daily `typ2'") xtitle(Day) $graphconfig
		;
	#delimit cr
	
	*save
	graph export "$figdir/august_`typ'_Illinois_`sta'.png", replace
end

/************************
Wow using abstraction to make a ton of figs super quickly!
Comparing every state's daily level to Illinois
*************************/
capture program drop make_august_figs
program define make_august_figs

	use "$datadir/nyt_cleaned_2020_08.dta", clear

	levelsof state, local(levels)
	foreach st of local levels {
		foreach type in "deaths" "cases" {
			fig1_template, inname("nyt_cleaned_2020_08") sta("`st'") typ("daily_`type'") typ2("`type'")
		}
	}
end





capture program drop analysis_main
program define analysis_main

	make_august_figs

end

analysis_main
