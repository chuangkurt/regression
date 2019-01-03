/*3-10*/
/*fig 3.19(a)*/
%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x="Lot Size" y="Work Hours";
run;

ods listing close;
proc loess data = toluca ;
model y = x / degree=2 smooth = 0.55 0.65 0.75 0.85;
run;

proc loess data = toluca ;
model y = x / degree=2 smooth = 0.85;
ods output OutputStatistics=loessout;
run;
ods listing;

proc print data=loessout;
run;
proc sort data=loessout;
by x;
run;

goptions reset = all;
symbol1 v=none c=blue i=join ;
symbol2 v=dot c=blue i=none h=.8; 
axis1 order=(0 to 150 by 50);
proc gplot data=loessout; 
plot  DepVar*x=2 pred*x=1/overlay haxis=axis1;
run;
quit;

/*fig 3.19(b)*/
data loessout;
set loessout;
rename Depvar=y pred=loess;
run;
proc print data=loessout;
run;
/*proc sort data=loessout;*/
/*by x;*/
/*run;*/
proc reg data = loessout noprint;
model y = x;
output out=temp lclm=mlb uclm=mub;
run;
quit;
proc print data=temp;
run;
 
goptions reset = all;
symbol1 v=none i=join c=red line=10;
symbol2 v=none h=.4 i=join c=black;
symbol3 v=none i=join c=red line=20;
axis1 label=(angle=90 "hours");
axis2 order=(0 to 150 by 50);
proc gplot data = temp;
plot (mlb loess mub)*x/overlay vaxis=axis1 haxis=axis2;
run;
quit;
