filename rate 'xxxx/Heart_rate.txt';  /*Use appropriate file path here*/

data rate;
  infile rate;
  input Heart_rate RPM Incline_level Weights Age;
  id = _n_;
  label id = 'Observation Number';
  
  Proc print;
  
/*Scatter plot for preliminary model*/
proc sgscatter data=rate;
  title "Scatterplot Matrix for Heart Rate Data";
  matrix Heart_rate RPM Incline_level Weights Age;
 run;
goptions reset = all;

proc corr data=rate noprob;
  var Heart_rate RPM Incline_level Weights Age;
  
proc means data=rate;
var Heart_rate RPM Incline_level Weights Age;
  
/*Preliminary model*/
proc reg  data=rate;
  model Heart_rate = RPM Incline_level Weights Age / ss1 vif  i influence;
  output out=rateout predicted=yhat residual=e student=tres h=hii cookd=cookdi dffits=dffitsi;
Proc print;

/* creating normal scores for residuals */
proc rank normal=blom out=enrm data=rateout;
  var e;
  ranks enrm;
run;

data ratenew; set rateout; set enrm;
  label enrm = 'Normal Scores';
  label e = 'e(Y | x1,x2,x3,x4)';
  label yhat = 'Predicted Heart_rate';

proc corr data=ratenew noprob;
  var e enrm;
run;
 
/* Residual plots for preliminary model */
goptions reset = all;
symbol1 v=dot i=join c=black;
axis1 label=(angle = 90);
axis2 order=(0 to 35 by 5);
proc gplot data = ratenew;
  plot e*id / vaxis = axis1 haxis=axis2;
run;

goptions reset = all;
symbol1 v=dot c=black;
axis1 label=(angle = 90);
proc gplot data = ratenew;
  plot e*yhat /vref = 0 vaxis = axis1;
  plot e*enrm / vaxis = axis1;
  plot e*RPM /vref = 0 vaxis = axis1;
  plot e*Incline_level /vref = 0 vaxis = axis1;
  plot e*Weights /vref = 0 vaxis = axis1;
  plot e*Age /vref = 0 vaxis = axis1;
run;

/*Cutoff values to identify y-outliers and Influence of the outliers alfa = 0.1*/

data cutoffs;
   tinvtres_Preliminary = tinv(.9985714286,29);
   finv50_Preliminary = finv(.50,5,30); output;
proc print;

/* Breusch-Pagan Test of Heteroscedasticity */
data rateBP; set rate; set rateout;
  e_sq = e**2;
  label e_sq ='Squared Residual';
run;

proc reg data=rateBP;
  model e_sq = RPM Incline_level Weights age;
run;

/* Modified-Levene Test of Heteroscedasticity */
data ratemod; set rate; set rateout;
  id = _n_;
  label id = 'Observation Number';
  group = 1;
  if Heart_rate > 127 then group = 2; 

proc sort data = ratemod;
  by group;

proc univariate data = ratemod noprint;
  by group;
  var e;
  output out=mout median=mede;

proc print data = mout;
 var group mede;

data mtemp;
  merge ratemod mout;
  by group;
  d = abs(e - mede);

proc sort data = mtemp;
  by group;

proc means data = mtemp noprint;
  by group;
  var d;
  output out=mout1 mean=meand;

proc print data = mout1;
  var group meand;

data mtemp1;
  merge mtemp mout1;
  by group;
  ddif = (d - meand)**2;

proc sort data = mtemp1;
 by group Heart_rate;

proc ttest data = mtemp1;
  class group;
  var d;

proc print data = mtemp1; 
 by group;
 var id Heart_rate e d ddif;
run;
/* END Modified-Levene Test */

/*Standardizing and Generate Interaction terms*/
data rate1a; set ratenew;
stdx1 = RPM;
stdx2 = Incline_level;
stdx3 = weights;
stdx4 = age;

proc standard data = rate1a mean=0 std=1 out=rate1astd;
var stdx1 stdx2 stdx3 stdx4;

