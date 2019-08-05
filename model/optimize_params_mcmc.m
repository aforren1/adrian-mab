% fit model
clear all
addpath ../analysis/matlab

% load some data to compare model to
load ../analysis/matlab/MCMC_all_clean
tic

subj = 1;
cond = 2;

for r=1:4
    V(:,:,r) = data.values{subj,r,cond};
end
data_ar = squeeze(data.ar(subj,:,:,cond));
data_pstick = squeeze(data.p_stick(subj,:,:,cond));

error_fun = @(params) model_error(params(1),params(2:3),V,data_ar',data_pstick')

paramsInit = [.14 .8 .6];
paramsLowerBound = [0 0 0];
paramsUpperBound = [1 1 1];

error_fun(paramsInit)

pOpt = fminsearch(error_fun,paramsInit)%,[],[],[],[],paramsLowerBound,paramsUpperBound)