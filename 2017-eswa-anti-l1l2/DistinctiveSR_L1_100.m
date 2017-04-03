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
%sigma=1
sigma

%load('input0.mat');
%clear inputData;
%inputData=input0;


%% print summary of experiment
fprintf('numOfTrain=%d\tnumOfTest=%d\tnumOfClasses= %d\n', numOfTrain, numOfTest, numOfClasses);

%% prepare samples for training
for cc=1:numOfClasses
    clear Ai;
    for tt=1:numOfTrain
        Ai(1,:)=double(inputData(cc,tt,:)); % A(i)
        trainData((cc-1)*numOfTrain+tt,:)=Ai/norm(Ai);
        trainLabels((cc-1)*numOfTrain+tt)=cc;
    end
end
%% prepare samples for test
for cc=1:numOfClasses
    clear Xi;
    for tt=1:numOfTest
        Xi = inputData(cc,tt+numOfTrain,:); % X(i)
        Xi = imnoise(Xi,'salt & pepper',salt);% 原始图像增加30%的椒盐噪声
        Xi = double(Xi);
        testData((cc-1)*numOfTest+tt,:)=Xi(:)/norm(Xi(:));
        testLabels((cc-1)*numOfTest+tt)=cc;
    end
end

%% classification
numOfAllTrains=numOfClasses*numOfTrain; % number of all training samples
numOfAllTests=numOfClasses*numOfTest;   % number of all test samples
clear usefulTrain;
usefulTrain=trainData;
clear preserved;

X=trainData';
Y=testData';

Xt = trainData;
XtX=zeros(numOfTrain*numOfClasses);
XtX=trainData*trainData';

%% solve the equation (11)
[size1 size2]=size(X);
M=eye(numOfTrain*numOfClasses);
for i=1:numOfClasses
    xi=X(:,(i-1)*numOfTrain+1:i*numOfTrain);
    M((i-1)*numOfTrain+1:i*numOfTrain,(i-1)*numOfTrain+1:i*numOfTrain)=xi'*xi;
end
% T=inv((1+2*gamma)*XtX+2*gamma*class_num*M);
T_L2=inv(XtX+2*gamma*(XtX+numOfClasses*M));
%sigma = 1;
tau = 1/norm(XtX)/sigma;
T_L1=inv(eye(size(XtX))/sigma+2*gamma*(XtX+numOfClasses*M));

%% classify all test samples
errors1=0; errors2=0;
clear solutionL1;
clear solutionL2;
clear testLabels1;
clear testLabels2;
for i=1:numOfAllTests
    y(:,1)=Y(:,i);
    solutionL2=T_L2*(trainData*y); % L2拟合项算法的解
    solutionL1=solutionL2;
    % print progress ...
    fprintf('%d ', i);
    if mod(i,20)==0
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
    contributionL1=zeros(size1,numOfClasses);  
    contributionL2=zeros(size1,numOfClasses);    
    for cc=1:numOfClasses
        for tt=1:numOfTrain
            contributionL1(:,cc)=solutionL1((cc-1)*numOfTrain+tt)*X(:,(cc-1)*numOfTrain+tt)+contributionL1(:,cc);
            contributionL2(:,cc)=solutionL2((cc-1)*numOfTrain+tt)*X(:,(cc-1)*numOfTrain+tt)+contributionL2(:,cc);
        end
    end
    clear deviation1;
    clear deviation2;
    for cc=1:numOfClasses
        deviation1(cc)=norm(y-contributionL1(:,cc));
        deviation2(cc)=norm(y-contributionL2(:,cc));
    end
    
    [minValue label1]=min(deviation1);
    testLabels1(i)=label1;
    
    [minValue label2]=min(deviation2);
    testLabels2(i)=label2;
    
    inte=floor((i-1)/numOfTest)+1;
    origLabels(i)=inte;
    
    if testLabels1(i)~=origLabels(i)
        errors1=errors1+1;
    end
    if testLabels2(i)~=origLabels(i)
        errors2=errors2+1;
    end
    
    % pick case for demo
    if testLabels1(i)==origLabels(i) && testLabels2(i)~=origLabels(i)
        i % print
        break;
    end
    
end
errorsRatioL1=errors1/numOfAllTests;
accuracy1=1-errorsRatioL1 % print
errorsRatioL2=errors2/numOfAllTests;
accuracy2=1-errorsRatioL2 % print