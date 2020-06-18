/*RFM ANALYSIS */

/* IMPORTING CUSTOMER DEMOGRAPHICS */

PROC IMPORT OUT= WORK.demo 
            DATAFILE= "H:\mayo\Panel_demo.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc print data=demo(obs=10);run;

proc contents data=demo;run;

data demo1;
set demo(rename=(Panelist_ID=PANID Combined_Pre_Tax_Income_of_HH=Income Age_Group_Applied_to_Male_HH=Age_Male_HH Type_of_Residential_Possession=Res_type

Education_Level_Reached_by_Femal= Edu_Female Education_Level_Reached_by_Male=Edu_Male Occupation_Code_of_Male_HH=Occ_Male_HH Male_Working_Hour_Code= Male_Hr 
Age_Group_Applied_to_Female_HH=Age_Female_HH Occupation_Code_of_Female_HH=Occ_Female_HH Female_Working_Hour_Code=Female_Hr Number_of_TVs_Used_by_HH=No_Tv_HH
Number_of_TVs_Hooked_to_Cable=No_Tv_Cable HH_Head_Race__RACE2_=HH_Race2 HH_Head_Race__RACE3_=HH_Race3 Microwave_Owned_by_HH=Microwave_HH market_based_upon_zipcode=mkt_zipcode
));
run;

proc freq data=demo1;
table HH_Race3;
run;

proc sql;
create table demographics(drop=HH_Race2 Microwave_HH MALE_SMOKE Panelist_Type Res_type HISP_CAT HISP_FLAG) as
select * from demo1 where Age_Female_HH<>0 and Age_Female_HH<>7 and Age_Male_HH<>0 and Age_Male_HH<>7 and Children_Group_Code<>0 
AND Edu_Female<>0 AND Edu_Female<>9 AND Edu_Male<>0 AND Edu_Male<>9 AND Family_Size<>0 AND Female_Hr<>7 AND HH_AGE<>0 AND HH_AGE<>7 and HH_EDU<>0 AND Income<>0 AND 
Male_Hr<>0 AND Marital_Status<>0 AND Occ_Male_HH<>11 AND Occ_Female_HH<>11;
quit;

proc sql;
select * from demographics(obs=10);
quit;

proc sql;
create table demo_cust as
select PANID,Marital_Status,HH_RACE,HH_Race3,Children_Group_Code,
CASE
	when Income in (1,2,3,4,5) then "LOW"
	when Income in (6,7,8,9) then "MEDIUM"
	ELSE "HIGH" END AS FAM_INCOME,
CASE
	when Family_Size in (1,2,3) then "SMALL"
	else "LARGE" end as FAM_SIZE,
CASE
	WHEN Age_Male_HH IN (1) THEN 'YOUNG'
	WHEN Age_Male_HH IN (2,3,4) THEN 'MIDDLE_AGE'
	ELSE 'OLD' END AS AGE_MALE,
CASE
	WHEN Age_Female_HH IN (1) THEN 'YOUNG'
	WHEN Age_Female_HH IN (2,3,4) THEN 'MIDDLE_AGE'
	ELSE 'OLD' END AS AGE_FEMALE,
CASE
	WHEN Edu_Female IN (1,2,3,4,5) THEN 'SCHOOL'
	ELSE 'COLLEGE' END AS Edu_Female,
CASE
	WHEN Edu_Male IN (1,2,3,4,5) THEN 'SCHOOL'
	ELSE 'COLLEGE' END AS Edu_Male,
CASE
	WHEN Occ_Male_HH IN (1,2,3) THEN 'WHITE_COLLAR_HIGH'
	WHEN Occ_Male_HH IN (4,5) THEN 'WHITE_COLLAR_LOW'
	WHEN Occ_Male_HH IN (6,7,8,9) THEN 'BLUE_COLLAR'
	WHEN Occ_Male_HH IN (10,13) THEN 'NOTWORKING'
	ELSE 'OTHER' END AS OCC_Male,

