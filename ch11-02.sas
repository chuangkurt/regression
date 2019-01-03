data ch7tab1;
input x1 x2 x3 y;
label x1 = '三頭肌皮褶厚度' 
       x2 = '大腿圍'
       x3 = '上臂圍'
       y = 'body fat';
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
  ;
run;

proc sql; 
  create table ch7tab1s as
  select *, (y-mean(y))/(std(y)*(sqrt(count(y)-1))) as ys,
              (x1-mean(x1))/(std(x1)*(sqrt(count(x1)-1))) as xs1,
              (x2-mean(x2))/(std(x2)*(sqrt(count(x2)-1))) as xs2,
              (x3-mean(x3))/(std(x3)*(sqrt(count(x3)-1))) as xs3
  from ch7tab1;
quit;

options papersize=(11.7in 8.3in);
ods pdf file="d:\ch11-02 output.pdf" startpage=no columns=2;

/*Fig 11.3*/
symbol1 v=dot h=.8;
proc reg data = ch7tab1s outest = ridgeout noprint;
model ys = xs1-xs3/ ridge = (0 to 0.1 by .002) outvif  ;
plot / ridgeplot vref=0;
run;
quit;

data ridge ridgevif;
set  ridgeout;
if _type_="RIDGEVIF" then output ridgevif;
if _type_="RIDGE" then output ridge;
run;quit;

/*Table 11.2*/
data ridge;
set ridge;
keep _ridge_ xs1 xs2 xs3;
run;
proc print data=ridge (obs=10);
run;

/*Table 11.3*/
data ridgevif;
set ridgevif;
keep _ridge_ xs1 xs2 xs3;
rename xs1=vif1 xs2=vif2 xs3=vif3;
run;
proc print data=ridgevif (obs=10);
run;

axis1 order=(0 to 2);
proc gplot data=ridgevif;
plot (vif1 vif2 vif3)*_ridge_/
	overlay vaxis=axis1 vref=1 href=0.02;
run;

proc means data=ch7tab1;
var y x1-x3;
output out=mout mean=ym xm1-xm3 std=ysd xsd1-xsd3;
run;
proc print data=mout;
run;
proc reg data = ch7tab1s outest = ridgedo noprint;
  model ys = xs1-xs3/ ridge = 0.02;
run;
quit;
data ridgedo;
set ridgedo;
keep xs1 xs2 xs3;
if _type_="RIDGE";
run;
data ridgedo;
merge ridgedo mout;
run;
proc print data=ridgedo;
run;

data ridgedo;
set ridgedo;
b1=(ysd/xsd1)*xs1;
b2=(ysd/xsd2)*xs2;
b3=(ysd/xsd3)*xs3;
b0=ym-b1*xm1-b2*xm2-b3*xm3;
keep b0-b3;
run;
proc print data=ridgedo;
run;

ods pdf close;
