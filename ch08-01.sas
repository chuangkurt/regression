data charge;
input y x1 x2;
label  y = "循環次數" x1 = "充電率"
  x2 = "溫度";
cards;
  150  0.6  10
   86  1.0  10
   49  1.4  10
  288  0.6  20
  157  1.0  20
  131  1.0  20
  184  1.0  20
  109  1.4  20
  279  0.6  30
  235  1.0  30
  224  1.4  30
;
run;

/*置中*/
proc sql; 
create table chargep as
  select *, 
		x1**2 as xsq1, x2**2 as xsq2,
		(x1*x2) as x12,
		x1-mean(x1)         as xc1,    x2-mean(x2)         as xc2,
		(x1-mean(x1))**2 as xcsq1, (x2-mean(x2))**2 as xcsq2,
		(x1-mean(x1))*(x2-mean(x2)) as xc12,
        (x1-mean(x1))/0.4 as xn1,  (x2-mean(x2))/10  as xn2,
        ((x1-mean(x1))/0.4)**2 as xnsq1, ((x2-mean(x2))/10)**2 as xnsq2, 
        ((x1-mean(x1))/0.4)*((x2-mean(x2))/10) as xn12
  from charge;
quit;

/*相關係數*/
proc corr data = chargep;
var x1-x2 xsq1-xsq2 x12;
ods select PearsonCorr;
run;
proc corr data = chargep;
var xc1-xc2 xcsq1-xcsq2 xc12;
ods select PearsonCorr;
run;
proc corr data = chargep;
var xn1-xn2 xnsq1-xnsq2 xn12;
ods select PearsonCorr;
run;

/*有無置中化的比較*/
/*macro*/
proc reg data=chargep;
Origin: model y=x1-x2 xsq1-xsq2 x12 / lackfit p r;
Normalize: model y=xn1-xn2 xnsq1-xnsq2 xn12 / lackfit p r;
Centering: model y=xc1-xc2 xcsq1-xcsq2 xc12 / lackfit p r;
ods select anova;
run;
proc reg data=chargep;
Origin: model y=x1-x2 xsq1-xsq2 x12 / p r;
Normalize: model y=xn1-xn2 xnsq1-xnsq2 xn12 / p r;
Centering: model y=xc1-xc2 xcsq1-xcsq2 xc12 / p r;
ods select FitStatistics;
run;
proc reg data=chargep;
Origin: model y=x1-x2 xsq1-xsq2 x12 / ss1 p r;
Normalize: model y=xn1-xn2 xnsq1-xnsq2 xn12 / ss1 p r;
Centering: model y=xc1-xc2 xcsq1-xcsq2 xc12 / ss1 p r;
ods select ParameterEstimates;
run;
proc reg data=chargep;
Origin: model y=x1-x2 xsq1-xsq2 x12 / p r;
Normalize: model y=xn1-xn2 xnsq1-xnsq2 xn12 / p r;
Centering: model y=xc1-xc2 xcsq1-xcsq2 xc12 / p r;
ods select OutputStatistics;
run;

/*figure 8.5 殘差*/
proc reg data = chargep plots=(qq residualbypredicted residuals);
model y=xn1-xn2 xnsq1-xnsq2 xn12;
output out=chargeout p=yhat r=res;
ods select qqplot residualbypredicted residualplot;
run;
proc univariate data=chargeout normal;
var res;
ods select TestsForNormality;
run;
   
/*檢定當然相同*/
proc reg data=chargep;
Origin: model y=x1-x2 xsq1-xsq2 x12;
test xsq1=xsq2=x12=0;
ods select TestANOVA;
run;
proc reg data=chargep;
Normalize: model y=xn1-xn2 xnsq1-xnsq2 xn12;
test xnsq1=xnsq2=xn12=0;
ods select TestANOVA;
run;
   
/*一階模型*/
proc reg data=chargep;
Origin: model y=x1-x2 / clb;
Normalize: model y=xn1-xn2 / clb;
ods select ParameterEstimates;
run;

proc reg data=chargep noprint;
Origin: model y=x1-x2 / clb;
output out=temp p=yhat;
run;

proc g3d data = temp;
plot  x2*x1 =  yhat;
scatter x2*x1 = y;
run;

ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\ch08-01.pdf" startpage=no columns=2;
