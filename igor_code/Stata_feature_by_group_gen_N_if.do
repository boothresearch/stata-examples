********************************************************************************
*********************  Project: Stata Issues
*********************  Programmer: Igor Kuznetsov
*********************  Date: ....
*********************  Goal: Document Stata 15.1 issues

/* 
One would expect that if will limit the sample for computation of the var
before running any estimations but it is not the case.
It will limit the sample only at the very last stage of imputing numbers
generating missing values for not selected rows by if statement [R behaves differently]
*/


set obs 10
gen row_count = _n
gen test1 = 0
replace test1 =1 if _n > 6
bysort test1: gen group_count = _N 
bysort test1: gen group_count2 = _N if row_count > 2
assert group_count == group_count2 if row_count > 2 // will show TRUE while one expects it to be FALSE
assert group_count == group_count2 // will show  FALSE only because of missing values in group_count2
br





/*The same problem
Another example*/

/*setting up */
clear

set obs 10

gen aa = _n
 gen bb = 0

 replace bb = 1 if _n > 3


 gen bb1 = 0

 replace bb1 = 1 if _n > 7


 bysort bb bb1: gen tes11 = _n

 bysort bb bb1: gen test22 = _N

 br

 
/*
 The command below will generate missing for rows with 
 aa > 2 
 but will still count them in _N
*/
 bysort bb bb1: gen test22_1 = _N if aa < 9 
sort aa 
 replace bb= . if _n ==10 


  
 sort aa 
 bysort bb bb1: gen test22_2 = _N if aa < 9 
  
 sort aa 
 
   replace aa = . if _n == 9
   
    bysort bb bb1: gen test22_3 = _N if aa < 9 
	

	   replace aa = . if _n == 1
   
    bysort bb bb1: gen test22_4 = _N if aa < 9 
	
	
	
	br
