% re-organize mcmc data
clear all
load MCMC_all_raw


Nsubj = 18;
Ncondition = 3;
Nblocks = 4;

Nblocks = 13;
for subj = 1:Nsubj
    for c = 1:Ncondition
        ib = 1;
        for b = 1:Nblocks
            if(d{subj}(b).condition==c)
                data.p_stick(subj,:,ib,c) = d{subj}(b).p_stick;
                data.N_rwd(subj,:,ib,c) = d{subj}(b).N_rwd;
                data.r_av(subj,:,ib,c) = d{subj}(b).r_av;
                data.ar(subj,:,ib,c) = d{subj}(b).ar;
                data.Noptions(subj,ib,c) = d{subj}(b).Noptions;
                data.r(subj,:,ib,c) = d{subj}(b).r;
                data.values{subj,ib,c} = d{subj}(b).values;
                ib = ib+1;
            end
        end
    end
end

save MCMC_all_clean data