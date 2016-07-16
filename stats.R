# rethinking package
library(rethinking)

# get data
data(rugged)
d <- rugged
d$log_gdp <- log(d$rgdppc_2000)
dd <- d[complete.cases(d$rgdppc_2000),]
ddd <- dd[, c('log_gdp', 'rugged', 'cont_africa')]

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

# traceplot
plot(m)

# TODO

# * link, sim
# * posterior predictive check
# * counterfactual plot
# * triptyc plot
# * compare, ensemble