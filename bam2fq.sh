#!/bin/bash

#SBATCH --job-name="bar1_bam2fq"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=short



source /mnt/apps/users/kkeegan/conda/etc/profile.d/conda.sh

conda activate /mnt/apps/users/kkeegan/conda/envs/samtools


samtools bam2fq $1 | gzip > $2
