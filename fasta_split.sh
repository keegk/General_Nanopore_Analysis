#!/bin/bash

#SBATCH --job-name="fasta_split"

split -l 10000 --additional-suffix=.fasta $1
