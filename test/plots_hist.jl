using PyPlot
# using ConfParser
using HDF5
# using Seaborn

reservoir = "Beta"
alphas = [0.5, 1.0, 2.0, 3.0, 1.0]
betas = [0.5, 1.0, 2.0, 1.0, 3.0]
budget = 64


for iparam in 1:5
	fig = figure()
	# Seaborn.set(style="darkgrid")

	# running tests
	x = [0:1:budget;]
	if Sys.KERNEL == :Darwin
		num_arms = h5open(string("/Users/xuedong/Programming/PhD/BestArm.jl/misc/log/infinite/", reservoir, "(", alphas[iparam], ",", betas[iparam], ")", "_", "dttts", "_N.h5"), "r") do file
	    	read(file, "dttts")
		end
	elseif Sys.KERNEL == :Linux
		num_arms = h5open(string("/home/xuedong/Documents/xuedong/phd/work/code/BestArm.jl/misc/log/infinite/", reservoir, "(", alphas[iparam], ",", betas[iparam], ")", "_", "dttts", "_N.h5"), "r") do file
    		read(file, "dttts")
		end
	end
	num_arms = reshape(num_arms', (budget+1,))
	print(sum(num_arms))
	bar(x, num_arms, color="#0f87bf", align="center", alpha=0.4) # Histogram

	xlabel("Number of arm plays")
	ylabel("Expectation of number of arms")
	grid("on")
	# legend(loc=1)
	if Sys.KERNEL == :Darwin
		savefig(string("/Users/xuedong/Programming/PhD/BestArm.jl/misc/results/hist/", reservoir, "(", alphas[iparam], ",", betas[iparam], ")", "_", "dttts", "_N.pdf"))
	elseif Sys.KERNEL == :Linux
		savefig(string("/home/xuedong/Documents/xuedong/phd/work/code/BestArm.jl/misc/results/hist/", reservoir, "(", alphas[iparam], ",", betas[iparam], ")", "_", "dttts", "_N.pdf"))
	end
	close(fig)
end