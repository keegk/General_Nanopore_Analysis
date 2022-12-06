#!/bin/bash
dir=$1
out=$2



fast5=$(find $dir -type f -name "*.fast5")
dircount=1
while [ -d "$out/fast5_$dircount/" ]
do
echo $out/fast5_$dircount
let dircount+=1
done
echo $dircount

for i in $fast5
do
echo $i
echo $out/fast5_$dircount

mkdir fast5_$dircount
mv $i fast5_$dircount/
  sbatch recursive.sh $PWD/fast5_$dircount/ $out/fast5_$dircount/
  let dircount+=1
done