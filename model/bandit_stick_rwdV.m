function sim = bandit_stick_rwdV(V,beta,q,Ns)
% simulate bandit policy soft win/stay lose/switch
rng(1); % set random number seed

[Na Nt] = size(V); % number of actions and timesteps

%%
a = zeros(Ns,Nt); % selected actions
a(:,1) = ceil(Na*rand(Ns,1)); % randomly pick the first action

if(nargin<4)
    Ns = 100;
end

Va = zeros(Ns,Nt); % value of selection actions
Va(:,1) = V(a(:,1),1); % value of first action

% policy parameters
if(nargin<2)
    beta = .08; % selection 'temperature'
end

if(nargin<3)
    q = [.9 60]; % p(stay)
end

% plot p_stick
%{
figure(2); clf; hold on
rr = [1:100];
pstick_r = q(1)*exp(beta*rr)./(exp(beta*q(2))+exp(beta*rr))+(1-q(1));
plot(rr,pstick_r,'k')
%}

% pre-sample random numbers for sampling from the multinomial
a_samp = rand(Ns,Nt);

% start simulation
for i=2:Nt
    % sample from proposal
    %Pstick = q(1)*exp(beta*Va(i-1))./(exp(beta*q(2))+exp(beta*Va(i-1)))+(1-q(1));
    Pstick = q(1)*exp(beta*Va(:,i-1))./(exp(beta*q(2))+exp(beta*Va(:,i-1)))+(1-q(1));
    
    %P_ap_ac = (1-Pstick)*ones(1,Na)/(Na-1); % probability for each other key
    %P_ap_ac(a(i-1)) = Pstick; % probability of proposal distribution given  
    
    P_ap_ac = (1-Pstick)*ones(1,Na)/(Na-1); % probability for each other key
    ii = sub2ind([Ns Na],[1:Ns]',a(:,i-1)); % get linear index for 'stick' action for each sample
    P_ap_ac(ii) = Pstick; % probability of proposal distribution given    
    
    a_pr = sum(repmat(a_samp(:,i),1,Na) > cumsum(P_ap_ac,2),2)+1;
    %a_pr = find(mnrnd(1,P_ap_ac)); % sample from proposal distribution
    a(:,i) = a_pr; % actual action i = proposed action
    %Va(i) = V(a_pr,i); % actual value of action i
    Va(:,i) = V(a(:,i),i);
    
    %V_pr = Va(i); % value of proposed action
    
    % Barker rule
    %aa(i) = exp(beta*V_pr)/(exp(beta*V_pr)+exp(beta*Vc)); % evaluate accept/reject probability
    % metropolis-hastings rule
    %aa(i) = min(1,exp(beta*V_pr)/exp(beta*Vc(i-1)));a
    
    
    %accept(i) = rand(1)<aa(i); % determine whether to accept/reject
    
    % update accepted action and value if accepted
end

r = Va;

sim.r = r;
sim.a = a;
%sim.accept = accept;
%sim.aa = aa;
%sim.ac = ac;

    
    