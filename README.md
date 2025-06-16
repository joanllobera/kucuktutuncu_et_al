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

To run locally, you need to first generate the tables needed for the data analysis.

to do so, make sure you have miniconda or anaconda installed. Open a terminal (mac, linux), or a conda powershell (windows) and do the following:

```
> conda env create -f environment.yml
> conda activate rl-sm-vr   
> jupyter notebook
```

Then in the browser open the jupyter notebook called **suplementary-material-for-k-kt-t-nc-et-al.ipynb**, and then select the menu option Run > Run all cels

This should create all the tables needed for the data analysis.


To run the R scripts containing the statistics and the stan model, you should do the following (only tested in mac):

1. Install **R**
2. Install the latest RStudio 

Note: on os X make sure you also have the latest Xtools to avoid problems with the compilation of Stan models 

3. In RStudio you have to go to Session -> Set Working Directory -> Project Directory   and point to the folder in the repository called "transitions_analysis"- so that all files referred to are now local instead of having to put full path names.
4.  Open the file called modeldata_publication.R
5. You should not run this file as a whole - but rather copy each successive line to the RStudio console and execute it

During this process you will see that there are other libraries to install (like rstan and expm).