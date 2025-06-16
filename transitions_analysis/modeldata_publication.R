#analysis of transitions data 21-9-2023

R <- as.matrix(read.csv("results-transitions.csv", header=FALSE))
#The configurations are 0 to 31, with 
#0 = 00000
#31 = 11111
#the proposed changes are
# 1 means a change in the 5th place = 16 (2**4)
# 2 means a change in the 4th place = 8  (2**3)
# 3 means a change in the 3rd place = 4  (2**2)
# 4 means a change in the 4th place = 2  (2**1)
# 5 means a change in the 1st place = 1  (2**0)
#because the changes are implemented from left to right on the binary number.
#so if the change is c then we need to use 2**(5-c)
#but the change only happens if the subsequent value is 1 corresponding to an acceptance of the change.

#1. Stereopsis (0 is mono, 1 is stereo)
#2. Parallax (0 is no parallax, 1 is parallax)
#3. Spatial sound (0 is mono, 1 is spatial)
#4. High resolution (0 is low, 1 is high)
#5. Colour (0 is original, 1 is alternative)

source("find_position_of_nine.R")
#need to find the number of proposals for change
pos <- apply(R,1,find_position_of_nine)

source("setConfigurations.R")
configuration <- setConfigurations() 

source("intToBinary.R")
N <- dim(R)
m <- N[1]
n <- N[2]
config <- matrix(-1,nrow = m, ncol = n)
changeAccept <- matrix(0,nrow=2,ncol=5) #first row means no change, second row change

#outcomes - the rows are vision, parallax, sound, resolution, colour
#the columns are 0->0 0->1 1->0 1->1
#a -> b meaning the configuration was in a but moved to b.
outcomes <- matrix(0,nrow=5,ncol=4)
#transition matrix
P <- matrix(0,nrow=32,ncol=32)

#create a file for storing the individual outcomes
#change, enabled, accept
f <- file("result_binary.csv", "w")
writeLines("change,enabled,accept", f)
#change is the factor to be changed

source("check_bit.R")

for(i in 1:m){
  #get the initial configuration
  init <- R[i,1]
  config[i,1] <- R[i,1]
  for(j in seq(from=2,to=n,by=2)){
    #each subsequent pair are the proposed change and whether it is accepted or not
    #a 9 means that there are no subsequent changes so stop this row
    change <- R[i,j]
    if(change != 9){#there are more to come
      #is that feature already enabled?
      enabled <- check_bit(init,change)
      accept <- R[i,j+1] #accept==0 means no change, accept==1 means change
      if(!enabled & accept==0){#no change from 0 to 0:      0->0
        outcomes[change,1] <- outcomes[change,1] + 1
      }
      else if(!enabled & accept==1){# change from 0 to 1:   0->1
        outcomes[change,2] <- outcomes[change,2] + 1
      }
      else if(enabled & accept==0){#change from 1 to 0:     1->0
        outcomes[change,3] <- outcomes[change,3] + 1
      }
      else{#enabled & accept==1 change from 1 to 0:         1->1
        outcomes[change,4] <- outcomes[change,4] + 1
      }
      changeAccept[accept + 1,change] <- changeAccept[accept + 1,change] + 1
      newconfig <- bitwXor(init,(2**(5-change))*accept)
      P[init+1,newconfig+1] = P[init+1,newconfig+1] + 1 #transition
      init <- newconfig
      config[i,(j %/% 2)+1] <- init
      cat(cat(intToBinary(init)),' ')
      
      #write to the file
      line <- paste(change, as.integer(enabled), accept, sep = ",")
      writeLines(line, f)
    }
    else break
  }
  cat("\n")
}
close(f)


#note that 
colSums(changeAccept) #is the total number of changes suggested by factor irrespective of current state
rowSums(outcomes) #is the same, summing over all states

