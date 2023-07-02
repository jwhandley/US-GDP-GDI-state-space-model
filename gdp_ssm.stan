data {
  int<lower=0> N; // Number of observations
  vector[N] y1; // Observation 1
  vector[N] y2; // Observation 2
}


parameters {
  vector[N] mu;
  real<lower=0> obs1_error;
  real<lower=0> obs2_error;
  real<lower=0> state_noise;
}

model {
  // Priors
  obs1_error ~ cauchy(0,1);
  obs2_error ~ cauchy(0,1);
  state_noise ~ cauchy(0,1);
  
  mu[1] ~ normal(0, 1);
  
  // State equation
  for (t in 2:N) {
    mu[t] ~ normal(mu[t-1],state_noise);
  }
  
  // Observation equation
  for (t in 1:N) {
    y1[t] ~ normal(mu[t],obs1_error);
    y2[t] ~ normal(mu[t],obs2_error);
  }
  
}
