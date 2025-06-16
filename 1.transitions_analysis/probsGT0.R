probsGT0 <- function(param){
  #finds probs of parameter values > 0
  options(digits=3)
  m <- dim(param)
  N <- m[1] #size of the sample
  k <- m[2] #number of parameters
  
  prob <- vector()
  for(i in 1:k){
    p <-sum(param[,i]>0)/N
    prob <- c(prob,p)
    print(p)
  }
  return(prob)
}
