#!/bin/bash

#SBATCH --job-name="seq_sum_dorado"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=medium

export PATH=/mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/dorado_0.7.2/dorado-0.7.2-linux-x64/bin:$PATH

dorado summary $1 > $2

