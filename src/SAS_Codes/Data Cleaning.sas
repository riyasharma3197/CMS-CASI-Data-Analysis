/* Importing 2013 Medicare data */
proc import datafile="/home/u63138836/MGH DATA EXERCISE/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.csv"
    out=medicare2013
    dbms=csv
    replace;
    getnames=yes;
run;

/* Importing 2014 Medicare data */
proc import datafile="/home/u63138836/MGH DATA EXERCISE/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2014.csv"
    out=medicare2014
    dbms=csv
    replace;
    getnames=yes;
run;

/* Merging 2013 and 2014 datasets */
data medicare_combined;
    set medicare2013 medicare2014;
run;

/* Looking for variables in the data */
proc contents data=medicare_combined;
run;


/* Sorting the dataset by NPI */
proc sort data=medicare_combined;
    by Rndrng_NPI;
run;

/* Previewing first 10 records to check for sorting*/
proc print data=medicare_combined(obs=10);
run;

/* Displaying state and credential values before filtering */
proc freq data=medicare_combined;
    table Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Crdntls;
    title "Displaying data with credentials and state";
run;

/* Filtering data with MD or DO in RI and NG */
data medicare_filtered;
    set medicare_combined;

    /* Clean credentials: remove periods and convert to uppercase */
    Rndrng_Prvdr_Crdntls = compress(upcase(Rndrng_Prvdr_Crdntls), '.');

    /* Kept only MDs and DOs */
    if index(Rndrng_Prvdr_Crdntls, 'MD') > 0 then Rndrng_Prvdr_Crdntls = 'MD';
    else if index(Rndrng_Prvdr_Crdntls, 'DO') > 0 then Rndrng_Prvdr_Crdntls = 'DO';
    else delete;

    /* Filtered for providers in Rhode Island or New Hampshire */
    where upcase(Rndrng_Prvdr_State_Abrvtn) in ('RI', 'NH');
run;

/* Checking final state and credential values */
proc freq data=medicare_filtered;
    table Rndrng_Prvdr_State_Abrvtn Rndrng_Prvdr_Crdntls;
    title "Displaying final data with credentials and state";
run;

/* Visualizing MD and DO count by state */
proc sgplot data=medicare_filtered;
    vbar Rndrng_Prvdr_State_Abrvtn / group=Rndrng_Prvdr_Crdntls 
        groupdisplay=cluster
        datalabel stat=sum;
    yaxis label="Number of Doctors";
    xaxis label="State";
    title "Number of Physicians in NH and RI";
run;

/* Sorting final dataset by NPI just to check two observation per provider*/
proc sort data=medicare_filtered;
    by Rndrng_NPI;
run;

/* Preview cleaned and filtered dataset */
proc print data=medicare_filtered(obs=10);
run;

/* Exporting cleaned dataset to CSV for next steps*/
proc export data=medicare_filtered
    outfile='/home/u63138836/MGH DATA EXERCISE/MGH-CLEAN-DATA.csv'
    dbms=csv
    replace;
run;
