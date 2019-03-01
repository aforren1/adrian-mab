function [r a accept aa ac Vc] = bandit4_mcmc(V,beta,q)
% simulate mcmc on a single run with a particular time-evolving payoff V

[Na Nt] = size(V); % number of actions and timesteps

%%
a = zeros(1,Nt); % selected actions
a(1) = ceil(Na*rand(1)); % randomly pick the first action
ac = a(1);  % current accepted sample

Va = zeros(1,Nt); % value of selection actions
Va(1) = V(a(1),1); % value of first action

Vc = Va(1); % value of current accepted action

% mcmc learning parameters
if(nargin<2)
    beta = .1; % selection 'temperature'
end

if(nargin<3)
    q = [.7 40]; % [p(stay) switch prob]
end
%qq = (1-q)/(Na-1); % uniform distribution on other targets

% proposal parameters
q1 = q(1);
q2 = 1-q(1);
q3 = q(2);


% start simulation
for i=2:Nt
    % define proposal distribution
    
    %Pstick = q1*exp(beta*Vc)./((Na-1)*exp(beta*q3)+exp(beta*Vc))+q2; % for this line, stick prob DOES depend on # actions available
    Pstick = q1*exp(beta*Vc)./(exp(beta*q3)+exp(beta*Vc))+q2; % for this line, stick probability DOESN'T depend on # actions available
    P_ap_ac = (1-Pstick)*ones(1,Na)/(Na-1); % probability for each other key
    P_ap_ac(ac) = Pstick; % probability of proposal distribution given    
    
    a_pr = find(mnrnd(1,P_ap_ac)); % same from proposal distribution
    
    a(i) = a_pr; % actual action i = proposed action
    Va(i) = V(a_pr,i); % actual value of action i
    
    V_pr = Va(i); % value of proposed action
    
    % Barker rule
    %aa(i) = exp(beta*V_pr)/(exp(beta*V_pr)+exp(beta*Vc)); % evaluate accept/reject probability
    % metropolis-hastings rule
    %aa(i) = min(1,exp(beta*V_pr)/exp(beta*Vc));
    % prior rule: metropolis-hastings
    % figure out reverse proposal distribution
    %Pstick2 = q1*exp(beta*V_pr)./((Na-1)*exp(beta*q3)+exp(beta*V_pr))+q2; % probability of sticking for reverse proposal
    Pstick2 = q1*exp(beta*V_pr)./(exp(beta*q3)+exp(beta*V_pr))+q2; % probability of sticking for reverse proposal
    P_ac_ap = (1-Pstick2)*ones(1,Na)/(Na-1); % probability for each other key
    P_ac_ap(a_pr) = Pstick2;
    
    aa(i) = min(1,exp(beta*V_pr)*P_ac_ap(ac)/(exp(beta*Vc)*P_ap_ac(a_pr)));
    
    accept(i) = rand(1)<aa(i); % determine whether to accept/reject
    
    % update accepted action and value if accepted
    if(accept(i))
        ac = a_pr;
        Vc = V_pr;
    end
end

r = Va;

