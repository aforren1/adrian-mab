% test models
clear all
addpath ../analysis/matlab

% load some data to compare model to
load ../analysis/matlab/MCMC_all_clean
tic
% simulate model for each run for each participant
for cond = 1:3 % condition number
    for run = 1:4 % run number
        for subj = 1:18 % subject number
            
            % model parameters
            beta = .15;
            q = 0.8;
            
            V = data.values{subj,run,cond};
            sim = bandit_mcmc(V,beta,q);
            sim_mcmc{cond}(subj,run) = process_data(sim);
            
            sim = bandit_mcmc_priorV(V,beta,[.9 60],5);
            sim_mcmc_prior{cond}(subj,run) = process_data(sim);
            
            mcmc_all.p_stick(subj,:,run,cond) = sim_mcmc{cond}(subj,run).p_stick;
            mcmc_all.ar(subj,:,run,cond) = sim_mcmc{cond}(subj,run).ar;
            
            mcmc_prior_all.p_stick(subj,:,run,cond) = sim_mcmc_prior{cond}(subj,run).p_stick;
            mcmc_prior_all.ar(subj,:,run,cond) = sim_mcmc_prior{cond}(subj,run).ar;
            
        end
    end
end
toc
%% aggregate
mcmcAv_subj = average_data(mcmc_all);
mcmcP_Av_subj = average_data(mcmc_prior_all);

%{
mcmcAv_blocks.p_stick = squeeze(nanmean(mcmc_all.p_stick,3));
mcmcAv_blocks.ar = squeeze(nanmean(mcmc_all.ar,3));

mcmcAv_subj.p_stick = squeeze(nanmean(mcmcAv_blocks.p_stick,1));
mcmcAv_subj.ar = squeeze(nanmean(mcmcAv_blocks.ar,1));
      

mcmcP_Av_blocks.p_stick = squeeze(nanmean(mcmc_prior_all.p_stick,3));
mcmcP_Av_blocks.ar = squeeze(nanmean(mcmc_prior_all.ar,3));

mcmcP_Av_subj.p_stick = squeeze(nanmean(mcmcP_Av_blocks.p_stick,1));
mcmcP_Av_subj.ar = squeeze(nanmean(mcmcP_Av_blocks.ar,1));
%}
%% plot single run
%{
subj = 1;
cond = 1;
run = 1;
% plot result
fhandle = figure(1); clf; hold on
set(fhandle, 'Position', [200, 100, 900, 500]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white
    
subplot(1,2,1); hold on
plot(data.p_stick(subj,:,run,cond),'k','linewidth',2)
plot(mcmc_all.p_stick,'r')
plot(mcmc_prior_all.p_stick,'g')

subplot(1,2,2); hold on
plot(data.ar(subj,:,run,cond),'k','linewidth',2)
plot(mcmc_all.ar,'r','linewidth',2)
plot(mcmc_prior_all.ar,'g','linewidth',2)
%}
%%
load MCMC_av

fhandle = figure(3); clf; hold on
set(fhandle, 'Position', [200, 100, 900, 500]); % set size and loction on screen
set(fhandle, 'Color','w') % set background color to white

subplot(1,2,1); hold on
for c=1:3
    plot(dAv_subj.p_stick(:,c),'color','k','linewidth',c)
    plot(mcmcAv_subj.p_stick(:,c),'color','g','linewidth',c)
    plot(mcmcP_Av_subj.p_stick(:,c),'color','r','linewidth',c)
    %plot(dAv_subj.r_av(:,c),'color','r','linewidth',c)
end
xlabel('reward')
ylabel('p_stick')
legend('4 choices','8 choices','26 choices')
xlim([0 10])
ylim([0 1])

subplot(1,2,2); hold on
for c=1:3
    plot(dAv_subj.ar(:,c),'color','k','linewidth',c)
    plot(mcmcAv_subj.ar(:,c),'color','g','linewidth',c)
    plot(mcmcP_Av_subj.ar(:,c),'color','r','linewidth',c)
    %plot(dAv_subj.r_av(:,c),'color','r','linewidth',c)
end
xlabel('reward')
ylabel('p_stick')
legend('4 choices','8 choices','26 choices')
ylim([0 1])
