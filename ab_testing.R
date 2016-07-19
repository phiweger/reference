library(rethinking)
library(ggplot2)

# http://stats.stackexchange.com/questions/47771/what-is-the-intuition-behind-beta-distribution
curve(dbeta(x, 3, 7), from=0, to=1)
curve(dbeta(x, 36 + 3, 114 + 7), from=0, to=1, col='red')
curve(dbeta(x, 50 + 3, 100 + 7), from=0, to=1, add=T, col='blue')


size = 1e3
p_grid <- seq(0, 1, length.out=size)
prior <- dbeta(p_grid, 3, 7)
likelihood <- dbeta(p_grid, 36, 114) # rather binomial?
# likelihood <- dbinom(36, size=150, prob=p_grid)
posterior <- likelihood * prior / sum(likelihood * prior)
samples <- sample(p_grid, size=1e4, replace=T, prob=posterior)
w <- rbinom(1e4, size=150, prob=samples)


da <- data.frame(clicks=50, nmail=150)
ma <- map(
	alist(
		clicks ~ dbinom(size=nmail, prob=p),
		p ~ dbeta(3, 7)
	),
	data=da)
sa <- extract.samples(ma)
pa <- rbinom(1e4, size=150, prob=sapply(sa[,], as.numeric))

db <- data.frame(clicks=36, nmail=150)
mb <- map(
	alist(
		clicks ~ dbinom(size=nmail, prob=p),
		p ~ dbeta(3, 7)
	),
	data=db)

# sample from posterior
sb <- extract.samples(mb)
# posterior predictive check
pb <- rbinom(1e4, size=150, prob=sapply(sb[,], as.numeric))


precis(ma, corr=T)
vc <- vcov(ma)
diag(vc)
cov2cor(vc)

precis(mb)


dab <- data.frame(sa=sa, sb=sb, pa=pa, pb=pb)
p <- ggplot(dab) + 
	geom_freqpoly(aes(x=sa), color='red') +
	geom_freqpoly(aes(x=sb), color='blue')
# p

q <- ggplot(dab) + 
geom_histogram(aes(x=pa), fill='red') +
geom_histogram(aes(x=pb), fill='blue')

q

