#!/bin/bash
#SBATCH --job-name="bar1_parse_gm1"
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=12G
#SBATCH --partition=medium


source /mnt/apps/users/kkeegan/conda/etc/profile.d/conda.sh

conda activate /mnt/apps/users/kkeegan/conda/envs/R_env 

#export PATH=/mnt/shared/scratch/kkeegan/apps/miniconda3/envs/R_env:$PATH
Rscript parsefilter_blasttable_v1.3.R $1 $2 90 1E-12 10000 20000
