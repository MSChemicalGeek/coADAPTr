#' Select the Output Directory for the Data (Step2)
#'
#' @param file_output The file path to save the output
#' @return The path to the folder where the output will be saved.
#' @export
#'
#' @examples output_folder()
#' @aliases output_folder
output_folder <- function() {
  cat("Please select the folder you would like your data/results to be stored in: \n")
  file_output <- choose.dir()
  return(file_output)
}
