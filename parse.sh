#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=long

source activate R_env

Rscript parse.R /home/nschurch/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/concatenated_blast.medplus.txt.gz out.txt 90 1E-12 5 200

