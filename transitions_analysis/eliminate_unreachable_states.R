eliminate_unreachable_states <- function(P) {
  # Find rows with all zeros (no transitions from these states)
  no_outgoing <- apply(P, 1, function(row) all(row == 0))
  
  # Find columns with all zeros (no transitions to these states)
  no_incoming <- apply(P, 2, function(col) all(col == 0))
  
  # Identify states to be eliminated
  to_eliminate <- no_outgoing & no_incoming
  
  # Eliminate states with no incoming or outgoing transitions
  P_new <- P[!to_eliminate, !to_eliminate]
  
  ind <- seq(1,32,1) #in order to idenfity the states to be eliminated
  
  # Return the modified transition matrix
  return(list(P_new = P_new, to_eliminate = ind[to_eliminate]))
}

