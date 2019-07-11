% load mcmc data

% analyze mcmc data
clear all

for i=1:18
    if(i-1<10)
        subjname = ['10',num2str(i-1)];
    else
        subjname = ['1',num2str(i-1)];
    end
    
    disp(subjname);
    d{i} = loadSubjData(subjname);

end
Nblocks = size(d{1},2)

save MCMC_all_raw