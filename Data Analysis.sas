/* Importing cleaned dataset*/
proc import datafile="/home/u63138836/MGH DATA EXERCISE/MGH-CLEAN-DATA.csv"
    out=medicare_clean
    dbms=csv
    replace;
    getnames=yes;
run;

/* Calculating mean and standard deviation of charges by state and year */
proc means data=medicare_filtered n mean median std min max maxdec=2;
    var Tot_Sbmtd_Chrg Tot_Mdcr_Alowd_Amt;
    class Rndrng_Prvdr_State_Abrvtn year;
    title "Mean and Standard Deviation of Charges by State";
run;

/*    Calculating mean and standard deviation of charges by state */
/* proc means data=medicare_filtered n mean median std min max maxdec=2; */
/*     var Tot_Sbmtd_Chrg Tot_Mdcr_Alowd_Amt; */
/*     class Rndrng_Prvdr_State_Abrvtn; */
/*     title "Summary Statistics of Medicare Billings: Rhode Island vs New Hampshire Physicians"; */
/* run; */

/* Getting frequency and percentages of specialties by state */
proc freq data=medicare_filtered;
    tables Rndrng_Prvdr_State_Abrvtn*Rndrng_Prvdr_Type / out=speciality_state_counts outpct;
    title "Speciality count and percentage by state";
run;

/* Sorting frequency output by state and descending count to create bar chart */
proc sort data=speciality_state_counts;
    by Rndrng_Prvdr_State_Abrvtn descending count;
run;

/* Created a bar chart of specialties grouped by state */
proc sgplot data=speciality_state_counts;
    vbar Rndrng_Prvdr_Type / response=count
        group=Rndrng_Prvdr_State_Abrvtn
        groupdisplay=cluster
        datalabel;
    yaxis label="Speciality count";
    xaxis label="Specialty" discreteorder=data;
    title "Specialties count per state";
run;

/* Rounded off pct_col and created a bar chart to show proportion of doctors */
data speciality_state_counts2;
    set speciality_state_counts;
    pct_col_rounded = round(pct_col, 1);
run;

proc sgplot data=speciality_state_counts2;
    vbar Rndrng_Prvdr_Type / response= pct_col_rounded
        group=Rndrng_Prvdr_State_Abrvtn
        groupdisplay=cluster
        datalabel;
    yaxis label="Proportion of Physicians (rounded to integer)";
    xaxis label="Specialty" discreteorder=data;
    title "Proportion of Physicians per state";
run;

/* Printing top 3 specialties for NH */
proc print data=speciality_state_counts(obs=3);
    where Rndrng_Prvdr_State_Abrvtn = 'NH';
/*     var Rndrng_Prvdr_Type count pct_row pct_col ; /* Adjust variables as needed */
    title "Top 3 Specialties in New Hampshire";
run;

/* Printing  top 3 specialties for NH */
proc print data=speciality_state_counts(obs=3);
    where Rndrng_Prvdr_State_Abrvtn = 'RI';
    title "Top 3 Specialties in Rhode Island";
run;





