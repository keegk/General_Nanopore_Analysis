# Seal_MinION
The analysis of a grey seal sample that was run on MinION at MRI before I started my PhD, but has not been analysed in detail before (past WIMP)

**General overview**

The MinION run generated the following data:

Pass - 283 directories, each with 4000 fast5 files of sizes ranging from approx 20-40KB per fast5 file.

Skip - 36 directories, each with 4000 fast5 files of sizes ranging from approx 20-40KB per fast5 file, but some reaching 200KB in size.

Fail - 12 directories,  each with 4000 fast5 files (except for directory 12 which has less) of sizes ranging from approx 20-50KB per fast5 file


**Bash script for rebasecalling**

I have rebasecalled the pass/skip/fail fast5 files using the bash script '*recursive.sh*' and setting the number of basecallers to 8 (--num_callers 8) when running this bash script on the command line on the gruffalo cluster. I have called the bash script 'recursive.sh' which incorporates the argument --recursive. This is because of the large number and hierachial layout of the fast5 files. For example, the main 'pass' directory has 283 subdirectories (1-283), with each of these subdirectories containing 4000 fast5 files. I can't run my recursive.sh bash script on all these files at once (I think). Instead, to rebasecall a manageable amount of fast5 files, I have grouped subdirectories into groups of 20 (e.g PASS (main directory) -> 1_20 (subdirectory)-> 1 (subdirectory),2(subdirectory),3(subdirectory)...20(subdirectory). Each of these 20 subdirectories contain ~ 4000 fast5 files. I have added the --recursive argument with the input path file being the 1_20 subdirectory, so that the guppybasecaller function will work recursively and rebasecall every fast5 file it finds under the 1_20 subdirectory (4,000 fast5 files x 20 subdirectories = ~ 80,000 fast5 files being rebasecalled). This bash script (with num_callers set to 8) typically takes 18-22 hours to run (a medium job on the gruffalo cluster).

*** UPDATE 06/12/2022 ****

With the addition of another bash script (*dircount.sh*) I can now rebasecall all fast5 files in one directory (from either the pass/skip/fail) in one go as this dircount.sh script searches a directory for all fast5 files (4000 per directory) then runs the recursive.sh on  each of the fast5 files, spawning 4000 jobs simultaneously on the cluster that each take a few seconds to complete (takes ~5 minutes to complete a single pass directory with 4000 fast5 files), instead of having to split my directories into 20 (as outline previously above) and wait a day to rebasecall this chunk and then repeat etc. The outputs for all the fast5 files all go to *one* output directory that assigns a * unique sequential number* to each output fast5 file so that they don't overwrite each other each time you rebasecall a directory. 

I then merged the fastq files from the rebasecalled fast5's by using the script '*ifthencat.sh*' which searches within each of the fast5 output files for a fastq file and concatenates what it finds into a single merged fastq file.

This dataset had duplicate reads and so to filter those out before doing a BLAST analysis, I use the package *SeqKit* which has many features associated with tidying up fast5 or fastq files, including removing duplicate files and keeping the first of the duplicate files only, which is what I am using it for. The code I used was first, setting up an interactive job using srsh command and then: **[kkeegan@n19-32-192-crossbones dummy_merged_fastqs]$ seqkit rmdup merged.fastq -s -o clean.fastq
[INFO] XXXX duplicated records removed**

*TO NOTE BEFORE BASECALLING:*

1) Back up your fast5 files before you rebasecall. The way the dircount.sh script works is that it empties the input directory (your 'raw'fast5 directories) as it sends them to recursive.sh for rebasecalling, so you need to have a back up directory of your fast5 files that remain untouched in case of a future need. Optional to do this for the fastq files generated after rebasecalling too, to preserve in case of directory/file corruption.

2)You wil likely need to give executable rights to .sh scripts if running for the first time, otherwise the bash scrip won't run. This is done by typing the code 'chmod a+rwx <filename>.sh' on the cluster, within the directory your .sh file is located

3) You may need to change the kit/flow cell name written in the recursive.sh file if you rebasecall new data using a new kit. 

4) I often had to set the path to guppy before I ran it. The path for this is written in the recursive.sh file but if you run guppy without using this bash script, you will likely need to set the path for guppy, in my case the code for this is 'export PATH=/home/kkeegan/projects/jhi/bioss/kkeegan_onttestdata/ont-guppy-cpu/bin:$PATH'



**R notebooks**

There are several R notebooks in this repository:

1. Investigating_fast5.Rmd: The initial examination of a selection of fast5 files from the MinION run, prior to rebasecalling. I have taken one fast5 file from the first subdirectory in each of the pass, skip and fail directory (3 fast5 files in total). 

2. Summary_sequence_file_1_20pass.Rmd: This was a notebook to check whether my recursive.sh bash script is working correctly and reabsecalling all the fast5 files within subdirectories. I noticed on WINSCP that the number of pass fastq files generated from the rebasecalling matched the number of fast5 directories, but not the number of fast5 files. For example, when I rebasecalled the first 20 subdirectories (each containing ~4000 fast5 files) within the main PASS directory, I got 20 fastq files (instead of ~80,000 fastq files, if every fast5 file produced a corresponding fastq file). However, I thought that perhaps each fastq file had just concatenated all of the fast5 files into one fastq output. To check this, I looked at the summary_sequencing.txt file generated and checked the number of rows in the fastq file. The result was ~80,000 rows, so I think that all the fast5 files are contained within this one 'concatenated' fastq file. I also added some QC plots to further investigate the fastq files generated and based on these plots, the QC analysis looks similar to QC analysis on a previous rebasecalling project, Davids MinION data ('QC_rebasecalled' repository).

3. Merging_summary_sequencing_files.Rmd: Now that I am somewhat happy that the recursive.sh script seems to be rebasecalling properly, I now looked at the idea of merging the multiple summary sequnecing files that are going to be generated from my 'batch' rebasecalling set up. For example, when rebasecalling the pass folder, I should get ~ 14 separate summary sequencing files if I rebasecall 20 subdirectories at a time (283/20 = 14.1). For the skip directory, I should get ~2 summary sequencing files (36/20) and the fail should yield one summary sequencing file (12/20). The reason I want to merge the summary sequencing files is because I have been told that there may be duplicate fast5 files buried in/ across the pass/skip/fail main directories - the person who moved these files off the MinION computer copied or moved some files at the time (I'm not sure why). So, the idea is to merge the summary sequencing files into one (if one text file can handle that much data) and then write another bit of code, maybe using 'grep' or 'unique' to pull out duplicate reads and remove them before proceeding with further analysis.
                                             