#outcomes is 0->0, 0->1, 1->0, 1->1 by factor 
#so outcomes[i,1] + outcomes[i,2] is the total number of times a change was proposed when factor i was off
# outcomes[i,3] + outcomes[i,4] is the total number when factor was on
propTimesChange <- matrix(0,nrow=5,ncol=2)
for(i in 1:5){
  s <- outcomes[i,1] + outcomes[i,2] #change proposed when i off
  propTimesChange[i,1] <- outcomes[i,2]/s
  s <- outcomes[i,3] + outcomes[i,4] #change proposed when i on
  propTimesChange[i,2] <- outcomes[i,4]/s
}
#propTimesChange[i,1] = proportion of times changed when i is off
#propTimesChange[i,2] = proportion of times changed when i is on
#For statistical analysis we need the binary variable 'accept' which
#is 0 or 1. For each trial we have the associated factor (condition) 
#1,2,...,5 and whether it was off (0) or on (1).
#In the above loop these are the variables
#change enabled accept and stored in the file result_binary.csv
result_binary <- read.csv("./result_binary.csv")
rb <- result_binary
#note that sum(rb$accept[rb$change==5 & rb$enabled==1] == 1), must be equal to outcomes[5,4], etc.

acceptdata <- list(
                  n = length(rb$change),
                  monovision = as.integer(rb$change==1)*(1-rb$enabled),
                  stereovision = as.integer(rb$change==1)*rb$enabled,
                  noparallax = as.integer(rb$change==2)*(1-rb$enabled),
                  parallax = as.integer(rb$change==2)*rb$enabled,
                  monosound = as.integer(rb$change==3)*(1-rb$enabled),
                  spatialsound = as.integer(rb$change==3)*rb$enabled,
                  lowres = as.integer(rb$change==4)*(1-rb$enabled),
                  highres = as.integer(rb$change==4)*rb$enabled,
                  origcolour = as.integer(rb$change==5)*(1-rb$enabled),
                  newcolour = as.integer(rb$change==5)*rb$enabled,
                  accept = rb$accept
)

#monovision (for example) means that a change is offered to vision and the current state for vision is mono
#model <- glm(accept ~ monovision+stereovision+noparallax+parallax+monosound+spatialsound
#                      +lowres + highres + origcolour + newcolour, family = binomial, data = acceptdata)

#library(car)
#vif(model)
#says that there is aliasing
#print(alias(model)) #shows that newcolour is perfectly predictable from the other variables. Therefore, newcolour
#should be removed

model <- glm(accept ~ monovision+stereovision+noparallax+parallax+monosound+spatialsound
             +lowres + highres + origcolour, family = binomial, data = acceptdata)
summary(model)
confint(model)

################################
#Stan
#If not already installed
##############################install.packages("rstan")


library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

#use model_accept2.stan which combines both models into one and gives the same results as running them separately
fit <- stan (file = "model_accept2.stan", # Stan program
            data = acceptdata, # named list of data
            chains = 4, # number of Markov chains
            iter = 2000, # total number of iterations per chain
            cores = 4, 
            seed=54321)

print(fit, pars=c("a0","b0","a1","b1"), probs=c(.025,.975))

#important to note that this this is Markov Chain Monte Carlo the results may differ 
#slightly from what is on the Kaggle because of the random sampling

e <- extract(fit)
#list all the variable names in e
names(e)

#find the probabilities of the parameters being positive

source("probsGT0.R")
mean(e$a0 > 0)
probsGT0(e$b0)

mean(e$a1 > 0)
probsGT0(e$b1)

mean(e$b0[,5] < e$b0[,1])
mean(e$b0[,5] < e$b0[,2])
mean(e$b0[,5] < e$b0[,3])
mean(e$b0[,5] < e$b0[,4])

mean(e$b0[,3] > e$b0[,1])
mean(e$b0[,3] > e$b0[,2])
mean(e$b0[,3] > e$b0[,4])
mean(e$b0[,3] > e$b0[,5])


