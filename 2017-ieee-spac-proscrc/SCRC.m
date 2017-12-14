% SCRC.m
% SRC x CRC

% Parameters already set
% numOfSamples=10;
% numOfClasses=40;
% inputData
% numOfTrain
% numOfTest
% trainData % already set
% testData % already set

algName = 'SCRC';

% print summary of experiment
fprintf('numOfTrain=%d\tnumOfClasses= %d\n', numOfTrain, numOfClasses);

[numOfAllTrains, sampleSize] = size(trainData); % number of all training samples
[numOfAllTests, sampleSize] = size(testData);   % number of all test samples

clear usefulTrain;
usefulTrain=trainData;
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
% solve the coefficients by SRC and CRC
clear testSample;
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
    clear contributionSCRC;
    for cc=1:numOfClasses
        contributionSCRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSCRC(:,cc)=contributionSCRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*solutionCRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
        end
    end
    % 计算距离|残差|余量
    clear deviationSCRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSCRC(cc)=norm(testSample'-contributionSCRC(:,cc));
    end
    
    % 保存识别结果
    [min_value xxSCRC]=min(deviationSCRC);
    labelSCRC(kk)=xxSCRC;
    
    % 分析余量
    %if kk==63 break; end
end

% stats the error rates
errorsSCRC=0; 

for kk=1:numOfAllTests
    %inte=floor((kk-1)/numOfTest+1);
    %dataLabel(kk)=inte;
    
    if labelSCRC(kk)~=testLabel(kk)
        errorsSCRC=errorsSCRC+1;
    end
end

errorsRatioSCRC = errorsSCRC/numOfAllTests;
accuracy = 1-errorsRatioSCRC % print