CASE
	WHEN Occ_Female_HH IN (1,2,3) THEN 'WHITE_COLLAR_HIGH'
	WHEN Occ_Female_HH IN (4,5) THEN 'WHITE_COLLAR_LOW'
	WHEN Occ_Female_HH IN (6,7,8,9) THEN 'BLUE_COLLAR'
	WHEN Occ_Female_HH IN (10,13) THEN 'NOTWORKING'
	ELSE 'OTHER' END AS OCC_Female,
Number_of_Dogs+Number_of_Cats as Total_Pets
from demographics;
quit;

proc  print data=demo_cust1(obs=10);run;

/* CREATING DUMMY VARIABLES */

data demo_cust1;
set demo_cust;
if FAM_INCOME="LOW" then FAM_INCOME_L=1; else FAM_INCOME_L=0;
if FAM_INCOME="MEDIUM" then FAM_INCOME_M=1;else FAM_INCOME_M=0;
if FAM_INCOME="HIGH" then FAM_INCOME_H=1;else FAM_INCOME_H=0;

if FAM_SIZE="SMALL" then FAM_SIZE_S=1;else FAM_SIZE_S=0;
if FAM_SIZE="LARGE" then FAM_SIZE_L=1;else FAM_SIZE_L=0;

if AGE_MALE="YOUNG" then AGE_MALE_Y=1;else AGE_MALE_Y=0;
if AGE_MALE="MIDDLE_AGE" then AGE_MALE_M=1;else AGE_MALE_M=0;
if AGE_MALE="OLD" then AGE_MALE_O=1;ELSE AGE_MALE_O=0;

if AGE_FEMALE="YOUNG" then AGE_FEMALE_Y=1;else AGE_FEMALE_Y=0;
if AGE_FEMALE="MIDDLE_AGE" then AGE_FEMALE_M=1;else AGE_FEMALE_M=0;
if AGE_FEMALE="OLD" then AGE_FEMALE_O=1;ELSE AGE_FEMALE_O=0;

if Edu_Female="SCHOOL" then Edu_Female_S=1;else Edu_Female_S=0;
if Edu_Female="COLLEGE" then  Edu_Female_C=1;ELSE Edu_Female_C=0;

if Edu_Male="SCHOOL" then Edu_Male_S=1;else Edu_Male_S=0;
if Edu_Male="COLLEGE" then Edu_Male_C=1;ELSE Edu_Male_C=0;

if OCC_Male="WHITE_COLLAR_HIGH" then OCC_Male_WH=1;else OCC_Male_WH=0;
if OCC_Male="WHITE_COLLAR_LOW" then OCC_Male_WL=1;else OCC_Male_WL=0;
if OCC_Male="BLUE_COLLAR" then OCC_Male_B=1;else OCC_Male_B=0;
if OCC_Male="NOTWORKING" then OCC_Male_NW=1;else OCC_Male_NW=0;
if OCC_Male="OTHER" then OCC_Male_O=1;else OCC_Male_O=0;

if OCC_Female="WHITE_COLLAR_HIGH" then OCC_Female_WH=1;else OCC_Female_WH=0;
if OCC_Female="WHITE_COLLAR_LOW" then OCC_Female_WL=1;else OCC_Female_WL=0;
if OCC_Female="BLUE_COLLAR" then OCC_Female_B=1;else OCC_Female_B=0;
if OCC_Female="NOTWORKING" then OCC_Female_NW=1;else OCC_Female_NW=0;
if OCC_Female="OTHER" then OCC_Female_O=1;else OCC_Female_O=0;

if Marital_Status=1 then Marital_Status_S=1;else Marital_Status_S=0;
if Marital_Status=2 then Marital_Status_M=1;else Marital_Status_M=0;
if Marital_Status in (3,4,5) then Marital_Status_DW=1;else Marital_Status_DW=0;

if HH_RACE=3 then HH_RACE_H=1;ELSE HH_RACE_H=0;
IF HH_RACE NE 3 THEN HH_RACE_NH=1;ELSE HH_RACE_NH=0;

if HH_Race3=1 then HH_Race3_W=1;else HH_Race3_W=0;
if HH_Race3=2 then HH_Race3_B=1;else HH_Race3_B=0;
if HH_Race3=3 then HH_Race3_H=1;else HH_Race3_H=0;
if HH_Race3=4 then HH_Race3_A=1;else HH_Race3_A=0;
if HH_Race3 in (5,6,7) then HH_Race3_O=1;else HH_Race3_O=0;

