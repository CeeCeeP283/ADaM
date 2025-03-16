
/* Generate Metadata*/
PROC CONTENTS DATA=ADAE_CONVERTED OUT=DEFINE_META NOPRINT;
RUN;

PROC PRINT DATA=DEFINE_META;
    VAR NAME TYPE LENGTH LABEL FORMAT;
    TITLE "Metadata for Define.XML";
RUN;


/* Export Metadata for Define.XML*/
PROC EXPORT DATA=DEFINE_META
    OUTFILE="&PATH./Define_Metadata.xlsx"
    DBMS=XLSX REPLACE;
RUN;

/* Export Summary Statistics for Documentation*/
PROC MEANS DATA=ADAE_CONVERTED N MEAN STD MIN MAX;
    VAR ASTDY AENDY;
    CLASS ARM;
    OUTPUT OUT=AE_STATS;
RUN;

PROC EXPORT DATA=AE_STATS
    OUTFILE="&PATH./AE_Statistics.xlsx"
    DBMS=XLSX REPLACE;
RUN;


/* Export ADAE Dataset to .XPT for Submission*/
LIBNAME xptout XPORT "&PATH./ADAE.xpt";

DATA xptout.ADAE;
    SET ADAE_CONVERTED;
RUN;
LIBNAME xptout CLEAR;


ODS PDF FILE="&PATH./Regulatory_Submission_Report.pdf" STYLE=JOURNAL;
TITLE "Regulatory Submission Report for ADAE Dataset";

* Section 1: Dataset Metadata;
TITLE2 "Dataset Metadata Summary";
PROC CONTENTS DATA=ADAE_CONVERTED;
RUN;

* Section 2: Summary Statistics;
TITLE2 "Summary Statistics for Analysis Variables";
PROC MEANS DATA=ADAE_CONVERTED N MEAN STD MIN MAX;
    VAR ASTDY AENDY;
    CLASS ARM;
RUN;

* Section 3: Adverse Event Frequency by Severity;
TITLE2 "Adverse Event Frequency by Severity";
PROC FREQ DATA=ADAE_CONVERTED;
    TABLE AEDECOD * AESEV / MISSING;
RUN;

* Section 4: List of Unresolved Adverse Events;
TITLE2 "Listing of Unresolved Adverse Events";
PROC PRINT DATA=ADAE_CONVERTED;
    WHERE AEONGO="Y";
    VAR USUBJID AETERM ASTDT AENDT AEONGO;
RUN;

* Section 5: Validation Report Summary (Pinnacle 21 Findings);
TITLE2 "Validation Report Summary (Pinnacle 21)";
DATA VALIDATION_SUMMARY;
    INFILE "&PATH./Pinnacle21_Report.csv" DSD FIRSTOBS=2;
    INPUT Issue $ Description $ Severity $;
RUN;
PROC PRINT DATA=VALIDATION_SUMMARY;
RUN;

ODS PDF CLOSE;