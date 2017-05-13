% kernelRepresentation.m

% Parameters
boundary=1.0e8;
sigma=1.0e7;
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
        kernel=exp(-(norm(k11-k12))^2/2/sigma);
        kernelTestData(tii,tjj)=kernel;
    end
end

% Perform representation-based classification
clear kernelTestSample;
clear solution;
for kk=1:numOfAllTests
    kernelTestSample=kernelTestData(kk,:);
    % 打印进度
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    
    % if cond(New_K1)<1.0e6
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
    label1(kk)=xx; % original space classification results
    
    [result0 orderNum]=sort(deviation,'ascend');
    orderedDeviations(kk,:)=result0(:);
    orderedNumbers(kk,:)=orderNum(:);
    
    % Use fraction of classes (30%) as coarse candidate
    featureTrainData=[];
    featureSpace = floor(numOfClasses*0.3);
    for ff=1:featureSpace; 
        for tt=1:numOfTrain
            featureTrainData=[featureTrainData 
                kernelTrainData((orderNum(ff)-1)*numOfTrain+tt,:)];
        end
    end
    
    featureTrainData2=featureTrainData*featureTrainData';
    if cond(featureTrainData2)<boundary %1.0e8
        solution=inv(featureTrainData2)*featureTrainData*kernelTestSample';
    else
        solution=inv(featureTrainData2+0.01*eye(featureSpace*numOfTrain))*featureTrainData*kernelTestSample';
    end
    
    clear contribution2;
    contribution2=zeros(numOfAllTrains,numOfAllTrains);
    for cc=1:numOfClasses
        for pqr=1:featureSpace;
            if orderNum(pqr)==cc
                for tt=1:numOfTrain
                    contribution2(:,cc)=contribution2(:,cc)+solution((pqr-1)*numOfTrain+tt)*featureTrainData(((pqr-1)*numOfTrain+tt),:)';
                end
            end
        end
    end
    for cc=1:numOfClasses
        deviation2(cc)=norm(kernelTestSample'-contribution2(:,cc));
    end
    [min_value yy]=min(deviation2);
    label2(kk)=yy; % feature space classification results
end

% Stats the classification results
errors1=0;
errors2=0;
for kk=1:numOfAllTests
    inte=floor((kk-1)/numOfTest+1);
    label(kk)=inte;
    if label1(kk)~=label(kk)
        errors1=errors1+1;
    end
    if label2(kk)~=label(kk)
        errors2=errors2+1;
    end
end

errors_ratio1=errors1/numOfClasses/numOfTest;
errors_ratio2=errors2/numOfClasses/numOfTest;

