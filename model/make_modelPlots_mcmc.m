% plot model fits

f = figure(1); clf; hold on
set(f,'Position',[100,150,1200,1200])
set(f,'Color','w')

for cond=1:3
    f = figure(cond)
    set(f,'Position',[100,150,1800,1200])
    set(f,'Color','w')
    for subj = 1:18
        subplot(4,5,subj); hold on
        for block = 1:4
            plot(data.p_stick(subj,:,block,cond),'k','linewidth',block);
            plot(model.p_stick(block,:,subj,cond),'r','linewidth',block);
        end
    end
end
