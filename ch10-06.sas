data surg;
infile "K:\Dropbox\51 regression\dataset\CH09TA01.txt" dlm= '09'x;
input x1-x8 y;
/*label x1 = "血液凝結分數"*/
/*        x2 = "前兆指數"*/
/*		x3 = "酵素功能指數"*/
/*		x4 = "肝功能指數"*/
/*		x5 = "年紀"*/
/*		x6=  "性別"*/
/*		x7=  "普通飲酒"*/
/*		x8=  "嚴重飲酒"*/
/*		 y =  "存活時間";*/
run;
data surg;
set surg;
lny= log(y);
x1x2=x1*x2;
x1x3=x1*x3;
x1x8=x1*x8;
x2x3=x2*x3;
x2x8=x2*x8;
x3x8=x3*x8;
run;


proc corr data=surg;
var lny x1 x2 x3 x8;
run;

proc reg data=surg;
model lny=x1 x2 x3 x8 x1x2 x1x3 x1x8 x2x3 x2x8 x3x8 / partial;
test x1x2=x1x3=x1x8=x2x3=x2x8=x3x8=0;
run;

/*Fig 10.9 (a)(b)(d)*/
goptions reset=all;
symbol v=dot i=none;
proc reg data=surg;
var x5;
model lny=x1 x2 x3 x8;
output out=out1 r=resi;
plot r.*p. r.*x5 r.*nqq.;
run;
quit;

/*Fig 10.9(c)*/
proc reg data=surg;
model lny=x1 x2 x3 x5 x8 / partial;
test x5=0;
run;


/*Multicollinearity*/
proc reg data=surg;
model lny= x1 x2 x3 x8/vif stb;
ods select ParameterEstimates;
ods output ParameterEstimates=surgest;
run; quit;
data surgvif;
set surgest (where=(VarianceInflation ne 0));
keep StandardizedEst VarianceInflation;
run;
proc means data=surgvif max mean;
var VarianceInflation;
run;


/*Y 離群值之確認*/
proc reg data = surg noprint;
model lny= x1 x2 x3 x8/influence r;
/*ods select ANOVA OutputStatistics StudResCooksDChart ResidualStatistics;*/
ods output OutputStatistics=surgrout;
run; quit;

/* Fig 10.10 (a) ti(Studentized Deleted Residuals)*/
goption reset=all;
title "ti(Studentized Deleted Residuals)";
axis1 label=none order=(-4.5 to 4.5 by 1) minor=none;
axis2 label=('觀測順序') offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=surgrout;
plot RStudent*observation / 
	vaxis=axis1 haxis=axis2 
	vref=(3.526093 -3.526093) lvref=2 cvref=blue;
run;
/*t(1-alpha/2n;n-p-1)=3.526093, where alpha=0.05, n=54, p=4*/


/*X 離群值之確認*/
goption reset=all;
title "Fig 10.10 (b) Leverage";
axis1 offset=(1cm) minor=none;
axis2 offset=(1cm) minor=none;
symbol1 i=none value=dot color=darkblue height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=surgrout;
plot HatDiagonal*observation / vaxis=axis1 haxis=axis2 
   vref=(0.1851852 0.5 0.2) cvref=('red' 'green' 'green')
   lvref=(1 2 2);
/* 2p/n=0.1851852, where p=5, n=54比它大就可被視為離群值*/
/* 比0.5大，Leverage過大*/
/*0.2-0.5 ，Leverage中度大*/
run;
ods pdf close;


/*辨識影響個案*/
data surgrout;
set surgrout;
PFofD=CDF("F", CooksD, 5, 49);
/*p=5, n-p=49*/
run;

/*F of CooksD Fig 10.10 (c)*/
goption reset=all;
title1 "F of CooksD";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt "#observation");
proc gplot data=surgrout;
plot PFofD*observation / vaxis=axis1 haxis=axis2 
	vref=(0 0.1 0.2 0.5 ) lvref=2 
    cvref=(black blue blue red);
/*帶進去F的值，若小於0.2，表影響不大*/
/*	若大於0.5，表影響很大*/
run;


/*DFFits Fig 10.10 (d)*/
goption reset=all;
title1 "DFFits";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=join value=dot color=darkblue height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=surgrout;
plot DFFITS*observation / vaxis=axis1 haxis=axis2 
	vref=(1 -1 0.6085806 -0.6085806 0) lvref=2 
    cvref=(red red blue blue black);
/*0.6085806=2*sqrt(p/n), where p=5, n=54*/
/*The absolute value of DFFITS exceeds 1 for small to medium data sets */
/*and 2*sqrt(p/n) for large data sets. */
run;


/*Table 10.6 把所有的閒疑犯叫出*/
proc print data = surgrout;
where observation in (17 23 28 32 38 42 52);
var Residual RStudent HatDiagonal CooksD DFFITS; 
run;
proc print data = surgrout;
where DFB_Intercept>1 or DFB_x1>1 or DFB_x2 >1 or DFB_x3 >1 or DFB_x8 >1;
run;


/*判斷影響情況*/
data surg;
set surg (drop=x1x2 x1x3 x1x8 x2x3 x2x8 x3x8);
if _n_ ne 17 then yd17=lny;
run;
proc print data=surg (obs=20);
run;

goption reset=all;
proc reg data = surg outest=surgest noprint;
Model1: model lny = x1 x2 x3 x8;
output out=surgout p=yhat;
run;
proc reg data = surg outest=surgestd17 noprint;
Modeld17: model yd17 = x1 x2 x3 x8;
output out=surgoutd17 p=yhatd17;
run;
/*proc print data=bfatest;*/
/*run;*/
/*proc print data=bfatestd3;*/
/*run;*/
data est;
set surgest surgestd17;
run;
proc print data=est;
run;

data preout;
merge surgout surgoutd17;
run;
data preout;
set preout;
diff_p=abs((yhatd17-yhat)/yhat);
diff_in=diff_p<0.05;
run;
proc means data=preout mean max;
var diff_p;
run;
proc freq data=preout;
table diff_in;
run;