IF Total_Pets=0 THEN Total_Pets_0=1; ELSE Total_Pets_0=0;
IF Total_Pets NE 0 THEN Total_Pets_1=1; ELSE Total_Pets_1=0;

if Children_Group_Code=1 then Child_1=1;else Child_1=0;
if Children_Group_Code=2 then Child_2=1;else Child_2=0;
if Children_Group_Code=3 then Child_3=1;else Child_3=0;
if Children_Group_Code=4 then Child_4=1;else Child_4=0;
if Children_Group_Code=5 then Child_5=1;else Child_5=0;
if Children_Group_Code=6 then Child_6=1;else Child_6=0;
if Children_Group_Code=7 then Child_7=1;else Child_7=0;
RUN;

data demo_cust1(drop =HH_Race3 Total_Pets HH_RACE Marital_Status OCC_Female OCC_Male Edu_Male Edu_Female AGE_FEMALE
AGE_MALE FAM_SIZE FAM_INCOME Children_Group_Code); 
set demo_cust1;
run;


/* IMPORTING PROD MAYO */

PROC IMPORT OUT= WORK.b 
            DATAFILE= "H:\mayo\prod_mayo.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc print data=b(obs=10);run;

/* IMPORITNG STORE SCANNER DATA */


data c;
infile "H:\mayo\mayo_PANEL_GR_1114_1165.dat" firstobs=2 delimiter='09'x;
input PANID  WEEK  UNITS OUTLET $ DOLLARS IRI_KEY COLUPC ;
run;

proc print data=c(obs=10);run;



proc sort data = b;
by colupc;
run;
proc sort data = c;
by colupc;
run;
DATA final; 
  MERGE b c;  
  BY colupc; 
RUN;

data final1;
set final;
Quantity1=input(Quantity,best4.);
run;

proc print data = final1(obs=100);run;
proc contents data=final1;run;

/* IMPORTING WEEK TRANSLATION DATA */

PROC IMPORT OUT= WORK.WEEK_TRANS 
            DATAFILE= "H:\mayo\IRI week translation.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc print data=week_trans(obs=10);run;



data week_trans;
set week_trans(rename=(Calendar_week_starting_on=week_start Calendar_week_ending_on=week_end));run;

data week_trans1;
set week_trans;
format week_start mmddyy8.;
format week_end mmddyy8.;run;

proc print data=week_trans1;run;

/* MERGING WEEKS, CUSTOMER DEGOGRAPHICS AND SCANNER DATA */

proc sql;
create table final_week_merged as
SELECT * FROM
(SELECT * FROM final1) AS A 
LEFT JOIN
(SELECT * FROM week_trans1) AS B
ON A.WEEK=B.IRI_Week
where L5="HELLMANNS";
QUIT;

proc print data=final_week_merged(obs=10);run;

data final_week_merged;
set final_week_merged;
LAST_WEEK=input(put('30DEC2001',9.),date9.);

run;

/* CREATING MONETARY, FREQUENCY AND RECENCY VARIABLES*/
PROC SQL;
CREATE TABLE PRE_RFM AS
SELECT PANID, SUM(DOLLARS) AS MONETARY,COUNT(week) AS FREQUENCY,MAX(week) AS last_buy,
MIN(1165-week) AS RECENCY
FROM final_week_merged
GROUP BY PANID
HAVING FREQUENCY>1;
QUIT;

proc print data=pre_rfm1(obs=10);run;

data pre_rfm1;
set pre_rfm;
format last_buy mmddyy8.;

id=1;
run;

proc corr data=pre_rfm1;
var monetary frequency recency;
run;

/* CREATING PERCENTILES */
proc means data=pre_rfm1 MIN P20 P40 P60 P80 MAX;
var monetary recency frequency;
output out=summary  min= P20= P40= P60= P80= Max= /autoname;run;

proc print data=summary(obs=10);run;
data summary;
set summary;
id=1;
run;

proc sql;
create table cust_clusters as
select * from
(select * from pre_rfm1) as a
left join
(select * from summary) as b
on a.id=b.id;quit;

proc print data=cust_clusters(obs=10);run;

