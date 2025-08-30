#!/bin/bash
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL

out=$1
db=$2

makeblastdb -in $1 -out $2 -dbtype nucl -parse_seqids


