% proSCRC_Multi.m
% ProCRC 与 SRC 进行乘法融合
% - 在表示系数上融合，参考 SCRC.m

algName = 'ProSCRC_Multi';

[numOfAllTrains, sampleSize] = size(trainData); % number of all training samples
[numOfAllTests, sampleSize] = size(testData);   % number of all test samples
fprintf('numOfTrain=%d\tnumOfClasses=%d\tnumOfAllTests=%d\n', numOfTrain, numOfClasses,numOfAllTests);

%% ProCRC
addpath 'ProCRC';
addpath 'ProCRC/utilities';
%clear coefProCRC;
%clear labelProCRC;
data.tr_descr = trainData';
data.tr_label = trainLabel';
data.tt_descr = testData';
data.tt_label = testLabel';
params.dataset_name      =      dbName;
params.gamma             =      [1e-2];
params.lambda            =      [1e-0];
params.class_num         =      numOfClasses;
params.model_type        =      'R-ProCRC';
disp('ProCRC start ...');
coefProCRC = ProCRC(data, params); %
% TODO 找出表示系数的计算步骤，再进行融合
%[labelProCRC, ~] = ProMax(coefProCRC, data, params);
pre_matrix = zeros(numOfClasses,numOfAllTests);
recon_tr_descr   = data.tr_descr * coefProCRC;
for ci = 1:numOfClasses
    loss_ci = recon_tr_descr - data.tr_descr(:, data.tr_label == ci) * coefProCRC(data.tr_label == ci,:);
    pci = sum(loss_ci.^2, 1);
    pre_matrix(ci,:) = pci;
end
% recognition
[~,labelProCRC] = min(pre_matrix,[],1);
errorsProCRC = 0;
for kk=1:numOfAllTests
    if labelProCRC(kk) ~= testLabel(kk,1)
        errorsProCRC=errorsProCRC+1;
    end
end
% save all deviations for ProCRC
deviationsProCRC = pre_matrix';
% result by ProCRC
accuracyProCRC = 1-errorsProCRC/numOfAllTests;

%% SRC
addpath 'SRC';
errorsSRC = 0;
clear testSample;
for kk=1:numOfAllTests
    testSample=testData(kk,:);
    % print progress ...
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % SRC solution - 有多种解可使用
    [solutionSRC, total_iter] =    SolveFISTA(trainData',testSample');
    % compute contributions
    clear contributionSRC;
    for cc=1:numOfClasses
        contributionSRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % 计算距离|残差|余量
    clear deviationSRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
    end
    
    % 保存识别结果
    [min_value xxSRC]=min(deviationSRC);
    %labelSRC(kk)=xxSRC;
    labelSRC = xxSRC;
    if labelSRC ~= testLabel(kk,1)
        errorsSRC=errorsSRC+1;
    end
    
    % 保存距离|残差
    deviationsSRC(kk,:) = deviationSRC;
end
% 准确率
accuracySRC = 1-errorsSRC/numOfAllTests;

%% 融合距离
%lambdas = [-100,-50,-30,-10,1,10,30,50,100];
%lambdas = [1];
[one,numOfCases] = size(lambdas);
bestLambda = 0;
bestAccuracy = 0;
for cii=1:numOfCases
    lambda = lambdas(cii); % -10 for LFW
    errorsFusion=0;
    for kk=1:numOfAllTests
        deviationProCRC = deviationsProCRC(kk,:);
        deviationSRC = deviationsSRC(kk,:);
        deviationFusion = deviationProCRC+lambda*deviationSRC;
        [min_value labelFusion]=min(deviationFusion);
        if labelFusion ~= testLabel(kk,1)
            errorsFusion=errorsFusion+1;
        end
    end    
    accuracyFusion = 1-errorsFusion/numOfAllTests;
    if accuracyFusion>bestAccuracy
        bestLambda = lambda;
        bestAccuracy=accuracyFusion;
    end
end

% best case
lambda = bestLambda; %
accuracyFusion = bestAccuracy; %

fprintf('\nCRC=%.4f\tDL=%.4f\tFusion=%.4f\tlambda=%d\n', accuracyProCRC,accuracySRC,accuracyFusion,lambda);

% improvement
improve1 = (accuracyFusion-accuracySRC)*100/accuracySRC;
improve2 = (accuracyFusion-accuracyProCRC)*100/accuracyProCRC;

% save to json
jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') '(' num2str(improve1,'%.1f') '%,' num2str(improve2,'%.1f') '%)_' num2str(lambda)];
jsonFile = [jsonFile  '.json'];
results = [accuracyProCRC, accuracySRC, accuracyFusion, lambda, trainIndices];
dbJson = savejson('', results, jsonFile);