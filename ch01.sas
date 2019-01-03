proc import datafile="K:\Dropbox\51 regression\dataset\toluca.csv"
      out=toluca dbms=csv replace;
  getnames=yes;
  label x='Lot Size' y='Work Hours';
run;
proc print data=toluca label;
run;

/*Table 1.1*/
proc sql;
  create table ch01tab01 as
  select *, x - mean(x) as xdif, y - mean(y) as ydif, (x - mean(x))*( y - mean(y)) as crp,
           (x - mean(x))*(x - mean(x)) as sqdevx, (y - mean(y))*(y - mean(y)) as sqdevy 
  from toluca;
quit;
proc print label;
run;

/*Figure 1.10 (a)*/
symbol1 v=dot h=.8 c=blue;
proc gplot data = toluca;
  plot y*x;
run;
quit;

/*Figure 1.10 (b)*/
proc reg data = toluca;
  model y = x;
  plot y*x;
run;
quit;

/*Table 1.2*/
proc reg data = toluca /*noprint*/;
  model y = x;
/*  model y = x / clb alpha=.1;*/
  output out=tolucares p=yhat r=resid;
run;
quit;
data tolucares;
  set tolucares;
  rsq = resid**2;
run;
proc print data = tolucares label;
  var x y yhat resid rsq;
  label rsq='Squared Residual';
run;

/*ods graphics on;*/
/*ods graphics off; */

goptions reset = all; 
/*symbol1 value=star color=black;*/
symbol1 v=dot h=.8 c=blue;
symbol2 v=circle i=join;
proc gplot data=tolucares;
  plot y*x=1 yhat*x=2/overlay;
  title 'Predicted & Observed Work Hours vs Lot Size';
run;

proc gplot data = tolucares;
  plot resid*x/vref=0;
  title 'Residual vs Lot Size';
run;
