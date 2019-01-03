options papersize=(11.7in 8.3in);
ods pdf file="d:\ch09-04 output.pdf" startpage=no columns=2;

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
  model lny = x1-x8/selection=rsquare adjrsq cp mse sse aic sbc;
  ods output SubsetSelSummary=tempout;
run; quit;

data ds_cp;
set tempout end=eof;
mse1=input(mse, 8.);
if eof then do;
call symput("tn",_n_);
end;
run;
/*proc print data=ds_cp;*/
/*run;*/

%macro create(n);
data ds_press;
array v mse1 press;
run;

/*%let i=2;*/
%do i=1 %to &n;
data temp1;
set tempout (firstobs=&i obs=&i keep=varsinmodel);
call symput("explan",varsinmodel);
run; quit;

proc reg data=surg outest = temp2 noprint;
model lny=&explan /mse press;
run; quit;

data temp3 (keep=mse1 press);
set temp2;
mse1=input(_mse_, 8.);
rename _press_=press;
run;quit;

data ds_press;
set ds_press temp3;
run;
%end;
data ds_press;
set ds_press;
if mse1 ne .;
run;
%mend create;
%create(&tn)

proc sql;
  create table presscp
  as select *
  from ds_press, ds_cp
  where ds_press.mse1 = ds_cp.mse1;
  quit;
run;
data modelcri;
retain modelindex p sse mse rsquare 
	adjrsq cp aic sbc press varsinmodel ;
set presscp;
drop mse1 control model dependent;
p=numinmodel+1;
run; 
proc sort data=modelcri;
by numinmodel varsinmodel;
run;

proc print data=modelcri;
run;


proc reg data=surg noprint;
model lny=x1-x8/selection=cp sse mse rsquare adjrsq cp aic sbc press;
plot rsq.*np. / haxis=1 to 10 by 1;
plot adjrsq.*np. / haxis=1 to 10 by 1;
plot cp.*np. / cmallows=blue haxis=1 to 10 by 1;
plot aic.*np. / haxis=1 to 10 by 1;
plot sbc.*np. / haxis=1 to 10 by 1;
run;

/* Press Criterion */
axis1 label=(a=90 "PRESSp") offset=(2,2) minor=none;
axis2 label=none order=1 to 10 by 1 minor=none;
symbol1 value=dot;
proc gplot data=modelcri;
plot press*p/ haxis=axis2 vaxis=axis1;
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
by press;
run;
data modelcri1;
set modelcri1;
pressrank=_n_;
run;
proc sort data=modelcri1;
by decending adjrsq;
run;
data modelcri1;
set modelcri1;
adjrsqrank=_n_;
run;
data modelcri1;
set modelcri1;
diffcp=abs(cp-p);
run;
proc sort data=modelcri1;
by diffcp;
run;
data modelcri1;
set modelcri1;
cprank=_n_;
run;
/*各自挑前5名出來*/
proc print data=modelcri1;
where aicrank<5 | sbcrank<5 | pressrank <5;
run;

/*從t值直接去刪除，也可得到SBC的結果？*/
proc reg data=surg;
model lny=x1-x8;
run;


proc reg data=surg;
model lny=x1-x8/selection=stepwise slentry=0.1 slstay=0.15;
run;

proc reg data=surg;
model lny=x1-x8/selection=forward slentry=0.1;
run;

proc reg data=surg;
model lny=x1-x8/selection=backward slstay=0.15;
run;
ods pdf close;





