% fit model
clear all
addpath ../analysis/matlab

% load some data to compare model to
load ../analysis/matlab/MCMC_all_clean


for cond = 1:3
    for subj = 1:2
    clear V
        
        for r=1:4
            V(:,:,r) = data.values{subj,r,cond};
        end
        data_ar = squeeze(data.ar(subj,:,:,cond));
        data_pstick = squeeze(data.p_stick(subj,:,:,cond));
        data_N_rwd = squeeze(data.N_rwd(subj,:,:,cond));
        
        %error_fun = @(params) model_error(params(1),params(2),V,data_ar',data_pstick')
        error_fun = @(params) model_lik(params(1),[params(2) params(3)],V,data_ar',data_pstick',data_N_rwd')
        
        paramsInit = [.14 .8 .6];
        error_fun(paramsInit);
        
        pOpt = fminsearch(error_fun,paramsInit)%,[],[],[],[],paramsLowerBound,paramsUpperBound)
        [~, m] = error_fun(pOpt);
        model.pOpt(:,subj,cond) = pOpt;
        model.ar(:,:,subj,cond) = m.ar;
        model.p_stick(:,:,subj,cond) = m.p_stick;
        
    end
end

%% compare parameters across conditions
fhandle = figure(2); clf; hold on
set(fhandle,'Position', [200 200 800 300])
set(fhandle,'Color','w')

subplot(1,3,1); hold on
plot(squeeze(model.pOpt(1,:,:))','.-')
ylabel('beta')
xlabel('condition')

subplot(1,3,2); hold on
plot(squeeze(model.pOpt(2,:,:))','.-')
ylabel('q(1)')
xlabel('condition')

subplot(1,3,3); hold on
plot(100*squeeze(model.pOpt(3,:,:))','.-')
ylabel('q(2)')
xlabel('condition')

clear fhandle
save model_fits_mcmc_noPrior

%% plot averaged data
load MCMC_all_clean

mcmc.ar = permute(model.ar,[3 2 1 4]);
mcmc.p_stick = permute(model.p_stick,[3 2 1 4]);
mcmc.pOpt = model.pOpt;

data_av = average_data(data);
mcmc_av = average_data(mcmc);
f = figure(3); clf; hold on
set(f,'Position',[300 250 700 300])
set(f,'Color','w')

subplot(1,2,1); hold on
for cond = 1:3
    plot(data_av.ar(:,cond),'k','linewidth',cond)
    plot(mcmc_av.ar(:,cond),'r','linewidth',cond)
end

subplot(1,2,2); hold on
for cond = 1:3
    plot(data_av.p_stick(:,cond),'k','linewidth',cond)
    plot(mcmc_av.p_stick(:,cond),'r','linewidth',cond)
end
