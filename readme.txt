------------------------------------------------

R bootcamp Report

Irmak Ozarslan, Barbara Maier

------------------------------------------------

This folder structure is the following:

/Rbootcamp_report
	/preprocessing_scripts
	/processed_data
	/raw_data
	/shiny_app
		/shapefiles


-The file R_bootcamp_report.html is the main report file.


-The file R_bootcamp_report.rmd is the markdown file used to generate the HTML output.

-To knit this markdown file, you need the 4 preprocessed data files which are:
drugdeats_processed1.csv
 MH_processed.csv
suicide_processed.csv
unemployment_processed.csv

- Shiny application is already deployed and can be accessed from the HTML report with a contained link.
- To deploy the shiny application, you need the merged data file which is :
merged_data_last.csv
- The application R file is : app.R

-Preprocessing scripts folder contains 2 files, one is for 4 datasets preprocessing: preprocessing_data.csv and the other is for geospatial data preprocessing: world_preprocessing.csv

-Raw data contains 4 datasets before preprocessing.


*******************************************************************