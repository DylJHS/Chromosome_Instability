# Chromosome_Instability
Chromosome instability model and project

This repository contains the scripts used in the project “Exploring Heterochromatin Gene Dynamics Reveals Major Contributors to Chromosomal Instability in Cancer”. The project investigates the role of heterochromatin-associated genes in maintaining genomic stability and how their dysregulation contributes to chromosomal instability (CIN), a hallmark of cancer. 


PROJECT OVERVIEW

Heterochromatin, a tightly packed form of DNA, is essential for stabilizing repetitive DNA sequences and regulating gene expression. Dysregulation of heterochromatin-associated genes can lead to chromosomal missegregation, aneuploidy, and other forms of genomic instability that drive cancer development. This project aimed to explore these dynamics by constructing a comprehensive interactome of heterochromatin-associated genes and employing machine learning models to analyse their relationship with CIN features across various cancer types.


CONTENTS

The repository includes scripts for data acquisition and processing, exploratory analysis, machine learning model development, and feature importance analysis. These scripts facilitate the analysis of RNA-seq data from The Cancer Genome Atlas (TCGA), the construction of protein-protein interaction networks using the STRING database, and the prediction of CIN features using a multi-output stacked ensemble model.

Data Processing: 
- The TCGA_Raw_Data_Processing.py script processes raw data from The Cancer Genome Atlas (TCGA) to prepare it for downstream analysis.

Interactome Construction: 
- The STRING_Interactome_Generation.py script contains a function which generates a heterochromatin interactome by querying the STRING Protein-Protein Interaction database. This script identifies physical interactions between proteins and builds the foundational dataset for the subsequent analyses.

Exploratory Analysis: 
- The SOI_and_Control_Set_Configuration.py leverages the interactome generation function to construct the sets used througout the analysis.
- TCGA_Comparative_exploratory_analysis.Rmd scripts perform an exploratory analysis, comparing the Set of Interest (SOI) in cancerous and non-cancerous conditions with control sets to identify distinct transcriptional profiles associated with cancer.
- The TCGA_dge_analysis.Rmd script conducts differential gene expression analysis between cancerous and non-cancerous tissues to identify key genes contributing to chromosomal instability.

Machine Learning Analysis: 
- The Chromosome_Instability_Model.R script implements a multi-output stacked ensemble model using XGBoost to predict CIN features, including arm-level aneuploidies, homologous recombination deficiency (HRD) signatures, and pericentromeric copy number variations (CNVs).

Feature Importance: 
- The Feature_Importance_Analysis.Rmd script assesses the contributions of individual heterochromatin-associated genes to chromosomal instability features, providing insights into their roles in cancer progression.
	
Feature Interaction Analysis: 
- The Feature_Interaction_Analysis.Rmd script explores interactions between CIN features, revealing selective dependencies and the complex interplay between different genomic anomalies in cancer.


IMPORTANT:
The pathnames and location variables should be paid attention to and re-configured to suit the local environments in which the analyses are being run.
