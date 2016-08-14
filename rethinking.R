# TODO

# * counterfactual plot
# * triptyc plot
# TODO: refresh argument

# rethinking package
library(rethinking)

# get data
data(rugged)
d <- rugged
str(d)

d$log_gdp <- log(d$rgdppc_2000)
dd <- d[complete.cases(d$rgdppc_2000),]

# STAN only wants variables that are eventually used in the model.
ddd <- dd[, c('log_gdp', 'rugged', 'cont_africa')]


# visualize a distribution
curve( dcauchy(x,0,2) , from=0 , to=10 ,
    xlab="sigma" , ylab="Density" , ylim=c(0,1) )
curve( dunif(x,0,10) , add=TRUE , col="red" )
curve( dexp(x,1) , add=TRUE , col="blue" )


# specify and fit model m
m <- map2stan(
    alist(
        log_gdp ~ dnorm(mu, sigma),
        mu <- a + bR * rugged + bA * cont_africa + bAR * rugged * cont_africa,
        a ~ dnorm(0, 100),
        c(bR, bA, bAR) ~ dnorm(0, 10),
        sigma ~ cauchy(0, 2)
        ),
    data=ddd
    )

# summary of posterior inference
precis(m, corr=T)
pairs(m)
# traceplot
plot(m)


# exercise 7H1
# How to encode a discrete variable without creating a dummy 
# variable for each class? 
data(tulips)
d <- tulips

# create dummy variable
d$index <- coerce_index(d$bed)
# center predictors
# When naming a variable, do not use dots. Stan does not like them.
d$water_c <- d$water - mean(d$water)
d$shade_c <- d$shade - mean(d$shade)

dd <- d[, c('water_c', 'shade_c', 'index', 'blooms')]
    
m <- map2stan(
    alist(
        blooms ~ dnorm(mu,sigma),
        mu <- a[index] +
              bW * water_c + bS * shade_c +
              bWS * water_c * shade_c ,
        a[index] ~ dnorm(130, 100),
        c(bW, bS, bWS) ~ dnorm(0, 100),
        sigma ~ dcauchy(0, 2)
    ),
    data=dd, chains=2, warmup=1000, iter=4000)
# truncate a prior to e.g. have only values > 0
# sigma ~ dnorm(0, 10) & T[0,]

# another truncation
# ..., data=..., constraints='lower=0', ...
# TODO: Are they equivalent?


# see model specification in Stan language
stancode(m)


precis(m, depth=2)
#         Mean StdDev lower 0.89 upper 0.89 n_eff Rhat
# a[1]   97.92  15.16      74.43     122.67  4945    1
# a[2]  142.17  15.05     118.63     165.91  4634    1
# a[3]  147.13  15.33     122.76     171.14  5163    1
# bW     74.96  10.68      58.86      92.81  4560    1
# bS    -41.16  10.79     -58.08     -23.88  4577    1
# bWS   -51.99  13.24     -73.85     -31.98  4885    1
# sigma  44.96   6.93      34.54      55.54  2734    1

plot(precis(m, depth=2))
coef(m)
plot(coef(m))

# Plot implied predictions for shade, given water and bed.
post <- extract.samples(m)
shade_seq <- seq(from=-1.5, 1.5, by=0.1)
mu <- link(m, data=data.frame(shade_c=shade_seq, index=1, water_c=0))
mu_mean <- apply(mu, 2, mean)
mu_HPDI <- apply(mu, 2, HPDI, prob=.89)

s <- sim(m, data=data.frame(shade_c=shade_seq, index=1, water_c=0))
s.PI <- apply(s, 2, PI, prob=.89)

plot(blooms ~ shade_c, dd, pch=16)
lines(shade_seq, mu_mean)
lines(shade_seq, mu_HPDI[1,], lty=2)
lines(shade_seq, mu_HPDI[2,], lty=2)
shade(s.PI, shade_seq)

# What’s the posterior distribution of the difference between 
# bed b and c, which appear to be similar?
diff_b_c <- post$a[,2] - post$a[,3]
HPDI(diff_b_c)
sum(diff_b_c < 0) / length(diff_b_c)


# binomial regression, link functions, outcome scale
data(chimpanzees)
d <- chimpanzees

m <- map(
    alist(
        pulled_left <- dbinom(1, p),
        logit(p) ~ a,
        a ~ dnorm(0, 10)
        ),
    data=d
    )
# > precis(m)
#   Mean StdDev 5.5% 94.5%
# a 0.32   0.09 0.18  0.46


# Parameters in a logistic regression are on the scale of log-odds.
logistic(0.32) # a
logistic(c(0.18, 0.46)) # PI


# see models code 10.4
compare(m10.1, m10.2, m10.3)
coeftab(m10.1, m10.2, m10.3)
plot(coeftab(m10.1, m10.2, m10.3))

# model-averaged posterior predictive check
dpred <- data.frame(
    prosoc_left=c(0, 1, 0, 1),
    condition=c(0, 0, 1, 1)
    )

e <- ensemble(m10.1, m10.2, m10.3, data=dpred)
p_pred <- apply(e$link, 2, mean)
PI_pred <- apply(e$link, 2, PI)


# convert fit method from MAP to STAN 
m_stan <- map2stan(m, data=d, iter=1e4, warmup=1000)







