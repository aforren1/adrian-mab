function sim = stick_rwd(V,beta,q)
% simulate bandit policy soft win/stay lose/switch

[Na Nt] = size(V); % number of actions and timesteps

%%
a = zeros(1,Nt); % selected actions
a(1) = ceil(Na*rand(1)); % randomly pick the first action
ac(1) = a(1);  % current accepted sample


Va = zeros(1,Nt); % value of selection actions
Va(1) = V(a(1),1); % value of first action

Vc = Va(1); % value of current accepted action

% policy parameters
if(nargin<2)
    beta = .08; % selection 'temperature'
end

if(nargin<3)
    q = [.9 60]; % p(stay)
end

% proposal distribution P_ij = P(a_pr = j|a_c = i)
%P = qq*ones(Na);
%P(eye(Na)>0)=q; 

% plot p_stick
figure(2); clf; hold on
rr = [1:100];
pstick_r = q(1)*exp(beta*rr)./(exp(beta*q(2))+exp(beta*rr))+(1-q(1));

plot(rr,pstick_r,'k')

% start simulation
for i=2:Nt
    % sample from proposal
    Pstick = q(1)*exp(beta*Va(i-1))./(exp(beta*q(2))+exp(beta*Va(i-1)))+(1-q(1));
    P_ap_ac = (1-Pstick)*ones(1,Na)/(Na-1); % probability for each other key
    P_ap_ac(a(i-1)) = Pstick; % probability of proposal distribution given  
    
    a_pr = find(mnrnd(1,P_ap_ac)); % sample from proposal distribution
    a(i) = a_pr; % actual action i = proposed action
    %Va(i) = V(a_pr,i); % actual value of action i
    Va(i) = V(a(i),i);
    
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

    
    