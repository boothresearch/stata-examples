********************************************************************************
*********************  Project: Stata Issues
*********************  Programmer: Igor Kuznetsov
*********************  Date: ....
*********************  Goal: Document Stata 15.1 issues


///////////////////////////////////////// TYPE 1 issues
/*It is mostly related how Stata stores float and double and
that the conversion of one into another may produce different results 
depending on the sequence of steps even for small numbers*/

clear
set obs 11
gen s = ""
replace s = "8502.02" if _n == 1
replace s = "0005.03" if _n == 2
replace s = "0001.05" if _n == 3
replace s = "0004.01" if _n == 4
replace s = "0004.02" if _n == 5
replace s = "0004.03" if _n == 6
replace s = "8708.05" if _n == 7
replace s = "8713.02" if _n == 8
replace s = "0040.01" if _n == 9
replace s = "0005.06" if _n == 10
replace s = "0050.06" if _n == 11 // works well for all columns

// replace s = subinstr(s,".","",.)


destring(s), gen(s_double)
replace s_double = s_double *100
destring(s), gen(s_float) float
replace s_float = s_float *100

gen double s_double_fr_float = s_float
gen float s_float_fr_double = s_double  // 
// gen  s_float_fr_double2 = s_double


gen s_int_fr_doub_orig = int(s_double)
gen s_int_fr_float_orig = int(s_float)


gen s_int_fr_doub_frfl = int(s_double_fr_float)
gen s_int_fr_float_frdb = int(s_float_fr_double)
// gen s_int_fr_float_frfl2 = int(s_float_fr_double2)



format %16.10g s_double s_float s_double_fr_float s_float_fr_double

/* One would expect that all the columns should be equal but they are not. 
Also, counterintuitively destring generates a double 
*/
foreach var of varlist s_* {

tostring(`var'), gen(s`var')
}
br


// clonevar s_intrec_fr_doub_orig = s_double 
// clonevar s_intrec_fr_float_orig = s_float 
// clonevar s_intrec_fr_doub_frfl = s_double_fr_float 
// clonevar s_intrec_fr_float_frdb = s_float_fr_double 

//
// recast long s_intrec_fr_doub_orig , force
// recast long s_intrec_fr_float_orig, force
// recast long s_intrec_fr_doub_frfl, force
// recast long s_intrec_fr_float_frdb, force
//


///////////////////////////////////////// TYPE 2 issues
/// large datasets and unique keys

clear
set obs 1
gen a = 20451423
di a
// will show 20451424 and NOT  20451423


/*gen does not copy the type of var but asserts float for all num vars 
even if it copies a var that is double*/
gen double a1 = 20451423
gen b = a
gen b1 = a1
assert b==a
// will show TRUE
assert b1==a1
// will show FALSE



// the following command will do nothing
replace a = a +0.1
di a
assert b==a
// but this one will change the values
replace a1 = a1 +0.1
format %20.10g a1
format %20.10g a
di a1

di a
// but this one will change the values
replace a1 = a1 +0.1
format %20.10g a1
format %20.10g a
di a1






// will round the number to double by default killing all dicimal numbers
gen a3 = "1111811818181.1008008008008"
destring(a3), gen(a33)
format %20.10g a33




/*The lean of the default float number that can lead to very subtle errors*/
* This issue can happen in a such a typical  situation as the following
clear
set obs 100000000
gen a = _n
count if a != _n  //  will show  62,334,176 not equal
duplicates r a // one can expect that a is uqniue but it is not

/*The same would happen if one tries to creat group ids for a very large dataset
with ~>25mln groups
Stata will not show any errors but will just roll over the count once it reacesh*/ 
 gen b = floor(a/2)
egen b1 = group(b)
duplicates r b1

 
 //////////////////////////         This can happen to anyone

  clear
  set obs 1
 // the following sequence shows that the sequence of steps really matters
 // as Stata can automatically convert 1) int to long 2) int to float 
//   3) long to double but it will NOT convert float to double   
cap drop a5
cap drop a6
cap drop a7
 gen int a5 = 1
 * the same will happen if 
  ////////////////////    gen a5 = "1"
 //////////////////// destring(a5), replace
  replace  a5 = a5 + 100000
replace  a5 = a5 + 0.1
 gen int a6 = 1
replace  a6 = a6 + 0.1
 replace a6 = a6 + 100000 
 asser a5 == a6 // false
 gen  a7 = 1
 replace  a7 = a7 + 100000
replace  a7 = a7 + 0.1
 asser a5 == a7  // false
 asser a6 == a7  // true
 
/* Stata position
 
 1. It is considered a user error not to specify the variable type you really need.
 
 https://www.statalist.org/forums/forum/general-stata-discussion/general/1433074-egen-bug-failure-to-upgrade-variable-type
*/




