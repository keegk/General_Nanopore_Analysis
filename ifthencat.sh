#!/bin/bash

dir=$1
out=$2
pass_list=()

fastq=$(find $dir -type f -name "*.fastq")

for i in $fastq ;do
if [[ $i == *"/pass/"* ]]; then
pass_list+=$i
pass_list+=" "
fi
done
gzip -c $pass_list > $2.gz

#echo ${pass_list}