#!/bin/bash

#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=short

source /mnt/shared/scratch/kkeegan/apps/miniconda3/etc/profile.d/conda.sh

conda activate /mnt/shared/scratch/kkeegan/apps/miniconda3/envs/read_QC

NanoPlot -t 4 --summary $1 -o $2

