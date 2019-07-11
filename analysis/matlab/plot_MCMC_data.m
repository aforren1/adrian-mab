% plot mcmc data
clear all
load MCMC_all_clean

Nsubj = 18;
Nblock = 4;
Ncond = 3;

% average across blocks
%for subj = 1:Nsubj
    %for c = 1:Ncond
        dAv_blocks.p_stick = squeeze(nanmean(data.p_stick,3));
        dAv_blocks.ar = squeeze(nanmean(data.ar,3));
        dAv_blocks.r_av = squeeze(nanmean(data.r_av,3));
        dAv_blocks.r = squeeze(nanmean(data.r,3));
    %end
%end

% average across subjects
%for c = 1:Ncond
    dAv_subj.p_stick = squeeze(nanmean(dAv_blocks.p_stick,1));
    dAv_subj.r_av = squeeze(nanmean(dAv_blocks.r_av,1));
    dAv_subj.r = squeeze(nanmean(dAv_blocks.r,1));
    dAv_subj.ar = squeeze(nanmean(dAv_blocks.ar,1));
    
    save MCMC_av dAv_subj dAv_blocks
%end

%%
% plot results
col = {'r','b','g'}
sty = {'-','--',':'};

figure(1); clf; hold on
for c=1:3
    plot(dAv_subj.r(:,c),'color','b','linewidth',c)
    %plot(dAv_subj.r_av(:,c),'color','r','linewidth',c)
end
xlabel('trial')
ylabel('reward')
legend('4 choices','8 choices','26 choices')

figure(2); clf; hold on
for c=1:3
    plot(dAv_subj.p_stick(:,c),'color',col{2},'linewidth',c)
end
ylim([0 1])
xlabel('reward')
ylabel('p(stick)')
legend('4 choices','8 choices','26 choices')

figure(3); clf; hold on
for c=1:3
    plot(dAv_subj.ar(:,c),'color',col{2},'linewidth',c)
end
ylim([0 1])
xlabel('Nback')
ylabel('p(same)')
legend('4 choices','8 choices','26 choices')

%% plot individual subjects
fhandle = figure(11); clf; hold on
    set(fhandle, 'Position', [600, 100, 1200, 600]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white

for s=1:Nsubj
    % plot p(stick)
    subplot(3,6,s); hold on
    for c=1:3
        plot(dAv_blocks.ar(s,:,c),'color',col{2},'linewidth',c)
    end
    ylim([0 1])
    xlabel('reward')
    ylabel('p(stick)')
end

fhandle = figure(12); clf; hold on
    set(fhandle, 'Position', [600, 100, 1200, 600]); % set size and loction on screen
    set(fhandle, 'Color','w') % set background color to white
for s=1:Nsubj
    % plot ar
    subplot(3,6,s); hold on
    for c=1:3
        plot(dAv_blocks.p_stick(s,:,c),'color',col{2},'linewidth',c)
    end
    ylim([0 1])
    xlabel('Nback')
    ylabel('p(same)')
end

    


