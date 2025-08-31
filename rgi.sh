#!/bin/bash
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --job-name="rgi"
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=short


source /mnt/shared/scratch/kkeegan/apps/miniconda3/etc/profile.d/conda.sh
conda activate /mnt/shared/scratch/kkeegan/apps/miniconda3/envs/rgi

export PATHDB=$PATHDB:/mnt/shared/scratch/kkeegan/personal/Databases/CARD/CARDdb

rgi main -i $1 -o $2  --low_quality    
