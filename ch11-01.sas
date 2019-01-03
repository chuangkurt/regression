data dbp;
input x y;
label x="¦~¬ö" y="µÎ±iÀ£";
cards;
  27   73
  21   66
  22   63
  24   75
  25   71
  23   70
  20   65
  20   70
  29   79
  24   72
  25   68
  28   67
  26   79
  38   91
  32   76
  33   69
  31   66
  34   73
  37   78
  38   87
  33   76
  35   79
  30   73
  31   80
  37   68
  39   75
  46   89
  49  101
  40   70
  42   72
  43   80
  46   83
  43   75
  44   71
  46   80
  47   96
  45   92
  49   80
  48   70
  40   90
  42   85
  55   76
  54   71
  57   99
  52   86
  53   79
  56   92
  52   85
  50   71
  59   90
  50   91
  52  100
  58   80
  57  109
run;

/*Fig 11.1 (a)(b)*/
proc reg data=dbp;
model y = x;
output out=dbpout r=resi;
plot y*x r.*x;
run;
quit;

data dbpout;
set dbpout;
absr = abs(resi);
run;

/*Fig 11.1 (c)*/
proc reg data=dbpout;
model absr=x;
output out=stdout p=stdp;
plot absr*x/ vaxis = (0 to 20 by 5);
run;

data stdout;
set stdout;
wt = 1/(stdp**2);
run;

proc print data=stdout (obs=10);
run;

proc reg data = stdout;
  weight wt;
  model y = x / clb;
run;
quit;
