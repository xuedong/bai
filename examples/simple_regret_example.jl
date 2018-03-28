using PyPlot
using BestArm

# Problem setting
type_dist = "Bernoulli"

mu = ones(1, 20)
mu /= 10
mu[19] = 0.5
mu[20] = 0.9
#println(mu)

budget = 200
mcmc = 1000

policies = [SuccReject, SeqHalvingNoRef]
names = ["Successive Reject", "Sequential Halving without Refresh"]
#policies = [UniformSampling, UCBE, UCBEAdaptive, SuccReject, UGapEB, UGapEBAdaptive, SeqHalvingNoRef, SeqHalvingRef]
#names = ["Uniform Sampling", "UCB-E", "Adaptive UCB-E", "Successive Reject", "UGapEB", "Adaptive UGapEB", "Sequential Halving without Refresh", "Sequential Halving with Refresh"]
lp = length(policies)

# Options
VERBOSE = true

# Tests
X = 1:budget
for imeth in 1:lp
	policy = policies[imeth]
	regrets = zeros(1, budget)
	for k in 1:mcmc
		_, _, _, recs = policy(mu, budget)
		regrets_current = compute_regrets(mu, recs, budget)
		regrets += regrets_current
		if VERBOSE
			if k % 10 == 0
				println(k*100/mcmc, "%")
			end
		end
	end
	#println(regrets/mcmc)
	if imeth == 4 || imeth == 7 || imeth == 8
		plot(X, transpose(regrets/mcmc), linestyle="-.", label=names[imeth])
	else
		plot(X, transpose(regrets/mcmc), label=names[imeth])
	end
end

xlabel("Allocation budget")
ylabel("Expectation of the simple regret")
ax = axes()
grid("on")
legend(bbox_to_anchor=[1.05,1], loc=2, borderaxespad=0)
ax[:set_position]([0.06,0.06,0.71,0.91])
show()
