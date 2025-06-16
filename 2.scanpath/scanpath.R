list.files(path = ".")
pq <- read.csv("./presence_questionnaire.csv", comment.char="#")
list.files("./data")

child_dirs <- list.files("./data")
child_dirs

child_dir = child_dirs[4]
f <- list.files(paste0("./data/",child_dir))
file_path <- f[grep("\\.csv$", f)]
g <- paste0(getwd(),"/data/",child_dir,"/",file_path)

g

getwd()

file.exists(g)


getAllEntropies <- function(ntime,nstates){
  #this computes an array of entropies for each individual
  #ntime is the number of time divisions, noting that the sampling
  #rate for eye tracking is 50Hz
  #nstates is the number of divisions of the x-target into segments
  #covering the 360 degrees in front of the participant
  
  
  # List all child directories within the parent directory
  child_dirs <- list.files("./data")
  #the rows are the participants and the columms the successive entropies
  allEntropy <- matrix(0,nrow=length(child_dirs),ncol=ntime)
  
  s <- seq(-pi,0,pi/nstates) #this divides the space in front (the x axis)
  s <- cos(s) #the x-coordinate
  ind <- 1 #which individual
  
  timelastchange <- vector() #time of last change of configuration
  #this stores the index into the segmented time period for the last change
  indexlastchange <- vector()
  
  # Loop over each child directory
  for (child_dir in child_dirs) {
    cat(ind," ",child_dir,"\n")
    
    # Change the working directory to the child directory
    #setwd(child_dir)
    
    # Find the file path
    #f <- list.files()
    #f <- list.files(paste0("/kaggle/input/scanpath-data/",child_dir))
    f <- list.files(paste0(getwd(),"/data/",child_dir))
    file_path <- f[grep("\\.csv$", f)]
    
    # Check if the file exists in the child directory
    #g <- paste0("/kaggle/input/scanpath-data/",child_dir,"/",file_path)
    g <- paste0(getwd(),"/data/",child_dir,"/",file_path)
    if (file.exists(g)) {
      
      # Read the file 
      d <- read.csv(g) 
      x <- d$EyeTrackingTarget_X 
      m <- length(x)
      t <- round(seq(1,m,(m/ntime)))
      t[length(t)+1] <- m
      #intervals are t[i]:t[i+1], i=1,...,nseg-1
      for(j in 1:(length(t)-1)){
        allEntropy[ind,j] <- entropy(s,x[t[j]:t[j+1]])
      }
      
      lastchange <- lastChange(d)
      #actual time of the last change
      timelastchange[ind] <- d$Seconds[lastchange]- d$Seconds[1]
      #indexlastchange[ind] <- findInterval(timelastchange[ind],t) + 1
      indexlastchange[ind] <- findInterval(round(lastchange),t)
      
    } else {
      warning(paste("File", file_path, "does not exist in directory", child_dir))
    }
    
    # Change back to the parent directory
    ind = ind+1
    #setwd("..")
  }
  #allEntropy <- allEntropy[,-ntime]
  return(list(allEntropy = allEntropy,timelastchange =timelastchange, indexlastchange=indexlastchange))
  
}


entropy <- function(states,x){
  #states is a sequence of intervals states[1], states[2] corresponding to segments 
  #on the target x axis dividing the scene in front.
  #x is a sequence of x values in the range -1 to 1 corresponding to observed
  #target eye movements
  
  #finds the frequency distribution of x by the segments s
  freq <- hist(x, breaks = states, plot = FALSE)
  p <- freq$counts/sum(freq$counts) #the probabilities
  
  return( -sum(ifelse(p == 0, 0, p * log2(p))) )
  
}

lastChange <- function(d){
  
  data_matrix <- cbind(d$Stereopsis, d[["6DoF"]], d$SpatialAudio, d$HighResolution, d$AltColour)
  
  # Convert each row to a binary number
  binary_numbers <- apply(data_matrix, 1, function(row) {
    sum(2^(which(rev(row) == 1) - 1))
  })
  
  # Find the index of the last change
  last_change_index <- max(which(c(TRUE, diff(binary_numbers) != 0)))
  
  return(last_change_index)
}


