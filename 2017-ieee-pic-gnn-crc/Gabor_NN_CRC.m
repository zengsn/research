% Gabor_NN_CRC.m
% 小波优化样本之后，通过绝对值距离分类法优化CRC，自动寻找最佳融合参数

% 原始论文
% https://github.com/zengsn/researches/tree/master/2016-caai%2Ctrit-crc-abs-fusion
% 改用 Gabor 小波
% https://cn.mathworks.com/matlabcentral/fileexchange/59500-gabor-wavelets

% 所需数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % 融合参数 λ
% 正融合：CRC结果优于ABS时使用，强调CRC的作用
positives = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; 
% 负融合：CRC结果差于ABS时使用，强调NN的作用
negatives = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 5, 10, 100];
lambdas = [positives, negatives];
[one, numOfCases] = size(lambdas);
%minTrains = 4; % 最小训练样本数
%maxTrains = 4; % 最大训练样本数
%inputData      % 所有样本数据

% 跑不同的训练样本
if maxTrains == 0
    maxTrains = floor(numOfSamples*0.8);
elseif maxTrains > 12
    maxTrains = 12;
end

% 计算小波层数
% !!!! 可调参数 
waveletName = 'gabor'; % 'rbio1.5'; % 使用小波 haar 
imageSize=[row, col]; % 样本大小
% % 
% % maxLevels = wmaxlev(imageSize,waveletName); 
% % % !!!! 可调参数 
% % if (maxLevels>1) % 可改为随机层数
% %     maxLevels = maxLevels-1;
% % end
%maxTrains = 1;
for numOfTrain=minTrains:numOfStep:maxTrains
    % 测试样本数
    numOfTest = numOfSamples-numOfTrain;
    fprintf('训练样本=%d；\t测试样本=%d；\t共 %d 组对象。\n', numOfTrain, numOfTest, numOfClasses);
    %设置gabor滤波器
    gaborArray = gaborFilterBank(5,8,39,39); 
    % 取出相应原始训练集和测试集
    for cc=1:numOfClasses
        %clear Ai;
        for tt=1:numOfTrain
            Ai(1,:)=inputData(cc,tt,:); % A(i)
            trainData((cc-1)*numOfTrain+tt,:)=Ai/norm(Ai);
            % 2D wavelet analysis newAi=wavedec2(Ai,maxLevels,waveletName);
            % 小波变换，提取gabor特征
            newAi= gaborFeatures(Ai,gaborArray,4,4); 
            trainData1((cc-1)*numOfTrain+tt,:)=newAi/norm(newAi);
        end
    end
    
    for cc=1:numOfClasses
        %clear Xi;
        for tt=1:numOfTest
            Xi(1,:)=inputData(cc,tt+numOfTrain,:); % X(i)
            testData((cc-1)*numOfTest+tt,:)=Xi/norm(Xi);
            % 2D wavelet analysis newXi=wavedec2(Xi,maxLevels,waveletName);       
            % 小波变换，提取gabor特征
            newXi= gaborFeatures(Xi,gaborArray,4,4);           
            testData1((cc-1)*numOfTest+tt,:)=newXi/norm(newXi);
        end
    end
    
    % 实现各种表示方法
    numOfAllTrains=numOfClasses*numOfTrain; % 训练总数
    numOfAllTests=numOfClasses*numOfTest;   % 测试总数
    %clear usefulTrain;
    usefulTrain=trainData;
    usefulTrain1=trainData1;
    %clear preserved;
    % (T*T'+aU)-1 * T
    preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
    preserved1=inv(usefulTrain1*usefulTrain1'+0.01*eye(numOfAllTrains))*usefulTrain1;
    % 求解各种测试样本的表示系数
    %clear testSample;
    %clear solutionCRC;
    for kk=1:numOfAllTests
        testSample=testData(kk,:);
        testSample1=testData1(kk,:);
        % 大小发生变化
        [row1, col1] = size(testSample1); 
        % CRC 解：(T*T'+aU)^-1 * T * D(i)'
        solutionCRC=preserved*testSample';
        solutionGCRC=preserved1*testSample1';
        % 打印进度
        fprintf('%d ', kk);
        if mod(kk,20)==0
            fprintf('\n');
        end
        
        % 计算贡献值
        %clear contributionCRC;
        for cc=1:numOfClasses
            contributionCRC(:,cc)=zeros(row*col,1);
            contributionGCRC(:,cc)=zeros(row1*col1,1);
            deviationNN(cc)=0; % abs of the contribution for crc
            deviationGNN(cc)=0; % abs of the contribution for crc
            
            for tt=1:numOfTrain
                % C(i) = sum(S(i)*T)
                contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
                contributionGCRC(:,cc)=contributionGCRC(:,cc)+solutionGCRC((cc-1)*numOfTrain+tt)*usefulTrain1((cc-1)*numOfTrain+tt,:)';
                deviationNN(cc)=deviationNN(cc)+abs(solutionCRC((cc-1)*numOfTrain+tt));
                deviationGNN(cc)=deviationGNN(cc)+abs(solutionGCRC((cc-1)*numOfTrain+tt));
            end
        end
        % 计算距离|残差|余量
        %clear deviationCRC;
        for cc=1:numOfClasses
            % r(i) = |D(i)-C(i)|
            deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
            deviationGCRC(cc)=norm(testSample1'-contributionGCRC(:,cc));
        end
        % 优化误差 CRC
        if redoDeviation==1
            minDeviationCRC=min(deviationCRC);
            maxDeviationCRC=max(deviationCRC);
            minDeviationNN=min(deviationNN);
            maxDeviationNN=max(deviationNN);
            deviationCRC=(deviationCRC-minDeviationCRC)/(maxDeviationCRC-minDeviationCRC);
            deviationNN=(deviationNN-minDeviationNN)/(maxDeviationNN-minDeviationNN);
            minDeviationGCRC=min(deviationGCRC);
            maxDeviationGCRC=max(deviationGCRC);
            minDeviationGNN=min(deviationGNN);
            maxDeviationGNN=max(deviationGNN);
            deviationGCRC=(deviationGCRC-minDeviationGCRC)/(maxDeviationGCRC-minDeviationGCRC);
            deviationGNN=(deviationGNN-minDeviationGNN)/(maxDeviationGNN-minDeviationGNN);
        else % 保持不变
        end
        % 识别结果 - 原始CRC
        [min_value1 xxCRC]=min(deviationCRC);
        labelCRC(kk)=xxCRC;
        [min_value2 yyNN]=max(deviationNN);
        labelNN(kk)=yyNN;
        % 识别结果 - 小波CRC
        [min_value1 xxGCRC]=min(deviationGCRC);
        labelGCRC(kk)=xxGCRC;
        [min_value2 yyGNN]=max(deviationGNN);
        labelGNN(kk)=yyGNN;
        % - 用不同参数融合的结果        
        for cii=1:numOfCases % 跑不同的参数
            lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
            % 融合余量
            fusionNNCRC=deviationCRC-lambda*deviationNN;
            [min_value3 zzNNCRC]=min(fusionNNCRC);
            fusionGNNCRC=deviationGCRC-lambda*deviationGNN;
            [min_value3 zzGNNCRC]=min(fusionGNNCRC);
            % 记录所有融合的结果
            labelNNCRC(cii,kk)=zzNNCRC; % 融合结果
            labelGNNCRC(cii,kk)=zzGNNCRC; % 融合结果
        end        
    end
    
    % 先统计CRC和NN的识别结果误差
    errorsCRC=0; errorsGCRC=0;
    errorsNN=0;errorsGNN=0;
    errorsNNCRC=0;errorsGNNCRC=0;
    
    for kk=1:numOfAllTests
        inte=floor((kk-1)/numOfTest+1);
        dataLabel(kk)=inte; % 正确位置
        
        % CRC and NN
        if labelCRC(kk)~=dataLabel(kk)
            errorsCRC=errorsCRC+1;
        end
        if labelNN(kk)~=dataLabel(kk)
            errorsNN=errorsNN+1;
        end
        if labelGCRC(kk)~=dataLabel(kk)
            errorsGCRC=errorsGCRC+1;
        end
        if labelGNN(kk)~=dataLabel(kk)
            errorsGNN=errorsGNN+1;
        end
    end
    
    % 找出最佳整合结果
    lowestLambda = 0; lowestLambda1 = 0;
    lowestErrors = numOfAllTests; % 最小错误数
    lowestErrors1 = numOfAllTests; % 最小错误数
    for cii=1:numOfCases % 检查不同参数下的结果
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        errorsNNCRC=0; % 错误数清零
        errorsGNNCRC=0; % 错误数清零
        for kk=1:numOfAllTests % 统计错误率
            if labelNNCRC(cii,kk)~=dataLabel(kk)
                errorsNNCRC=errorsNNCRC+1;
            end
            if labelGNNCRC(cii,kk)~=dataLabel(kk)
                errorsGNNCRC=errorsGNNCRC+1;
            end
        end
        % 记录最佳结果
        if errorsNNCRC<lowestErrors
            lowestLambda = lambda;
            lowestErrors=errorsNNCRC;
        end
        % 记录最佳结果
        if errorsGNNCRC<lowestErrors1
            lowestLambda1 = lambda;
            lowestErrors1=errorsGNNCRC;
        end
        %fprintf('%f：%d\n', lowestLambda, lowestErrors);
    end
    
    % 取出最佳结果
    lambda = lowestLambda;
    errorsNNCRC = lowestErrors;
    lambda1 = lowestLambda1;
    errorsGNNCRC = lowestErrors1;
    
    % 统计错误率
    errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
    errorsRatioNN=errorsNN/numOfClasses/numOfTest;
    errorsRatioNNCRC=errorsNNCRC/numOfClasses/numOfTest;
    errorsRatioGCRC=errorsGCRC/numOfClasses/numOfTest;
    errorsRatioGNN=errorsGNN/numOfClasses/numOfTest;
    errorsRatioGNNCRC=errorsGNNCRC/numOfClasses/numOfTest;
    accuracyGNNCRC = 1 - errorsRatioGNNCRC;
    % 保存结果
    result(numOfTrain, 1)=lambda1;
    result(numOfTrain, 2)=errorsRatioCRC;
    result(numOfTrain, 3)=errorsRatioNN;
    result(numOfTrain, 4)=errorsRatioNNCRC;
    result(numOfTrain, 5)=errorsRatioGNNCRC;
    result(numOfTrain, 6)=(errorsRatioCRC-errorsRatioGNNCRC)/errorsRatioCRC;
    result(numOfTrain, 7)=(errorsRatioNN-errorsRatioGNNCRC)/errorsRatioNN;
    result(numOfTrain, 8)=(errorsRatioNNCRC-errorsRatioGNNCRC)/errorsRatioNNCRC;
    result % print
      
    % 将结果单独保存到文件
    jsonFile = [dbName '_' num2str(numOfTrain) '_' num2str(lambda1) '_' num2str(accuracyGNNCRC,'%.4f') '.json'];
    minimal = min([errorsRatioCRC, errorsRatioNN, errorsRatioNNCRC]);
    if errorsRatioGNNCRC < minimal 
        jsonFile = ['+' jsonFile]; % 有提升
    elseif errorsRatioGNNCRC == minimal 
        jsonFile = ['=' jsonFile]; % 持平
    else
        jsonFile = ['-' jsonFile]; % 无提升
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end

% 完成一个库的测试，保存所有最佳结果
jsonFile = ['~' dbName '_GNN-CRC_' num2str(minTrains) '~' num2str(maxTrains) '.json'];
dbJson = savejson('', result, jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];



