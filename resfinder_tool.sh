#!/bin/bash

#SBATCH --job-name ="resfinder_tool_kma"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=medium
#SBATCH --mem=8G


python3.12 /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/blast_databases/resfinder_tool/resfinder/src/resfinder/run_resfinder.py --nanopore  --inputfasta $1 -k $2  -db_res $3 -o $4 -s "Other" -l 0.6 -t 0.8 --acquired
