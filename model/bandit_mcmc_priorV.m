function sim = bandit_mcmc_priorV(V,beta,q,Ns)
% simulate mcmc on a single run with a particular time-evolving payoff V
% This version vectorized to simulate multiple runs in parallel
%
% inputs:
%   V - time-varying pay-off Noptions x Nt
%   beta - selection temperature
%   q - prior parameters
%   Ns - number of sample runs to simulate

rng(1); % set random number seed

[Na, Nt] = size(V); % number of actions and timesteps

%%
a = zeros(Ns,Nt); % selected actions
%aa = a;
%accept = a;

a(:,1) = ceil(Na*rand(Ns,1)); % randomly pick the first action
ac = a(:,1);  % current accepted sample

Va = zeros(Ns,Nt); % value of selection actions
Va(:,1) = V(a(:,1),1); % value of first action

Vc = Va(:,1); % value of current accepted action

% mcmc learning parameters
if(nargin<2)
    beta = .1; % selection 'temperature'
end

if(length(beta)==1) % allow for two values of beta - one for selection, one for prior
    beta = beta*[1 1]; % set them the same unless beta is supplied as a two-element vector
end

if(nargin<3)
    q = [.7 40]; % [p(stay) switch prob]
end
%qq = (1-q)/(Na-1); % uniform distribution on other targets

% proposal parameters
if(length(q)==2)
    model = 'prior';
    q1 = q(1);
    q2 = 1-q(1);
    q3 = q(2);
else
    model = 'no_prior';
end

AA = repmat([1:Na],Ns,1);
o = ones(Ns,1);

% pre-sample random numbers for sampling from the multinomial
a_samp = rand(Ns,Nt);

% start simulation
for i=2:Nt
    % define proposal distribution
    
    %Pstick = q1*exp(beta*Vc)./((Na-1)*exp(beta*q3)+exp(beta*Vc))+q2; % for this line, stick prob DOES depend on # actions available
    if strcmp(model,'prior')
        Pstick = q1*exp(beta(2)*Vc)./(exp(beta(2)*q3)+exp(beta(2)*Vc))+q2; % for this line, stick probability DOESN'T depend on # actions available
    else
        Pstick = q*o;
    end
    P_ap_ac = (1-Pstick)*ones(1,Na)/(Na-1); % probability for each other key
    ii = sub2ind([Ns Na],[1:Ns]',ac); % get linear index for 'stick' action for each sample
    P_ap_ac(ii) = Pstick; % probability of proposal distribution given    
    
    %[~, a_pr] = find(mnrnd(1,P_ap_ac)); % sample from proposal distribution
    % sample from multinomial. NB - not that easy to read but hopefully
    % much faster than using mnrnd
    a_pr = sum(repmat(a_samp(:,i),1,Na) > cumsum(P_ap_ac,2),2)+1;
    %repmat(a_samp(:,i),1,Na-1)
    %a_pr = mnrnd(1,P_ap_ac)*[1:Na]';
    
    a(:,i) = a_pr; % actual action i = proposed action
    Va(:,i) = V(a_pr,i); % actual value of action i
    
    V_pr = Va(:,i); % value of proposed action
    
    % Barker rule
    %aa(i) = exp(beta*V_pr)/(exp(beta*V_pr)+exp(beta*Vc)); % evaluate accept/reject probability
    % metropolis-hastings rule
    %aa(i) = min(1,exp(beta*V_pr)/exp(beta*Vc));
    % prior rule: metropolis-hastings
    % figure out reverse proposal distribution
    %Pstick2 = q1*exp(beta*V_pr)./((Na-1)*exp(beta*q3)+exp(beta*V_pr))+q2; % probability of sticking for reverse proposal
    
    % --pre-vec code:
    %Pstick2 = q1*exp(beta*V_pr)./(exp(beta*q3)+exp(beta*V_pr))+q2; % probability of sticking for reverse proposal
    %P_ac_ap = (1-Pstick2)*ones(1,Na)/(Na-1); % probability for each other key
    %P_ac_ap(a_pr) = Pstick2;
    % ---
    
    % return probability - i.e. probability that you would sample current
    % accepted action from proposal
    if strcmp(model,'prior')
        Pstick2 = q1*exp(beta(2)*V_pr)./(exp(beta(2)*q3)+exp(beta(2)*V_pr))+q2; % for this line, stick probability DOESN'T depend on # actions available
    else
        Pstick2 = q*o;
    end
    P_ac_ap = (1-Pstick2)*ones(1,Na)/(Na-1); % probability for each other key
    ii = sub2ind([Ns Na],[1:Ns]',a_pr); % get linear index for 'stick' action for each sample
    P_ac_ap(ii) = Pstick2; % probability of proposal distribution given  
    
    i_ac = sub2ind([Ns Na],[1:Ns]',ac);
    i_a_pr = sub2ind([Ns Na],[1:Ns]',a_pr);
    aa(:,i) = min(1,exp(beta(1)*V_pr).*P_ac_ap(i_ac)./(exp(beta(1)*Vc).*P_ap_ac(i_a_pr)));
    
    accept(:,i) = rand(Ns,1)<aa(:,i); % determine whether to accept/reject
    
    % update accepted action and value if accepted
    ac(accept(:,i)) = a_pr(accept(:,i));
    Vc(accept(:,i)) = V_pr(accept(:,i));
    
    % if current action is accepted action, update Vc
    Vc(ac==a(:,i)) = V_pr(ac==a(:,i));
    
    
    %if(accept(i))
    %    ac = a_pr;
    %    Vc = V_pr;
    %end
end

r = Va;

sim.r = r;
sim.a = a;
sim.accept = accept;
sim.aa = aa;
sim.ac = ac;
sim.Vc = Vc;



