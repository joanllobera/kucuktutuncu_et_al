extract_until_minus1 <- function(row) {
  return(row[seq_len(which(row == -1)[1] - 1)])
}