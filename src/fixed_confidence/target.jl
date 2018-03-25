function ChernoffTarget(mu,delta,rate,Target=ones(1,length(mu))/length(mu))
  # sampling rule : choose arm maximizing (Target - empirical proportion)
  condition = true
  K=length(mu)
  N = zeros(1,K)
  S = zeros(1,K)
  # initialization
  for a in 1:K
      N[a]=1
      S[a]=sample_arm(mu[a], type_dist)
  end
  t=K
  Best=1
  while (condition)
       Mu=S./N
       Ind=find(Mu.==maximum(Mu))
       # Empirical best arm
       Best=Ind[floor(Int,length(Ind)*rand())+1]
       # Compute the stopping statistic
       NB=N[Best]
       SB=S[Best]
       muB=SB/NB
       MuMid=(SB+S)./(NB+N)
       Index=collect(1:K)
       splice!(Index,Best)
       Score=minimum([NB*d(muB, MuMid[i], type_dist)+N[i]*d(Mu[i], MuMid[i], type_dist) for i in Index])
       if (Score > rate(t,0,delta))
            # stop
            condition=false
       elseif (t >1000000)
            # stop and return (0,0)
            condition=false
            Best=0
            print(N)
            print(S)
            N=zeros(1,K)
       else
	    I=indmax(Target-N/t)
	    t+=1
	    S[I]+=sample_arm(mu[I], type_dist)
	    N[I]+=1
	end
   end
   recommendation=Best
   return (recommendation,N)
end
