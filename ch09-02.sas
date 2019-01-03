data surg;
infile "F:\Dropbox\51 regression\dataset\CH09TA01.txt" dlm= '09'x;
input x1-x8 y;
label x1 = "��G��������"
        x2 = "�e������"
		x3 = "�ï��\�����"
		x4 = "�x�\�����"
		x5 = "�~��"
		x6=  "�ʧO"
		x7=  "���q���s"
		x8=  "�Y�����s"
		 y =  "�s���ɶ�";
run;

/*�P�_�����ܼƪ��d��A�o�{�i�঳outlier*/
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

/*�դ@���ҫ�*/
proc reg data=surg;
model y=x1-x4;
output out=surg4o r=res p=pred;
run;
proc univariate data=surg4o normal;
var res;
ods select TestsForNormality;
run;

/*�լݬ��ഫ*/
proc transreg data=surg;
model boxcox(y / lambda = -5 to 5 by .5)
   = identity(x1-x4);
run;
/*��y�@log�ഫ*/
data surg;
set surg;
lny= log(y);
run;
/*�A�ݬ�����*/
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


