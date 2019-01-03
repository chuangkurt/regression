%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x='Lot Size' y='Work Hours';
run;

proc sort data=toluca out=toluca_p;
by x;
run;
proc print data=toluca_p;
run;

/*Example 1 and 2*/
data new;
input x y;
cards;
65 .
100 .
;
run;
data toluca_p;
set toluca_p new;
run;
proc print data=toluca_p;
run;

proc reg data = toluca_p noprint;
  model y = x / clb alpha=0.1;
  output out=toluca_out p=yhat uclm=mub lclm=mlb stdp=msd;
  output out=toluca_out1 p=yhat stdi=psd ucl=pub lcl=plb;
run;

proc print data=toluca_out;
where x in (65 100);
run;


proc import datafile="&indir\expenditure.csv" out=expen dbms=csv replace;
  getnames=yes;
  label x="Population" y="Per capita Expenditure";
run;
proc print;run;

proc corr data=expen pearson spearman plots=matrix(histogram);
  var x y;
run;