/* SEGMENTING INTO CLUSTERS */
data cust_clusters(drop = id _type_ _freq_ last_buy);
set cust_clusters;
if (monetary>monetary_p80 ) then segment=1;
else if (monetary < monetary_p20 and frequency<frequency_p40 ) then segment=2;
else segment=0;run;

PROC FREQ DATA=cust_clusters;
TABLE segment;
RUN;

PROC SQL;
CREATE TABLE segment1 AS
SELECT * FROM cust_clusters WHERE segment=1;
QUIT;

PROC SQL;
CREATE TABLE segment2 AS
SELECT * FROM cust_clusters WHERE segment=2;
QUIT;




proc sql;
create table segment1_demo as
select * from 
(select * from demo_cust1) as a
inner join
(select * from segment1) as b
on a.panid=b.panid;quit;

proc sql;
create table segment2_demo as
select * from 
(select * from demo_cust1) as a
inner join
(select * from segment2) as b
on a.panid=b.panid;quit;



DATA segment1_demo (DROP = MONETARY_Min RECENCY_Min MONETARY_P20 RECENCY_P20 MONETARY_P40 RECENCY_P40 MONETARY_P60 RECENCY_P60 MONETARY_P80 RECENCY_P80 MONETARY_Max 
RECENCY_Max	segment frequency_Min frequency_P20 frequency_P40 frequency_P60 frequency_P80 frequency_Max group);
SET segment1_demo;
RUN;

DATA segment2_demo (DROP = MONETARY_Min RECENCY_Min MONETARY_P20 RECENCY_P20 MONETARY_P40 RECENCY_P40 MONETARY_P60 RECENCY_P60 MONETARY_P80 RECENCY_P80 MONETARY_Max 
RECENCY_Max	segment frequency_Min frequency_P20 frequency_P40 frequency_P60 frequency_P80 frequency_Max group);
SET segment2_demo;
RUN;

/* ANALYZING CLUSTER 1 */
proc means data=segment1_demo;run;

/* ANALYZING CLUSTER 2 */
proc means data=segment2_demo;run;



/* ANALYSIS 2 - Determine the effect of price, display, feature and promotion on the sales of Hellman’s mayonnaise.*/ 

PROC IMPORT OUT= mayo 
            DATAFILE= "H:\mayo\prod_mayo.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data UPC_WEEK;
