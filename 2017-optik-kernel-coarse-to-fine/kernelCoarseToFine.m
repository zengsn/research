% kernelRepresentation.m

% Parameters
boundary=1.0e8;
sigma=1.0e7;
% proportions of classes as candidate 
if exist('proportions','var')==0
    proportions = [0.2,0.4,0.6,0.8,1.0]; 
end

% numOfSamples=10;
% numOfClasses=20;
% numOfTrain=5; 
% numOfTest=5;

% Prepare data for training and test
for cc=1:numOfClasses
    for tt=1:numOfTrain
        clear Ai;
        Ai(1,:)=inputData(cc,tt,:); % A(i)
        trainData((cc-1)*numOfTrain+tt,:)=Ai;
    end
end
for cc=1:numOfClasses
    for tt=1:numOfTest
        clear Xi;
        Xi(1,:)=inputData(cc,tt+numOfTrain,:); % X(i)
        testData((cc-1)*numOfTest+tt,:)=Xi;
    end
end

numOfAllTrains=numOfClasses*numOfTrain; % 训练总数
numOfAllTests =numOfClasses*numOfTest;  % 测试总数
clear usefulTrain;
usefulTrain=trainData;

% Kernel data for training and test
for tii=1:numOfAllTrains
    k11=usefulTrain(tii,:);
    for tjj=1:numOfAllTrains
        k12=usefulTrain(tjj,:); % trainData
        kernel=exp(-(norm(k11-k12))^2/2/sigma);
        kernelTrainData(tii,tjj)=kernel;
    end
end
for tii=1:numOfAllTests
    k11=testData(tii,:);
    for tjj=1:numOfAllTrains
        k12=usefulTrain(tjj,:);
        kernel=exp(-(norm(k11-k12))^2/2 /sigma);
        kernelTestData(tii,tjj)=kernel;
    end
end

% Perform representation-based classification
clear kernelTestSample;
clear solution;
for kk=1:numOfAllTests
    testSample=testData(kk,:)/norm(testData(kk,:)); % normal 
    kernelTestSample=kernelTestData(kk,:);
    % 打印进度
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    
    % kernel coarse to fine
    if cond(kernelTrainData)<boundary % 1.0e8
        solution=inv(kernelTrainData)*kernelTestSample';
    else
        solution=inv(kernelTrainData+0.01*eye(numOfAllTrains))*kernelTestSample';
    end
    
    clear contribution;
    contribution=zeros(numOfAllTrains,numOfAllTrains);
    
    for cc=1:numOfClasses
        for tt=1:numOfTrain
            contribution(:,cc)=contribution(:,cc)+solution((cc-1)*numOfTrain+tt)*kernelTrainData(:,(cc-1)*numOfTrain+tt);
        end
    end
    
    clear deviation;
    for cc=1:numOfClasses
        deviation(cc)=norm(kernelTestSample'-contribution(:,cc));
    end
    
    [min_value xx]=min(deviation);
    labelKernel1(kk)=xx; % kernel classification results
    
    % sort the classes based on deviations    
    [resultKernel orderNum]=sort(deviation,'ascend');
    orderedDevKernel(kk,:)=resultKernel(:);
    %orderedNumbers(kk,:)=orderNum(:);  
    
    % Use different number of classes as candidate classes
    for pp=1:5 % 
        candidateTrainData=[];
        numOfCandidate = floor(numOfClasses*proportions(pp));
        for ff=1:numOfCandidate;
            for tt=1:numOfTrain
                candidateTrainData=[candidateTrainData
                    kernelTrainData((orderNum(ff)-1)*numOfTrain+tt,:)];
            end
        end
        
        candidateTrainData2=candidateTrainData*candidateTrainData';
        if cond(candidateTrainData2)<boundary %1.0e8
            solution=inv(candidateTrainData2)*candidateTrainData*kernelTestSample';
        else
            solution=inv(candidateTrainData2+0.01*eye(numOfCandidate*numOfTrain))*candidateTrainData*kernelTestSample';
        end
        
        clear contribution2;
        contribution2=zeros(numOfAllTrains,numOfAllTrains);
        for cc=1:numOfClasses
            for pqr=1:numOfCandidate;
                if orderNum(pqr)==cc
                    for tt=1:numOfTrain
                        contribution2(:,cc)=contribution2(:,cc)+solution((pqr-1)*numOfTrain+tt)*candidateTrainData(((pqr-1)*numOfTrain+tt),:)';
                    end
                end
            end
        end
        clear deviation2;
        for cc=1:numOfClasses
            deviation2(cc)=norm(kernelTestSample'-contribution2(:,cc));
        end
        [min_value yy]=min(deviation2);
        labelKernelN2(:,kk,pp)=yy; % stage 2 classification results
    
    end
    
end

% Stats the classification results
errorsKernel1=0;
for kk=1:numOfAllTests
    inte=floor((kk-1)/numOfTest+1);
    label(kk)=inte;
    if labelKernel1(kk)~=label(kk)
        errorsKernel1=errorsKernel1+1;
    end
end
    
% pick the best case
lowestErrorsKernel2=numOfAllTests;
bestKernelCandidate=0; % 
for pp=1:5
    errorsKernel2=0;
    numOfCandidate=floor(numOfClasses*proportions(pp));
    labelKernel2 = labelKernelN2(:,:,pp);
    for kk=1:numOfAllTests
        if labelKernel2(kk)~=label(kk)
            errorsKernel2=errorsKernel2+1;
        end
    end
    if errorsKernel2<lowestErrorsKernel2
        lowestErrorsKernel2 = errorsKernel2;
        bestKernelCandidate = proportions(pp);
    end 
    errorsRatioKernelCF(pp,1)=proportions(pp);
    errorsRatioKernelCF(pp,2)=errorsKernel2/numOfClasses/numOfTest;
end
errorsKernel2 = lowestErrorsKernel2; 

errorsRatio1=errorsKernel1/numOfClasses/numOfTest;
errorsRatio2=errorsKernel2/numOfClasses/numOfTest;

