
goption reset=all;
data bfat;
input x1 x2 x3 y;
/*label x1 = "三頭肌皮褶厚度" */
/*          x2 = "大腿圍"*/
/*	      x3 = "上臂圍"*/
/*          y = "人體脂肪量";*/
cards;
  19.5  43.1  29.1  11.9
  24.7  49.8  28.2  22.8
  30.7  51.9  37.0  18.7
  29.8  54.3  31.1  20.1
  19.1  42.2  30.9  12.9
  25.6  53.9  23.7  21.7
  31.4  58.5  27.6  27.1
  27.9  52.1  30.6  25.4
  22.1  49.9  23.2  21.3
  25.5  53.5  24.8  19.3
  31.1  56.6  30.0  25.4
  30.4  56.7  28.3  27.2
  18.7  46.5  23.0  11.7
  19.7  44.2  28.6  17.8
  14.6  42.7  21.3  12.8
  29.5  54.4  30.1  23.9
  27.7  55.3  25.7  22.6
  30.2  58.6  24.6  25.4
  22.7  48.2  27.1  14.8
  25.2  51.0  27.5  21.1
run;

/*辨識影響個案*/
proc reg data = bfat;
model y = x1 x2/influence r;
ods output OutputStatistics=bfatrout;
run; quit;
data bfat_all;
merge bfat bfatrout;
run;
proc print data=bfat (obs=5);
run;


data bfatinf;
retain Observation x1 x2 y DFFITS CooksD
	DFB_Intercept DFB_x1 DFB_x2;
set bfat_all (keep=Observation x1 x2 y DFFITS CooksD
	DFB_Intercept DFB_x1 DFB_x2);
PFofD=CDF("F", CooksD, 3, 17);
/*p=3, n-p=17*/
run;
proc print data=bfatinf (obs=5);
run;

ods pdf close;

options papersize=(11.7in 8.3in);
ods pdf file="d:\ch10-04 output.pdf" startpage=no columns=2;

/*DFFits*/
goption reset=all;
title1 "DFFits";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt '#DFFITS');
proc gplot data=bfatinf;
plot DFFITS*observation / vaxis=axis1 haxis=axis2 
	vref=(1 -1 0.7745 -0.7745 0) lvref=2 
    cvref=(red red blue blue black);
/*0.77456=2*sqrt(p/n)*/
/*The absolute value of DFFITS exceeds 1 for small to medium data sets */
/*and 2*sqrt(p/n) for large data sets. */
run;

/*CooksD Fig 10.8 (a)*/
goption reset=all;
title1 "Fig 10.8 (a)";
axis1 label=none offset=(1cm) minor=none order=(-4.5 to 4.5 by 1.5);
axis2 label=none offset=(1cm) minor=none order=(10 to 30 by 5);
proc gplot data=bfat_all;
bubble residual*predictedvalue=cooksd / 
	blabel vaxis=axis1 haxis=axis2 ;
run;

/*CooksD Fig 10.8 (b)*/
goption reset=all;
title1 "CooksD";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=join value=dot color=red height=1.3 
        pointlabel=(height=10pt "#CooksD");
proc gplot data=bfatinf;
plot CooksD*observation / vaxis=axis1 haxis=axis2 ;
run;

/*F of CooksD Fig 10.8 (b)*/
goption reset=all;
title1 "F of CooksD";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt "#CooksD");
proc gplot data=bfatinf;
plot PFofD*observation / vaxis=axis1 haxis=axis2 
	vref=(0 0.1 0.2 0.5 ) lvref=2 
    cvref=(black blue blue red);
/*帶進去F的值，若小於0.2，表影響不大*/
/*	若大於0.5，表影響很大*/
run;

options papersize=(11.7in 8.3in);
ods pdf file="d:\ch10-04a output.pdf" startpage=yes columns=2;

proc print data = bfatinf noobs;
where (-0.77456>DFFITS and DFFITS>0.77456) or 
		PFofD>0.2 or DFB_Intercept>1 or DFB_x1>1 or DFB_x2 >1;
run;


data bfat;
set bfat;
if _n_ ne 3 then yd3=y;
run;
proc print data=bfat;
run;

goption reset=all;
proc reg data = bfat outest=bfatest noprint;
Model1: model y = x1 x2;
output out=bfatout p=yhat;
run;
proc reg data = bfat outest=bfatestd3 noprint;
Modeld3: model yd3 = x1 x2;
output out=bfatoutd3 p=yhatd3;
run;
/*proc print data=bfatest;*/
/*run;*/
/*proc print data=bfatestd3;*/
/*run;*/
data est;
set bfatest bfatestd3;
run;
proc print data=est;
run;

data preout;
merge bfatout bfatoutd3;
run;
proc print data=preout;
run;

data preout;
set preout;
diff_p=abs((yhatd3-yhat)/yhat);
diff_in=diff_p<0.05;
run;
proc means data=preout mean;
var diff_p;
run;
proc freq data=preout;
table diff_in;
run;

ods pdf close;


