data table42;
input x y;
cards;
   20  114
  196  921
  115  560
   50  245
  122  575
  100  475
   33  138
  154  727
   80  375
  147  670
  182  828
  160  762
run;
proc reg data=table42;
model y=x/noint clb;
run;
