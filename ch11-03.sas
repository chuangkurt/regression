data ch11tab4; 
input state $20. y x1 x2 x3 x4 x5;
/*label y = 'Math profeciency'*/
/*        x1 = 'Parents'*/
/*        x2 = 'Homelib'*/
/*        x3 = 'Reading'*/
/*        x4 = 'TV Watching'*/
/*        x5 = 'Absences';*/
cards;
 Alabama                 252  75  78  34  18  18
 Arizona                 259  75  73  41  12  26
 Arkansas                256  77  77  28  20  23
 California              256  78  68  42  11  28
 Colorado                267  78  85  38   9  25
 Connecticut             270  79  86  43  12  22
 Delaware                261  75  83  32  18  28
 Distric_of_Columbia     231  47  76  24  33  37
 Florida                 255  75  73  31  19  27
 Georgia                 258  73  80  36  17  22
 Guam                    231  81  64  32  20  28
 Hawaii                  251  78  69  36  23  26
 Idaho                   272  84  84  48   7  21
 Illinois                260  78  82  43  14  21
 Indiana                 267  81  84  37  11  23
 Iowa                    278  83  88  43   8  20
 Kentucky                256  79  78  36  14  23
 Louisiana               246  73  76  36  19  27
 Maryland                260  75  83  34  19  27
 Michigan                264  77  84  31  14  25
 Minnesota               276  83  88  36   7  20
 Montana                 280  83  88  44   6  21
 Nebraska                276  85  88  42   9  19
 New_Hampshire           273  83  88  40   7  22
 New_Jersey              269  79  84  41  13  23
 New_Mexico              256  77  72  40  11  27
 New_York                261  76  79  35  17  29
 North_Carolina          250  74  78  37  21  25
 North_Dakota            281  85  90  41   6  14
 Ohio                    264  79  84  36  11  22
 Oklahoma                263  78  78  37  14  22
 Oregon                  271  81  82  41   9  31
 Pennsylvania            266  80  86  34  10  24
 Rhode_Island            260  78  80  38  12  28
 Texas                   258  77  70  34  15  18
 Virgin_Islands          218  63  76  23  27  22
 Virginia                264  78  82  33  16  24
 West_Virginia           256  82  80  36  16  25
 Wisconsin               274  81  86  38   8  21
 Wyoming                 272  85  86  43   7  23
;
run;

options papersize=(11.7in 8.3in);
ods pdf file="d:\ch11-03 outputa.pdf" startpage=no columns=2;

proc print data=ch11tab4; 
run;

/*Fig 11.5(b)*/
proc reg data = ch11tab4;
model y = x2;
output out=regout r=res p=yhat ucl=pub lcl=plb;
ods select ResidualPlot;
run;

/*Fig 11.5(a)*/
proc loess data = ch11tab4;
model y = x2 / degree=2 smooth = 4;
ods output OutputStatistics=loessout;
ods select FitPlot;
run;
proc sort data=loessout;
by x2 DepVar;
run;
proc print data=loessout (obs=10); 
run;

goption reset=all;
axis1 order=(60 to 90 by 10) minor=none offset=(1cm 1cm);
axis2 label=(angle=90 r=-90) minor=none;
symbol1 v=dot  c=blue  h=1;
symbol2 i=rlcli95 ci=blue co=blue w=1.1 line=2;
symbol3 i=join c=red line=3 w=1.1;
proc gplot data=loessout;
plot DepVar*x2=1 DepVar*x2=2 Pred*x2=3/ overlay haxis=axis1 vaxis=axis2;
run;


proc sql; 
  create table ch11tab5 as
  select *, (x2-mean(x2)) as xc2,
              (x2-mean(x2))*(x2-mean(x2)) as xcs2
  from ch11tab4;
quit;

proc reg data = ch11tab5;
model y = xc2 xcs2 / influence;
output out=tab5out p=yhat cookd=CooksD;
ods select ParameterEstimates;
run;

/*Fig 11.5(c)*/
data tab5out;
set tab5out;
observation=_n_;
run;
proc sort data=tab5out;
by x2;
run;
axis1 order=(60 to 90 by 10) minor=none offset=(1cm 1cm);
axis2 label=(angle=90 r=-90) minor=none;
symbol1 v=dot  c=blue  h=1;
symbol2 i=join c=red w=1.2;
proc gplot data=tab5out;
plot y*x2=1 yhat*x2=2/ overlay haxis=axis1 vaxis=axis2;
run;
goption reset=all;

/*Fig 11.5(d)*/
data tab5out;
set tab5out;
PFofD=CDF("F", CooksD, 3, 37);
/*p=3, n-p=37*/
run;
/*F of CooksD*/
title1 "F of CooksD";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt "#observation");
proc gplot data=tab5out;
plot PFofD*observation / vaxis=axis1 haxis=axis2 
	vref=(0 0.1 0.2 0.5 ) lvref=2 
    cvref=(black blue blue red);
/*帶進去F的值，若小於0.2，表影響不大*/
/*	若大於0.5，表影響很大*/
run;
goption reset=all;