a <- getAllEntropies(30,18)

#This corresponds to figure 5A in the publication
plot(t,et,xlab="time segment",ylab = "median entropy",pch=16)


entropyByLastChange <- function(a){
  #a is the result of getAllEntropies
  #here we save the entropy corresponding to the last change
  w <- vector()
  n <- dim(a$allEntropy)
  n <- n[1]
  
  for(i in 1:n[1]){
    w[i] <- a$allEntropy[i,a$indexlastchange[i]]
  }
  return(w)
  
}

elast <- entropyByLastChange(a)
PI <- matrix(data = c(pq$there,pq$reality,pq$place,pq$virtualplace),nrow=29,ncol=4)
PI_median <- apply(PI,1,median)


#This corresponds to figure 5B in the publication
plot(PI_median,elast,xlab="PI_median",ylab="entropy",xlim=c(1,7), pch=16)


PI_median2 <- PI_median^2
lm <- lm(elast ~ PI_median + PI_median2)
summary(lm)

cor.test(elast[PI_median>=3],PI_median[PI_median>=3])


#let's sample over the time periods and the number of states
#the total time is 20 minutes so let's sample randomly


e10 <- rep(0,29)
N <- 10
for(i in 1:N) {
  ntime <- round(runif(1,5,40))
  nstates <- round(runif(1,3,30))
  a <- getAllEntropies(ntime,nstates)
  e10 <- e10 + entropyByLastChange(a)
  cat("i = ",i," ","ntime = ",ntime,"nstates = ",nstates, "\n")
  flush.console()
}
e10 <- e10/N

#This corresponds to figure 6, without the quadratic fit plotted
plot(PI_median,e10,xlim=c(1,7),ylab="median entropy", pch=16)



#Stan analysis
library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

mydata <- list(
  N = length(PI_median),
  pres = PI_median,
  entropy = e10
)


fit <- stan (file = "model_scanpath.stan", # Stan program
             data = mydata, # named list of data
             chains = 4, # number of Markov chains
             iter = 3000, # total number of iterations per chain
             cores = 4,
             #control = list(max_treedepth = 12),
             seed=54321)


print(fit, pars=c("b","sigma","v"),probs=c(.025,.975))

e <- rstan::extract(fit)

#probabilities of the parameters being positive
mean(e$b[,1]>0)
mean(e$b[,2]>0)
mean(e$b[,3]>0)


#find the probability that the degrees of freedom might be less than 30
mean(e$v < 30)


#obtain the means of the parameters forming the quadratic
b0 <- mean(e$b[,1])
b1 <- mean(e$b[,2])
b2 <- mean(e$b[,3])


#now plot the quadratic over the data points
p <- seq(1,7,0.1)
ent <- b0 + b1*p + b2*(p^2)


sz <- 1.5
plot(p, ent, type="l", ylim=c(1,3.5), xlim=c(1,7), xlab="", ylab="", 
     cex.lab=sz, cex.axis=sz)
par(new=TRUE)
plot(PI_median, e10, ylim=c(1,3.5), xlim=c(1,7), ylab="entropy", 
     pch=16, cex.lab=sz, cex.axis=sz)

#The  previous corresponds to figure 6, with the quadratic fit plotted


#plot observed against predicted posterior distribution means
#plot(e10,apply(e$entropy_new,2,mean))
cor.test(e10,apply(e$entropy_new,2,mean))

loo_summary <- function(fit, name) {
  
  log_lik <- extract_log_lik(fit, merge_chains = FALSE,parameter_name=name)
  r_eff <- relative_eff(exp(log_lik))
  loo <- loo(log_lik, r_eff = r_eff, cores = 2)
  return(loo)
}

library("loo")
loo <- loo_summary(fit,"log_lik_entropy")
loo
