function psame = get_psame(a)
% compute probability that selection on this trial is the same as previous
% trials, as a function of delay between trials

for d = 1:15 % delay
    current = a(:,d+1:end);
    previous = a(:,1:end-d);
    psame(:,d) = nanmean(current==previous,2);
end