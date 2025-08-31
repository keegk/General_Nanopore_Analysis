#!/bin/bash

#SBATCH --job-name="GOUGH_BLASTN_CARD"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=medium

source activate /mnt/apps/users/kkeegan/conda/envs/blast

export BLASTDB=$BLASTDB:/mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/blast_databases/CARD/CARD_db_prot/


blastx -query $1 -db CARD_db_prot -out $2 -num_threads 12 -outfmt "7 sscinames qacc sacc pident qcovs qcovhsp length mismatch gapopen gaps slen qlen qstart qend sstart send evalue staxids bitscore"  
