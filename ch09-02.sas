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

/*判斷解釋變數的範圍，發現可能有outlier*/
proc univariate data=surg noprint;
histogram x1-x5;
run;

data surg;
set surg;
n=1;
run;
proc boxplot data=surg;
plot (x1-x5)*n;
run;

proc corr data=surg plot=matrix;
var y x1-x5;
run;

proc freq data=surg;
tables x6-x8;
run;

proc corr data=surg plot=matrix;
var y x6-x8;
run;

/*試一階模型*/
proc reg data=surg;
model y=x1-x4;
output out=surg4o r=res p=pred;
run;
proc univariate data=surg4o normal;
var res;
ods select TestsForNormality;
run;

/*試看看轉換*/
proc transreg data=surg;
model boxcox(y / lambda = -5 to 5 by .5)
   = identity(x1-x4);
run;
/*對y作log轉換*/
data surg;
set surg;
lny= log(y);
run;
/*再看相關性*/
proc corr data=surg plot=matrix;
var lny x1-x4;
run;
proc reg data=surg;
model lny=x1-x4;
output out=surgln4o r=res p=pred;
plot r.*nqq.;
b4: test x4=0;
run;
proc univariate data=surgln4o normal;
var res;
ods select TestsForNormality;
run;


ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\ch09-02 output.pdf" startpage=no columns=2;


