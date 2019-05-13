function p_stick = get_pstick(data)
% figure out p_stick given different rewards
%clear all
%load bandit_data_mth4
Nsamp = size(data.r,1);
for j=1:Nsamp
    bins = [0:10:100];
    rrng = data.r(j,1:end-1);
    for b = 1:length(bins)-1
        i_bin{j,b} = find(rrng>bins(b) & rrng<bins(b+1)); % trials in this reward bin
        stick{j,b} = (data.a(j,i_bin{j,b}) == data.a(j,i_bin{j,b}+1)); % trials in this bin which stuck
        p_stick_all(j,b) = mean(stick{j,b});
        if(isfield(data,'aa'))
            aa{j,b} = data.aa(j,i_bin{j,b});
            p_accept_all(j,b) = mean(aa{j,b});
        end
    end
end

p_stick = nanmean(p_stick_all,1);

if(exist('p_accept_all'))
    p_accept = nanmean(p_accept_all,1);
end

%figure(21); clf; hold on
%plot(bins(1:end-1)+5,p_stick,'o-')

%% parametric fit
%{
R = [0:1:100];

q1 = 1;
q2 = 0;
q3 = 56;

beta = 0.25;
prior = exp(beta*R)./(3*exp(beta*q3)+exp(beta*R));
prior = q1*prior+q2;

plot(R,prior,'r')
ylim([0 1])
%}