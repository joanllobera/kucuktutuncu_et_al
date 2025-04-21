# The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in Virtual Reality: A Reinforcement Learning Paradigm

This repository contains the materials used for the data analysis of:

 Küçüktütüncü, Macia-Varela, Llobera & Slater  (2025) *The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in  Virtual Reality: A Reinforcement Learning Paradigm* accepted at IEEE Transactions on Visualization and Computer Graphics (TVCG)

The scripts found here can also be run directly online, in Kaggle, using the following links:

- Basic data analysis and formating (in python): [Suplementary material for Küçüktütüncü et al. | Kaggle](https://www.kaggle.com/code/joanllobera/suplementary-material-for-k-kt-t-nc-et-al/)

- Statistical model to analyse the transitions (in R): [Transitions Analysis | Kaggle](https://www.kaggle.com/code/melslater/transitions-analysis)

The analysis of the transitions data that is at the heart of the statistical analysis described in the paper.

- Analysis of the scanpath data including the computation of entropy (in R): [Scanpath | Kaggle](https://www.kaggle.com/code/melslater/scanpath/notebook)

A preprint of the publication can be found [[The Role of Sensorimotor Contingencies and Eye Scanpath Entropy in Presence in Virtual Reality: A Reinforcement Learning Paradigm](https://zenodo.org/records/10432799)]

To run locally, make sure you have miniconda or anaconda installed.
Open a terminal (mac, linux), or a conda powershell (windows) and do the following:

```
> conda env create -f environment.yml
> conda activate rl-sm-vr   
> jupyter notebook
```

Then in the browser open the jupyter notebook called **suplementary-material-for-k-kt-t-nc-et-al.ipynb**, and then select the menu option Run > Run all cels

This should create all the tables needed for the data analysis.
```

To run the scanpath data analysis, you will need to be able to compile the Stan model,which requires having Rtools installed. To install Rtools, depending on which operating system you are in, see [RStan Getting Started · stan-dev/rstan Wiki · GitHub](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) 



 simply open the file `scanpath.ipynb` in the notebook, and execute.

```shell

```