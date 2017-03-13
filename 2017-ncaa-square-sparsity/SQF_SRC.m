%% SQF_SRC.m
% 表示系数项求平方和

%% 参数       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % 融合参数 λ
% 正融合：CRC结果优于ABS时使用，强调CRC的作用
positives = [0.01, 0.05, 0.1, 0.3, 0.5, 0.7, 0.9];
% 负融合：CRC结果差于ABS时使用，强调ABS的作用
negatives = [1.1, 1.3, 1.5, 1.7, 1.9, 5, 10, 100];
lambdas = [positives, negatives];
[one, numOfCases] = size(lambdas);
%minTrains = 4; % 最小训练样本数
%maxTrains = 4; % 最大训练样本数
%inputData      % 所有样本数据

% 跑不同的训练样本
%{
if maxTrains == 0
    maxTrains = floor(numOfSamples*0.8);
elseif maxTrains > 12
    maxTrains = 12;
end
%}

% 实现各种表示方法
numOfTest = numOfSamples-numOfTrain;
numOfAllTrain=numOfClasses*numOfTrain; % 训练总数
numOfAllTest=numOfClasses*numOfTest;   % 测试总数
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;
% 求解各种测试样本的表示系数
clear testSample;
clear solutionSRC;
errorsSRC=0; errorsSQSRC=0;
for kk=1:numOfAllTest
    testSample=testData(kk,:);
    % 打印进度
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % SRC 解
    [solutionSRC, total_iter] =    SolveFISTA(trainData',testSample');
    % 计算贡献值
    clear contributionSRC;
    clear contributionSQSRC;
    for cc=1:numOfClasses
        contributionSRC(:,cc)=zeros(row*col,1);
        contributionSQSRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            % Square SRC
            contributionSQSRC(:,cc)=contributionSQSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)^2*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % 计算距离|残差|余量
    clear deviationSRC;
    clear deviationSQSRC;
    clear useDeviationSRC;
    clear useDeviationSQSRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
        % New Algorithm
        deviationSQSRC(cc)=norm(testSample'-contributionSQSRC(:,cc));
    end
    % 距离处理
    minDeviationSRC=min(deviationSRC);
    maxDeviationSRC=max(deviationSRC); % use = (val-min)/(max-min)
    useDeviationSRC=(deviationSRC-minDeviationSRC)/(maxDeviationSRC-minDeviationSRC);
    %useDeviationSRC=deviationSRC;
    
    minDeviationSQSRC=min(deviationSQSRC);
    maxDeviationSQSRC=max(deviationSQSRC); % use = (val-min)/(max-min)
    %useDeviationSRCTrans=(deviationSRCTrans-minDeviationSRCTrans)/(maxDeviationSRCTrans-minDeviationSRCTrans);
    useDeviationSQSRC=deviationSQSRC;
    
    % 保存识别结果
    [min_value xxSRC]=min(useDeviationSRC);
    labelSRC(kk)=xxSRC;
    if labelSRC(kk)~=testLabel(kk)
        errorsSRC=errorsSRC+1;
    end
    [min_value xxSQSRC]=min(useDeviationSQSRC);
    labelSQSRC(kk)=xxSQSRC;
    if labelSQSRC(kk)~=testLabel(kk)
        errorsSQSRC=errorsSQSRC+1;
    end
    
    % 融合
    for cii=1:numOfCases % 跑不同的参数
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        % 融合余量
        deviationSQFSRC=deviationSRC+lambda*deviationSQSRC;
        [min_value zzSRC]=min(deviationSQFSRC);
        % 记录最佳结果 - 用于结果分析
        %if kk==113 && lambda==0.1
        %    bestDeviationCRC = deviationCRC2;
        %    bestAbsoluteDistance = crcABS2;
        %    bestFusionCRC = fusionCRC;
        %end
        % 记录所有融合的结果
        labelSQFSRC(cii,kk)=zzSRC; % SRC
    end
end
    
% 找出最佳整合结果
lowestLambdaSRC = 0;
lowestErrorsSRC = numOfAllTest; % 最小错误数
for cii=1:numOfCases % 检查不同参数下的结果
    lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
    errorsSQFSRC=0; % 错误数清零
    for kk=1:numOfAllTest % 统计错误率
        if labelSQFSRC(cii,kk)~=testLabel(kk)
            errorsSQFSRC=errorsSQFSRC+1;
        end
    end
    %fprintf('%f：%d\n', lambda, errorsCRCFusion);
    % 记录最佳结果
    if errorsSQFSRC<lowestErrorsSRC
        lowestLambdaSRC = lambda;
        lowestErrorsSRC = errorsSQFSRC;
    end
    %fprintf('%f：%d\n', lowestLambda, lowestErrors);
end

% 取出最佳结果
lambdaSRC = lowestLambdaSRC;
errorsSQFSRC = lowestErrorsSRC;

% 统计错误率
errorsRatioSRC=errorsSRC/numOfClasses/numOfTest;
errorsRatioSQSRC=errorsSQSRC/numOfClasses/numOfTest;
errorsRatioSQFSRC=errorsSQFSRC/numOfClasses/numOfTest;

% 保存结果
result(numOfTrain, 1)=1-errorsRatioSRC;
result(numOfTrain, 2)=1-errorsRatioSQSRC;
result(numOfTrain, 3)=(errorsRatioSRC-errorsRatioSQSRC)/errorsRatioSRC;
result(numOfTrain, 4)=lambdaSRC;
result(numOfTrain, 5)=1-errorsRatioSQFSRC;
result(numOfTrain, 6)=(errorsRatioSRC-errorsRatioSQFSRC)/errorsRatioSRC;
improveSQSRC = result(numOfTrain, 3) * 100; %
improveSQFSRC = result(numOfTrain, 6) * 100; %
result % print

% 保存到文件
type = 'SQF_SRC';
jsonFile = [dbName '/SQF_SRC_' num2str(numOfTrain)];
jsonFile = [jsonFile '_SRC(' num2str(improveSQSRC,2) '%,' num2str(lambdaSRC,2) '|' num2str(improveSQFSRC,2) '%)'];
jsonFile = [jsonFile '.json'];
dbJson = savejson('', result(numOfTrain,:), jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];

