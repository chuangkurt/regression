%let indir=F:\Dropbox\51 regression\dataset;

proc import datafile="&indir\toluca.csv" out=toluca dbms=csv replace;
  getnames=yes;
  label x="Lot Size" y="Work Hours";
run;

proc reg data=toluca outest=tolest noprint;
  model y=x/ mse; 
  output out=tolout p=yhat r=res stdp=stdi ;
run;
quit;

data tolest1;
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

data tolout1;
  set tolout;
  expec=&rmse*quantile("normal",(n-0.375)/(&tn+0.25));
run;

proc corr data=tolout1 pearson spearman plots=matrix(histogram);
  var res expec;
run;
