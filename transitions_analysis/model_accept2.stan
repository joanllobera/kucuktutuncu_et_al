 // For the binary variable accept
data {
  int<lower=0> n; // number of observations
  int<lower=0, upper=1> accept[n]; // binary outcome
  int<lower=0, upper=1> monovision[n];
  int<lower=0, upper=1> stereovision[n];
  int<lower=0, upper=1> noparallax[n];
  int<lower=0, upper=1> parallax[n];
  int<lower=0, upper=1> monosound[n];
  int<lower=0, upper=1> spatialsound[n];
  int<lower=0, upper=1> lowres[n];
  int<lower=0, upper=1> highres[n];
  int<lower=0, upper=1> origcolour[n];
  int<lower=0, upper=1> newcolour[n];
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
    m0 = a0 + b0[1]*monovision[i] + b0[2]*noparallax[i] + b0[3]*monosound[i] +  b0[4]*lowres[i] + b0[5]*origcolour[i];
    m1 = a1 + b1[1]*stereovision[i] + b1[2]*parallax[i] + b1[3]*spatialsound[i] +  b1[4]*highres[i] + b1[5]*newcolour[i];
    accept_new0[i] = bernoulli_logit_rng(m0);
    accept_new1[i] = bernoulli_logit_rng(m1);
    log_lik_accept0[i] = bernoulli_logit_lpmf(accept[i]|m0);
    log_lik_accept1[i] = bernoulli_logit_lpmf(accept[i]|m1);
  }
}
