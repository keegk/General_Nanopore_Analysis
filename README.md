# Seal_MinION
The analysis of a grey seal sample that was run on MinION at MRI before I started my PhD, but has not been analysed in detail before (past WIMP)

**General overview**

The MinION run generated the following data:

Pass - 283 directories, each with 4000 fast5 files of sizes ranging from approx 20-40KB per fast5 file.

Skip - 36 directories, each with 4000 fast5 files of sizes ranging from approx 20-40KB per fast5 file, but some reaching 200KB in size.

Fail - 12 directories,  each with 4000 fast5 files (except for directory 12 which has less) of sizes ranging from approx 20-50KB per fast5 file


**Bash script for rebasecalling**

I have rebasecalled a handful of the the pass/skip/fail fast5 files using the bash script '*recursive.sh*' and setting the number of basecallers to 8 (--num_callers 8) when running this bash script on the command line on the gruffalo cluster. I have called the bash script 'recursive.sh' which incorporates the argument --recursive. This is because of the large number and hierachial layout of the fast5 files. For example, the main 'pass' directory has 283 subdirectories (1-283), with each of these subdirectories containing 4000 fast5 files. I can't run my recursive.sh bash script on all these files at once (I think). Instead, to rebasecall a manageable amount of fast5 files, I have grouped subdirectories into groups of 20 (e.g PASS (main directory) -> 1_20 (subdirectory)-> 1 (subdirectory),2(subdirectory),3(subdirectory)...20(subdirectory). Each of these 20 subdirectories contain ~ 4000 fast5 files. I have added the --recursive argument with the input path file being the 1_20 subdirectory, so that the guppybasecaller function will work recursively and rebasecall every fast5 file it finds under the 1_20 subdirectory (4,000 fast5 files x 20 subdirectories = ~ 80,000 fast5 files being rebasecalled). This bash script (with num_callers set to 8) typically takes 18-22 hours to run (a medium job on the gruffalo cluster).

*** UPDATE 06/12/2022 ****

With the addition of another bash script (*dircount.sh*) I can now rebasecall all fast5 files in one directory (from either the pass/skip/fail) in one go as this dircount.sh script searches a directory for all fast5 files (4000 per directory) then runs the recursive.sh on  each of the fast5 files, spawning 4000 jobs simultaneously on the cluster that each take a few seconds to complete (takes ~5 minutes to complete a single pass directory with 4000 fast5 files), instead of having to split my directories into 20 (as outline previously above) and wait a day to rebasecall this chunk and then repeat etc. The outputs for all the fast5 files all go to *one* output directory that assigns a * unique sequential number* to each output fast5 file so that they don't overwrite each other each time you rebasecall a directory.

I then merged the fastq files from the rebasecalled fast5's by using the script '*ifthencat.sh*' which searches within each of the fast5 output files for a fastq file and concatenates what it finds into a single merged fastq file. Run this not on the head node (as with dircount.sh) but as 'sbatch ifthencat.sh $1 $2'.

This dataset had duplicate reads and so to filter those out before doing a BLAST analysis, I use the package *SeqKit* which has many features associated with tidying up fast5 or fastq files, including removing duplicate files and keeping the first of the duplicate files only, which is what I am using it for. The code I used was first, setting up an interactive job using srsh command and then: **[kkeegan@n19-32-192-crossbones dummy_merged_fastqs]$ seqkit rmdup merged.fastq -s -o clean.fastq
[INFO] XXXX duplicated records removed**

*TO NOTE BEFORE BASECALLING:*

1) Back up your fast5 files before you rebasecall. The way the dircount.sh script works is that it empties the input directory (your 'raw'fast5 directories) as it sends them to recursive.sh for rebasecalling, so you need to have a back up directory of your fast5 files that remain untouched in case of a future need. Optional to do this for the fastq files generated after rebasecalling too, to preserve in case of directory/file corruption.

2) You wil likely need to give executable rights to .sh scripts if running for the first time, otherwise the bash scrip won't run. This is done by typing the code 'chmod a+rwx <filename>.sh' on the cluster, within the directory your .sh file is located

