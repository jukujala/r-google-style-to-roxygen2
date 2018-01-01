# just run the main function from transform_comments.r with file given as argument

source("transform_comments.r")

args <- commandArgs(TRUE)
 if(length(args) < 1) {
  args <- c("--help")
}
# print help
if("--help" %in% args) {
  cat("
      Rscript run_gstyle_to_roxygen2.r input_file

      Transform input_file function documentation from Google R style to roxygen2 style.")
  
  q(save="no")
}

fn <- args[[1]]
if(!file.exists(fn)) {
  cat("Input file does not exist.")
  q(save="no")
}
lines <- readLines(fn)
x <- printTransformedLines(lines)
# you can debug with this:
#x <- capture.output(printTransformedLines(lines, add_export=TRUE))
