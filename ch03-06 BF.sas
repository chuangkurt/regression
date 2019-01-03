proc import datafile="K:\Dropbox\51 regression\dataset\toluca.csv"
     out=toluca dbms=csv replace;
     getnames=yes;
label x='Lot Size' y='Work Hours';
run;
proc print;run;

proc reg data=toluca noprint;
  model y=x;
  output out=tolout r=res;
run;
proc print data=tolout;
run;

/*���[��n�q���ӭȤ�*/
proc freq data=tolout;
  tables x;
run;

/*���s*/
data tolout1;
  set tolout;
  id=_n_;
  group=.;
  if x<=70 then group=1;
  if x>70 then group=2;
run;
proc sort data=tolout1;
  by x group;
run;
proc print data=tolout1;
run;

/*��U�s�ӼơB�ݮt�����*/
proc means data = tolout1 noprint;
  by group;
  var res;
  output out= tolmout median=med;
run;
proc print data = tolmout label;
run;

/*�N����ƲV�i�h�A�A��Xd*/
data tolout2;
  merge tolout1 tolmout;
  by group;
  d = abs(res - med);
run;
proc print data=tolout2;
run;

/*�˩w�A���]�ܲ��۵�*/
proc ttest data=tolout2;
  class group;
  var d;
run;


/*��@Table 3.3*/
/*��d���˥�����*/
proc means data = tolout2 noprint;
  by group;
  var d;
  output out=tol2mout mean=md;
run;
proc print data = tol2mout;
  var group md;
run;

/*�U�۪�d�P�Ӳռ˥��������Z������*/
data tolout3;
  merge tolout2 tol2mout;
  by group;
  diffs = (d - md)**2;
run;

/*table 3.3*/
proc print data = tolout3; 
 by group;
 var id x y res d diffs;
run;
