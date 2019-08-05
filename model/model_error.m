function [e2 model] = model_error(beta,q,V,data_ar,data_pstick)
% optimize model parameters for each condition for each participant
Nsamp = 100;
if(length(q)>1)
    q(2) = q(2)*100;
end

for run = 1:4
    sim = bandit_mcmc_priorV(V(:,:,run),beta,q,Nsamp);
    sim = process_data(sim);
    sim_p_stick(run,:) = sim.p_stick;
    sim_ar(run,:) = sim.ar;
end

e2 = nansum(nansum((sim_ar(2:4,:) - data_ar(2:4,:)).^2)) + nansum(nansum((sim_p_stick(2:4,:)-data_pstick(2:4,:)).^2));
%%
figure(1); clf; hold on
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

model.ar = sim_ar;
model.p_stick = sim_p_stick;