# Chromosome_Instability
Chromosome instability model and project

This repository contains the scripts used in the project “Exploring Heterochromatin Gene Dynamics Reveals Major Contributors to Chromosomal Instability in Cancer”. The project investigates the role of heterochromatin-associated genes in maintaining genomic stability and how their dysregulation contributes to chromosomal instability (CIN), a hallmark of cancer. 


PROJECT OVERVIEW

Heterochromatin, a tightly packed form of DNA, is essential for stabilizing repetitive DNA sequences and regulating gene expression. Dysregulation of heterochromatin-associated genes can lead to chromosomal missegregation, aneuploidy, and other forms of genomic instability that drive cancer development. This project aimed to explore these dynamics by constructing a comprehensive interactome of heterochromatin-associated genes and employing machine learning models to analyse their relationship with CIN features across various cancer types.


CONTENTS

The repository includes scripts for data acquisition and processing, exploratory analysis, machine learning model development, and feature importance analysis. These scripts facilitate the analysis of RNA-seq data from The Cancer Genome Atlas (TCGA), the construction of protein-protein interaction networks using the STRING database, and the prediction of CIN features using a multi-output stacked ensemble model.

Data Processing: 
- The TCGA_Raw_Data_Processing.py script reads raw TCGA RNA-seq data (either TPM or expected counts), processes it to separate sample headers, and reformats the data into a structured DataFrame where genes are represented as rows and samples as columns. The processed data is then saved as a CSV file for use in downstream analyses.

Interactome Construction: 
- The STRING_Interactome_Generation.py script contains a function that queries the STRING Protein-Protein Interaction (PPI) database to retrieve a list of genes interacting with a given list of proteins. It first converts the input protein names to their corresponding STRING identifiers, then uses these identifiers to fetch physically interacting genes from the STRING database. The result is a comprehensive list of unique interacting genes, which forms the foundational dataset for subsequent analyses.

Exploratory Analysis: 
- The SOI_and_Control_Set_Configuration.py script transforms raw TCGA RNA-seq data into a Set-of-Interest (SOI) mRNA dataset and multiple control mRNA datasets. It leverages the Gene_list function from the STRING_Interactome_Generation.py script to retrieve genes interacting with a predefined set of proteins. The script then creates a dataset focusing on these genes of interest and generates control datasets by randomly selecting genes that match the shape of the SOI dataset. The resulting datasets are saved in CSV format for further analysis.
- The TCGA_Normal_Gene_Set_Generation.py script generates normal (non-cancerous) gene expression datasets from the TCGA Pan-Cancer (PANCAN) project for exploratory analysis. It identifies and selects samples corresponding to healthy tissue types, excludes metastatic samples, and creates both full and subset datasets of healthy gene expression data. The script also generates control gene sets corresponding to each cancerous control set, ensuring that the same genes are used across both cancerous and healthy datasets. The resulting datasets are saved in CSV format for further analysis.
- TCGA_Comparative_exploratory_analysis.Rmd script conducts a comprehensive exploratory analysis comparing the Set-of-Interest (SOI) gene expression profiles in cancerous and non-cancerous tissues. It leverages various statistical tests and visualizations to assess the differences between the SOI and multiple control gene sets across different conditions. The analysis includes calculating mean expression levels, performing non-parametric tests like the Friedman test and Wilcoxon signed-rank test, and generating plots to visualize expression differences. The script is crucial in identifying significant expression patterns and differences in the SOI compared to control gene sets, both in cancerous and non-cancerous contexts.
- The TCGA_dge_analysis.Rmd script performs a Differential Gene Expression Analysis (DGEA) comparing cancerous and non-cancerous tissue samples from TCGA RNA-seq data. It uses the expected counts data to identify differentially expressed genes (DEGs) across all tissues and within specific cancer types. The analysis includes preprocessing steps like data normalization, removal of low-count genes, and creation of linear models using the voom transformation. Results are presented in the form of detailed tables and volcano plots, highlighting significant DEGs, especially those related to the Set-of-Interest (SOI). The script also extends the analysis to tissue-specific DGEA, comparing the expression profiles within different cancer subtypes.

Feature Engineering: 
- The Pericentromeric_cnv_segmentation.Rmd script processes TCGA PanCancer CNV data to define and analyse pericentromeric regions. It identifies contiguous satellite regions, calculates overlap-weighted CNV values within these regions for each sample, and restructures the data to provide a matrix of CNV values across the defined pericentromeric regions.

Machine Learning Analysis: 
- The Train_test_split.r script processes RNA data files by identifying common sample IDs across multiple datasets, then randomly selecting 75% of these common IDs to create training and testing sets. It saves the resulting training, testing, and full datasets in their respective directories, ensuring consistency across the different RNA data files.
- The arm_lev_aneu_weight.r script processes CNV data to extract arm-level aneuploidies, calculates class weights for each chromosome arm, and saves the results to a CSV file. It normalises the class weights by calculating the inverse frequency of aneuploidies across samples, ensuring that rare events are weighted appropriately for subsequent analysis. The script also reorders the arms according to a predefined order before saving the weights.
- The base_class_tune.r, base_regress_tune.r, and meta_learner_tune.r scripts are designed to optimize machine learning models by fine-tuning their hyperparameters. They load the necessary datasets, apply cross-validation, and use grid search to identify the best model configurations for both regression and classification tasks, as well as for a meta-learning model. The scripts then save the optimal model parameters and performance metrics for further analysis and use.
- The CIN_model_analysis.Rmd script performs a comprehensive analysis of the General CIN model, including both base and meta-layer layers. It merges RNAseq and CIN features, trains models using cross-validation, and evaluates their performance. The script also analyses genomic feature importance and interdependencies and generates visualizations to assess model accuracy and predictive power.

Cancer-Specific Analysis:
The cancer-specific scripts (cancer_specific_CIN_model_analysis.Rmd, cancer_specific_arm_lev_aneu_weight.r, cancer_specific_base_class_tune.r, cancer_specific_base_regress_tune.r, cancer_specific_meta_learner_tune.r, cs_Train_test_split.R) do the same thing as the general (PanCan) scripts but are focused on using the data parsed by tissue type.


IMPORTANT:
The pathnames and location variables should be paid close attention to and re-configured to suit the local environments in which the analyses are being run.


REQUIREMENTS: 
The analyses rely the TCGA PanCan data which can be downloaded from: 
- https://xenabrowser.net/datapages/?cohort=TCGA%20Pan-Cancer%20(PANCAN)&removeHub=https%3A%2F%2Fxena.treehouse.gi.ucsc.edu%3A443 (RNAseq, HRD signatures)
- https://gdc.cancer.gov/about-data/publications/pancanatlas (Segmented CNV, Arm-level ploidy)
- https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables (metadata)
  
The pericentromeric annotations can be acquired from: 
- https://genome.ucsc.edu/cgi-bin/hgc?hgsid=2264477098_2fIMqrqQPFZBX4anxrWLSety2h4q&db=hub_3671779_hs1&c=chr9&l=47548620&r=76777036&o=49055551&t=76694047&g=hub_3671779_censat&i=hsat3_9_3%28B5%29

