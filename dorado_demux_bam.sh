#!/bin/bash

#SBATCH --job-name="demux_dorado"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=medium

export PATH=/mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/dorado_0.7.2/dorado-0.7.2-linux-x64/bin:$PATH

dorado demux --output-dir $1 --no-classify $2

