%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x="Lot Size" y="Work Hours";
run;


/*Figure 3.1 (a), (c), (d)*/
proc univariate data = toluca plots;
  var x;
run;

/*Figure 3.1 (b), time series plot*/
data toluca1;
  set toluca;
  id = _n_;
  group=1;
run;
/*goptions reset = all;*/
symbol1 v=dot h=.8 i=join;
proc gplot data = toluca1;
  plot x*id;
run;


/*Fig 3.2(a), 3.2(d)*/
symbol1 v=dot h=.8 c=blue;
proc reg data = toluca1 noprint;
  model y = x;
  output out=tolout r=res;
  plot r.*x r.*nqq.;
run;
/*Fig 3.2(b)*/
symbol1 v=dot h=.8 i=join;
proc gplot data = tolout;
  plot res*id;
run;
quit;



/*Fig 3.2(c)*/
/*symbol1 v=dot h=.8 c=blue i=join;*/
proc boxplot data=tolout;
  plot res*group;
run;

/*Fig 3.3*/
data ch3tab01;
input y x;
label y = "人次增加量" x = "路線圖發送數";
cards;
   .60   80
  6.70  220
  5.30  140
  4.00  120
  6.55  180
  2.15  100
  6.60  200
  5.75  160
;
run;
proc reg data = ch3tab01 noprint;
  model y = x;
  plot y*x r.*x r.*nqq.;
  output out=ch3out r=res p=yhat;
run;
quit;

/*Table 3.1*/
proc print data = ch3out label;
  var y x yhat residual;
run;

