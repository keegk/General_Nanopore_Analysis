#!/usr/bin/env Rscript
script.version <- "1.3"
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
  args[5] = 100000
  args[6] = 2000
} else if (length(args)==2) {
  args[3] = 90
  args[4] = 1E-6
  args[5] = 100000
  args[6] = 2000
} else if (length(args)==3) {
  args[4] = 1E-6
  args[5] = 100000
  args[6] = 2000
} else if (length(args)==4) {
  args[5] = 100000
  args[6] = 2000
} else if (length(args)==5) {
  args[6] = 2000
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

filtersomething <- function(df, pc.id.thresh = 90, eval.thresh = 1E-6, #normal brackets
                            gap.thresh = 100000, mismatch.thresh = 2000){
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
						  gap.thresh = 100000, mismatch.thresh = 2000){
  
  #parsing the blast nt database version 7
to match the blast output 7 I used when blasting fasta files 
	#Read blast results line by line from a large concatenated file of hit from
  # multiple queries, filtering the top hits.
	#normal brackets = these are the arguments provided to the function
	#curly brackets = tells you how to operate on the arguments
	#we want to provide a connection (con) to a file
  
  pc.id.thresh <- as.numeric(pc.id.thresh)
  eval.thresh <- as.numeric(eval.thresh)
  gap.thresh <- as.numeric(gap.thresh)
  mismatch.thresh <- as.numeric(mismatch.thresh)
  
  #  print(pc.id.thresh)
  #  print(eval.thresh)
  #  print(gap.thresh)
  #  print(mismatch.thresh)

# define metadata variables:
  blast.ver = NA
  column.names <- c() # currently an empty vector as we dont know how many columns there are, its length is by default zero 
  n.hits <- NA
  out.hits <- NA
  nreads <- 0 # counter to count the total number of reads we parse.
  nread_hits <- 0 # counter to count the number of reads with BLAST hits.
  read_inc <- 0 # counter to count the number of reads we have parsed within a reporting block.
  current_read <- NA # the current read id
  
  inc_time <- Sys.time()
  # loop through the file reading a hit a line at the time looking for hits, while the length of a line is greater than zero, do:
	#readLines remembers where it is in a file, we can use that to our advantage
  while(length(aline <- readLines(con, n = 1)) >0 ){
    
    # record the blast version, but only do this once for the first read
	  #all the metadata lines in the concatenated file begin with a hash (#)
	  #so, if the file starts with # BLASTN, tell us the version, but only for the first read
    if(startsWith(aline, "# BLASTN") & is.na(blast.ver)){
      blast.ver <- strsplit(aline, split=" ")[[1]][3] #the first [[1]] tells you the string is made up of one thing and then the second value [[3]] tells you within this one line it has 3 elements/values
    }
    
    if(startsWith(aline, "# Query")){
      current_read <- strsplit(aline, split=" ")[[1]][3]
      
      # increment the counters
      read_inc <- read_inc + 1
      nreads <- nreads + 1
      
      # log the read name and which read we are on
      #print(sprintf("parsing read %i: %s", nreads, current_read))
      
      # log total reporting blocks and runtime
      if (read_inc==100){
        runtime <- Sys.time() - inc_time
        print(sprintf("Parsed %i reads in %.2f %s.",
                      read_inc, runtime,
                      attr(runtime, "units")))
        inc_time <- Sys.time()
        read_inc <- 0
      }
    }
    
    # get the column names for the blast output.
    # assumes BLAST output table format.
    if(startsWith(aline, "# Fields") & length(column.names)==0){ #the length statement here is just syaing, if column.names is zero (which we have stated it is in the metadata section as we didn't know how many columns we would have), then run:
      line <- strsplit(aline, split=": ")[[1]][2] #this is taking the second component of "Fields" which has all your column headers (query acc, subject ID etc, basically all the fields from the blast ouput)
      line <- str_replace_all(line, " ", ".") #replace spaces in the field elements (query.acc etc) with a dot
      line <- str_replace_all(line, "\\.\\.", ".") #the \\ is used to "escape" the dots (i.e treat them as literal dots, as . can mean all special characters, but we specifically want to act on . (in this case replace .. with .) so we have to say specifically to act on .
      line <- str_replace_all(line, "\\.,\\.", ",.") #replace .,. with .
      line <- str_replace_all(line, "%", "percent") #replace the sign % with the word percent
      column.names <- strsplit(line, ",.")[[1]] #replace ,. with the first element of the list 
	  write.table(t(data.frame(column.names)), file = outname, sep = ",",
				  col.names = FALSE, row.names = FALSE)
    }
    
    # get the number of matching hits for this read, read them,
    # filter them, and write out the results
    line.match <- str_match(aline, "# ([0-9]+) hits found") #if it starts with a hash and any number between 0-9 but could be more than one number so we put + after the 0-9 (output a number between 0-9 and there might be nmore than one of them) then do:
    if (!is.na(line.match[1][1])){ 
      n.hits <- as.integer(line.match[1,2])
      if (n.hits > 0) {
        nread_hits <- nread_hits+1
        
        # read the BLAST hits
        hit.lines <- readLines(con, n = n.hits)
        hit.lines <- as.data.frame(t(data.frame(strsplit(hit.lines, split="\t"))))
        hit.lines <- data.frame(hit.lines, row.names=NULL)
        
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
        # lets just try writing the hits out to the file when we
        # process them...
        if (nreads==1){
          write.table(hit.lines, file = outname, sep = ",",
                      row.names = FALSE, append = TRUE,
                      col.names = FALSE)
        } else {
          write.table(hit.lines, file = outname, sep = ",",
                      row.names = FALSE, append = TRUE,
                      col.names = FALSE)
        }
      }
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
