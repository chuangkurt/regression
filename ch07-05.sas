/*兒童影像工作室在21個中型都市、想拓展業務*/
data portrait;
input y x1 x2;
label y="一個社區的銷售" x1="16歲以下人口數" x2="人均支配所得";
cards;
174.40	68.50	16.70
164.40	45.20	16.80
244.20	91.30	18.20
154.60	47.80	16.30
181.60	46.90	17.30
207.50	66.10	18.20
152.80	49.50	15.90
163.20	52.00	17.20
145.40	48.90	16.60
137.20	38.40	16.00
241.90	87.90	18.30
191.10	72.80	17.10
232.00	88.40	17.40
145.30	42.90	15.80
161.10	52.50	17.80
209.70	85.70	18.40
146.40	41.30	16.50
144.00	51.70	16.30
232.60	89.60	18.10
224.10	82.70	19.10
166.50	52.30	16.00
run;

proc sql; 
create table portrait_s as
  select *, ( y - mean(y) )/( std(y)*( sqrt( count(y)-1 ) ) ) as ys,
            ( x1 - mean(x1) )/( std(x1)*( sqrt( count(x1)-1 ) ) ) as xs1,
            ( x2 - mean(x2) )/( std(x2)*( sqrt( count(x2)-1 ) ) ) as xs2
  from portrait;
quit;

proc print data = portrait_s;
run;
proc means data = portrait_s mean std ;
run;

proc reg data = portrait_s plots=none;
origin: model y = x1 x2 / stb;
stdize: model ys=xs1 xs2;
run;
ods pdf close;
ods pdf file="d:\ch07-05.pdf" startpage=no;
