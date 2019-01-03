proc reg data=surg;
model lny=x1 ;
model lny=x2 ;
model lny=x3 ;
model lny=x4 ;
model lny=x5 ;
model lny=x6 ;
model lny=x7 ;
model lny=x8 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x3 x1/ss2 ;
model lny=x3 x2/ss2 ;
model lny=x3 x4/ss2 ;
model lny=x3 x5/ss2 ;
model lny=x3 x6/ss2 ;
model lny=x3 x7/ss2 ;
model lny=x3 x8/ss2 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x2 x3 x1;
model lny=x2 x3 x4 ;
model lny=x2 x3 x5 ;
model lny=x2 x3 x6 ;
model lny=x2 x3 x7 ;
model lny=x2 x3 x8 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x2 x3 x8 x1 ;
model lny=x2 x3 x8 x4 ;
model lny=x2 x3 x8 x5 ;
model lny=x2 x3 x8 x6 ;
model lny=x2 x3 x8 x7 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x1 x2 x3 x8 x4 ;
model lny=x1 x2 x3 x8 x5 ;
model lny=x1 x2 x3 x8 x6 ;
model lny=x1 x2 x3 x8 x7 ;
ods select ParameterEstimates;
run;


/*Backward*/
proc reg data=surg;
model lny=x1-x8 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x1-x3 x5-x8 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x1-x3 x5-x6 x8 ;
ods select ParameterEstimates;
run;

proc reg data=surg;
model lny=x1-x3 x6 x8 ;
ods select ParameterEstimates;
run;
