#!/bin/bash

#SBATCH --job-name="bar_1"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=4
#SBATCH --mem=12G
#SBATCH --partition=long

source /mnt/apps/users/kkeegan/conda/etc/profile.d/conda.sh
conda activate /mnt/apps/users/kkeegan/conda/envs/blast


export BLASTDB=/mnt/shared/datasets/databases/ncbi/


blastn -query $1 -db nt -out $2 -num_threads 12 -max_target_seqs 10 -outfmt "7 sscinames qacc sacc pident length mismatch gapopen gaps slen qlen qstart qend sstart send evalue staxids bitscore"  
