library(tidyverse) # metapackage of all tidyverse packages
R <- as.matrix(read.csv("./results-transitions.csv"))

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



pos <- apply(R,1,find_position_of_nine)



setConfigurations <- function(){
  configs <- vector(mode="character")
  configs[1] <- "Monocular - No Parallax - Mono Audio - Low Resolution - Original Color"
  configs[2] <- "Monocular - No Parallax - Mono Audio - Low Resolution - Alternative Color"
  configs[3] <- "Monocular - No Parallax - Mono Audio - High Resolution - Original Color"
  configs[4] <- "configs[1] <- Monocular - No Parallax - Mono Audio - High Resolution - Alternative Color"
  configs[5] <- "Monocular - No Parallax - Spatial Audio - Low Resolution - Original Color"
  configs[6] <- "Monocular - No Parallax - Spatial Audio - Low Resolution - Alternative Color"
  configs[7] <- "Monocular - No Parallax - Spatial Audio - High Resolution - Original Color"
  configs[8] <- "Monocular - No Parallax - Spatial Audio - High Resolution - Alternative Color"
  configs[9] <- "Monocular - Parallax - Mono Audio - Low Resolution - Original Color"
  configs[10] <- "Monocular - Parallax - Mono Audio - Low Resolution - Alternative Color"
  configs[11] <- "Monocular - Parallax - Mono Audio - High Resolution - Original Color"
  configs[12] <- "Monocular - Parallax - Mono Audio - High Resolution - Alternative Color"
  configs[13] <- "Monocular - Parallax - Spatial Audio - Low Resolution - Original Color"
  configs[14] <- "Monocular - Parallax - Spatial Audio - Low Resolution - Alternative Color"
  configs[15] <- "Monocular - Parallax - Spatial Audio - High Resolution - Original Color"
  configs[16] <- "Monocular - Parallax - Spatial Audio - High Resolution - Alternative Color"
  configs[17] <- "Stereopsis - No Parallax - Mono Audio - Low Resolution - Original Color"
  configs[18] <- "Stereopsis - No Parallax - Mono Audio - Low Resolution - Alternative Color"
  configs[19] <- "Stereopsis - No Parallax - Mono Audio - High Resolution - Original Color"
  configs[20] <- "Stereopsis - No Parallax - Mono Audio High Resolution - Alternative Color"
  configs[21] <- "Stereopsis - No Parallax - Spatial Audio - Low Resolution Original Color"
  configs[22] <- "Stereopsis - No Parallax - Spatial Audio - Low Resolution - Alternative Color"
  configs[23] <- "Stereopsis - No Parallax - Spatial Audio - High Resolution - Original Color"
  configs[24] <- "Stereopsis - No Parallax - Spatial Audio - High Resolution - Alternative Color"
  configs[25] <- "Stereopsis - Parallax - Mono Audio - Low Resolution - Original Color"
  configs[26] <- "Stereopsis - Parallax - Mono Audio - Low Resolution - Alternative Color"
  configs[27] <- "Stereopsis - Parallax - Mono Audio - High Resolution - Original Color"
  configs[28] <- "Stereopsis - Parallax - Mono Audio - High Resolution - Alternative Color"
  configs[29] <- "Stereopsis - Parallax - Spatial Audio - Low Resolution - Original Color"
  configs[30] <- "Stereopsis - Parallax - Spatial Audio - Low Resolution - Alternative Color"
  configs[31] <- "Stereopsis - Parallax - Spatial Audio - High Resolution - Original Color"
  configs[32] <- "Stereopsis - Parallax - Spatial Audio  -  High Resolution - Alternative Color"
  
  return(configs)
}

configuration <- setConfigurations() 

factor_level <- matrix("",nrow=2,ncol=5) #the index into this is [change,accept+1] 
factor_level[1,1] <- "MonoVision"
factor_level[1,2] <- "NoParallax"
factor_level[1,3] <- "MonoSound"
factor_level[1,4] <- "LowRes"
factor_level[1,5] <- "OriginalColour"

factor_level[2,1] <- "StereoVision"
factor_level[2,2] <- "Parallax"
factor_level[2,3] <- "SpatialSound"
factor_level[2,4] <- "HighRes"
factor_level[2,5] <- "AltColour"



intToBinary <- function(n) {
  if (n == 0) return("0")
  
  bits <- rev(as.integer(intToBits(n)))
  start <- which(bits == 1)[1]
  paste0(bits[start:length(bits)], collapse = "")
}

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




# n is the integer number
# position is the bit position you want to check (0-indexed, i.e., rightmost bit is 0)
check_bit <- function(n, position) {
  return(bitwAnd(n, 2**(5-position))>0)
}


#create a file for storing the individual outcomes
#change, enabled, accept
f <- file("result_binary.csv", "w")
writeLines("change,enabled,accept", f)
#change is the factor to be changed


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




