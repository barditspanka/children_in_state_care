
Family foster care or residential care: the impact of home environment on children raised in state care
Replication and code documentation
Authors: Anna Bárdits and Gábor Kertesi. The replication package and codes are written by Anna Bárdits (contact:bardits.anna@krtk.hun-ren.hu)

OVERVIEW

The code in the replication package produces the tables and figures presented in the paper and online appendix. The full replication package including the datasets required for the reproduction of the analysis can be accessed at the Centre for Economic and Regional Studies (CERS) prosperity server. Data used in this project is individual-level, sensitive, and cannot be made publicly available. The codes in the replication package are public.
Access to the data can be provided through the Databank of CERS (contact: adatkeres@krtk.hun-ren.hu). The replicator can get remote access to the analysis data, and the main raw data source (Admin3), and can reproduce all results in the main text of the paper remotely. To replicate the full process which generates the analysis data from raw data, the replicator or locally hired assistant has to be physically present in CERS’s Research Rooms.
This replication package assumes that the replicator wishes to reproduce the results remotely, using the analysis data. The codes that generate the analysis data from the raw data sources are also included in the package.
 
DESCRIPTION OF THE SCRIPTS

If the replicator runs the analysis from the analysis data, she will only need to use the Do/setup.do  Do/analyze_data.do files. The Do/analyze_data.do script calls further subscripts, which are all located in the Do folder of the replication package. Data needed for the replication are in the Input_data and Output_data folders of the parent directory on CERS’s server. The datasets needed for the replication are the following:
Output_data/CISC_regdata.dta	The main dataset used in the analysis. Individual level, person id “anon”. The data is prepared from raw data sources using the Do/create_clean_dataset.do and Do/create_regression_sample.do scripts.
Output_data/county_data.dta	County-level data with selected variables Do/create_clean_dataset.do
Input_data/residential_ratio_hun.dta	Additional data needed for one figure. Hungarian Statistical Office data  for ratio in foster carehttps://www.ksh.hu/stadat_files/szo/hu/szo0017.html
Input_data/unicef_datacare.dta	Additional data needed for one figure https://bettercarenetwork.org/sites/default/files/2022-02/Better%20data%20for%20better%20child%20protection%20in%20Europe_Technical%20report%20to%20the%20DataCare%20project.pdf

If the replicator wishes to reproduce the data cleaning process as well, Do/master.do script should be run, and access to Admin3 h2 files is needed. The master.do file calls subscripts (including analyze_data.do and additionally data preparation and cleaning scripts), which in turn call further subscripts. 
 
Instructions to Replicators
•	Connect to CERS’s prosperity server (detailed instructions are given by CERS Databank, adatkeres@krtk.hu), with VNC viewer
•	Open Stata-Mp version 16.24 (use the following command in the terminal: /home/apps/stata/prosperity/stata16_24/xstata-mp)
•	Open and run the do files (from beginning to end).
1.	run Do/setup.do – installs packages, and sets the working directory. The working directory is set in line 1 (e.g. cd “/path/Replication” )
2.	run Do/analyze_data.do
In the script the number of the exhibit is indicated in the comments. The results are stored in the Results folder. After running the codes and obtaining the exhibits, the replicator can open the files on CERS’s server using the “libreoffice” command in the terminal. (For example, after changing to the parent directory, type “libreoffice Results/ Results/proxycontrol_outcome.csv". Alternatively, if the replicator wishes to save the exhibits to her own computer, she can request the Databank to download and send her the outputs of the Results folder.

