function [matout]=normcol_equal(matin)
% solve the proximal problem 
% matout = argmin||matout-matin||_F^2, s.t. matout(:,i)=1
matout = matin./repmat(sqrt(sum(matin.*matin,1)+eps),size(matin,1),1);


