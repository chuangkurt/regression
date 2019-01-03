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
;
run;


/*置中*/
proc sql; 
create table bfatt as
  select *, 
		(x1*x2) as x12, (x1*x3) as x13, (x2*x3) as x23,
		x1-mean(x1)  as xc1, x2-mean(x2) as xc2, x3-mean(x3) as xc3,
		(x1-mean(x1))*(x2-mean(x2)) as xc12,
        (x1-mean(x1))*(x3-mean(x3)) as xc13,
		(x3-mean(x3))*(x2-mean(x2)) as xc23
  from bfat;
quit;


/*相關係數*/
proc corr data = bfatt;
var x1-x3 x12 x13 x23;
ods select PearsonCorr;
run;
proc corr data = bfatt;
var xc1-xc3 xc12 xc13 xc23;
ods select PearsonCorr;
run;


/*有無置中化的比較*/
/*macro*/
proc reg data=bfatt;
Origin: model y=x1-x3 x12 x13 x23;
Centering: model y=xc1-xc3 xc12 xc13 xc23;
ods select anova;
run;
proc reg data=bfatt;
Origin: model y=x1-x3 x12 x13 x23;
Centering: model y=xc1-xc3 xc12 xc13 xc23;
ods select FitStatistics;
run;
proc reg data=bfatt;
Origin: model y=x1-x3 x12 x13 x23 / ss1;
Centering: model y=xc1-xc3 xc12 xc13 xc23 / ss1;
ods select ParameterEstimates;
run;
proc reg data=bfatt;
Origin: model y=x1-x3 x12 x13 x23 / p r;
Centering: model y=xc1-xc3 xc12 xc13 xc23 / p r;
ods select OutputStatistics;
run;

  
/*檢定當然相同*/
proc reg data=bfatt;
Origin: model y=x1-x3 x12 x13 x23;
test x12=x13=x23=0;
ods select TestANOVA;
run;
proc reg data=bfatt;
Centering: model y=xc1-xc3 xc12 xc13 xc23;
test xc12=xc13=xc23=0;
ods select TestANOVA;
run;
   
ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\ch08-02.pdf" startpage=no columns=2;