3) You may need to change the kit/flow cell name written in the recursive.sh file if you rebasecall new data using a new kit. 

4)  Make sure you run the dircount.sh script on the your scratch space rather than home space on the cluster, as fast5 files will get sent to where you run the dircount.sh script and then the second script (recursive.sh) acts on these files. The final output for the rebasecalled files should also go to a directory in your scratch space. Large amounts of files in your home space is not recommended on the cluster and it will be flagged with the cluster admin.

5) I often had to set the path to guppy before I ran it. The path for this is written in the recursive.sh file but if you run guppy without using this bash script, you will likely need to set the path for guppy, in my case the code for this is 'export PATH=/home/kkeegan/projects/jhi/bioss/kkeegan_onttestdata/ont-guppy-cpu/bin:$PATH'



**R notebooks**

There are several R notebooks in this repository:

1. Investigating_fast5.Rmd: The initial examination of a selection of fast5 files from the MinION run, prior to rebasecalling. I have taken one fast5 file from the first subdirectory in each of the pass, skip and fail directory (3 fast5 files in total). 

2. Summary_sequence_file_1_20pass.Rmd: This was a notebook to check whether my recursive.sh bash script is working correctly and reabsecalling all the fast5 files within subdirectories. I noticed on WINSCP that the number of pass fastq files generated from the rebasecalling matched the number of fast5 directories, but not the number of fast5 files. For example, when I rebasecalled the first 20 subdirectories (each containing ~4000 fast5 files) within the main PASS directory, I got 20 fastq files (instead of ~80,000 fastq files, if every fast5 file produced a corresponding fastq file). However, I thought that perhaps each fastq file had just concatenated all of the fast5 files into one fastq output. To check this, I looked at the summary_sequencing.txt file generated and checked the number of rows in the fastq file. The result was ~80,000 rows, so I think that all the fast5 files are contained within this one 'concatenated' fastq file. I also added some QC plots to further investigate the fastq files generated and based on these plots, the QC analysis looks similar to QC analysis on a previous rebasecalling project, Davids MinION data ('QC_rebasecalled' repository).

