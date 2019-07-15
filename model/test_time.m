% test time for vectorization
clear all
load ../analysis/matlab/MCMC_all_clean

V = data.values{1,1,1};
beta = .15;


N=5:100:1005;
for i=1:length(N)
    tic
    N(i);
    sim = bandit_mcmc_priorV(V,beta,[.9 60],N(i));
    
    T(i) = toc;
end

figure(10); clf; hold on
plot(N,T,'o-')