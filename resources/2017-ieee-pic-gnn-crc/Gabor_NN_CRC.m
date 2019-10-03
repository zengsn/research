% Gabor_NN_CRC.m
% С���Ż�����֮��ͨ������ֵ������෨�Ż�CRC���Զ�Ѱ������ںϲ���

% ԭʼ����
% https://github.com/zengsn/researches/tree/master/2016-caai%2Ctrit-crc-abs-fusion
% ���� Gabor С��
% https://cn.mathworks.com/matlabcentral/fileexchange/59500-gabor-wavelets

% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % �ںϲ��� ��
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��CRC������
positives = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; 
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��NN������
negatives = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 5, 10, 100];
lambdas = [positives, negatives];
[one, numOfCases] = size(lambdas);
%minTrains = 4; % ��Сѵ��������
%maxTrains = 4; % ���ѵ��������
%inputData      % ������������

% �ܲ�ͬ��ѵ������
if maxTrains == 0
    maxTrains = floor(numOfSamples*0.8);
elseif maxTrains > 12
    maxTrains = 12;
end

% ����С������
% !!!! �ɵ����� 
waveletName = 'gabor'; % 'rbio1.5'; % ʹ��С�� haar 
imageSize=[row, col]; % ������С
% % 
% % maxLevels = wmaxlev(imageSize,waveletName); 
% % % !!!! �ɵ����� 
% % if (maxLevels>1) % �ɸ�Ϊ�������
% %     maxLevels = maxLevels-1;
% % end
%maxTrains = 1;
for numOfTrain=minTrains:numOfStep:maxTrains
    % ����������
    numOfTest = numOfSamples-numOfTrain;
    fprintf('ѵ������=%d��\t��������=%d��\t�� %d �����\n', numOfTrain, numOfTest, numOfClasses);
    %����gabor�˲���
    gaborArray = gaborFilterBank(5,8,39,39); 
    % ȡ����Ӧԭʼѵ�����Ͳ��Լ�
    for cc=1:numOfClasses
        %clear Ai;
        for tt=1:numOfTrain
            Ai(1,:)=inputData(cc,tt,:); % A(i)
            trainData((cc-1)*numOfTrain+tt,:)=Ai/norm(Ai);
            % 2D wavelet analysis newAi=wavedec2(Ai,maxLevels,waveletName);
            % С���任����ȡgabor����
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
            % С���任����ȡgabor����
            newXi= gaborFeatures(Xi,gaborArray,4,4);           
            testData1((cc-1)*numOfTest+tt,:)=newXi/norm(newXi);
        end
    end
    
    % ʵ�ָ��ֱ�ʾ����
    numOfAllTrains=numOfClasses*numOfTrain; % ѵ������
    numOfAllTests=numOfClasses*numOfTest;   % ��������
    %clear usefulTrain;
    usefulTrain=trainData;
    usefulTrain1=trainData1;
    %clear preserved;
    % (T*T'+aU)-1 * T
    preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
    preserved1=inv(usefulTrain1*usefulTrain1'+0.01*eye(numOfAllTrains))*usefulTrain1;
    % �����ֲ��������ı�ʾϵ��
    %clear testSample;
    %clear solutionCRC;
    for kk=1:numOfAllTests
        testSample=testData(kk,:);
        testSample1=testData1(kk,:);
        % ��С�����仯
        [row1, col1] = size(testSample1); 
        % CRC �⣺(T*T'+aU)^-1 * T * D(i)'
        solutionCRC=preserved*testSample';
        solutionGCRC=preserved1*testSample1';
        % ��ӡ����
        fprintf('%d ', kk);
        if mod(kk,20)==0
            fprintf('\n');
        end
        
        % ���㹱��ֵ
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
        % �������|�в�|����
        %clear deviationCRC;
        for cc=1:numOfClasses
            % r(i) = |D(i)-C(i)|
            deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
            deviationGCRC(cc)=norm(testSample1'-contributionGCRC(:,cc));
        end
        % �Ż���� CRC
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
        else % ���ֲ���
        end
        % ʶ���� - ԭʼCRC
        [min_value1 xxCRC]=min(deviationCRC);
        labelCRC(kk)=xxCRC;
        [min_value2 yyNN]=max(deviationNN);
        labelNN(kk)=yyNN;
        % ʶ���� - С��CRC
        [min_value1 xxGCRC]=min(deviationGCRC);
        labelGCRC(kk)=xxGCRC;
        [min_value2 yyGNN]=max(deviationGNN);
        labelGNN(kk)=yyGNN;
        % - �ò�ͬ�����ںϵĽ��        
        for cii=1:numOfCases % �ܲ�ͬ�Ĳ���
            lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
            % �ں�����
            fusionNNCRC=deviationCRC-lambda*deviationNN;
            [min_value3 zzNNCRC]=min(fusionNNCRC);
            fusionGNNCRC=deviationGCRC-lambda*deviationGNN;
            [min_value3 zzGNNCRC]=min(fusionGNNCRC);
            % ��¼�����ںϵĽ��
            labelNNCRC(cii,kk)=zzNNCRC; % �ںϽ��
            labelGNNCRC(cii,kk)=zzGNNCRC; % �ںϽ��
        end        
    end
    
    % ��ͳ��CRC��NN��ʶ�������
    errorsCRC=0; errorsGCRC=0;
    errorsNN=0;errorsGNN=0;
    errorsNNCRC=0;errorsGNNCRC=0;
    
    for kk=1:numOfAllTests
        inte=floor((kk-1)/numOfTest+1);
        dataLabel(kk)=inte; % ��ȷλ��
        
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
    
    % �ҳ�������Ͻ��
    lowestLambda = 0; lowestLambda1 = 0;
    lowestErrors = numOfAllTests; % ��С������
    lowestErrors1 = numOfAllTests; % ��С������
    for cii=1:numOfCases % ��鲻ͬ�����µĽ��
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        errorsNNCRC=0; % ����������
        errorsGNNCRC=0; % ����������
        for kk=1:numOfAllTests % ͳ�ƴ�����
            if labelNNCRC(cii,kk)~=dataLabel(kk)
                errorsNNCRC=errorsNNCRC+1;
            end
            if labelGNNCRC(cii,kk)~=dataLabel(kk)
                errorsGNNCRC=errorsGNNCRC+1;
            end
        end
        % ��¼��ѽ��
        if errorsNNCRC<lowestErrors
            lowestLambda = lambda;
            lowestErrors=errorsNNCRC;
        end
        % ��¼��ѽ��
        if errorsGNNCRC<lowestErrors1
            lowestLambda1 = lambda;
            lowestErrors1=errorsGNNCRC;
        end
        %fprintf('%f��%d\n', lowestLambda, lowestErrors);
    end
    
    % ȡ����ѽ��
    lambda = lowestLambda;
    errorsNNCRC = lowestErrors;
    lambda1 = lowestLambda1;
    errorsGNNCRC = lowestErrors1;
    
    % ͳ�ƴ�����
    errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
    errorsRatioNN=errorsNN/numOfClasses/numOfTest;
    errorsRatioNNCRC=errorsNNCRC/numOfClasses/numOfTest;
    errorsRatioGCRC=errorsGCRC/numOfClasses/numOfTest;
    errorsRatioGNN=errorsGNN/numOfClasses/numOfTest;
    errorsRatioGNNCRC=errorsGNNCRC/numOfClasses/numOfTest;
    accuracyGNNCRC = 1 - errorsRatioGNNCRC;
    % ������
    result(numOfTrain, 1)=lambda1;
    result(numOfTrain, 2)=errorsRatioCRC;
    result(numOfTrain, 3)=errorsRatioNN;
    result(numOfTrain, 4)=errorsRatioNNCRC;
    result(numOfTrain, 5)=errorsRatioGNNCRC;
    result(numOfTrain, 6)=(errorsRatioCRC-errorsRatioGNNCRC)/errorsRatioCRC;
    result(numOfTrain, 7)=(errorsRatioNN-errorsRatioGNNCRC)/errorsRatioNN;
    result(numOfTrain, 8)=(errorsRatioNNCRC-errorsRatioGNNCRC)/errorsRatioNNCRC;
    result % print
      
    % ������������浽�ļ�
    jsonFile = [dbName '_' num2str(numOfTrain) '_' num2str(lambda1) '_' num2str(accuracyGNNCRC,'%.4f') '.json'];
    minimal = min([errorsRatioCRC, errorsRatioNN, errorsRatioNNCRC]);
    if errorsRatioGNNCRC < minimal 
        jsonFile = ['+' jsonFile]; % ������
    elseif errorsRatioGNNCRC == minimal 
        jsonFile = ['=' jsonFile]; % ��ƽ
    else
        jsonFile = ['-' jsonFile]; % ������
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end

% ���һ����Ĳ��ԣ�����������ѽ��
jsonFile = ['~' dbName '_GNN-CRC_' num2str(minTrains) '~' num2str(maxTrains) '.json'];
dbJson = savejson('', result, jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];



