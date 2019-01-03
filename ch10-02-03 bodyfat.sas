data bfat;
input x1 x2 x3 y;
label x1 = "三頭肌皮褶厚度" 
          x2 = "大腿圍"
	      x3 = "上臂圍"
          y = "人體脂肪量";
cards;
  19.5  43.1  29.1  11.9
  24.7  49.8  28.2  22.8
  30.7  51.9  37.0  18.7
  29.8  54.3  31.1  20.1
  19.1  42.2  30.9  12.9
  25.6  53.9  23.7  21.7
  31.4  58.5  27.6  27.1
  27.9  52.1  30.6  25.4
  22.1  49.9  23.2  21.3
  25.5  53.5  24.8  19.3
  31.1  56.6  30.0  25.4
  30.4  56.7  28.3  27.2
  18.7  46.5  23.0  11.7
  19.7  44.2  28.6  17.8
  14.6  42.7  21.3  12.8
  29.5  54.4  30.1  23.9
  27.7  55.3  25.7  22.6
  30.2  58.6  24.6  25.4
  22.7  48.2  27.1  14.8
  25.2  51.0  27.5  21.1
run;
data bfat;
set bfat;
n=_n_;
run;

proc reg data=bfat;
model y=x1 x2/partial pcorr1;
ods exclude nobs DiagnosticsPanel FitStatistics FitPlot;
run;

/*Hat Matrix*/
data tab1002;
input x1 x2 y;
cards;
14 25  301
19 32 327
12 22 246
11 15 187
run;
proc reg data=tab1002;
model y = x1-x2 /influence r;
output out=tabout p=yhat r=resi h=hii stdr=stdr;  
run; quit;
data tabout;
retain x1 x2 y yhat resi hii s2ei;
set tabout;
s2ei=stdr**2;
drop stdr;
run;
proc print data=tabout;
run;

/*Y 離群值之確認*/
/*Table 10.3*/
proc reg data = bfat;
model y = x1 x2/influence r;
ods select ANOVA OutputStatistics StudResCooksDChart ResidualStatistics;
ods output OutputStatistics=bfatrout;
run; quit;
proc print data=bfatrout (obs=5);
run;

/*ei(Residuals) & ti(Studentized Deleted Residuals)*/
goption reset=all;
axis1 label=none order=(-4.5 to 4.5 by 1) minor=none;
axis2 label=('觀測順序') offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt '#observation');
symbol2 i=none value=trianglefilled color=blue height=1.3;
proc gplot data=bfatrout;
plot (Residual RStudent)*observation / overlay 
	vaxis=axis1 haxis=axis2 
	vref=(3.252 -3.252) lvref=2 cvref=blue;
run;
/*t(1-alpha/2n;n-p-1)=3.252, where alpha=0.1*/


/*10.3 X 離群值之確認*/
data bfatrout1;
merge bfat bfatrout;
label x1="x1" x2="x2";
run;
proc print data=bfatrout1 (obs=10);
run;
proc means data=bfatrout1;
var x1-x2;
run;


title1 "Leverage Value";
axis1 offset=(1cm) minor=none;
axis2 offset=(1cm) minor=none;
symbol1 i=none value=dot color=red height=1.3 
        pointlabel=(height=10pt '#HatDiagonal');
proc gplot data=bfatrout1;
plot x2*x1 / vaxis=axis1 haxis=axis2 
	href=25.30 vref=51.17;
run;
/*x1bar=25.30 x2bar=51.17 */

goption reset=all;
axis1 offset=(1cm) minor=none;
axis2 offset=(1cm) minor=none;
symbol1 i=none value=dot color=darkblue height=1.3 
        pointlabel=(height=10pt '#observation');
proc gplot data=bfatrout1;
plot HatDiagonal*observation / vaxis=axis1 haxis=axis2 
   vref=(0.3 0.5 0.2) cvref=('red' 'green' 'green')
   lvref=(1 2 2);
/*0.3 是由2p/n=2x3/20, 比它大就可被視為離群值*/
/*0.5 比它大，Leverage過大*/
/*0.2-0.5 ，Leverage中度大*/
run;
proc print data = bfatrout1;
var x1 x2 y HatDiagonal;
where HatDiagonal> (0.3);
run;


