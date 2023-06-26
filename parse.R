#!/usr/bin/env Rscript
script.version <- "1.1"
start_time <- Sys.time()
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
	stop("At least one argument must be supplied (input blast file)", call.=FALSE)
	# set defaults below
} else if (length(args)==1) {
	args[2] = "out.txt"
	args[3] = 90
	args[4] = 1E-6
	args[5] = 5
	args[6] = 200
} else if (length(args)==2) {
	args[3] = 90
	args[4] = 1E-6
	args[5] = 5
	args[6] = 200
} else if (length(args)==3) {
	args[4] = 1E-6
	args[5] = 5
	args[6] = 200
} else if (length(args)==4) {
	args[5] = 5
	args[6] = 200
} else if (length(args)==5) {
	args[6] = 200
}

print(sprintf("Script: parse.R (%s)", script.version))
print(sprintf("Filtering file: %s", args[1]))
print(sprintf("Identidy threshold: %s", args[3]))
print(sprintf("E-value threshold: %s", args[4]))
print(sprintf("Maximum gap number threshold: %s", args[5]))
print(sprintf("Maximum mismatch number threshold: %s", args[6]))
print(sprintf("Writing filtered output to file: %s", args[2]))

library(stringr)
library(dplyr) #needed for filter option?

filtersomething <- function(df, pc.id.thresh = 90, eval.thresh = 1E-6,
gap.thresh = 5, mismatch.thresh = 200){
	# Filter the blast hit table for percentage identity,
	# evalue below a threshold, gaps below a threshold,
	# and mismatches below a threhold.
	
	newdf <- df %>%
	filter(percent.identity > pc.id.thresh) %>%
	filter(evalue < eval.thresh) %>%
	filter(gap.opens <= gap.thresh) %>%
	filter(mismatches <= mismatch.thresh)
	return(newdf)
}

parseBlastNT7 <- function(con, outname, pc.id.thresh = 90, eval.thresh = 1E-6,
gap.thresh = 5, mismatch.thresh = 200){
	
	# Read blast results line by line from a large concatenated file of hit from
	# multiple queries, filtering the top hits.

	pc.id.thresh <- as.numeric(pc.id.thresh)
	eval.thresh <- as.numeric(eval.thresh)
	gap.thresh <- as.numeric(gap.thresh)
	mismatch.thresh <- as.numeric(mismatch.thresh)

	#  print(pc.id.thresh)
	#  print(eval.thresh)
	#  print(gap.thresh)
	#  print(mismatch.thresh)

	blast.ver = NA
	column.names <- c()
	n.hits <- NA
	out.hits <- NA
	nreads <- 0
	nread_hits <- 0
	read_inc <- 0
	
	inc_time <- Sys.time()
	# loop through the file reading a hit a line at the time looing for hits
	while(length(aline <- readLines(con, n = 1)) >0 ){
		
		# record the blast version, but only do this once for the first read
		if(startsWith(aline, "# BLASTN") & is.na(blast.ver)){
			blast.ver <- strsplit(aline, split=" ")[[1]][3]
		}
		
		# get the column names for the blast output.
		# assumes BLAST output table format.
		if(startsWith(aline, "# Fields") & length(column.names)==0){
			line <- strsplit(aline, split=": ")[[1]][2]
			line <- str_replace_all(line, " ", ".")
			line <- str_replace_all(line, "\\.\\.", ".")
			line <- str_replace_all(line, "\\.,\\.", ",.")
			line <- str_replace_all(line, "%", "percent")
			column.names <- strsplit(line, ",.")[[1]]
		}
		
		# get the number of matching hits for this read, read them,
		# filter them, and write out the results
		line.match <- str_match(aline, "# ([0-9]+) hits found")
		read_inc <- read_inc+1
		if (!is.na(line.match[1][1])){
			n.hits <- as.integer(line.match[1,2])
			if (n.hits > 0) {
				nread_hits <- nread_hits+1
				
				# read the BLAST hits
				hit.lines <- readLines(con, n = n.hits)
				hit.lines <- as.data.frame(t(data.frame(strsplit(hit.lines, split="\t"))))
				hit.lines <- data.frame(hit.lines, row.names=NULL)

				# log the read name and which read we are on
				#print(sprintf("parsing read %i: %s", nreads, hit.lines[1,2]))
				
				# ensure appropriate columns are numeric and that the
				# column names are correct
				hit.lines[,4:13] <- sapply(hit.lines[,4:13], as.numeric)
				colnames(hit.lines) <- column.names

				# filter the data. assumes a dataframe is returned
				hit.lines <- filtersomething(hit.lines,
											 pc.id.thresh = pc.id.thresh,
											 eval.thresh = eval.thresh)

				# concerned that for large file there are too many rows in
				# the output table to keep the table in memory in R. instead
				# lets just try writing the fits out to the file when we
				# process them...
				if (nreads==1){
				write.table(hit.lines, file = outname, sep = ",", 
							row.names = FALSE)
				} else {
				write.table(hit.lines, file = outname, sep = ",",
							row.names = FALSE, append = TRUE,
							col.names = FALSE)
				}
			}
		}
		nreads <- nreads + 1 # counter to count the number of reads we parse.
		if (read_inc==10000){
			runtime <- Sys.time() - inc_time
			print(sprintf("Parsed %i reads in %.2f %s.",
						  read_inc, runtime,
						  attr(runtime, "units")))
			inc_time <- Sys.time()
			read_inc <- 0
		}
	}

	return(list("blast.version" = blast.ver,
	"format.column.names" = column.names,
	"nreads" = nreads,
	"nread_hits" = nread_hits))
}

con <- gzfile(args[1], open="r")
testver <- parseBlastNT7(con, args[2], pc.id.thresh = args[3], eval.thresh = args[4], gap.thresh = args[5], mismatch.thresh = args[6])
#write.csv(testver$filtered.hits, args[2], row.names=FALSE)
runtime <- Sys.time() - start_time
print("Finished sucessfully.")
print(sprintf("Parsed %i reads in %.2f %s.",
			  testver$nreads, runtime,
			  attr(runtime, "units")))
print(sprintf("%i reads have BLASTN hits.",
			  testver$nread_hits))
