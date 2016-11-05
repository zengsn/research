% Multiplication.m
% Fusion of SRC and CRC by multiplying each entry in coefficient vectors

% Parameters already set
% numOfSamples=10;
% numOfClasses=40;
% inputData
% numOfTrain
% numOfTest
% trainData % already set
% testData % already set

% print summary of experiment
fprintf('numOfTrain=%d\tnumOfTest=%d\tnumOfClasses= %d\n', numOfTrain, numOfTest, numOfClasses);

numOfAllTrains=numOfClasses*numOfTrain; % number of all training samples
numOfAllTests=numOfClasses*numOfTest;   % number of all test samples
clear usefulTrain;
usefulTrain=trainData;
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
% solve the coefficients by SRC and CRC
clear testSample;
clear solutionCRC;
for kk=1:numOfAllTests
    testSample=testData(kk,:);
    % CRC solution：(T*T'+aU)^-1 * T * D(i)'
    solutionCRC=preserved*testSample';
    % print progress ...
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % SRC solution
    [solutionSRC, total_iter] =    SolveFISTA(usefulTrain',testSample');
    % compute contributions
    clear contributionCRC;
    clear contributionSRC;
    clear contributionFusion;
    for cc=1:numOfClasses
        contributionCRC(:,cc)=zeros(row*col,1);
        contributionSRC(:,cc)=zeros(row*col,1);
        contributionFusion(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
            contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
            % New Algorithm
            contributionFusion(:,cc)=contributionFusion(:,cc)+(solutionSRC((cc-1)*numOfTrain+tt)*solutionCRC((cc-1)*numOfTrain+tt))*usefulTrain((cc-1)*numOfTrain+tt,:)';
        end
    end
    % 计算距离|残差|余量
    clear deviationSRC;
    clear deviationCRC;
    clear deviationFusion;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
        deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
        % New Algorithm
        deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc));
    end
    
    % 保存识别结果
    [min_value xxSRC]=min(deviationSRC);
    labelSRC(kk)=xxSRC;
    [min_value xxCRC]=min(deviationCRC);
    labelCRC(kk)=xxCRC;
    [min_value xxFusion]=min(deviationFusion);
    labelFusion(kk)=xxFusion;
end

% stats the error rates
errorsSRC=0; errorsCRC=0; errorsFusion=0;

for kk=1:numOfAllTests
    inte=floor((kk-1)/numOfTest+1);
    dataLabel(kk)=inte;
    
    if labelSRC(kk)~=dataLabel(kk)
        errorsSRC=errorsSRC+1;
    end
    if labelCRC(kk)~=dataLabel(kk)
        errorsCRC=errorsCRC+1;
    end
    if labelFusion(kk)~=dataLabel(kk)
        errorsFusion=errorsFusion+1;
    end
end

errorsRatioSRC = errorsSRC/numOfAllTests;
errorsRatioCRC = errorsCRC/numOfAllTests;
errorsRatioFusion = errorsFusion/numOfAllTests;