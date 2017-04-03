% DistinctiveSR_L1.m
% Distinctive sparse representation with L1

%% Parameters 
% numOfSamples=10;
% numOfClasses=40;
% inputData
% numOfTrain
% numOfTest
%gamma=1e-3
gamma
iterations=100;
%iterations
sigma

%load('input0.mat');
%clear inputData;
%inputData=input0;


%% print summary of experiment
fprintf('numOfTrain=%d\tnumOfTest=%d\tnumOfClasses= %d\n', numOfTrain, numOfTest, numOfClasses);

%% classification
numOfAllTrain=numOfClasses*numOfTrain; % number of all training samples
numOfAllTest=numOfClasses*numOfTest;   % number of all test samples

X=trainData';
Y=testData';

Xt = trainData;
XtX=zeros(numOfTrain*numOfClasses);
XtX=trainData*trainData';

%% solve the equation (11)
[dimention, ~]=size(X);
M=eye(numOfTrain*numOfClasses);
for kk=1:numOfClasses
    xi=X(:,(kk-1)*numOfTrain+1:kk*numOfTrain);
    M((kk-1)*numOfTrain+1:kk*numOfTrain,(kk-1)*numOfTrain+1:kk*numOfTrain)=xi'*xi;
end
% T=inv((1+2*gamma)*XtX+2*gamma*class_num*M);
T_L2=inv(XtX+2*gamma*(XtX+numOfClasses*M));
%sigma = 1;
tau = 1/norm(XtX)/sigma;
T_L1=inv(eye(size(XtX))/sigma+2*gamma*(XtX+numOfClasses*M));

%% classify all test samples
errorsL1=0; errorsL2=0;
clear solutionL1;
clear solutionL2;
clear labelL1;
clear labelL2;
for kk=1:numOfAllTest
    y(:,1)=Y(:,kk);
    solutionL2=T_L2*(trainData*y); % L2拟合项算法的解
    solutionL1=solutionL2;
    % print progress ...
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % new method
    z = zeros(size(y));
    z_bar = z;
    for iter = 1:iterations
        z_old = z;
        solutionL1=T_L1*(solutionL1+sigma*Xt*z_bar); % L1拟合项算法的解
        z = z + tau*(y - X*solutionL1);
        z = z ./ max(1,abs(z));
        z_bar = 2*z - z_old;
    end
    %% sparse contribution
    contributionL1=zeros(dimention,numOfClasses);  
    contributionL2=zeros(dimention,numOfClasses);    
    for cc=1:numOfClasses
        for tt=1:numOfTrain
            contributionL1(:,cc)=solutionL1((cc-1)*numOfTrain+tt)*X(:,(cc-1)*numOfTrain+tt)+contributionL1(:,cc);
            contributionL2(:,cc)=solutionL2((cc-1)*numOfTrain+tt)*X(:,(cc-1)*numOfTrain+tt)+contributionL2(:,cc);
        end
    end
    clear deviation1;
    clear deviation2;
    for cc=1:numOfClasses
        deviationL1(cc)=norm(y-contributionL1(:,cc));
        deviationL2(cc)=norm(y-contributionL2(:,cc));
    end
    
    [minValue xxL1]=min(deviationL1);
    labelL1(kk)=xxL1;
    
    [minValue xxL2]=min(deviationL2);
    labelL2(kk)=xxL2;
    
    if labelL1(kk)~=testLabel(kk)
        errorsL1=errorsL1+1;
    end
    if labelL2(kk)~=testLabel(kk)
        errorsL2=errorsL2+1;
    end
    
    % pick case for demo
    %if l1Labels(i)==origLabels(i) && l2Labels(i)~=origLabels(i)
        %kk % print
        %break;
    %end
    
end
errorsRatioL1=errorsL1/numOfAllTest;
accuracyL1=1-errorsRatioL1 % print
errorsRatioL2=errorsL2/numOfAllTest;
accuracyL2=1-errorsRatioL2 % print