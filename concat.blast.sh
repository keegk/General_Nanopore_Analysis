#!/bin/bash
#SBATCH --mail-user=karen.keegan@moredun.ac.uk
#SBATCH --cpus-per-task=12
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=long

dir=$1
out=$2


blast=$(find $dir -type f -name "*.txt")

for i in $blast ;do
	xargs cat $i >> $out
done

pigz $out






