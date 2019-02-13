function data = loadSubjData(subjname)
% load data from an individual participant in the MCMC experiment

datapath = ['../data/',subjname,'/'];
disp(datapath);
fnames = dir(datapath);
Nblocks = size(fnames,1)-2;
for i=1:Nblocks
    disp(fnames(i+2).name);
    dtemp = csvread([datapath,fnames(i+2).name],1,0);
    %dtemp = readtable([datapath,fnames(i+2).name],'ReadVariableNames',1);
    %dd = table2struct(dtemp);
    d(i).a = dtemp(:,1)'; % action
    d(i).r = dtemp(:,3)'; % reward
    d(i).RT = dtemp(:,4)';
    d(i).subject = dtemp(:,5);
    d(i).values = dtemp(:,7:end)';
    d(i).Noptions = size(d(i).values,1);
    d(i).Ntrials = size(d(i).a,2);
    if(d(i).Noptions==4 & d(i).Ntrials>30)
        d(i).condition = 1;
    elseif(d(i).Noptions==8)
        d(i).condition = 2;
    elseif(d(i).Noptions==26)
        d(i).condition = 3;
    else
        d(i).condition = 0; % practice
    end
    
    
end

% compute other stats (e.g. stick probability)
for i=1:Nblocks
    data(i) = process_data(d(i));
end


    