#library(loo)
#source("loo_summary.R")

#loo0 <- loo_summary(fit,"log_lik_accept0")
#loo1 <- loo_summary(fit,"log_lik_accept1")

#everything is fine for this one
#loo0

#there is only one data point with a bad diagnostic
#loo1

################################

source("extract_until_minus1.R")
#turn into a list
configList <- apply(config, MARGIN=1, FUN=extract_until_minus1)
#to get a row of the list use
configList[[1]]
length(configList[[1]])
#to get the last element
configList[[1]][length(configList[[1]])]
tail(configList[[1]],n=1)

#transform each element to binary
configBinary <- lapply(configList, function(sublist) {
  lapply(sublist, intToBinary)
})

#print out by row
for(i in 1:m){
  for(j in configBinary[[i]]){
    cat(j,' ')
  }
  cat("\n")
}

#this gets the last configurations for each person
last <- vector()
for(i in 1:m){
  last[i] <- tail(configList[[i]],n=1)
}
table(last)
tab_last <- table(last)

# Convert the table to a 2x8 matrix
matrix_last <- matrix(c(as.numeric(names(tab_last)), as.numeric(tab_last)), nrow = 2, byrow = TRUE)
for(i in matrix_last[1,]){
  print(intToBinary(i))
}
for(i in matrix_last[1,]){
  print(i)
}
for(i in matrix_last[2,]){
  print(i)
}

##################
#find the occurences of each factor in the last configurations
#vision, parallax, sound, resolution, colour

numoccurences <- vector(mode="integer",length=5)
for(f in 1:5){#each factor
  for(i in 1:m){#each person
    if(check_bit(last[i],f)) {
      numoccurences[f] <- numoccurences[f] + 1
    }
  }
}

numoccurences


##################
#Markov Chain analysis
#P is the counts of the transitions matrix
#note that for some configurations never visited all entries are 0
for(i in 1:32){
  s <- sum(P[i,])
  if(s > 0){
    P[i,] <- P[i,]/s
  }
}

#eliminate unreachable states - there are no transitions to them or from them
source("eliminate_unreachable_states.R")

reducedMatrix <- eliminate_unreachable_states(P)
#the new matrix
Pnew <- reducedMatrix$P_new
eliminatedStates <- reducedMatrix$to_eliminate

eliminatedStates

#################

#remember that the eliminatedStates refer to indices in the P matrix, not to the list of configurations
for(i in eliminatedStates) print(intToBinary(i-1))
for(i in eliminatedStates) print(i-1)

#from now on work with Pnew
install.packages("expm")
library(expm)
#test example
rowSums(Pnew  %^% 20)

#Now I need a function that maps the new state numbers to the old
mapping_vector <- setdiff(1:nrow(P), eliminatedStates)
mapToOriginal <- function(newState) {
  if (newState < 1 || newState > length(mapping_vector)) {
    stop("Invalid new state number")
  }
  return(mapping_vector[newState])
}

#The equilibrium vector is the eigenvector associated with the eigenvalue 1, normalized so that its elements sum to 1.
en <- eigen(t(Pnew))

index <- which.min(abs(en$values - 1))
steady_state <- Re(en$vectors[,index])
pi <- steady_state / sum(steady_state)

for(i in pi) print(round(i,3))

####################
configs <- setConfigurations()
ind27 <- seq(1,27)
v <- apply(as.array(ind27),1,mapToOriginal)
z <- configs[v]

# Get the ordering of 'pi' from greatest to least
order_indices <- order(pi, decreasing = TRUE)

# Apply this ordering to both 'pi' and 'v'
sorted_pi <- pi[order_indices]
sorted_v <- v[order_indices]
# Now 'sorted_pi' and 'sorted_v' have the same ordering

#this gives the output that corresponds to Table 7 - remembering that there is random sampling involved so it 
#won't necessarily be identical
for(i in configs[sorted_v]) print(i)

