function [r a] = bandit4_KF_softmax(V,alpha,beta)
% bandit problem with KF value estimation and softmax action selection
Na = size(V,1); % number of actions available

if(nargin<2)
    alpha = 0; % default to no stickiness
end

if(nargin<3)
    beta = .112;
end
% tracking value of different options
mu_pre = zeros(size(V));
sigma2_pre = zeros(size(V));
mu_post = zeros(size(V));
sigma2_post = zeros(size(V));

mu_0 = 87.1*ones(Na,1);
sigma2_0 = 4.61;
lambda = .9836;
theta = 50;
sigma_d = 2.8;
sigma_o = 4;
    
% First timestep
% pick first action at random
aa(:) = mnrnd(1,ones(1,Na)/Na); % same from proposal distribution
a(1) = find(aa);
Nt = size(V,2);

for i=1:Nt
    % update prior
    if(i==1)
        mu_pre(:,i) = lambda*mu_0 + (1-lambda)*theta*ones(Na,1);
        sigma2_pre(:,i) = lambda^2*sigma2_0 + sigma_d^2;
    else
        mu_pre(:,i) = lambda*mu_post(:,i-1) + (1-lambda)*theta*ones(Na,1);
        sigma2_pre(:,i) = lambda^2*sigma2_post(:,i-1) + sigma_d^2;
    end
    
    % select action
    % softmax
    
    if(rand(1)<alpha & i>1)
        a(i) = a(i-1);
    else
        P = exp(beta*mu_pre(:,i))/sum(exp(beta*mu_pre(:,i)));
        aa = mnrnd(1,P); % sample from softmax distribution
        a(i) = find(aa);
    end
    
    r(i) = V(a(i),i); % reward on trial 1
    delta(i) = r(i) - mu_pre(a(i),i); % reward prediction error
    kappa(i) = sigma2_pre(a(i),i)/(sigma2_pre(a(i),i)+sigma_o^2);

    % kalman update
    mu_post(a(i),i) = mu_pre(a(i),i) + kappa(i)*delta(i);
    sigma2_post(a(i),i) = (1-kappa(i))*sigma2_pre(a(i),i);
    
    a_not_chosen = find(aa==0);
    mu_post(a_not_chosen,i) = mu_pre(a_not_chosen,i);
    sigma2_post(a_not_chosen,i) = sigma2_pre(a_not_chosen,i);
    
end

% evaluate
% figure(3); clf; hold on
% plot(V(2,:),'k')
% plot(mu_pre(2,:),'r')
