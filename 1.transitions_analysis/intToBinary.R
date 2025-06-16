intToBinary <- function(n) {
  if (n == 0) return("0")
  
  bits <- rev(as.integer(intToBits(n)))
  start <- which(bits == 1)[1]
  paste0(bits[start:length(bits)], collapse = "")
}
