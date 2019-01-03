
data bank;
input x y;
if x=75 then level=1;
else if x=100 then level=2;
else if x=125 then level=3;
else if x=150 then level=4;
else if x=175 then level=5;
else if x=200 then level=6;
label x="最低存款金額" y="新開戶數";
cards;
125	160
100	112
200	124
75	28
150	152
175	156
75	42
175	124
125	150
200	104
100	136
run;
proc reg data=bank;
  model y=x / lackfit  clb;
run;
proc anova data=bank;
  class level;
  model y=level;
run;
