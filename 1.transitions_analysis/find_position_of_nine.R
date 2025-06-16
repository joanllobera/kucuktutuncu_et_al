find_position_of_nine <- function(row) {
  if (length(row) < 2) {
    return(NA) # Return NA if the row has only one element
  }
  
  # Ignore the first element
  row <- row[-1]
  
  # Find the position of the first occurrence of 9
  position <- which(row == 9)[1]
  
  if (is.na(position)) {
    return(NA) # Return NA if 9 is not found
  }
  
  # Return the position - 1, as we want to exclude the 9 itself
  return((position - 1)/2)
}