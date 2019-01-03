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

/*Sec 7.1*/
proc corr data=bfat plots=matrix nocorr;
var y x1-x3;
run;

proc reg data = bfat;
x1:    model y = x1;
x2:    model y = x2;
x12:   model y = x1 x2;
x123: model y = x1-x3;
ods select anova;
run;

proc reg data = bfat;
model y = x1-x3/ss1 ss2;
ods select ParameterEstimates;
run;

/*Sec 7.2-7.3*/
/*ss1 逐一加入的貢獻度*/
/*ss2 該變數對整個模型的貢獻度,*/
proc reg data = bfat plots=none;
model y = x1-x3/ss1 ss2;
/*ods select anova ParameterEstimates TestANOVA;*/
b3: test x3 = 0;  
b23: test x2=x3=0;
run;

proc reg data=bfat plots=none;
x123: model y=x1-x3;
x12:   model y=x1 x2;
x1:     model y=x1;
ods select FitStatistics;
run;

/*Sec. 7.4*/
proc reg data = bfat plots=none;
model y = x1-x3/pcorr1 pcorr2;
model y = x2 x1/pcorr1 pcorr2;
ods select ParameterEstimates;
run;

/*Sec. 7.4 comments*/
proc reg data=bfat noprint;
model y x1=x2;
output out=bfatout r=resy resx1 p=yhat x1hat;
run;

goption reset=all;
axis1 label=("e(Y|X2)");
axis2 label=("e(X1|X2)");
symbol1 value=circle c=blue;
proc gplot data=bfatout;
plot resy*resx1 / vref=0 lvref=2 vaxis=axis1 haxis=axis2;
title "Partial Regression Plot";
run;

proc reg data=bfatout plots=none;
model resy=resx1;
run;
ods pdf close;
ods pdf file="d:\sec7-4.pdf" startpage=no;

