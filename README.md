# Data and Decisions Cryptopunk Sale Price Modeling

This repository contains the scripts used to generate
a regression and lasso model for predicting Cryptopunk rarity.
This was the result of a Data and Decisions class project at
the Stanford Graduate School of Business executed in collaboration
with Crypto Clarity.

Contributors:
* Claire Yun
* Claire Chen
* Divya Giyanani
* Kevin Liang
* Natalie Meurer

## Included Files

`rarity_parser.py` - Simple python script to transform rarity data in json format into rarity information in csv format. Also extracts features related to whether a punk is a person of color.

`RegressionProject.R` - Core modeling file. Preprocesses data, merges information from 
the provided sales history (not provided in this repository) with the rarity information,
and constructs regression and lasso models.
