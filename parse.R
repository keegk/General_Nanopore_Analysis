#!/usr/bin/env Rscript
script.version <- "1.0"
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
  
  newdf <- df %>%
    filter(percent.identity > pc.id.thresh) %>%
    filter(evalue < eval.thresh) %>%
	filter(gap.opens <= gap.thresh) %>%
	filter(mismatches <= mismatch.thresh)
	
  return(newdf)
}

parseBlastNT7 <- function(con, pc.id.thresh = 90, eval.thresh = 1E-6,
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
  
  while(length(aline <- readLines(con, n = 1)) >0 ){
    
    if(startsWith(aline, "# BLASTN") & is.na(blast.ver)){
      blast.ver <- strsplit(aline, split=" ")[[1]][3]
    }
    
    if(startsWith(aline, "# Fields") & length(column.names)==0){
      line <- strsplit(aline, split=": ")[[1]][2]
      line <- str_replace_all(line, " ", ".")
      line <- str_replace_all(line, "\\.\\.", ".")
      line <- str_replace_all(line, "\\.,\\.", ",.")
      line <- str_replace_all(line, "%", "percent")
      column.names <- strsplit(line, ",.")[[1]]
    }
    
    line.match <- str_match(aline, "# ([0-9]+) hits found")
    if (!is.na(line.match[1][1])){
      n.hits <- as.integer(line.match[1,2])
      if (n.hits > 0) {
		  hit.lines <- readLines(con, n = n.hits)
		  hit.lines <- as.data.frame(t(data.frame(strsplit(hit.lines, split="\t"))))
		  hit.lines <- data.frame(hit.lines, row.names=NULL)
		  
		  # logging the read names
		  print(sprintf("parsing read: %s", hit.lines[1,2]))
		  nreads <- nreads + 1 # counter to count the numer of reads we parse.
		  
		  hit.lines[,4:13] <- sapply(hit.lines[,4:13], as.numeric)
		  colnames(hit.lines) <- column.names
		  
		  # put filtering function in here - make sure it returns a dataframe
		  hit.lines <- filtersomething(hit.lines,
									   pc.id.thresh = pc.id.thresh,
									   eval.thresh = eval.thresh)

		  
		  if(!is.data.frame(out.hits)){
			out.hits <- hit.lines
		  } else {
			out.hits <- rbind(out.hits, hit.lines)
		  }
	  }
    }
    
  }
  
  return(list("blast.version" = blast.ver,
              "format.column.names" = column.names,
              "filtered.hits" = out.hits,
			  "nreads" = nreads))
}

con <- gzfile(args[1], open="r")
testver <- parseBlastNT7(con, pc.id.thresh = args[3], eval.thresh = args[4], gap.thresh = args[5], mismatch.thresh = args[6])
write.csv(testver$filtered.hits, args[2], row.names=FALSE)
print(sprintf("Finished sucessfully. Parsed %i reads.", testver$nreads))


