#!/bin/bash

#SBATCH --job-name="bar24_gm3_array"
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --partition=medium
#SBATCH --array=0-294

source /mnt/apps/users/kkeegan/conda/etc/profile.d/conda.sh
conda activate /mnt/apps/users/kkeegan/conda/envs/blast

export BLASTDB=/mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/blastdbs_2023-08-15/

cd $1
FILES=(*.fasta)
OUTDIR=$2
blastn -query ${FILES[$SLURM_ARRAY_TASK_ID]} -db nt -out $2__$SLURM_JOB_ID.$SLURM_ARRAY_TASK_ID.txt -num_threads 12 -max_target_seqs 10 -outfmt "7 sscinames qacc sacc pident length mismatch gapopen gaps slen qlen qstart qend sstart send evalue staxids bitscore"
