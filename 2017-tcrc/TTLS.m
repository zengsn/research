function x = T_TLS(A,b,thresh)

% Solves the linear equation Ax=b using
% truncated total least squares.
%
% Ref. Regularization by Truncated TLS
% Fierro et al, Siam J Sci Comput 1997
%
% A is the matrix
% b is the RHS vector
% thresh (optional) is the SVD threshold

[m n] = size(A);
if sum(size(b)-[m 1])
    error('A, b size mis-match')
end
if nargin==2
    thresh = eps;
end

% augmented matrix
Z = [full(A');b'];
[V W] = svd(Z);

% find sing val above
d = diag(W); %disp(d); return;
k = sum(d<thresh); %disp(thresh);
q = n - k + 1;

% proceed to checkout
V12 = V(1:n,q:end);
V22 = V(n+1,q:end);
x = -V12 * V22' ./ norm(V22).^2;