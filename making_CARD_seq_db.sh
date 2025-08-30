#!/bin/bash
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --mail-type=END,FAIL
out=$2
db=$3

find $1 -type f -name 'nucleotide*' -exec cat {} + >> $2

makeblastdb -in $2 -out $3 -dbtype nucl 