proc robustreg data = ch11tab5 method=m(wf=huber(C=1.345) maxiter=0 scale=4.6683);
model y = xc2 xcs2;
output out=IRLS p=yhat1 r=res1 weight=wt;
ods select ParameterEstimates;
run;
quit;
proc print data=IRLS (obs=10);
run;
proc robustreg data = ch11tab5 method=m(wf=huber(C=1.345) maxiter=7 scale=med);
model y = xc2 xcs2;
output out=IRLS p=yhat1 r=res1 weight=wt;
ods select ParameterEstimates;
run;
quit;
proc print data=IRLS (obs=10);
run;

/*Fig 11.5(e)*/
data IRLS;
set IRLS;
observation=_n_;
run;
proc sort data=IRLS;
by x2;
run;
title "Robust Quadratic Fit";
axis1 order=(60 to 90 by 10) minor=none offset=(1cm 1cm);
axis2 label=(angle=90 r=-90) minor=none;
symbol1 v=dot  c=blue  h=1;
symbol2 i=join c=red w=1.2;
proc gplot data=IRLS;
plot y*x2=1 yhat1*x2=2/ overlay haxis=axis1 vaxis=axis2;
run;
goption reset=all;

/*Fig 11.5(f)*/
goption reset=all;
title1 "穩健加權";
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt "#observation");
proc gplot data=IRLS;
plot wt*observation;
run;
goption reset=all;
proc print data=IRLS;
where observation in (8 11 36);
run;


/*Fig 11.6*/
goption reset=all;
proc sgscatter data=ch11tab5 ; 
plot (y x1-x2)* (y x1-x2) /loess=(smooth=0.9 degree=2);
run;

proc corr data=ch11tab5 plots=matrix;
var y x1-x5;
run;

/*Tab 11.6*/
proc reg data = ch11tab5 noprint;
model y =x1-x5/influence;
output out=out5 r=res h=HatDiagonal rstudent=RStudent COOKD=CooksD;
run;

data out5;
set out5;
observation=_n_;
PFofD=CDF("F", CooksD, 6, 34);
/*p=6, n-p=34*/
run;
/*F of CooksD*/
title1 "F of CooksD";
axis1 label=none offset=(1cm) minor=none;
axis2 label=none offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt "#observation");
proc gplot data=out5;
plot PFofD*observation / vaxis=axis1 haxis=axis2 
	vref=(0 0.1 0.2 0.5 ) lvref=2 
    cvref=(black blue blue red);
/*帶進去F的值，若小於0.2，表影響不大*/
/*	若大於0.5，表影響很大*/
run;
goption reset=all;

/*X 離群值之確認*/
title "Leverage";
axis1 offset=(1cm) minor=none;
axis2 offset=(1cm) minor=none;
symbol1 i=none value=dot color=darkblue height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=out5;
plot HatDiagonal*observation / vaxis=axis1 haxis=axis2 
   vref=(0.3 0.5 0.2) cvref=('red' 'green' 'green')
   lvref=(1 2 2);
/* 2p/n=0.3, where p=6, n=40比它大就可被視為離群值*/
/* 比0.5大，Leverage過大*/
/*0.2-0.5 ，Leverage中度大*/
run;
goption reset=all;


/* ti(Studentized Deleted Residuals)*/
title "ti(Studentized Deleted Residuals)";
axis1 label=none minor=none;
axis2 label=('觀測順序') offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=out5;
plot RStudent*observation / 
 vaxis=axis1 haxis=axis2 
 vref=(3.529649 -3.529649) lvref=2 cvref=blue;
run;
goption reset=all;
/*t(1-alpha/2n;n-p-1)=3.529649, where alpha=0.05, n=40, p=6*/

proc print data = out5;
where (RStudent>3.529649 or RStudent<-3.529649) or HatDiagonal>0.3 or
	PFofD>0.2;
run;
/*hat (2*6/40), qt(1-0.05/(2*40),40-6-1), qf(0.5,6,34) qf(0.25,6,34)*/

/*model selection*/
proc reg data = ch11tab5;
model y =x1-x5/selection=rsquare rsquare adjrsq cp aic sbc;
ods select SubsetSelSummary;
ods output SubsetSelSummary=modelcri;
run;

/*設定各自的rank*/
proc sort data=modelcri;
by aic;
run;
data modelcri1;
set modelcri;
aicrank=_n_;
run;
proc sort data=modelcri1;
by sbc;
run;
data modelcri1;
set modelcri1;
sbcrank=_n_;
run;
proc sort data=modelcri1;
by decending adjrsq;
run;
data modelcri1;
set modelcri1;
adjrsqrank=_n_;
run;
/*各自挑前5名出來*/
proc print data=modelcri1;
where aicrank<5 | sbcrank<5;
run;

proc reg data = ch11tab5;
model y =x2-x4;
ods select ParameterEstimates;
run;
proc robustreg data = ch11tab5 method=m(wf=huber(C=1.345) maxiter=8 scale=med);
model y =x2-x4;
ods select ParameterEstimates;
run;

ods pdf close;

