options papersize=(11.7in 8.3in);
ods pdf file="d:\ch09-03 output.pdf" startpage=no columns=2;

data surg;
infile "F:\Dropbox\51 regression\dataset\CH09TA01.txt" dlm= '09'x;
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

proc reg data=surg;
  model lny = x1-x4/selection=rsquare adjrsq cp mse sse aic sbc;
  ods output SubsetSelSummary=tempout;
  ods select SubsetSelSummary;
run; quit;
/*proc print data=tempout;*/
/*run;*/

/*當有用selection時，press是不管用的。*/
/*所以才需每個模型都跑一遍，再與tempout作連結*/
proc reg data = surg outest = tempest noprint;
  model lny = x1/press mse;
  model lny = x2/press mse;
  model lny = x3/press mse;
  model lny = x4/press mse;
  model lny = x1 x2/press mse;
  model lny = x1 x3/press mse;
  model lny = x1 x4/press mse;
  model lny = x2 x3/press mse;
  model lny = x2 x4/press mse;
  model lny = x3 x4/press mse;
  model lny = x1 x2 x3/press mse;
  model lny = x1 x2 x4/press mse;
  model lny = x1 x3 x4/press mse;
  model lny = x2 x3 x4/press mse;
  model lny = x1 x2 x3 x4/press mse;
run;quit;
/*proc print data=tempest;*/
/*run;*/

data tempout;
  set tempout;
  mse1=input(mse, 6.);
run;
data tempest;
  set tempest;
  mse1=input(_mse_, 6.);
run;

proc sql;
  create table submodels
  as select *
  from tempout, tempest
  where tempout.mse1 = tempest.mse1;
  quit;
run;

data submodels;
set submodels;
rename _p_=p _edf_=df _press_=press;
run;
proc print data=submodels;
 var varsinmodel p df sse mse rsquare adjrsq cp aic sbc press;
run;

/*R-square*/
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "R-square") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot rsquare*p/ haxis=axis1 vaxis=axis2;
run;

/*Adj R-square*/
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "Adj R-square") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot adjrsq*p/ haxis=axis1 vaxis=axis2;
run;

/* Cp Criterion */
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "Cp") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot cp*p/ haxis=axis1 vaxis=axis2 vref=(4 5) cvref=("blue" "red");
run;

/* AIC Criterion */
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "AICp") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot aic*p/ haxis=axis1 vaxis=axis2;
run;

/* SBC Criterion */
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "SBCp") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot sbc*p/ haxis=axis1 vaxis=axis2;
run;

/* Press Criterion */
axis1 label=none offset=(5,5) minor=none;
axis2 label=(a=90 "Press") offset=(2,2) minor=none;
symbol1 value=dot;
proc gplot data=submodels;
plot press*p/ haxis=axis1 vaxis=axis2;
run;

proc reg data=surg noprint;
model lny=x1-x4/selection=cp sse rsquare adjrsq cp aic sbc;
plot cp.*np. /  cmallows=blue vaxis=0 to 15 by 5;
plot rsq.*np. / vaxis=0 to 1 by 0.2;
plot adjrsq.*np. / vaxis=0 to 1 by 0.2;
plot aic.*np. / vaxis=-180 to -50 by 20;
plot sbc.*np. / vaxis=-160 to -50 by 20;
run;
quit;
ods pdf close;
