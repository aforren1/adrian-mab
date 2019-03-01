% analyze results
clear all
load example_data %bandit_data_mth4
addpath ../analysis
%%
V = data.V;
data.ar = get_psame(data.a); % reward

%% simulate on same sequence
%V = data(:,6:9)';
Nsamp = 200;
for j=1:Nsamp
    [mcmc.r(j,:) mcmc.a(j,:) mcmc.accept(j,:) mcmc.aa(j,:) mcmc.ac(j,:)] = bandit_mcmc(V,.2,.75);
    [softmax.r(j,:) softmax.a(j,:)] = bandit_KF_softmax(V);
    [softmax_sticky.r(j,:) softmax_sticky.a(j,:)] = bandit_KF_softmax(V,0.5);
    [mcmc_prior.r(j,:) mcmc_prior.a(j,:) mcmc_prior.accept(j,:) mcmc_prior.aa(j,:) mcmc_prior.ac(j,:)] = bandit_mcmc_prior(V);
end
%%
mcmc.ar = mean(get_psame(mcmc.a));
softmax.ar = mean(get_psame(softmax.a));
softmax_sticky.ar = mean(get_psame(softmax_sticky.a));
mcmc_prior.ar = mean(get_psame(mcmc_prior.a));


figure(11); clf; hold on
%subplot(2,1,1); hold on
plot(max(V),'k--','linewidth',2)
plot(data.r,'k','linewidth',2)
plot(mean(mcmc.r),'r','linewidth',2)
plot(mean(softmax.r),'b','linewidth',2)
plot(mean(softmax_sticky.r),'m','linewidth',2)
plot(mean(mcmc_prior.r),'g','linewidth',2)

[rmax amax] = max(V);
%subplot(2,1,2); hold on
legend('best possible','data','mcmc','softmax+KF')
xlabel('trials')
ylabel('average reward earned')

figure(10); clf; hold on
plot(V','linewidth',2)
xlabel('trials')
ylabel('button values')

max_ar = get_psame(amax);


figure(12); clf; hold on
plot(data.ar,'k','linewidth',2)
plot(mcmc.ar,'r','linewidth',2)

plot(softmax.ar,'b','linewidth',2)
plot(max_ar,'k--','linewidth',2)
plot(softmax_sticky.ar,'m','linewidth',2)
plot(mcmc_prior.ar,'g')
xlabel('# trials back')
ylabel('p(same action)')
legend('data','mcmc','softmax','optimal action','sticky softmax','mcmc prior')

%%
% compare average reward over the whole sequence
mcmc.mean_r = mean(mean(mcmc.r));
mcmc.std_r = std(mean(mcmc.r'));
softmax.mean_r = mean(mean(softmax.r));
softmax.std_r = std(mean(softmax.r'));
mcmc_prior.mean_r = mean(mean(mcmc_prior.r));
mcmc_prior.std_r = std(mean(mcmc_prior.r'));

mean_max = mean(max(V));
data.mean_r = mean(data.r);

figure(15); clf; hold on
plot(1,data.mean_r,'ko')
plot(2,mcmc.mean_r,'ro')
%plot(3,mcmc_prior.mean_r,'mo')
plot(3,softmax.mean_r,'bo')
plot(4,mean_max,'k.')
plot(5,mcmc_prior.mean_r,'go')
plot(6,mean(mean(V)),'mo')
plot([2 2],mcmc.mean_r*[1 1]+mcmc.std_r*[1 -1],'r');

%plot([3 3],mcmc_prior.mean_r*[1 1]+mcmc_prior.std_r*[1 -1],'r');

plot([3 3],softmax.mean_r*[1 1]+softmax.std_r*[1 -1],'b');
plot([5 5],mcmc_prior.mean_r*[1 1]+mcmc_prior.std_r*[1 -1],'g');

legend('data','mcmc','softmax','max','mcmc_prior','random')
xlabel('# trials back')
ylabel('p(same action)')

%% compare p_stick
data.p_stick = get_pstick(data);
mcmc.p_stick = get_pstick(mcmc);
mcmc_prior.p_stick = get_pstick(mcmc_prior);
softmax.p_stick = get_pstick(softmax);
softmax_sticky.p_stick = get_pstick(softmax_sticky);

figure(16); clf; hold on
plot(data.p_stick,'ko-')
plot(softmax.p_stick,'bo-')
plot(mcmc.p_stick,'ro-')
plot(softmax_sticky.p_stick,'mo-')
plot(mcmc_prior.p_stick,'go-')
legend('data','softmax','mcmc','sticky softmax','mcmc prior')
