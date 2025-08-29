# General_Nanopore_Analysis

Outlined below are the steps and scripts in the Nanopore shotgun metagenomic pipeline ("The Nanopore pipelin"):

1) Basecalling. See individual results chapter repositories for the different basecalling modular scripts used for each. The outputs of basecalling scripts convert raw FAST5/POD5 Nanopore files into FASTQ files.
2) Concatenating and compressing FASTQ files generated from basecalling
      -compressing_passed_fastq.sh (searches within each of the FAST5/POD5 directories for FASTQ files and concatentates these into a single FASTQ file)
3) Tidying the FASTQ files
      -tool SeqKit is used to remove duplicate reads and then Seqtk is used to convert these tidied FASTQ files into fasta files for BLASTn analysis. Note there are no bash scripts for these tools, they can be used on an interactive job on the HPC. fOR SeqKit: 'seqkit rmdup concat.fastq -s -o clean.fastq'. For Seqtk:'seqkit rmdup concat.fastq -n -o cleanbyID2.fastq.'
 4) READ QC
      - Using a custom R script (read_QC_in_R.Rmd)
      - Nanoplot with Guppy data: Nanoplot_guppy.sh; Nanoplot with Dorado data: dorado_bam_seq_sum.sh and Nanoplot.sh
5) Taxa identification
   
 Both scripts below set the same BLASTn parameters and output the same information in text files, the only difference is one uses single FASTA files as input and the second takes advantage of "array" jobs on a HPC, which allows users to input and process multiple files (in this case FASTA) within a single script:

      -BLAST_ncbi_out7.sh (single fasta files as input)
      -BLAST_ncbi_out7_array.sh (array job that can take multiple fasta files at once)


Filtering of taxonomic hits in BLASTn scripts:
1.	Maximum target hits = 10
2.	Percent identity > 90
3.	E-value ≤ 1 x 10-12

BLASTn text outputs:


Variable name	Definition
sscinames	Scientific name (the scientific name of the subject the query has aligned to)
qacc	The query (read) NCBI accession number
sacc	The subject (read) NCBI accession number
pident	Percent identity of the alignment
length	Length of the alignment
mismatch	The number of mismatches in the alignment
gaps	The number of gaps in the alignment (inclusive of gap openings)
gapopen	The number of gap openings in the alignment
slen	The length of the subject read,
qlen	The length of the query read (before alignment)
qstart	The start location of the alignment on the query read
qend	The end location of the alignment on the query read
sstart	The start location of the alignment on the subject read
send	The end location of the alignment on the subject read
evalue	E-value
bitscore	Bitscore
staxids	Subject taxonomic ID


      