infile "H:\mayo\mayo_groc_1114_1165" firstobs=2;
input IRI_KEY WEEK SY_0 $  GE_0 $ VEND_0 $ ITEM_0 $ UNITS DOLLARS F$ D PR;
SY = put(input(SY_0, best2.),z2.);
GE = put(input(GE_0, best2.),z2.);
VEND = put(input(VEND_0, best5.),z5.);
ITEM = put(input(ITEM_0, best5.),z5.);
UPC = catx('-',SY,GE,VEND,ITEM);
run;
PROC SQL;
CREATE TABLE UPC_GROUPED AS
SELECT A.*,B.* FROM
(SELECT * FROM UPC_WEEK) AS A
LEFT JOIN
(SELECT * FROM mayo) AS B
ON A.UPC=B.UPC;
PROC PRINT DATA=UPC_GROUPED(OBS=20);
RUN;
PROC SQL;
create table MAYO_HELLMANNS as select *
from UPC_GROUPED
where L5 LIKE '%HELL%';
proc sql;
create table MAYO_HELLMANNS1 as
select iri_key,count(distinct WEEK) AS distinct_weeks from MAYO_HELLMANNS
group by iri_key
having distinct_weeks=52;
QUIT;
proc sql;
create table MAYO_HELLMANNS_FINAL as select * from MAYO_HELLMANNS
where iri_key in (select iri_key from MAYO_HELLMANNS1); quit;
data MAYO_HELLMANNS_FINAL; 
set MAYO_HELLMANNS_FINAL;
tot_vol=vol_eq*units;
ppu=dollars/tot_vol; 
run;
proc univariate data=MAYO_HELLMANNS_FINAL;
var ppu; 
run;
proc sql;
create table HELLMANNS_CALC as select iri_key,week,units,tot_vol,dollars,f,d,pr,upc,ppu
from MAYO_HELLMANNS_FINAL; 
quit;
proc freq data=HELLMANNS_CALC; table f; run;
proc freq data=HELLMANNS_CALC; table d; run;
proc freq data=HELLMANNS_CALC; table pr; run;
data HELLMANNS_CALC; 
set HELLMANNS_CALC; 
if f='NONE' then f1=0; else f1=1;
if d='0' then d1=0; else d1=1;
if pr='0' then pr1=0; else pr1=1; 
run;
/* Creating grouped dataset at Store,Week,UPC level */
proc sql;
create table HELLMANNS_GROUPED as select iri_key,week,upc,sum(units) as tot_units,sum(tot_vol) as sum_vol,sum(dollars) as tot_dollars,
sum(f1) as tot_f1, sum(d1) as tot_d1,sum(pr1) as tot_pr1, avg(ppu) as avg_ppu
from HELLMANNS_CALC
group by iri_key,week,upc; quit;
/* Creating weighted price, feature, display and price reduction variables for panel regression */
proc sql;
create table HELLMANNS_WEEKLY as
select iri_key,week,sum(units) as tot_iri_week_units, sum(tot_vol) as tot_iri_week_vol
from HELLMANNS_CALC
group by iri_key,week; quit;
PROC SQL;
CREATE TABLE HELLMANNS_GROUPED1 AS
SELECT C.*, D.* FROM 
(SELECT * FROM HELLMANNS_GROUPED) AS C
LEFT JOIN
(SELECT * FROM HELLMANNS_WEEKLY) AS D
ON C.IRI_KEY=D.IRI_KEY AND C.WEEK=D.WEEK;
QUIT;
DATA HELLMANNS_GROUPED1;
SET HELLMANNS_GROUPED1;
IF tot_f1=0 THEN w_feature=0;
ELSE w_feature=1*(sum_vol/tot_iri_week_vol);
IF tot_d1=0 THEN W_DISPLAY=0;
ELSE w_display=1*(sum_vol/tot_iri_week_vol);
IF tot_pr1=0 THEN W_PROMOTION=0;
ELSE W_PROMOTION=1*(sum_vol/tot_iri_week_vol);
RUN;
/* Creating final panel dataset for regression */
proc sql;
create table HELLMANNS_FINAL as
select iri_key,week,sum(tot_units) as sum_units,sum(sum_vol) as sum_tot_vol,sum(tot_dollars) as sum_dollars,avg(avg_ppu) as avg_price,
sum(w_feature) as sum_w_feature,sum(w_display) as sum_w_display,sum(w_promotion) as sum_w_promotion 
from HELLMANNS_GROUPED1
group by iri_key,week; quit;
/*Check for Non-Linearity*/
proc sgplot data=HELLMANNS_FINAL; 
scatter x=avg_price y=sum_dollars; 
run;
/*MULTICOLLINEARITY*/
PROC CORR DATA=HELLMANNS_FINAL;
RUN;

PROC PANEL DATA = HELLMANNS_FINAL;
ID IRI_KEY WEEK;       
MODEL sum_units = sum_w_feature sum_w_display sum_w_promotion /FIXTWO RANTWO;
RUN;
/*Interaction Effect*/
data HELLMANNS_PANEL;
set HELLMANNS_FINAL;
PRICESQ = avg_price * avg_price;
INTF_D =  sum_w_feature * sum_w_display;
INTF_P =  sum_w_feature * sum_w_promotion;
INTD_P = sum_w_display * sum_w_promotion;
INTF_D_P = sum_w_display *  sum_w_feature * sum_w_promotion;
RUN;
PROC REG DATA=HELLMANNS_PANEL;
MODEL sum_units = PRICESQ sum_w_feature sum_w_display sum_w_promotion INTF_D INTD_P/ VIF COLLIN;
RUN;
PROC PANEL DATA = HELLMANNS_PANEL;
ID IRI_KEY WEEK;       
MODEL sum_units = PRICESQ sum_w_feature sum_w_display sum_w_promotion INTF_D INTD_P /FIXTWO RANTWO;    
RUN;



