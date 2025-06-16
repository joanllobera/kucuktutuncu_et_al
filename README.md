# The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in Virtual Reality: A Reinforcement Learning Paradigm

This repository contains the materials used for the data analysis of:

 Küçüktütüncü, Macia-Varela, Llobera & Slater  (2025) *The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in  Virtual Reality: A Reinforcement Learning Paradigm* accepted at IEEE Transactions on Visualization and Computer Graphics (TVCG)


A preprint of the publication can be found [[The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in Virtual Reality: A Reinforcement Learning Paradigm](https://zenodo.org/records/10432799)]



### Run data analysis online



The scripts found here can also be run directly online, in Kaggle, using the following links:

- Basic data analysis and formating (in python): [Suplementary material for Küçüktütüncü et al. | Kaggle](https://www.kaggle.com/code/joanllobera/suplementary-material-for-k-kt-t-nc-et-al/)

- Statistical model to analyse the transitions (in R): [Transitions Analysis | Kaggle](https://www.kaggle.com/code/melslater/transitions-analysis)

The analysis of the transitions data that is at the heart of the statistical analysis described in the paper.

- Analysis of the scanpath data including the computation of entropy (in R): [Scanpath | Kaggle](https://www.kaggle.com/code/melslater/scanpath/notebook)

### Run data analysis locally

You must first download this repository to a local directory. The scripts running locally have three parts, each explained below. 

#### 1. Transitions analysis


To run the R scripts containing the statistics and the stan model for the transitions analysis, you should do the following (only tested in mac):

1. Install **R**
2. Install the latest RStudio 

Note: on os X make sure you also have the latest Xtools to avoid problems with the compilation of Stan models 

3. In RStudio you have to go to Session -> Set Working Directory -> Project Directory   and point to the folder in the repository called "transitions_analysis"- so that all files referred to are now local instead of having to put full path names.
4.  Open the file called modeldata_publication.R
5. You should not run this file as a whole - but rather copy each successive line to the RStudio console and execute it

Note: During this process you will see that there are other libraries to install (like rstan and expm).

6. At the end of running this script, you should get the result that corresponds to Table 7 of the publication. 

#### 2. Scanpath analysis

To run the scripts and the stan model corresponding to the scanpath analysis, you should: 

1. In RStudio you have to go to Session -> Set Working Directory -> Project Directory   and point to the folder in the repository called "scanpath"- so that all files referred to are now local instead of having to put full path names.
2. If you have run the transition analysis you should also select Session -> New session to remove the variables previously created
3. Open the file called scanpath.R
4. Run this file step by step
5. At the end of running this script you should get the result that corresponds to figure 6 of the publication.


#### 3. Generate transitions table from raw data

If instead of using the table `results_transitions.csv` you want to generte it from raw data,  you will need to run the python notebook. .

To do so, put the terminal in folder "3.process_raw_data". Also, make sure you have miniconda or anaconda installed. Open a terminal (mac, linux), or a conda powershell (windows) and do the following:

```
> conda env create -f environment.yml
> conda activate rl-sm-vr   
> jupyter notebook
```

Then in the browser open the jupyter notebook called **suplementary-material-for-k-kt-t-nc-et-al.ipynb**, and then select the menu option Run > Run all cels

This should create all the tables needed for the data analysis. In particular, the table `results_transitions.csv`, which is used as input for the Stan model in section 1.

It will also generate some preliminary plots not included in the final publication, used as a sanity check.
