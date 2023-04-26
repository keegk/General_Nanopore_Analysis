#!/bin/bash

#SBATCH --job-name="blast_SEAL"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --partition=short

source activate blast

export BLASTDB=$BLASTDB:/mnt/shared/apps/databases/ncbi/



blastn -query $1 -db nt -out $2 -num_threads 12 -max_target_seqs 10 -outfmt "7 sscinames qacc sacc pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids"  