data rateint; set rate1astd;
 x1x2 = RPM * Incline_level;
 x1x3 = RPM * Weights;
 x1x4 = RPM * age;
 x2x3 = Incline_level * Weights;
 x2x4 = Incline_level * age;
 x3x4 = Weights * age;
 stdx1x2 = stdx1 * stdx2;
 stdx1x3 = stdx1 * stdx3;
 stdx1x4 = stdx1 * stdx4;
 stdx2x3 = stdx2 * stdx3;
 stdx2x4 = stdx2 * stdx4;
 stdx3x4 = stdx3 * stdx4;

  label enrm = 'Normal Scores';
  label e = 'e(Y | x1,x2,x3,x4)';
  label yhat = 'Predicted Heart_rate';

proc corr data=rateint noprob;
  var Heart_rate RPM Incline_level Weights age x1x2 x1x3 x1x4 x2x3 x2x4 x3x4;

proc corr data=rateint noprob;
  var Heart_rate RPM Incline_level Weights age stdx1x2 stdx1x3 stdx1x4 stdx2x3 stdx2x4 stdx3x4;
run;

/* Partial Regression Plots for Interactions */

proc reg  data=rateint;
  model x1x2 = RPM Incline_level Weights age;
  output out=outint residual=ex1x2;

proc reg  data=outint;
  model x1x3 = RPM Incline_level Weights age;
  output out=outint residual=ex1x3;

proc reg  data=outint;
  model x1x4 = RPM Incline_level Weights age;
  output out=outint residual=ex1x4;

proc reg  data=outint;
  model x2x3 = RPM Incline_level Weights age;
  output out=outint residual=ex2x3;

proc reg  data=outint;
  model x2x4 = RPM Incline_level Weights age;
  output out=outint residual=ex2x4;

proc reg  data=outint;
  model x3x4 = RPM Incline_level Weights age;
  output out=outint residual=ex3x4;

data partreg; set rateint; set outint;
  label ex1x2 = 'e(x1x2 | x1,x2,x3,x4)';
  label ex1x3 = 'e(x1x3 | x1,x2,x3,x4)';
  label ex1x4 = 'e(x1x4 | x1,x2,x3,x4)';
  label ex2x3 = 'e(x2x3 | x1,x2,x3,x4)';
  label ex2x4 = 'e(x2x4 | x1,x2,x3,x4)';
  label ex3x4 = 'e(x3x4 | x1,x2,x3,x4)';
proc print;

proc gplot data = partreg;
  plot e*ex1x2 /vref = 0 vaxis = axis1;
  plot e*ex1x3 /vref = 0 vaxis = axis1;
  plot e*ex1x4 /vref = 0 vaxis = axis1;
  plot e*ex2x3 /vref = 0 vaxis = axis1;
  plot e*ex2x4 /vref = 0 vaxis = axis1;
  plot e*ex3x4 /vref = 0 vaxis = axis1;
run;

/* Best Subsets */
/* selection = {rsquare adjrsq cp press aic mse sse} */
/* aic = Akaike's information criterion */
/* sbc = Schwarz's Bayesian criterion */
/* start = smallest # of predictors in a model */
/* stop = largest # of predictors in a model */
/* best = maximum # of models to be printed */

proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=1 stop=10 best=20;

proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=1 stop=1 best=2;
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=2 stop=2 best=2;
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=3 stop=3 best=2;
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=4 stop=4 best=2;
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=5 stop=5 best=2;
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = adjrsq cp aic sbc start=6 stop=6 best=2;
run;

/* Backwards deletion*/

proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = backward  slstay=.1;

/* Stepwise Regression (Backward and Forward)*/
proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age
        stdx1x2 stdx1x4 stdx2x3
        / selection = stepwise  slentry=.1 slstay=.1;
run;

/*Best model A*/

data rate_newA; /* New obsn at Age=30 and Incline_level = 13*/
  if _n_ = 1 then Age =35;
  if _n_ = 1 then Incline_level = 13; output;
  set rate; 

