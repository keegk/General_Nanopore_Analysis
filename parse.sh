#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=long

source activate R_env
#Navigate to location of R script
cd /mnt/shared/scratch/kkeegan/personal/Seal_MinION/R/
  
Rscript parse.R