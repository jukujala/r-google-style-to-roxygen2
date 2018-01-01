
# R Google style to roxygen2 style

[roxygen2](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html)
makes it easy to generate documentation for 
[R packages](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/).
Code in this repo just transforms function documentation part of 
[Google R style](https://google.github.io/styleguide/Rguide.xml)
to roxygen2 format.

## Example input/output

Input:

    # Add together two numbers
    #
    # Args:
    #.  x: A number
    #.  y: A number
    #
    # Returns:
    #.  The sum of x and y

Output:

    #' Add together two numbers
    #' @export
    #'
    #' @param x: A number
    #' @param y: A number
    #'
    #' @return The sum of x and y

## Usage

    git clone https://github.com/jukujala/r-google-style-to-roxygen2.git
    cd r-google-style-to-roxygen2/
    Rscript run_run_transform_comments.r my_file.r
    # prints to stdout

## Feedback

Feel free to report bugs to my email given at github page.
Tell also if there is a better way to do the transformation, the current state
machine logic feels too complicated.

## Status of this software

This is just something I quickly wrote, so do not expect it to work well ;)