proc reg  data=rate;
  model Heart_rate = Incline_level Age / ss1 vif  i influence;
  output out=rateoutA predicted=yhatA residual=eA student=tresA h=hiiA cookd=cookdiA dffits=dffitsiA;
Proc print;

/*95% PI and CI*/
proc reg  data=rate_newA;
  model Heart_rate = Incline_level Age / clm cli;
run;
output out=temp1 l95m=cl95 u95m=cu95 l95=pl95 u95=pu95 p=yhat1 stdp=se_yhat1 stdi=se_pred1;


/*Cutoff values to identify y-outliers and Influence of the outliers alfa = 0.1*/

data cutoffs;
   tinvtres_Model_A = tinv(.9985714286,31);
   finv50_Model_A = finv(.50,3,32); output;
proc print;

/* creating normal scores for residuals - Model A */
proc rank normal=blom out=enrmA data=rateoutA;
  var eA;
  ranks enrmA;
run;

data ratenew_A; set rateoutA; set enrmA;
  label enrmA = 'Normal Scores';
  label eA = 'e(Y | x2,x4)';
  label yhatA = 'Predicted Heart_rate';

proc corr data=ratenew_A noprob;
  var eA enrmA;
run;
 
/* Residual plots for preliminary model A*/
goptions reset = all;
symbol1 v=dot i=join c=black;
axis1 label=(angle = 90);
axis2 order=(0 to 35 by 5);
proc gplot data = ratenew_A;
  plot eA*id / vaxis = axis1 haxis=axis2;
run;

goptions reset = all;
symbol1 v=dot c=black;
axis1 label=(angle = 90);
proc gplot data = ratenew_A;
  plot eA*yhatA /vref = 0 vaxis = axis1;
  plot eA*enrmA / vaxis = axis1;
  plot eA*Incline_level /vref = 0 vaxis = axis1;
  plot eA*Age /vref = 0 vaxis = axis1;
run;

/*Best model B*/
proc reg  data=rate;
  model Heart_rate = Age / ss1 vif  i influence;
  output out=rateoutB predicted=yhatB residual=eB student=tresB h=hiiB cookd=cookdiB dffits=dffitsiB;
Proc print;

/*Cutoff values to identify y-outliers and Influence of the outliers alfa = 0.1*/

data cutoffs;
   tinvtres_Model_B = tinv(.9985714286,32);
   finv50_Model_B = finv(.50,2,33); output;
proc print;

/* creating normal scores for residuals - Model B */
proc rank normal=blom out=enrmB data=rateoutB;
  var eB;
  ranks enrmB;
run;

data ratenew_B; set rateoutB; set enrmB;
  label enrmB = 'Normal Scores';
  label eB = 'e(Y | x4)';
  label yhatB = 'Predicted Heart_rate';

proc corr data=ratenew_B noprob;
  var eB enrmB;
run;
 
/* Residual plots for preliminary model B*/
goptions reset = all;
symbol1 v=dot i=join c=black;
axis1 label=(angle = 90);
axis2 order=(0 to 35 by 5);
proc gplot data = ratenew_B;
  plot eB*id / vaxis = axis1 haxis=axis2;
run;

goptions reset = all;
symbol1 v=dot c=black;
axis1 label=(angle = 90);
proc gplot data = ratenew_B;
  plot eB*yhatB /vref = 0 vaxis = axis1;
  plot eB*enrmB / vaxis = axis1;
  plot eB*Age /vref = 0 vaxis = axis1;
  
run;

/*Three-predictor model for verifying significance of predictors*/

proc reg  data=rateint;
  model Heart_rate = Age stdx1x4 / ss1 vif  i influence;
  output out=rateoutV predicted=yhatV residual=eV student=tresV h=hiiV cookd=cookdiV dffits=dffitsiV;
Proc print;

proc reg data=rateint;
  model Heart_rate = RPM Incline_level Weights Age stdx1x2 stdx1x4 stdx2x3/ ss1 vif;
  output out=rateoutFull;
