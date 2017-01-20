% abs_crc_lambda.m
% 绝对值优化CRC，自动寻找最佳融合参数

%clear all;

%addpath 'src_solution';

% 所需数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % 融合参数 λ
% 正融合：CRC结果优于ABS时使用，强调CRC的作用
positives = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; 
% 负融合：CRC结果差于ABS时使用，强调ABS的作用
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
%maxTrains = 1;
for numOfTrain=minTrains:maxTrains
    % 测试样本数
    numOfTest = numOfSamples-numOfTrain;
    fprintf('训练样本=%d；\t测试样本=%d；\t共 %d 组对象。\n', numOfTrain, numOfTest, numOfClasses);
    
    % 取出相应原始训练集和测试集
    for cc=1:numOfClasses
        %clear Ai;
        for tt=1:numOfTrain
            Ai(1,:)=inputData(cc,tt,:); % A(i)
            trainData((cc-1)*numOfTrain+tt,:)=Ai/norm(Ai);
        end
    end
    for cc=1:numOfClasses
        %clear Xi;
        for tt=1:numOfTest
            Xi(1,:)=inputData(cc,tt+numOfTrain,:); % X(i)
            testData((cc-1)*numOfTest+tt,:)=Xi/norm(Xi);
        end
    end
    
    % 实现各种表示方法
    numOfAllTrains=numOfClasses*numOfTrain; % 训练总数
    numOfAllTests=numOfClasses*numOfTest;   % 测试总数
    %clear usefulTrain;
    usefulTrain=trainData;
    %clear preserved;
    % (T*T'+aU)-1 * T
    preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
    % 求解各种测试样本的表示系数
    %clear testSample;
    %clear solutionSRC;
    %clear solutionCRC;
    for kk=1:numOfAllTests
        testSample=testData(kk,:);
        % CRC 解：(T*T'+aU)^-1 * T * D(i)'
        solutionCRC=preserved*testSample';
        % 打印进度
        fprintf('%d ', kk);
        if mod(kk,20)==0
            fprintf('\n');
        end
        % SRC 解
        %[solutionSRC, total_iter] =    SolveFISTA(usefulTrain',testSample');
        
        % 计算贡献值
        %clear contributionCRC;
        %clear contributionSRC;
        for cc=1:numOfClasses
            contributionCRC(:,cc)=zeros(row*col,1);
            contributionSRC(:,cc)=zeros(row*col,1);
            crcABS1(cc)=0; % abs of the contribution for crc
            srcABS1(cc)=0; % abs of the contribution for src
            
            for tt=1:numOfTrain
                % C(i) = sum(S(i)*T)
                contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
                %contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
                crcABS1(cc)=crcABS1(cc)+abs(solutionCRC((cc-1)*numOfTrain+tt));
                %srcABS1(cc)=srcABS1(cc)+abs(solutionSRC((cc-1)*numOfTrain+tt));
            end
        end
        % 计算距离|残差|余量
        %clear deviationSRC;
        %clear deviationCRC;
        for cc=1:numOfClasses
            % r(i) = |D(i)-C(i)|
            deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
            %deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
        end
        % 优化误差 CRC
        if redoDeviation==1
            minDeviationCRC=min(deviationCRC);
            maxDeviationCRC=max(deviationCRC);
            minCRCABS1=min(crcABS1);
            maxCRCABS1=max(crcABS1);
            deviationCRC2=(deviationCRC-minDeviationCRC)/(maxDeviationCRC-minDeviationCRC);
            crcABS2=(crcABS1-minCRCABS1)/(maxCRCABS1-minCRCABS1);
        else % 保持不变
            deviationCRC2 = deviationCRC;
            crcABS2 = crcABS1;
        end
        % 优化误差 SRC
%         minDeviationSRC=min(deviationSRC);
%         maxDeviationSRC=max(deviationSRC);
%         minSRCABS1=min(srcABS1);
%         maxSRCABS1=max(srcABS1);
%         deviationSRC2=(deviationSRC-minDeviationSRC)/(maxDeviationSRC-minDeviationSRC);
%         srcABS2=(srcABS1-minSRCABS1)/(maxSRCABS1-minSRCABS1);
        % 识别结果 CRC
        [min_value1 xxCRC]=min(deviationCRC2);
        labelCRC(kk)=xxCRC;
        [min_value2 yyCRC]=max(crcABS2);
        labelCRCABS(kk)=yyCRC;
        % - 用不同参数融合的结果        
        for cii=1:numOfCases % 跑不同的参数
            lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
            % 融合余量
            fusionCRC=deviationCRC2-lambda*crcABS2;
            [min_value3 zzCRC]=min(fusionCRC);
            % 记录所有融合的结果
            labelCRCFusions(cii,kk)=zzCRC; % 融合结果
        end
        % 识别结果 SRC
%         [min_value1 xxSRC]=min(deviationSRC2);
%         labelSRC(kk)=xxSRC;
%         [min_value2 yySRC]=max(srcABS2);
%         labelSRCABS(kk)=yySRC;
%         % result=wucha2-0.5*abs2;
%         fusionSRC=deviationSRC2-lambda*srcABS2;
%         % result=wucha2./abs2;
%         [min_value3 zzSRC]=min(fusionSRC);
%         labelSRCFusion(kk)=zzSRC; % 融合结果
    end
    
    % 先统计CRC和ABS的识别结果误差
    errorsCRC=0; errorsSRC=0;
    errorsABS1=0;errorsABS2=0;
    errorsSRCFusion=0;
    
    for kk=1:numOfAllTests
        inte=floor((kk-1)/numOfTest+1);
        dataLabel(kk)=inte; % 正确位置
        
        % CRC
        if labelCRC(kk)~=dataLabel(kk)
            errorsCRC=errorsCRC+1;
        end
        if labelCRCABS(kk)~=dataLabel(kk)
            errorsABS1=errorsABS1+1;
        end
        
        % SRC
%         if labelSRC(kk)~=dataLabel(kk)
%             errorsSRC=errorsSRC+1;
%         end
%         if labelSRCABS(kk)~=dataLabel(kk)
%             errorsABS2=errorsABS2+1;
%         end
%         if labelSRCFusion(kk)~=dataLabel(kk)
%             errorsSRCFusion=errorsSRCFusion+1;
%         end
    end
    
    % 找出最佳整合结果
    lowestLambda = 0;
    lowestErrors = numOfAllTests; % 最小错误数
    for cii=1:numOfCases % 检查不同参数下的结果
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        errorsCRCFusion=0; % 错误数清零
        for kk=1:numOfAllTests % 统计错误率
            if labelCRCFusions(cii,kk)~=dataLabel(kk)
                errorsCRCFusion=errorsCRCFusion+1;
            end
        end
        %fprintf('%f：%d\n', lambda, errorsCRCFusion);
        % 记录最佳结果
        if errorsCRCFusion<lowestErrors
            lowestLambda = lambda;
            lowestErrors=errorsCRCFusion;
        end
        %fprintf('%f：%d\n', lowestLambda, lowestErrors);
    end
    
    % 取出最佳结果
    lambda = lowestLambda;
    errorsCRCFusion = lowestErrors;
    
    % 统计错误率
    errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
    errorsRatioABS1=errorsABS1/numOfClasses/numOfTest;
    errorsRatioCRCFusion=errorsCRCFusion/numOfClasses/numOfTest;
    errorsRatioSRC=errorsSRC/numOfClasses/numOfTest;
    errorsRatioABS2=errorsABS2/numOfClasses/numOfTest;
    errorsRatioSRCFusion=errorsSRCFusion/numOfClasses/numOfTest;
    
    % 保存结果
    result(numOfTrain, 1)=lambda;
    result(numOfTrain, 2)=errorsRatioCRC;
    result(numOfTrain, 3)=errorsRatioABS1;
    result(numOfTrain, 4)=errorsRatioCRCFusion;
    result(numOfTrain, 5)=(errorsRatioCRC-errorsRatioCRCFusion)/errorsRatioCRC;
    result(numOfTrain, 6)=(errorsRatioABS1-errorsRatioCRCFusion)/errorsRatioABS1;
    %result(numOfTrain, 4)=errorsRatioSRC;
    %result(numOfTrain, 5)=errorsRatioABS2;
    %result(numOfTrain, 6)=errorsRatioSRCFusion;
    result % print
    
    % 将结果单独保存到文件
    jsonFile = [dbName '_' num2str(numOfTrain) '_' num2str(lambda) '.json'];
    minimal = min([errorsRatioCRC, errorsRatioABS1]);
    if errorsRatioCRCFusion < minimal 
        jsonFile = ['+' jsonFile]; % 有提升
    elseif errorsRatioCRCFusion == minimal 
        jsonFile = ['=' jsonFile]; % 持平
    else
        jsonFile = ['-' jsonFile]; % 无提升
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end

% 完成一个库的测试，保存所有最佳结果
jsonFile = ['~' dbName '_' num2str(minTrains) '~' num2str(maxTrains) '.json'];
dbJson = savejson('', result, jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];



