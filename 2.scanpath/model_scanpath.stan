data {
  int<lower=0> N;       // Number of data points
  vector[N] pres;       // Independent variable
  vector[N] entropy;    // Dependent variable
}

parameters {
  vector[3] b;                 
  real<lower=0> sigma;      
  real<lower=1> v;      //degrees of freedom
}

model {
  // Priors
  b ~ normal(0, 10);
  sigma ~ gamma(2,0.1);
  v ~ gamma(2,0.1);
  
  // Likelihood
  for(i in 1:N) {
    entropy[i] ~ student_t(v, b[1] + b[2]*pres[i] + b[3]*(pres[i]^2), sigma);
  }
}

generated quantities {
  vector[N] entropy_new;
  vector[N] log_lik_entropy;
  real m;
  
  for(i in 1:N){
    m = b[1] + b[2]*pres[i] + b[3]*(pres[i]^2);
    entropy_new[i] = student_t_rng(v,m, sigma);
    log_lik_entropy[i] = student_t_lpdf(entropy[i]|v,m, sigma);
  }
}