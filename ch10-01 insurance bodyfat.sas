options papersize=(11.7in 8.3in);
ods pdf file="d:\ch10-01 output.pdf" startpage=no columns=2;

data insurance;
input x1 x2 y;
/*label x1="平均年收入" x2="風險規避分數"*/
/*	y="壽險保額";*/
cards;
45.010   6   91
57.204   4  162
26.852   5   11
66.290   7  240
40.964   5   73
72.996  10  311
79.380   1  316
52.766   8  154
55.916   6  164
38.122   4   54
35.840   6   53
75.796   9  326
37.408   5   55
54.376   2  130
46.186   7  112
46.130   4   91
30.366   3   14
39.060   5   63
run;

proc reg data=insurance;
model y x1=x2;
output out=insout1 r=ye x1e;
/*ods exclude NObs DiagnosticsPanel ResidualPlot DiagnosticsPanel */
/*	FitStatistics FitPlot*/
ods select ANOVA ParameterEstimates;
run;

data insout1;
set insout1;
label ye="e(Y|X2)" x1e="e(X1|X2)";
run;
proc print data=insout1 (obs=10) label;
run;

symbol1 value=dot;
proc reg data=insout1;
var ye x1 x1e;
model ye=x1e / r;
plot ye*x1 ye*x1e r.*x1/ vref=0;
ods exclude DiagnosticsPanel ResidualPlot 
	FitStatistics FitPlot;
run;

proc reg data=insurance;
model y=x2 x1/partial pcorr1 r;
run;


data bfat;
input x1 x2 x3 y;
label x1 = "三頭肌皮褶厚度" 
          x2 = "大腿圍"
	      x3 = "上臂圍"
          y = "人體脂肪量";
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
data bfat;
set bfat;
n=_n_;
run;

proc reg data=bfat;
model y=x1 x2/partial pcorr1;
ods exclude nobs DiagnosticsPanel FitStatistics FitPlot;
run;

ods pdf close;
