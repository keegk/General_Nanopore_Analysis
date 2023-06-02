
con <- gzfile("concatenated_blast.txt.gz", open = "r") # con here is 'connection', as stated in the readLines usage above. Set up the connection (the blast file) here using gzip and open = 'r' (open for reading in text mode). gzfile opens connections to things like compressed files or URLS ('generalized files')
line1 <- readLines(con, n = 5) #n = 5 means the number of lines to read in at a time (set to 5 here)
line1


library(stringr)
#install.packages("dplyr")
library(dplyr) #needed for filter option?

filtersomething <- function(df, pc.id.thresh = 90, eval.thresh = 1E-6){
  
  newdf <- df %>%
    filter(percent.identity > pc.id.thresh) %>%
    filter(evalue < eval.thresh)
  
  return(newdf)
}

parseBlastNT7 <- function(con, pc.id.thresh = 90, eval.thresh = 1E-6){
  
  # Read blast results line by line from a large concatenated file of hit from
  # multiple queries, filtering the top hits.
  
  blast.ver = NA
  column.names <- c()
  n.hits <- NA
  out.hits <- NA
  
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
      hit.lines <- readLines(con, n = n.hits)
      hit.lines <- as.data.frame(t(data.frame(strsplit(hit.lines, split="\t"))))
      hit.lines <- data.frame(hit.lines, row.names=NULL)
      hit.lines[,4:13] <- sapply(hit.lines[,4:13], as.numeric)
      colnames(hit.lines) <- column.names
      
      # put filtering function in here - make sure it returns a dataframe
      hit.lines <- filtersomething(hit.lines,
                                   pc.id.thresh == "pc.id.thresh",
                                   eval.thresh == "eval.thresh")

      
      if(!is.data.frame(out.hits)){
        out.hits <- hit.lines
      } else {
        out.hits <- rbind(out.hits, hit.lines)
      }
    }
    
  }
  
  return(list("blast.version" = blast.ver,
              "format.column.names" = column.names,
              "filtered.hits" = out.hits))
}

con <- gzfile("concatenated_blast.txt.gz", open="r")
testver <- parseBlastNT7(con)
