%% runTune.m
% To find best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loadFERET;
%loadGT;
%loadLFW;  % LFW dataset
%loadAR;
useDeep = 0;
if useDeep == 1
    deepModel = 'ResNet_v1_101';
    %deepModel = 'ResNet_v2_101';
    %deepModel = 'Inception_v4';
    dirSuffix = ['.h5.' deepModel];
    h5File = ['.h5.' lower(deepModel)];
    if strcmp(deepModel,'ResNet_v1_101')    % ResNet_v1_101
        layerName='/resnet_v1_101/logits';
    elseif strcmp(deepModel,'ResNet_v2_101')% ResNet_v2_101
        layerName='/resnet_v2_101/logits';
    elseif strcmp(deepModel,'Inception_v4') % Inception-v4
        layerName='/Logits';
    else
        disp(['Unknown model: ' deepModel]);
    end
    
    path = '/Volumes/SanDisk128B/datasets-h5/';
    h5   = [dbName '_' num2str(row) 'x' num2str(col) h5File];
    dbName_o = dbName;
    dbName   = [dbName dirSuffix];
    h5Data = h5read([path h5], layerName);
    h5disp([path h5], layerName);
    dim = size(h5Data,1);
    dimOfData = size(size(h5Data),2);
    numOfAllSamples=size(inputLabel ,1);
    if dimOfData==2
        for ii=1:numOfAllSamples
            inputDataDeep(:,ii)=h5Data(:,ii);
        end
    elseif dimOfData==4
        for ii=1:numOfAllSamples
            inputDataDeep(:,ii)=h5Data(:,1,1,ii);
        end
    else
        disp('Unknown dim of data.');
    end
    clear h5Data;
end
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isTune = 1;
aCases = [1,5,10,20,30,40,50,60,70,80];
%aCases = [0.5,0.1,0.05,0.03,0.025,0.02,0.01,0.001];
%aCases = [aCases,0.001,0.01,0.05,0.1,0.5];
%aCases = [20,30,40,50,60,70,80,90];
aCases = [1];
[~,numOfCases]=size(aCases);
thCases=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
thCases=[0.1,0.2,0.3,0.4];
%thCases=[0.5,0.6,0.7,0.8];
%thCases= [0.5];
[~,numOfThresh]=size(thCases);

%% 3. PREPARE TRAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numOfTrain = 5; % The number of training sample of each class(including the first m images of each class)
minTrain = numOfTrain;
maxTrain = numOfTrain;
stepOfTran = 1;
runtimes = 1;

%% 4. EVALUATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for thii=1:size(thCases,2)
    for aii=1:size(aCases,2)
        a = aCases(aii); %
        b = 1; %
        th = thCases(thii); %
        runN;
    end
end

%% 4. END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Test done!');