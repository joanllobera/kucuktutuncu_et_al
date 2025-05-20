# n is the integer number
# position is the bit position you want to check (0-indexed, i.e., rightmost bit is 0)
check_bit <- function(n, position) {
  return(bitwAnd(n, 2**(5-position))>0)
}
