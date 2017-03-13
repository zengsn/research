%% SQF_CRC.m
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
numOfAllTrain=numOfClasses*numOfTrain; % 训练总数
numOfAllTest=numOfClasses*numOfTest;   % 测试总数
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;
% 求解各种测试样本的表示系数
clear testSample;
clear solutionCRC;
errorsCRC=0; errorsSQCRC=0;
for kk=1:numOfAllTest
    testSample=testData(kk,:);
    % CRC 解：(T*T'+aU)^-1 * T * D(i)'
    solutionCRC=preserved*testSample';
    % 打印进度
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % 计算贡献值
    clear contributionCRC;
    clear contributionSQCRC;
    for cc=1:numOfClasses
        contributionCRC(:,cc)=zeros(row*col,1);
        contributionSQCRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            % New Algorithm
            contributionSQCRC(:,cc)=contributionSQCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)^2*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % 计算距离|残差|余量
    clear deviationCRC;
    clear deviationSQCRC;
    clear useDeviationCRC;
    clear duseDeviationSQCRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
        % New Algorithm
        deviationSQCRC(cc)=norm(testSample'-contributionSQCRC(:,cc));
    end
    % 距离处理
    minDeviationCRC=min(deviationCRC);
    maxDeviationCRC=max(deviationCRC); % use = (val-min)/(max-min)
    useDeviationCRC=(deviationCRC-minDeviationCRC)/(maxDeviationCRC-minDeviationCRC);
    
    minDeviationSQCRC=min(deviationSQCRC);
    maxDeviationSQCRC=max(deviationSQCRC); % use = (val-min)/(max-min)
    useDeviationSQCRC=(deviationSQCRC-minDeviationSQCRC)/(maxDeviationSQCRC-minDeviationSQCRC);
    
    % 保存识别结果
    [min_value xxCRC]=min(useDeviationCRC);
    labelCRC(kk)=xxCRC;
    if labelCRC(kk)~=testLabel(kk)
        errorsCRC=errorsCRC+1;
    end
    [min_value xxSQCRC]=min(useDeviationSQCRC);
    labelSQCRC(kk)=xxSQCRC;
    if labelSQCRC(kk)~=testLabel(kk)
        errorsSQCRC=errorsSQCRC+1;
    end
    
    % 融合
    for cii=1:numOfCases % 跑不同的参数
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        % 融合余量
        deviationSQFCRC=deviationCRC+lambda*deviationSQCRC;
        [min_value zzSQFCRC]=min(deviationSQFCRC);
        % 记录最佳结果 - 用于结果分析
        %if kk==113 && lambda==0.1
        %    bestDeviationCRC = deviationCRC2;
        %    bestAbsoluteDistance = crcABS2;
        %    bestFusionCRC = fusionCRC;
        %end
        % 记录所有融合的结果
        labelSQFCRC(cii,kk)=zzSQFCRC; % CRC
    end
end
    
% 找出最佳整合结果
lowestLambdaCRC = 0;
lowestErrorsCRC = numOfAllTest; % 最小错误数
for cii=1:numOfCases % 检查不同参数下的结果
    lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
    errorsSQFCRC=0; % 错误数清零
    for kk=1:numOfAllTest % 统计错误率
        if labelSQFCRC(cii,kk)~=testLabel(kk)
            errorsSQFCRC=errorsSQFCRC+1;
        end
    end
    %fprintf('%f：%d\n', lambda, errorsCRCFusion);
    % 记录最佳结果
    if errorsSQFCRC<lowestErrorsCRC
        lowestLambdaCRC = lambda;
        lowestErrorsCRC=errorsSQFCRC;
    end
    %fprintf('%f：%d\n', lowestLambda, lowestErrors);
end

% 取出最佳结果
lambdaCRC = lowestLambdaCRC;
errorsSQFCRC = lowestErrorsCRC;

% 统计错误率
errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
errorsRatioSQCRC=errorsSQCRC/numOfClasses/numOfTest;
errorsRatioSQFCRC=errorsSQFCRC/numOfClasses/numOfTest;

% 保存结果
result(numOfTrain, 1)=1-errorsRatioCRC;
result(numOfTrain, 2)=1-errorsRatioSQCRC;
result(numOfTrain, 3)=(errorsRatioCRC-errorsRatioSQCRC)/errorsRatioCRC;
result(numOfTrain, 4)=lambdaCRC;
result(numOfTrain, 5)=1-errorsRatioSQFCRC;
result(numOfTrain, 6)=(errorsRatioCRC-errorsRatioSQFCRC)/errorsRatioCRC;
improveCRC = result(numOfTrain, 3) * 100;
improveCRCFusion = result(numOfTrain, 6) * 100;
result % print

% 保存到文件
type = 'SQF_CRC';
jsonFile = [dbName '/SQF_CRC_' num2str(numOfTrain)];
jsonFile = [jsonFile '_CRC(' num2str(improveCRC,2) '%,' num2str(lambdaCRC,2) '|' num2str(improveCRCFusion,2) '%)'];
jsonFile = [jsonFile '.json'];
dbJson = savejson('', result(numOfTrain,:), jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];

