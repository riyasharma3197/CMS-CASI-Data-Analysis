/* Multivariable Regression model controlling for provider type (i.e., specialty) and year */
proc glm data=medicare_filtered;
    class Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Type year;
    model Tot_Mdcr_Alowd_Amt = Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Type year / SOLUTION;
    title "Regression: NH vs RI on Total Allowed Charges (Controlling for Specialty and Year)";
run;

/* Regression model with different reference category */
/* proc glm data=medicare_filtered; */
/*     class Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Type (ref = 'Anesthesiology') year ; */
/*     model Tot_Mdcr_Alowd_Amt = Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Type year / SOLUTION; */
/*     title "Regression Analysis with different reference category"; */
/* run; */

/* Correlation Analysis/* 
/* Filtering dataset with identifiers and submitted charges for 2013 */
data work.charges2013;
    set medicare_filtered;
    WHERE YEAR = 2013;
    keep Rndrng_NPI Rndrng_Prvdr_Last_Org_Name Rndrng_Prvdr_First_Name Tot_Sbmtd_Chrg;
    rename Tot_Sbmtd_Chrg = Tot_Sbmtd_Chrg_2013;
run;

/* Filtering dataset with identifiers and submitted charges for 2014 */
data work.charges2014;
    set medicare_filtered;
    WHERE YEAR = 2014;
    keep Rndrng_NPI Rndrng_Prvdr_Last_Org_Name Rndrng_Prvdr_First_Name Tot_Mdcr_Alowd_Amt;
    rename Tot_Mdcr_Alowd_Amt = Tot_Mdcr_Alowd_Amt_2014;
run;

/* Sorting both datasets by Provider NPI for merging */
proc sort data=charges2013; 
    by Rndrng_NPI; 
run;

proc sort data=charges2014; 
    by Rndrng_NPI; 
run;

/* Merging dataset with NPI */
data charges_merged;
    merge charges2013(in=a) charges2014(in=b);
    by Rndrng_NPI;
    if a and b;
run;

/*Sort full dataset by year for any further analysis */
proc sort data=medicare_filtered;
    by year;
run;

/* Pearson correlation between 2013 submitted charges and 2014 allowed charges */
proc corr data=charges_merged;
    var Tot_Sbmtd_Chrg_2013 Tot_Mdcr_Alowd_Amt_2014;
    title "Correlation between 2013 Submitted Charges and 2014 Allowed Charges";
run;