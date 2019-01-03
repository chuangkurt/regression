/*鐪238 be located and removed*/
/*鐪 emits(發射) alpha particles that can be detected.*/
/*record the intensity of alpha particle strikes in counts per second (#/sec)*/
data ch3tab10;
input y x ; 
label x = "Plutonium Activity, pCi/g"
		y ="Alpha Count, #/sec.";
cards;
  0.150  20
  0.004   0
  0.069  10
  0.030   5
  0.011   0
  0.004   0
  0.041   5
  0.109  20
  0.068  10
  0.009   0
  0.009   0
  0.048  10
  0.006   0
  0.083  20
  0.037   5
  0.039   5
  0.132  20
  0.004   0
  0.006   0
  0.059  10
  0.051  10
  0.002   0
  0.049   5
  0.106   0
;
run;

/*Step 1. 觀察迴歸性*/
/*fig 3.20(a)*/
goptions reset=all;
symbol1 v=dot h=.8 c=blue;
axis1 order=(-10 to 30 by 10);
proc gplot data=ch3tab10;
plot y*x/ haxis=axis1;
run;
quit;

/*fig 3.20(b)*/
ods listing close;
proc loess data = ch3tab10 ;
  model y = x / degree=2  smooth = 0.85;
  ods output OutputStatistics=loessout;
run;
ods listing;

proc sort data = loessout;
by x;
run;
proc print data=loessout; 
run;

goptions reset=all;
axis1 order=(-10 to 30 by 10);
axis2 order=(0 to .15 by .03);
symbol1 v=none c=blue i=join;
symbol2 v=dot c=red i=none; 
proc gplot data=loessout; 
plot  DepVar*x=2 pred*x=1/overlay haxis=axis1 vaxis=axis2;
run;
quit;

/*有異常點，確定該資料的控制環境有問題，決定剔除*/

/*fig 3.21*/
goption reset=all;
symbol1 v=dot h=.8 c=blue;
proc reg data = ch3tab10 outest=tolest;
  where y ne .106;
  model y = x/lackfit sse;
  output out=tolout p=yhat r=res stdp=sti;
  plot r.*p. r.*nqq.;
run;
quit;

/*檢定：斜率存在*/
/*殘差圖：喇叭狀*/
/*QQ圖：厚尾*/


/*用Breusch-Pagan test 常數變異數*/
data tolest;
  set tolest;
  call symput("sse",_sse_);
run;
/*殘差平方*/
data tol_logr2;
  set tolout;
  *logr2=log(res**2);
  logr2=res**2;
run;
proc reg data=tol_logr2 outest=tol_logr2est;
  model logr2=x;
  ods output ANOVA=anova NObs=nobs;
run;
quit;
data ssr;
  set anova;
  if source="模型" then call symput("ssrs",ss);
run;
data nobs;
  set nobs (obs=1 firstobs=1);
  call symput("nobs",n);
run;
quit;
data B_P_test;
 ssrs=&ssrs;
 sse=&sse;
 nobs=&nobs;
 tests=(ssrs/2)/((sse/nobs)**2);
 pv=cdf("chisquare",tests,1);
run;
proc print data=B_P_test;
run;

/*顯示要矯正非常數誤差變異、Chap11有加權最小平方法*/
/*用Box-Cox來找到適到的轉換*/
proc transreg data=ch3tab10 test;
  where y ne .106;
  model BoxCox(y) = identity(x);
run;

data ch3tab10a;
 set ch3tab10 (rename=(y=oldy));
 y= sqrt(oldy);
 if oldy ne .106;
run;

/*再作一次*/
goption reset=all;
symbol1 v=dot h=.8 c=blue;
proc reg data = ch3tab10a outest=tolest;
  where y ne .106;
  model y = x/lackfit sse;
  output out=tolout p=yhat r=res stdp=sti;
  plot r.*p. r.*nqq.;
run;
quit;
/*殘差圖的變異較穩定*/
/*常態機率圖也近直線*/

/*但迴歸不怎麼直線，故對X轉換*/
data ch3tab10b;
 set ch3tab10a (rename=(x=oldx));
 x= sqrt(oldx);
run;
/*再作一次*/
goption reset=all;
symbol1 v=dot h=.8 c=blue;
proc reg data = ch3tab10b outest=tolest;
  where y ne .106;
  model y = x/lackfit sse mse;
  output out=tolout p=yhat r=res stdp=sti;
  plot r.*p. r.*nqq.;
run;
quit;
/*殘差相關性檢定*/
data tolest;
  set tolest;
  call symput("rmse",_rmse_);
run;
proc sort data=tolout;
  by res;
run;
data tolout;
  set tolout end=eof;
  n=_n_;
  if eof then do;
    call symput("tn",_n_);
  end;
run;
data tolout;
  set tolout;
  expec=&rmse*quantile("normal",(n-0.375)/(&tn+0.25));
run;
proc corr data=tolout pearson spearman plots=matrix(histogram);
  var res expec;
run;
/*用Breusch-Pagan test 常數變異數*/
data tolest;
  set tolest;
  call symput("sse",_sse_);
run;
/*殘差平方*/
data tol_logr2;
  set tolout;
  *logr2=log(res**2);
  logr2=res**2;
run;
proc reg data=tol_logr2 outest=tol_logr2est;
  model logr2=x;
  ods output ANOVA=anova NObs=nobs;
run;
quit;
data ssr;
  set anova;
  if source="模型" then call symput("ssrs",ss);
run;
data nobs;
  set nobs (obs=1 firstobs=1);
  call symput("nobs",n);
run;
quit;
data B_P_test;
 ssrs=&ssrs;
 sse=&sse;
 nobs=&nobs;
 tests=(ssrs/2)/((sse/nobs)**2);
 pv=cdf("chisquare",tests,1);
run;
proc print data=B_P_test;
run;
/*非常數變異的問題不嚴重*/
/*完成不錯的迴歸*/
ods listing close;
proc loess data = ch3tab10b;
  model y = x / degree=2  smooth = 0.85;
  ods output OutputStatistics=loessout;
run;
ods listing;
proc sort data = loessout;
 by x;
run;
data loessout (rename = ( Depvar=y pred=loess) );
  set loessout;
run;
proc reg data = loessout noprint;
model y = x;
output out=temp lclm=mlb uclm=mub;
run;
quit;
proc print data=temp;
run;
 
goptions reset=all;
symbol1 v=dot i=none c=blue h=.8;
symbol2 v=none i=join c=red line=1;
symbol3 v=none h=.4 i=join c=black line=1;
symbol4 v=none i=join c=red line=1;
axis1 label=(angle=90 "Sqrt(Y)") order=(0 to .4 by .1);
axis2 order=(-1 to 5 by 1);
proc gplot data = temp;
  plot (y mlb loess mub)*x/ overlay vaxis=axis1 haxis=axis2 ;
  format sqrtx 2. sqrty 3.1;
run;
quit;

