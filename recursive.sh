#!/bin/bash

#SBATCH --job-name="rebasecalling_fast5_files"
#SBATCH --cpus-per-task=12
export PATH=/home/kkeegan/projects/jhi/bioss/kkeegan_onttestdata/ont-guppy-cpu/bin:$PATH


guppy_basecaller --recursive --flowcell FLO-MIN106  --kit SQK-LSK109


guppy_basecaller --input_path $1 --save_path $2 --recursive --flowcell FLO-MIN106  --kit SQK-LSK109

