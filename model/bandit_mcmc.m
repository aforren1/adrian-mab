function sim = bandit4_mcmc(V,beta,q)
% simulate mcmc on a single run with a particular time-evolving payoff V

[Na Nt] = size(V); % number of actions and timesteps

%%
a = zeros(1,Nt); % selected actions
a(1) = ceil(Na*rand(1)); % randomly pick the first action
ac(1) = a(1);  % current accepted sample


Va = zeros(1,Nt); % value of selection actions
Va(1) = V(a(1),1); % value of first action

Vc = Va(1); % value of current accepted action

% mcmc learning parameters
if(nargin<2)
    beta = .08; % selection 'temperature'
end

if(nargin<3)
    q = .9; % p(stay)
end
qq = (1-q)/(Na-1); % uniform distribution on other targets

% proposal distribution P_ij = P(a_pr = j|a_c = i)
P = qq*ones(Na);
P(eye(Na)>0)=q; 

% start simulation
for i=2:Nt
    % sample from proposal
    a_pr = find(mnrnd(1,P(ac(i-1),:))); % same from proposal distribution
    
    a(i) = a_pr; % actual action i = proposed action
    Va(i) = V(a_pr,i); % actual value of action i
    
    V_pr = Va(i); % value of proposed action
    
    % Barker rule
    %aa(i) = exp(beta*V_pr)/(exp(beta*V_pr)+exp(beta*Vc)); % evaluate accept/reject probability
    % metropolis-hastings rule
    aa(i) = min(1,exp(beta*V_pr)/exp(beta*Vc(i-1)));
    
    accept(i) = rand(1)<aa(i); % determine whether to accept/reject
    
    % update accepted action and value if accepted
    if(accept(i))
        ac(i) = a_pr;
        Vc(i) = V_pr;
    else
        ac(i) = ac(i-1);
        Vc(i) = Vc(i-1);
    end
end

r = Va;

sim.r = r;
sim.a = a;
sim.accept = accept;
sim.aa = aa;
sim.ac = ac;

    
    