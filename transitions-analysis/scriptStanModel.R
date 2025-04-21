result_binary <- read.csv("result_binary.csv")
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



install.packages("rstan", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))
#Now the analysis with Stan
library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


stan_model <- "
// For the binary variable accept
data {
  int<lower=0> n; // number of observations
  array[n] int<lower=0, upper=1> accept; // binary outcome
  array[n] int<lower=0, upper=1> monovision;
  array[n] int<lower=0, upper=1> stereovision;
  array[n] int<lower=0, upper=1> noparallax;
  array[n] int<lower=0, upper=1> parallax;
  array[n] int<lower=0, upper=1> monosound;
  array[n] int<lower=0, upper=1> spatialsound;
  array[n] int<lower=0, upper=1> lowres;
  array[n] int<lower=0, upper=1> highres;
  array[n] int<lower=0, upper=1> origcolour;
  array[n] int<lower=0, upper=1> newcolour;
}

transformed data{
  int k = 5; //number of parameters
}

parameters {
  real a0;
  real a1;
  vector[k] b0;
  vector[k] b1;
}

model {
  real m0;
  real m1;
  a0 ~ normal(0,10);
  a1 ~ normal(0,10);
  b0 ~ normal(0,10);
  b1 ~ normal(0,10);
  for(i in 1:n){
    /*
    accept[i] ~ bernoulli_logit(a + b[1]*monovision[i] + b[2]*stereovision[i]
                        + b[3]*noparallax[i] + b[4]*parallax[i] 
                        + b[5]*monosound[i] + b[6]*spatialsound[i] 
                        + b[7]*lowres[i] + b[8]*highres[i] 
                        + b[9]*origcolour[i]);
    */
    m0 = a0 + b0[1]*monovision[i] + b0[2]*noparallax[i] + b0[3]*monosound[i] +  b0[4]*lowres[i] + b0[5]*origcolour[i];
    m1 = a1 + b1[1]*stereovision[i] + b1[2]*parallax[i] + b1[3]*spatialsound[i] +  b1[4]*highres[i] + b1[5]*newcolour[i];
    accept[i] ~ bernoulli_logit(m0);
    accept[i] ~ bernoulli_logit(m1);
  }
}

generated quantities {
  vector[n] accept_new0;
  vector[n] accept_new1;
  vector[n] log_lik_accept0;
  vector[n] log_lik_accept1;
  real m0;
  real m1;

  for(i in 1:n){
    /*
    m = a + b[1]*monovision[i] + b[2]*stereovision[i]
          + b[3]*noparallax[i] + b[4]*parallax[i] 
          + b[5]*monosound[i] + b[6]*spatialsound[i] 
          + b[7]*lowres[i] + b[8]*highres[i] 
          + b[9]*origcolour[i];
    */
    m0 = a0 + b0[1]*monovision[i] + b0[2]*noparallax[i] + b0[3]*monosound[i] +  b0[4]*lowres[i] + b0[5]*origcolour[i];
    m1 = a1 + b1[1]*stereovision[i] + b1[2]*parallax[i] + b1[3]*spatialsound[i] +  b1[4]*highres[i] + b1[5]*newcolour[i];
    accept_new0[i] = bernoulli_logit_rng(m0);
    accept_new1[i] = bernoulli_logit_rng(m1);
    log_lik_accept0[i] = bernoulli_logit_lpmf(accept[i]|m0);
    log_lik_accept1[i] = bernoulli_logit_lpmf(accept[i]|m1);
  }
}
"





fit <- stan (model_code = stan_model, # Stan program
             data = acceptdata, # named list of data
             chains = 4, # number of Markov chains
             iter = 2000, # total number of iterations per chain
             cores = 4, 
             seed=54321)