3. Merging_summary_sequencing_files.Rmd: Now that I am somewhat happy that the recursive.sh script seems to be rebasecalling properly, I now looked at the idea of merging the multiple summary sequnecing files that are going to be generated from my 'batch' rebasecalling set up. For example, when rebasecalling the pass folder, I should get ~ 14 separate summary sequencing files if I rebasecall 20 subdirectories at a time (283/20 = 14.1). For the skip directory, I should get ~2 summary sequencing files (36/20) and the fail should yield one summary sequencing file (12/20). The reason I want to merge the summary sequencing files is because I have been told that there may be duplicate fast5 files buried in/ across the pass/skip/fail main directories - the person who moved these files off the MinION computer copied or moved some files at the time (I'm not sure why). So, the idea is to merge the summary sequencing files into one (if one text file can handle that much data) and then write another bit of code, maybe using 'grep' or 'unique' to pull out duplicate reads and remove them before proceeding with further analysis. IGNORE THIS NOTEBOOK - I DIDNT USE THIS. I CONCATENATED FASTQ FILES USING concat.fastq to do this, as outlined below.

**Bash script for merging pass fastq files after rebasecalling**

Called concat.fastq, this script uses the find command to find all files ending in .fastq within a directory and then uses a for loop to pick out each of these fast q files which have the name <pass> in their pathname (as I do not want to include the failed fast q reads) and concatenates them all together into one very large single fastq file.

I then check for any duplicated reads that may be present and I also convert this fastq file to fasta for BLAST ANALYSIS not using a bash script but by running an interactive job on the cluster (srsh command to initiate interactive job) and for trimming, use the package SeqKit (conda install -c bioconda seqkit) and running seqkit rmdup concat.fastq -s -o clean.fastq. Note, it was suggested to remove duplicates by read ID rather than sequence, as sequences that are just similar to each other by chance may all be removed, possibly removing reads that shoudl have been kept. To test whether remove by read ID resulted in less sequences being removed, I reran this seqkit code with no additional arguments (default filter by read ID I believe, 'seqkit rmdup concat.fastq -o cleanbyID.fastq.') and then also with the additional argument -n which removes by entire name not just read ID 'seqkit rmdup concat.fastq -n -o cleanbyID2.fastq.' I also reran using the original code I used 'seqkit rmdup concat.fastq -s -o cleanbyID3.fastq.'. All of these gave the exact same file size (5,529,494 KB) and the exact same number of sequences removed (66666 duplicated records removed) so I am happy to keep with my original code and all subsequent data generated below using the clean.fastq file (seqkit rmdup concat.fastq -s -o clean.fastq). To convert this clean.fastq to clean.fasta, I simply use the package seqtk (conda install -c bioconda seqtk) and convert to fasta using 'seqtk seq -a clean.fastq > cleaned_fasta.fasta'. cleaned_fasta.fasta was approx 2.8Gb in size.

**Bash script for splitting fasta file into multiple fasta files for BLAST**

In order to run smoothly on the cluster (launching several small BLAST jobs rather than one extremely large BLAST search) I split my clean.fasta files into several hundred fasta files by using the script fasta_split.sh. However next time I run this I can split the original clean fasta file into fewer individual files as I had 200 individual files when I set the split to 10,000 lines which each only took 2-5 hours to BLAST on cluster (small job). So in future increase this split to 100,000 or so and run BLAST jobs set to medium partition on each fasta file.


**Bash script for BLAST analysis using NCBI nt database**

The blast script I used is called blast7.sh (the 7 just referes to the 7th version I tried that I liked and decided to go further with). I was playing around with the output with previous bas scripts and the number of max target seqs to choose. For blast7.sh I included in the tabular ouput the scientific name of organisms so they would be easy to deduce quickly. I also set max-target-seqs to 10 (previous practice runs we had set this to 5). I originally didnt want to set a limit on max-target-seqs but even with requesting Gb memorey up to 32Gb on cluster, the script would run out of memory and fail, so I settled on 10 (default I think is 5000). The only issue here is that max-target-seqs has been criticised in the past for only giving the first e value hits it finds in the database (rather than the best) so I am not sure if using max-taget-seqs is the best option, but I'm not yet sure how to get around this just now.

**Bash script for concatenating multiple blast.txt files into one and compressing this**

Once I had run all the small BLAST jobs ~200 times (I had about 200 individual fasta files from my fasta_split.sh script above) I then wanted to concatenate these all back into one large blast text file and also compress this for storage. To do this I wrote the script concat.blast.sh which uses a for loop to find any .txt files, concatenates them into one text file and the using pigz (as recommended by the cluster help page) to compress this file. Compressed blast text reulst file is still approx 25Gb in size. I can then use this in R to pick out most common species from seal samples etc. and further downstream analsysis.

**Location of files on cluster**

*Projects section (shared between Karen and Nick):*

**Backup of raw compressed data (fast5) straight off MinION:** /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_backup/fast5_untouched

**Basecalled, compressed data using fast accuracy Guppy v6.0.1:** /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/Basecalling_and_fastq/Rebasecalled_jan2023.tar.gz

**Post-basecalled data including raw fasta files, raw blast files, concatenated fasta and concatenated blast files**
1) The fatsa file that was used as input for the seal BLAST run is: /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/Dataset_post_basecalling/fasta_split/cleaned_fasta.fasta. It was first split into many files each containing 5,000 reads (/mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/Dataset_post_basecalling/fasta_split) and each fasta file was run through the blast7.sh script (BLAST database used is NCBI  database on cluster).
2) Blast text files produced from this are compressed and located here: /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/Dataset_post_basecalling/raw_blast_files
3) The final concatenated and compressed NCBI blast file, having removed any duplicate reads, is called concatenated_blast_third_run.txt.gz and is loacated here: /mnt/shared/projects/jhi/bioss/kkeegan_onttestdata/Seal_MinION_analysis/Dataset_post_basecalling/concatenated_compressed_third_run
   Note: The number of reads in concatenated_blast_third_run.txt.gz and cleaned_fasta.fasta (the input file used for BLAST script) are both 984,943 reads respectively. 

