
# transform Google R style formatted function documentations to roxygen2 style format

# below is example output in roxygen2 format

#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}

# below is example input in Google R style format

# Add together two numbers
#
# Args:
#.  x: A number
#.  y: A number
#
# Returns:
#.  The sum of x and y

catnl <- function(line) {
  # cat for input+newline
  cat(paste(line, "\n", sep=""))
}

lineEmpty <- function(line) {
  # return TRUE if line is empty after trimming
  #
  # Args:
  #.  line: string
  #
  # Returns:
  #   TRUE if line is empty
  if(trimws(line, which = "left")=="") {TRUE} else {FALSE}
}

lineStartsWith <- function(line, char) {
    # return TRUE if line starts with char
    #
    # Args:
    #.  line: string
    #.  char: single character
    #
    # Returns:
    #   TRUE if line begins with char after trimming
    stopifnot(nchar(char) == 1)
    line <- trimws(line, which="left")
    if(substr(line, 1, 1) == char) {TRUE} else {FALSE} 
}

printLines <- function(lines) {
  # print all lines in input
  #
  # Args:
  #.  lines: list of strings
  #
  # Returns:
  #.  TRUE
  lapply(lines, catnl)
  return(TRUE)
}

roxygenesis <- function(line, add=NULL) {
  # Transform eg "# foo" to "#' foo"
  #
  # Etymology:
  #.  This is a genesis for function documentation.
  #
  # Args:
  #.  line: function document line, begins with # always
  #.  add: add this part after "#' "
  #
  # Returns:
  #   transform to roxygen style
  line <- trimws(line, which="left")
  stopifnot(substr(line, 1, 1)=="#")
  line_start <- "#' "
  if(!is.null(add)) {
    line_start <- paste0("#' ", add, " ")
  }
  gsub("^#[#][[:blank:]]*", line_start, line)
}

labelFunDocLine <- function(line) {
  # give label such as "args" to a line
  #
  # Args:
  #.  line: new line
  #
  # Returns:
  #.  label in set (args, arg_name, returns, other)

  # remove white spaces from the start of line
  line <- trimws(line, which="left")
  has_args <- grepl("^[#]*[[:blank:]]*Args:[[:blank:]]*", line)
  has_returns <- grepl("^[#]*[[:blank:]]*Returns:[[:blank:]]*", line)
  # support only function arguments up to 50 characters
  has_argument_name <- (
    grepl("^[#]*[[:blank:]]*(\\w|\\.){1,50}:[[:blank:]]*", line)
  )
  if(has_returns) {
    return("returns")
  }
  if(has_args) {
    return("args")
  }
  if(has_argument_name) {
    return("arg_name")
  }
  return("other")
}

labelAllFunDocLines <- function(fun_doc) {
  # label each line in function documentation
  #
  # Logic:
  #.  1) Give label (args, arg_name, returns, other) to each line independently
  #.  2) Relabel line after returns to return_body
  #
  # Returns:
  #.  label for each line from set (other, args, arg_name, returns, return_body)
  labels <- lapply(fun_doc, labelFunDocLine)
  stopifnot(length(labels) == length(fun_doc))
  # mark the line after returns
  suppressWarnings(
    return_index <- min(which(labels == "returns"))
  )
  if(length(return_index) >= 1 && length(labels) >= return_index +1 ) {
    labels[[return_index + 1]] <- "return_body"
  }
  return(labels)
}

transformFunDocLine <- function(line, label) {
  # Transform function document line
  #
  # Args:
  #.  line: function document line
  #.  label: one of (other, args, arg_name, returns, return_body)

  # remove "Args:" and "Returns:" lines
  out <- NULL
  if(label == "other") {
    out <- roxygenesis(line)
  }
  if(label == "arg_name") {
    out <- roxygenesis(line, add = "@param")
  }
  if(label == "return_body") {
    out <- roxygenesis(line, add = "@return")
  }
  return(out)
}

transformFunDoc <- function(fun_doc, add_export=FALSE) {
  # Transform Google style R function document to roxygen2 style.
  # See above for examples.
  #
  # Args:
  #.  fun_doc: list of function document lines
  #.  add_export: if TRUE then add @export
  #
  # Returns:
  #.  List of transformed function document lines.

  # label all lines
  labels <- labelAllFunDocLines(fun_doc)
  transformed_fun_doc <- mapply(transformFunDocLine, fun_doc, labels)
  transformed_fun_doc <- unlist(transformed_fun_doc)
  if(add_export & length(transformed_fun_doc) > 0) {
    transformed_fun_doc <- append(transformed_fun_doc, "#' @export", 1)
  }
  return(transformed_fun_doc)
}

printTransformedLines <- function(lines, add_export=FALSE) {
  # transform lines to roxygen2 document format and print them
  #
  # Args:
  #.  lines: vector of code string lines
  #.  add_export: if TRUE then add @export to each function document

  # Logic:
  # step A: print lines until "function" keyword is found
  # step B: store (to S1) lines until "{" character is found
  # step C: if first -non-empty line starts with # then go to D, otherwise print
  #   the stored S1 lines and go to A
  # step D: store (to S2) function document lines until line does not begin with #
  # step E: transform function document lines lines at S2, print S1, and go to A

  store_fun_def <- list()
  store_fun_doc <- list()

  state <- "find function"
  for (i in 1:length(lines)) {
    line <- lines[[i]]
    if(state == "find function") {
      # print lines until "function" keyword is found
      if(grepl("function", line)) {
        state <- "find {"
      } else {
         catnl(line)
      }
    }
    if(state == "find {") {
      #store lines until { is found and function body starts
      store_fun_def <- c(store_fun_def, line)
      if(grepl("\\{", line)) {
        state <- "find #"
      }
    } else if(state == "find #") {
      # find start of function documentation
      if(lineEmpty(line)) {
        # if line is empty, just store it
        store_fun_def <- c(store_fun_def, line)
      } else if(lineStartsWith(line, "#")) {
        # else if line starts with # then start storing the documentation
        state <- "store function documentation"
      } else {
        # no function documentation found, just print what we have found so far
        printLines(store_fun_def)
        store_fun_def <- list()
        state <- "find function"
      }    
    }
    if(state == "store function documentation") {
      if(lineStartsWith(line, "#")) {
        # store function documentation starting with #
        store_fun_doc <- c(store_fun_doc, line)
      } else {
        # function documentation has ended, print transformed documentation and
        # continue
        transformed_fun_doc <- transformFunDoc(store_fun_doc, add_export)
        printLines(transformed_fun_doc)
        store_fun_doc <- list()
        printLines(store_fun_def)
        store_fun_def <- list()
        catnl(line)
        state <- "find function"
      }
    }
  }
  # print any remaining stored lines as such
  printLines(store_fun_def)
  printLines(store_fun_doc)
  return(TRUE)
}
