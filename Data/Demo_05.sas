/*************************************/
/* Demo 5: Loading Files into Memory */
/*************************************/

/* View data source files in viyaCas */

PROC CASUTIL INCASLIB="viyaCas";
     LIST files;
QUIT;

/* View in-memory tables in viyaCas */

PROC CASUTIL INCASLIB="viyaCas";
     LIST tables;
QUIT;

/* Server-Side Load */
/* Use when file is in a caslib */
/* Load orders.csv to a session scope in-memory table */

PROC CASUTIL;
   LOAD CASDATA="orders.csv"
   INCASLIB="viyacas"
   CASOUT="ordersIM" 
   OUTCASLIB="viyaCas";
QUIT;

/* Load orders.csv to a global scope in-memory table by adding PROMOTE */
/* Table is visible in VA */

PROC CASUTIL;
   LOAD CASDATA="orders.csv"
   INCASLIB="viyacas"
   CASOUT="ordersIM_global" 
   OUTCASLIB="viyacas"
   PROMOTE;
QUIT;

PROC CASUTIL INCASLIB="viyaCas";
     LIST tables;
QUIT;

/* Client-Side Load */
/* Use when file is not in a caslib, but you want to use it in CAS */
/* Load SAS data set using PROC CASUTIL */

PROC CASUTIL;
   LOAD DATA=sashelp.cars 
   CASOUT="cars_CAS" 
   OUTCASLIB="viyacas" 
   PROMOTE;
QUIT;

PROC CASUTIL INCASLIB="viyacas";
     LIST tables;
QUIT;

/* Load CSV file using PROC CASUTIL */

PROC CASUTIL;
   LOAD FILE="/home/student/workshop/SSV/airport_traffic_2020.csv"  
   CASOUT="EU_Air_2020" 
   OUTCASLIB="viyacas" 
   PROMOTE;
QUIT;

PROC CASUTIL INCASLIB="viyacas";
     LIST tables;
QUIT;

/* Load and promote SAS data set using DATA step */

DATA viyacas.ToyotaCars_CAS (PROMOTE=YES); 
   SET sashelp.cars;
   WHERE Make="Toyota";
RUN;

PROC CASUTIL INCASLIB="viyacas";
     LIST tables;
QUIT;

/* Load CSV using PROC IMPORT */

PROC IMPORT DATAFILE="/home/student/workshop/SSV/airport_traffic_2022.csv"
            DBMS=csv   
            OUT=viyacas.EU_Air_2022
            REPLACE;
RUN;

PROC CASUTIL INCASLIB="viyacas";
     LIST tables;
QUIT;