/* ANALYSIS 3 - PRICE REDUCTION ,FEATURE AND DISPLAY ANALYSIS*/
DATA DELIVERY_STORES;
INFILE "H:\mayo\Delivery_Stores" DLM=" " FIRSTOBS=2;
INPUT IRI_KEY  OU $  EST_ACV  MARKET_NAME  $25. OPEN  CLSD  MSKDNAME  $;
IF OU='GR';
RUN;

PROC PRINT DATA=DELIVERY_STORES(obs=5);RUN;


DATA MAYO_GROC;
INFILE "H:\mayo\mayo_groc_1114_1165" FIRSTOBS=2;
INPUT IRI_KEY WEEK SY GE VEND ITEM UNITS DOLLARS F $ D PR;
run;


data MAYO_GROC1;
SET MAYO_GROC;
 SY_p=put(SY,z2.);
 format SY z2.;
 GE_p=put(GE,z2.);
 format GE z2.;
 VEND_p=put(VEND,z5.);
 format VEND z5.;
 ITEM_p=put(ITEM,z5.);
 format ITEM z5.;
 UPC = catx('-',SY_p ,GE_p,VEND_p ,ITEM_p);
run;

PROC PRINT DATA=MAYO_GROC1(obs=5);RUN;

PROC CONTENTS DATA=MAYO_GROC1;RUN;


PROC IMPORT OUT=PROD_MAYO
     DATAFILE= "H:\mayo\prod_mayo.xls" 
     DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC PRINT DATA=PROD_MAYO(obs=5);RUN;

PROC CONTENTS DATA=PROD_MAYO;RUN;

/*Merged Data*/
PROC SQL;
create table MAYO_GROC_PROD as
  select * from MAYO_GROC1, PROD_MAYO
where MAYO_GROC1.UPC=PROD_MAYO.UPC ;
run;

PROC PRINT DATA=MAYO_GROC_PROD(obs=10);RUN;

PROC SQL;
create table Q3 as
select L5 as Brand_Name , sum(DOLLARS) as Total_Sales
from MAYO_GROC_PROD
group by L5
order by Total_Sales DESC;
RUN;

PROC PRINT DATA=Q3(obs=10);RUN;

PROC SQL;
create table T1 as
  select * from MAYO_GROC_PROD, DELIVERY_STORES
where DELIVERY_STORES.IRI_KEY=MAYO_GROC_PROD.IRI_KEY ;
run;

/*Creating Dummy Variables*/
DATA T2;
SET T1;
IF F='NONE' THEN DO ;F_N=1; F_B=0 ; F_A=0 ; F_APLUS=0 ; F_C=0;END;
IF F='A+' THEN DO;F_APLUS=1 ; F_B=0 ; F_A=0 ; F_N=0 ; F_C=0;END;
IF F='A' THEN DO;F_A=1 ; F_B=0  ; F_APLUS=0 ; F_N=0 ; F_C=0;END;
IF F='B' THEN  DO; F_B=1  ; F_A=0 ; F_APLUS=0 ; F_N=0 ; F_C=0;END;
IF F='C' THEN DO;F_C=1 ; F_B=0 ; F_A=0 ; F_APLUS=0 ; F_N=0;END;

IF D='0' THEN DO;D_2=0 ; D_1=0 ; D_0=1;END;
IF D='1' THEN DO;D_2=0 ; D_1=1 ; D_0=0;END;
IF D='2' THEN DO;D_2=1 ; D_1=0 ; D_0=0;END;

IF PR='0' THEN DO;PR_1=0 ; PR_0=1;END;
IF PR='1' THEN DO;PR_1=1 ; PR_0=0;END;

IF L5='KRAFT MIRACLE WHIP' THEN DECISION='A';
ELSE IF L5='HELLMANNS' THEN DECISION='B';
ELSE IF L5='BEST FOODS' THEN DECISION='C';
RUN;
PROC PRINT DATA=T2(obs=10);RUN;

/*Selecting only 3 brands*/
DATA T3;
SET T2;
IF DECISION = "." then delete;
RUN;

/*Logistic Model*/
PROC LOGISTIC data=T3 descending;
  class DECISION(ref = "B") / param=ref ;
  model DECISION = F_N F_A F_B F_C D_0 D_2 PR_0/ link = glogit;
RUN;
