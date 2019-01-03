data soap;
input y x1 x2;
label  y = "Scrap(屑)" x1 = "Speed"
         x2 = "Production line";
cards;
  218  100  1
  248  125  1
  360  220  1
  351  205  1
  470  300  1
  394  255  1
  332  225  1
  321  175  1
  410  270  1
  260  170  1
  241  155  1
  331  190  1
  275  140  1
  425  290  1
  367  265  1
  140  105  0
  277  215  0
  384  270  0
  341  255  0
  215  175  0
  180  135  0
  260  200  0
  361  275  0
  252  155  0
  422  320  0
  273  190  0
  410  295  0
;
run;

proc format;
value x2f 0="生產線2" 1="生產線1";
run;

data soap;
set soap;
format x2 x2f.;
run;

proc print data=soap (obs=10);
run;

goption reset=all;
symbol1 v=dot c=blue;
symbol2 v=circle c=red;
axis1 order=(100 to 350 by 50);
legend1 value=("第二條生產線" "第一條生產線");
proc gplot data = soap;
plot y*x1 = x2 / haxis = axis1 legend=legend1;
run;
quit;

data soap;
set soap;
x1x2 = x1*x2;
run;
proc reg data = soap outest=soapest;
model y = x1 x2 x1x2/ ss1 clb;
output out=soapout p=yhat r=res;
run;
quit;

proc print data=soapest;
run;
proc print data=soapout;
run;

/*殘差 v.s. 兩個生產線的預測值*/
proc sort data = soapout;
by x2;
run;
symbol1 c=blue v=dot;
proc gplot data = soapout;
by x2;
plot res*yhat/ vref = 0;
run;
quit;

/*檢定殘差1*/
proc univariate data= soapout noprint; 
var res;
histogram res/normal;
qqplot res;
run;

/*檢定殘差2*/
data soapest;
set soapest;
call symput("rmse",_rmse_);
run;
proc sort data=soapout;
by res;
run;
data temp;
set soapout end=eof;
n=_n_;
if eof then do;
call symput("tn",_n_);
end;
run;
data temp (keep=res expec);
set temp;
expec=&rmse*quantile("normal",(n-0.375)/(&tn+0.25));
run;
proc corr data=temp pearson;
var res expec;
run;

/*檢定兩線的變異數*/
data soap1 soap2;
set soap;
if x2=1 then output soap1;
else if x2=0 then output soap2;
run;
/*各自作regression*/
proc reg data = soap1 noprint;
  model y = x1;
  output out=soap1o r=res;
run;
proc print data=soap1o;
run;
proc reg data = soap2 noprint;
  model y = x1;
  output out=soap2o r=res;
run;
proc print data=soap2o;
run;
data soap12;
set soap1o soap2o;
label res="個別生產線的殘差";
run;
proc print data=soap12 label;
run;

proc means data=soap12;
class x2;
var res;
output out=soap12o median=mres;
run;
proc print data=soap12o;
run;
data soap12o;
set soap12o;
if x2 ^= .;
keep x2 mres;
run;
proc print data=soap12;
run;
proc print data=soap12o;
run;

proc sort data=soap12;
by x2;
run;
proc sort data=soap12o;
by x2;
run;
/*殘差減去各群的中位數之絕對值*/
data soap3;
merge soap12 soap12o;
by x2;
diff=abs(res-mres);
label mres="中位數";
run;
proc print data=soap3;
run;

proc means data=soap3;
var diff;
class x2;
run;
proc ttest data=soap3;
class x2;
var diff;
title "Brown-Forsythe test";
run;
goption reset=all;
/*看集區t值-0.64，其絕對值即為0.636*/

/*檢定beta2, beta3*/
proc reg data = soap;
model y = x1 x2 x1x2 / alpha=0.01;
b2b3: test x2=x1x2=0;
b3:     test x1x2=0;
ods select testanova;
run;

proc reg data = soap;
model y = x1 x2 x1x2/clb alpha=0.05;
ods select ParameterEstimates;
run;

ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\ch08-07 output.pdf" startpage=no columns=2;
