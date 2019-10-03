% runWithNTrainings.m
% Run experiment with different number of training samples

%% run with different algorithms
addpath 'FISTA';
addpath 'L1LS';
addpath 'DALM';
addpath 'Homotopy';
addpath 'OMP';
addpath 'INNC';
addpath 'LDA';
addpath 'PCA';
addpath 'CRC';
addpath 'KNN';
addpath 'SVM';
addpath 'SCRC';
addpath 'SQ';
addpath 'AntiL1L2';

%% training settings
[numOfAllSamples, one] = size(inputLabel);

%% record the number of samples belonging to each class
% in case of different samples in each class
eachClass=zeros(numOfClasses,1);
for ii=1:numOfClasses
    for jj=1:numOfAllSamples
        if(inputLabel(jj)==ii)
            eachClass(ii)=eachClass(ii)+1;
        end
    end %jj
end %ii

%% use for preprare experiment cases
numOfSamples = min(eachClass);

%% run test cases
numOfAllCases = 0;
minTrains = 5;
maxTrains = max(floor(numOfSamples*0.8),minTrains);
%maxTrains = min(12,maxTrains);
maxTrains = 40;
stepOfTrain = max(floor((maxTrains-minTrains)/5),1);
stepOfTrain = 5;
for numOfTrain=minTrains:stepOfTrain:maxTrains
    %numOfTest = numOfSamples-numOfTrain;
    assert(numOfTrain<numOfSamples);
    
    prepareNormalTraining2; % preprare training samples    
    %prepareSaltTesting; % preprare training samples with salt test samples
    
    % perform classification without random training samples
    %FISTA2;    
    %CRC2;
    %PCA2;
    %PCA2_L2;
    %DirectLDA;
    %LDA;
    %L1LS2;
    %DALM2;
    %Homotopy2;
    %OMP2;
    %INNC2;
    %ClassifyByKNN;
    %ClassifyBySVM;
    SCRC;
    %proSCRC_Plus1;
    %SQ_SRC;
    %SQF_SRC;
    %SQ_CRC;
    %SQF_CRC;
%    ASRL1L2;
    %DSRL2;
    
    % save result 
    numOfAllCases = numOfAllCases+1;
    result(numOfAllCases,1)=numOfTrain;
    result(numOfAllCases,2)=accuracy;
    result % print
    
end
if maxTrains > minTrains % record all results
    jsonFile = ['=' dbName '_' algName '_' num2str(minTrains) '-' num2str(maxTrains) '.json'];
    dbJson = savejson('', result, jsonFile);
end