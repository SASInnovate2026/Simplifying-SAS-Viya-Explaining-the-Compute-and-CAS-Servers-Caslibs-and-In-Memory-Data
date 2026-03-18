/**************************************/
/* Demo 6: Running a DATA Step in CAS */
/**************************************/

/* Load file into memory */

CASLIB ssvCas PATH="/home/student/workshop/SSV" LIBREF=ssvCas global;

proc casutil;
    list files;
quit;

PROC CASUTIL;
	/*data source file name*/
	LOAD CASDATA="chocolate_enterprise_reporting.sas7bdat"
	/*caslib the data source file is currently in*/
	INCASLIB="ssvcas"
	/*name of the new in-memory table*/
	CASOUT="Choc_Enterprise"
	/*caslib to put the in-memory table in*/
	/*can be the same or different from the INCASLIB*/
	OUTCASLIB="ssvcas"
	promote;
QUIT;

/* Helpful Options */
/* SESSREF= option: Specifies to only run the DATA step in CAS */

/* Output dataset is not in a caslib */
/* Sessref option prevents the step from running on Compute */
data work.EU_Orders /sessref= CJsSession;
     set ssvcas.choc_enterprise;
     where continent="Europe";
run;

/* Output dataset is now a caslib so the step can run in CAS */
data ssvcas.EU_Orders /sessref=CJsSession;
     set ssvcas.choc_enterprise;
     where continent="Europe";
run;

/* MSGLEVEL option: Generates in-depth messages in the log */

options msglevel=i;

data ssvcas.EU_Orders /sessref=CJsSession;
     set ssvcas.choc_enterprise;
     where continent="Europe";
run;

/* PUT _THREADID_ = _N_ : Used to visualize how data is distributed among threads */

data ssvcas.EU_Orders;
     set ssvcas.choc_enterprise end=eof;
     where continent="Europe";
     if eof then put _threadid_= _N_=;
run;

/* SUM Statement */
/* How many rows are returned? */

data ssvcas.EU_Orders;
     set ssvcas.choc_enterprise end=eof;
     where continent="Europe";
     if country_nm="France" then FranceOrders+1;
     if eof=1 then output;
     keep FranceOrders;
     if eof then put _threadid_= _N_=;
run;

/* SINGLE=YES data set option: DATA step runs single threaded on CAS server */
/* Run second, single-threaded DATA step summarizes smaller table */

data ssvcas.EU_Orders_Sum / single=yes;
     set ssvcas.eu_orders end=eof;
     TotalFranceOrders+FranceOrders;
     keep TotalFranceOrders;
     if eof=1 then output;
     if eof then put _threadid_= _N_=;
run;

/* Run one, single-threaded DATA step in CAS on entire table */

data ssvcas.EU_Orders_Single / single=yes;
     set ssvcas.choc_enterprise end=eof;
     where continent="Europe";
     if country_nm="France" then FranceOrders+1;
     if eof=1 then output;
     keep FranceOrders;
     if eof then put _threadid_= _N_=;
run;

/* Remember, Compute server can also be used as normal */

/* Grouping data on the CAS Server */
/* View distinct countries */

proc sql;
select distinct country_nm
     from ssvcas.choc_enterprise;
quit;

/* No need to pre-sort data */
/* Each BY group remains together on a thread */
/* First BY variable determines how data is distributed to threads */
/* How many threads are used? */

data ssvcas.choc_country;
     set ssvcas.choc_enterprise end=eof;
     by country_nm;
     if first.country_nm then CountryTotal=0;
     CountryTotal+1;
     if last.country_nm then output;
     keep country_nm CountryTotal;
     if eof then put _threadid_= _N_=;
run;

/* Row order within a group can vary */
/* Run DATA step twice */

data ssvcas.choc_city;
     set ssvcas.choc_enterprise end=eof;
     by country_nm city_nm;
     keep country_nm city_nm transaction_id customer_name;
     if eof then put _threadid_= _N_=;
run;

/* ADDROWID=YES data set option: Used to maintain row order */
/* _ROWID_ is added as a variable */

libname choc "/home/student/workshop/SSV";

data ssvcas.choc_rowid (addRowId=yes);
     set choc.chocolate_enterprise_reporting;
run;

/* With _ROWID_ as last variable on BY statement, order is guaranteed */
/* Run DATA step twice */

data ssvcas.withrowid;
     set ssvcas.choc_rowid end=eof;
     by country_nm city_nm _rowid_;
     keep country_nm city_nm transaction_id customer_name _rowid_;
     if eof then put _threadid_= _N_=;
run;