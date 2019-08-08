% test bandit_stick_rwd

clear all
addpath ../analysis/matlab

% load some data to compare model to
load ../analysis/matlab/MCMC_all_clean

clear V

subj = 2;
r = 2;
cond = 2;
V = data.values{subj,r,cond};

sim = bandit_stick_rwdV(V,.14,[.99 55],100)

sim = process_data(sim);

figure(1); clf; hold on
subplot(1,2,1); hold on
plot(sim.ar);
ylim([0 1])

subplot(1,2,2); hold on
plot(sim.p_stick)
ylim([0 1])