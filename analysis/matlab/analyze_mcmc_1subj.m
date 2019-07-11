% analyze mcmc data
clear all
subjname = '103';
d = loadSubjData(subjname)
Nblocks = size(d,2)
%% plot results for sanity check
col = {'r','b','g'}
sty = {'-','--',':'};
figure(1); clf; hold on
for i=1:Nblocks
    if(d(i).condition)
        plot(d(i).p_stick,'color',col{d(i).condition},'linestyle',sty{d(i).condition},'linewidth',d(i).condition);
    end
end
xlabel('Reward')
ylabel('p(stick)')

figure(2); clf; hold on
for i=1:Nblocks
    if(d(i).condition)
        plot(d(i).ar,'color',col{d(i).condition},'linestyle',sty{d(i).condition},'linewidth',d(i).condition);
    end
end
ylim([0 1])
xlabel('N back')
ylabel('p(same action)')
