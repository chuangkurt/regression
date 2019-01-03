data tab0706;
input x1 x2 y;
label x1="工作機組規模"
 x2="獎金水準" y="生產力";
cards;
  4  2  42
  4  2  39
  4  3  48
  4  3  51
  6  2  49
  6  2  53
  6  3  61
  6  3  60
;
run;

proc corr data=tab0706 plot=matrix;
run;

proc reg data = tab0706;
model y = x1;
model y = x2;
model y = x1-x2 / ss1;
model y = x2 x1 / ss1;
ods select ParameterEstimates;
run;


data tab0708;
input x1 x2 y;
cards;
  2  6  23
  8  9  83
  6  8  63
10 10  103
;
run;

proc corr data=tab0708 plot=matrix;
run;

proc reg data = tab0708;
model y = x1-x2;
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
  25.0  50.0  29.0 .
run;

proc corr data=bfat plot=matrix;
run;

proc reg data=bfat;
model y=x1 / ss1;
model y=x2 / ss1;
model y=x1-x2 / ss1 pcorr1;
model y=x2 x1 / ss1 pcorr1;
model y=x1-x3 / ss1 pcorr1;
ods select ParameterEstimates;
run;


/*prediction*/
/*macro*/



%macro create(varn);
data pred;
input x1-x3 y yhat yhatsd m;
run;

%do i=1 %to &varn;
proc reg data=bfat noprint;
model y=x1-x&i;
output out=bfatout p=yhat stdp=yhatsd;
run;
data bfatout;
set bfatout;
if _n_=21;
m=&i;
run;

data pred;
set pred bfatout;
run;
%end;

proc print data=pred;
run;
%mend create;
%create(3)


proc reg data=bfat;
model y=x1-x2 / alpha=0.025;
ods select anova ParameterEstimates;
run;

ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\sec7-6.pdf" startpage=no columns=2;
