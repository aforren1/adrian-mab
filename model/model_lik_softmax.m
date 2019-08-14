function [e2 model] = model_lik_softmax(params,V,data_ar,data_pstick,data_N_rwd)
% optimize model parameters for each condition for each participant
Nsamp = 100;
Ntrials = size(V,2);

params(3) = 100*params(3); % rescale initial reward parameter
params(6) = 100*params(6); % rescale 'mean rwd' parameter
tic
for run = 1:4
    sim = bandit_KF_softmaxV(V(:,:,run),params,Nsamp);
    sim = process_data(sim);
    sim_p_stick(run,:) = sim.p_stick;
    sim_ar(run,:) = sim.ar;
    sim_rAv(run,:) = mean(sim.r);
end
toc
% compute log-likelihood of data given simulations

% p_stick
epsilon = .0001; % minimum probability of p(stick) - to avoid -Inf likelihood
sim_p_stick = max(sim_p_stick,epsilon);
data_N_stick = data_pstick.*data_N_rwd;

for i=1:4
    for j=1:size(sim_p_stick,2)
        LL_pstick(i,j) = data_N_stick(i,j)*log(sim_p_stick(i,j)) + (data_N_rwd(i,j)-data_N_stick(i,j))*log(1-sim_p_stick(i,j));
    end
    
    for j=1:size(sim_ar,2);
        LL_ar(i,j) = (Ntrials - j)*data_ar(i,j)*log(sim_ar(i,j)) + (Ntrials-j)*(1-data_ar(i,j))*log(1-sim_ar(i,j));
    end
end

e2 = -nansum(nansum(LL_pstick(2:4,:))) - nansum(nansum(LL_ar(2:4,:)));

model.ar = sim_ar;
model.p_stick = sim_p_stick;
model.rAv = sim_rAv;
%e2 =  - nansum(nansum(LL_ar(2:4,:));
%e2 = nansum(nansum((sim_ar(2:4,:) - data_ar(2:4,:)).^2)) + nansum(nansum((sim_p_stick(2:4,:)-data_pstick(2:4,:)).^2));
%%
%
figure(10); clf; hold on
subplot(1,2,1); hold on
for run = 1:4
    plot(data_ar(run,:),'k','linewidth',run)
    plot(sim_ar(run,:),'r','linewidth',run)
end
ylim([0 1])

subplot(1,2,2); hold on
for run = 1:4
    plot(data_pstick(run,:),'k','linewidth',run)
    plot(sim_p_stick(run,:),'r','linewidth',run)
end
ylim([0 1])
%}


        
