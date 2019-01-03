%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x='Lot Size' y='Work Hours';
run;

proc reg data=toluca;
model y = x / clb;
run;



%macro create(n);
proc surveyselect data=toluca
   method=urs n=25 out=SampleSRS noprint;
run;
proc reg data=SampleSRS outest=estSRS noprint;
model y = x;
run;

%do i=1 %to &n-1;
proc surveyselect data=toluca
   method=urs n=25 out=SampleSRS noprint;
run;
proc reg data=SampleSRS outest=est noprint;
model y = x;
run;
data estSRS;
set estSRS est;
run;
%end;
%mend create;
%create(10000)

proc print data=estSRS;
run;

proc reg data=toluca;
model y = x;
run;

proc means data=estSRS mean std;
run;
