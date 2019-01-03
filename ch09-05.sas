options papersize=(11.7in 8.3in);
ods pdf file="d:\ch09-05 output.pdf" startpage=yes columns=1;

filename myurl url
"http://www.stat.usu.edu/jrstevens/stat5100/data/surgical.txt";
data surg;
infile myurl delimiter = '09'x;
/* '09'x indicates tab-delimited .txt file */
input x1-x8 y;
label x1 = "血液凝結分數"
        x2 = "前兆指數"
		x3 = "酵素功能指數"
		x4 = "肝功能指數"
		x5 = "年紀"
		x6=  "性別"
		x7=  "普通飲酒"
		x8=  "嚴重飲酒"
		 y =  "存活時間";
run;

data surg;
set surg;
lny= log(y);
run;

/*data surg;*/
/*set surg;*/
/*ru = uniform(1234);*/
/*id = _n_;*/
/*run;*/
/*proc sort data=surg;*/
/*by ru;*/
/*run;*/

data train; 
set surg;
if _n_ <= 54;
data test; 
set surg;
if _n_ > 54;
run;

/*這裏的模型要自行輸入*/
proc reg data=train outseb press outest=trainest noprint;
MODEL1: model lny=x1-x3 x8 / sse mse rsquare adjrsq;
MODEL2: model lny=x1-x3 x5 x8 / sse mse rsquare adjrsq;
MODEL3: model lny=x1-x3 x5 x6 x8 / sse mse rsquare adjrsq;
run; quit;
proc print data=trainest;
run;

/*這裏的模型要自行輸入*/
/*利用selection把Cp撈出來*/
%let modelvec="x1 x2 x3 x8", "x1 x2 x3 x5 x8", "x1 x2 x3 x5 x6 x8";
proc reg data=train;
model lny=x1-x8 / selection=cp cp mse;
ods output SubsetSelSummary=traincp;
run; quit;
data traincp1;
set traincp;
if varsinmodel in (&modelvec);
run;
proc sort data=traincp1;
by decending varsinmodel;
run;
proc print data=traincp1;
run;

/*整理Cp表格，用_model_ merge*/
data traincp2;
input _model_ $ @@;
cards;
MODEL1  MODEL2  MODEL3
;
run;
data traincp (keep=cp rsquare varsinmodel mse _model_);
merge traincp1 traincp2;
run;
proc sort data=traincp;
by _MODEL_;
run;
proc print data=traincp;
run;

data trainest;
merge trainest traincp;
by _model_;
run;
proc print data=trainest;
run;

/*自行輸入預測函數*/
data test;
set test;
yhat1=3.85273+0.07333*x1+0.01419*x2+0.01545*x3+0.35315*x8;
yhat2=4.03855+0.073611*x1+0.014057*x2+0.015448*x3+0.34139*x8 -.003431875*x5; 
yhat3=4.05439+0.071524*x1+0.013760*x2+0.015109*x3+0.35107*x8 -.003452317*x5+0.087227*x6; 
model1=(lny-yhat1)**2;
model2=(lny-yhat2)**2;
model3=(lny-yhat3)**2;
run;
proc means data=test;
var model1-model3;
output out=mspr mean=MODEL1-MODEL3;
run;

/*MSPR call出來，好跟trainest merge*/
data mspr (keep=model1-model3);
set mspr;
run;
proc transpose data=mspr out=mspr name=_MODEL_;
var model1-model3;
run;

data trainest;
merge trainest mspr;
by _model_;
run;
proc print data=trainest;
run;

/*拿測試資料建模*/
proc reg data=test outseb press outest=testest noprint;
MODEL1c: model lny=x1-x3 x8 / sse mse rsquare adjrsq;
MODEL2c: model lny=x1-x3 x5 x8 / sse mse rsquare adjrsq;
MODEL3c: model lny=x1-x3 x5 x6 x8 / sse mse rsquare adjrsq;
run; quit;
proc print data=testest;
run;

proc reg data=test;
model lny=x1-x8 / selection=cp cp mse;
ods output SubsetSelSummary=testcp;
run; quit;
data testcp1;
set testcp;
if varsinmodel in (&modelvec);
run;
proc sort data=testcp1;
by decending varsinmodel;
run;
proc print data=testcp1;
run;


data testcp2;
input _model_ $ @@;
cards;
MODEL1c  MODEL2c  MODEL3c
;
run;
data testcp (keep=cp rsquare varsinmodel mse _model_);
merge testcp1 testcp2;
run;
proc print data=testcp;
run;

data testest;
merge testest testcp;
by _model_;
run;
proc print data=testest;
run;

/*最後整合資料，這裏的變數也需自行輸入*/
%let xvec=intercept x1 x2 x3 x5 x6 x8;
data combo1 (keep=_model_ _type_ _press_ &xvec _sse_ _mse_ _rsq_ _adjrsq_ cp varsinmodel col1);
set trainest testest;
run;
proc sort data=combo1;
by _model_;
run;

data combo;
retain _model_ _type_ &xvec _sse_ _press_ _mse_  cp col1 _adjrsq_ _rsq_ varsinmodel;
set combo1;
rename _model_=MODEL _type_=TYPE 
	_sse_=SSE _press_=PRESS _mse_=MSE  cp=Cp col1=MSPR 
    _adjrsq_=adjRsq _rsq_=Rsq;
run;
proc print data=combo;
run;

ods pdf close;
