%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x="Lot Size" y="Work Hours";
run;

proc reg data=toluca outest=tolest noprint;
  model y=x/ sse;
  output out=tolout p=yhat r=res stdp=sti;
run;
data tolest;
  set tolest;
  call symput("sse",_sse_);
run;
proc print data=tolest;
run;

/*´Ý®t¥­¤è*/
data tol_logr2;
  set tolout;
  * logr2=log(res**2);
  logr2=res**2;
run;
proc print data=tol_logr2;
run;

/*ods trace on;*/
/*ods trace off;*/

proc reg data=tol_logr2 outest=tol_logr2est;
  model logr2=x;
  ods output ANOVA=anova NObs=nobs;
run;
quit;
data ssr;
  set anova (obs=1 firstobs=1);
  keep ss;
  call symput("ssrs",ss);
run;
data nobs;
  set nobs (obs=1 firstobs=1);
  call symput("nobs",n);
run;
quit;

data B_P_test;
 ssrs=&ssrs;
 sse=&sse;
 nobs=&nobs;
 tests=(ssrs/2)/((sse/nobs)**2);
 pv=1-cdf("chisquare",tests,1);
run;
proc print data=B_P_test;
run;
