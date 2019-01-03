data ch3tab07;
  input x y;
  label x = "受訓天數" y = "業積";
cards;
  0.5   42.5
  0.5   50.6
  1.0   68.5
  1.0   80.7
  1.5   89.0
  1.5   99.6
  2.0  105.3
  2.0  111.8
  2.5  112.3
  2.5  125.7
;
run;

data ch3tab07;
  set ch3tab07;
  sqrtX = sqrt(x);
run;

/*fig. 3.14 (a) (b)*/

symbol1 v=star c=red h=1.5;
symbol2 v=dot c=blue h=0.8;
proc gplot data=ch3tab07;
  plot y*x=1 y*sqrtx=2/overlay;
run;
goptions reset = all; 

/*fig. 3.14 */
symbol1 v=dot c=blue h=.8;
proc reg data = ch3tab07;
  var x;
  model y = sqrtx;
  plot y*x y*sqrtx r.*sqrtx r.*nqq.;
run;
quit;

data ch3tab08;
  input x y logy;
  label x = "Age" y = "Plasma(血漿多胺水準)" logy = "Log(plasma)";
cards;
    0  13.44  1.1284
    0  12.84  1.1086
    0  11.91  1.0759
    0  20.09  1.3030
    0  15.60  1.1931
  1.0  10.11  1.0048
  1.0  11.38  1.0561
  1.0  10.28  1.0120
  1.0   8.96   .9523
  1.0   8.59   .9340
  2.0   9.83   .9926
  2.0   9.00   .9542
  2.0   8.65   .9370
  2.0   7.85   .8949
  2.0   8.88   .9484
  3.0   7.94   .8998
  3.0   6.01   .7789
  3.0   5.14   .7110
  3.0   6.90   .8388
  3.0   6.77   .8306
  4.0   4.86   .6866
  4.0   5.10   .7076
  4.0   5.67   .7536
  4.0   5.75   .7597
  4.0   6.23   .7945
;
run;

/*fig 3.16*/
symbol1 v=dot c=blue h =.8;
proc reg data = ch3tab08;
  var y;
  model logy = x;
  plot y*x logy*x r.*x r.*nqq.;
run;
quit;

/**/
ods graphics on;
proc transreg data=ch3tab08 test;
	model BoxCox(y) = identity(x);
run;

data ch3tab08;
set ch3tab08;
y2=y**(-0.5);
run;

proc reg data=ch3tab08;
model y2=x / lackfit  clb;
run;
