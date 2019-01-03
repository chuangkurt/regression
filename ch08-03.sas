data stockfirm;
input y x1 x2;
label y = "已過的月數" x1 = "公司規模"
        x2 = "公司型態";
cards;
  17  151  0
  26   92  0
  21  175  0
  30   31  0
  22  104  0
   0  277  0
  12  210  0
  19  120  0
   4  290  0
  16  238  0
  28  164  1
  15  272  1
  11  295  1
  38   68  1
  31   85  1
  21  224  1
  20  166  1
  13  305  1
  30  124  1
  14  246  1
;
run;

proc reg data = stockfirm;
model y = x1 x2/ clb;
run;

data stockfirm;
set stockfirm;
if x2 = 0 then do;
  z1 = x1;
  y1 = y;
end;
if x2= 1 then do;
  z2 = x1 ;
  y2 = y;
end;
run;
proc print data=stockfirm (obs=10);
run;

proc reg data = stockfirm noprint;
model y = z1 ;
output out = sfout_z1 p = pz1;
run;
proc print data=sfout_z1 (obs=10);
run;
proc reg data = sfout_z1 noprint;
model y = z2;
output out=sfout_z2 p= pz2;
run;
proc print data=sfout_z2 (firstobs=10 obs=20);
run;

goption reset=all;
symbol1 v=circle c=red ;
symbol2 v=dot    c=blue ;
symbol3 v=none i=join c=red;
symbol4 v=none i=join c=blue;
axis1 label=("Size of Firm") order=(0 to 350 by 50) minor=none;
axis2 label=(angle = 90 "Months Elapsed") minor=none;
legend1 label=none value=( "合作社" "股份公司" "合作社迴歸線" "股份公司迴歸線");
proc gplot data = sfout_z2;
plot y1*z1 y2*z2 pz1*z1 pz2*z2 / overlay haxis = axis1 vaxis=axis2 legend=legend1;
run;
quit;

ods pdf close;
options papersize=(11.7in 8.3in);
ods pdf file="d:\ch08-03 output.pdf" startpage=no columns=2;
