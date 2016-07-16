%% Iterative Reweighted Least Squares (IRLS) for Logistic Regression
%  MAP estimation of hyperplane w with L1 penalty
%
% min NLL(w) = min -sum_{i=1}^{n} [y_i log mu_i + (1-y_i) log(1-mu_i)]
% where mu_i = sigm(w'x_i)
%
% XSw=Sz, w=(X'SX)^{-1}X'Sz, where z = Xw_k+S_k^{-1}(y-mu_k)
% X is n x d and S_k=diag(mu_ik(1-mu_ik))
%
% Newton updates: w_{k+1}= w_k - H^{-1} g_k
% with g_k = X(mu_k-y) + lambda*w and H = X'SX + lambda*I

close all; clear all;

%% synthetic dataset
n = 1000; d = 4; 
mu0 = zeros(d,1); 
Sigma0=diag(ones(d,1)); 
X = randn(n,d);
w0 = mvnrnd(mu0, Sigma0)'; %ground truth hyperplane
z0 = randn(n,1) + X*w0;    %ground truth z_i
y = sign(z0);              %ground truth labels \in {+1,-1}

%% IRLS
max_num_iter=1e2; w=zeros(d,max_num_iter);

%sigmoid function
sigm = @(X,y,w) 1./(1+exp(-y.*(X*w)));

%init w
w(:,1)=zeros(d,1);
%w(:,1)=randn(d,1); %may oscillate
%w(:,1)=mvnrnd(w0,0.1*Sigma0)'; %ground truth + noise

%prior / regularization for numerical stability
lambda=1e-4; vInv = 2*lambda*eye(d);

for k=1:max_num_iter
    
    mu_k = sigm(X,y,w(:,k));        %bernoulli probability   
    Sk = mu_k.*(1-mu_k) + eps;      %weight matrix 
    z_k = X*w(:,k)+(1-mu_k).*y./Sk; %response update
    
    %w(:,k+1)=inv(X'*Sk*X + vInv)*(X'*Sk*z_k); %w update
    Xd=X'*sparse(diag(Sk)); R=chol(Xd*X+vInv);
    w(:,k+1)=R\(R'\Xd*z_k);
    
    %check convergence
    fprintf('iter: %d, ||w_{k+1}-w_{k}||= %.6f\n', k, norm(w(:,k+1)-w(:,k),2));
    if (norm(w(:,k+1)-w(:,k),2) < 1e-6), break; end
end
w2=w(:,:);
w=w(:,1:k);

%% compute MSE
MSE = (cummean(w,2)-repmat(w0,1,size(w,2))).^2;

%% plot MSE
figure; legendInfo={};
for dim=1:d
    legendInfo{dim} = ['dim = ', num2str(dim)];
    plot(1:size(w,2),MSE(dim,:),'color',rand(1,3),'linewidth',2.0); hold on; grid on;
end
xlabel('iterations'); ylabel('MSE'); legend(legendInfo);
title('MSE vs iterations for IRLS Logistic Regression');


