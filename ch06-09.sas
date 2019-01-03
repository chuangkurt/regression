/*兒童影像工作室在21個中型都市、想拓展業務*/
data portrait;
input y x1 x2;
label y="一個社區的銷售" x1="16歲以下人口數" x2="人均支配所得";
cards;
174.40	68.50	16.70
164.40	45.20	16.80
244.20	91.30	18.20
154.60	47.80	16.30
181.60	46.90	17.30
207.50	66.10	18.20
152.80	49.50	15.90
163.20	52.00	17.20
145.40	48.90	16.60
137.20	38.40	16.00
241.90	87.90	18.30
191.10	72.80	17.10
232.00	88.40	17.40
145.30	42.90	15.80
161.10	52.50	17.80
209.70	85.70	18.40
146.40	41.30	16.50
144.00	51.70	16.30
232.60	89.60	18.10
224.10	82.70	19.10
166.50	52.30	16.00
run;

proc corr data=portrait plot=matrix nocorr;
var y x1 x2;
run;

proc reg data=portrait;
model y=x1 x2/p clm xpx covb clb;
output out=portout r=res p=pre;
run;

data portout;
set portout;
x1x2=x1*x2;
absres=abs(res);
label x1x2="交互作用項";
run;

/*fig 6.8, fig 6.9(a)*/
goption reset=all;
axis1 label=("殘差");
axis2 label=("|殘差|");
axis3 label=("預測值");
symbol1 v=dot  c=blue  h=0.8;
proc gplot data=portout;
plot res*(x1x2) / vref=0 lvref=2 vaxis=axis1; 
plot absres*pre / vaxis=axis2 haxis=axis3; 
run;
/*從殘差分析看來，似乎還可以*/

/*fig 6.9(b)*/
proc univariate data=portout normal;
var res;
qqplot res / normal; 
ods select TestsForNormality QQplot;
run;

/*預測*/
data extra;
input y x1 x2;
cards;
.           65.40    17.60
.           53.10    17.70
run;

data portrait_new;
set portrait extra;
obs=_n_;
if y ne . then col=1;
else col=2;
run;

proc reg data=portrait_new noprint;
model y=x1 x2/cli clm;
/*ods output OutputStatistics=temp2;*/
output out= temp 
    r=res p=yhat uclm=mub lclm=mlb stdp=msd
	ucl=pub lcl=plb stdi=psd;
run;

proc print data = temp label noobs;
where obs >= 22;
var x1 x2 mlb mub plb pub;
run;

symbol1 v=dot c=blue h=0.8;
symbol2 v=dot c=red h=0.8;
proc gplot data=portrait_new;
plot x1*x2=col; 
run;
ods pdf close;
ods pdf file="d:\ch06-09 outpdf.pdf" startpage=no;

