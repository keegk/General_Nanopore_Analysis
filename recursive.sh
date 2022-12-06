#!/bin/bash

#SBATCH --job-name="rebasecalling_fast5_files"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=12
echo "Input path is $1"
echo "Save path is $2"



guppy_basecaller --input_path $1 --save_path $2 --recursive --flowcell FLO-MIN106  --kit SQK-LSK109
