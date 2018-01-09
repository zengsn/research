%% run.m
% Run with best parameters

clear all;


%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loadFERET;
%loadGT;
loadLFW;  % LFW dataset
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
    
    path = '/Volumes/SanDisk128/datasets/';
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
if size(strfind(dbName,'GT'),1)>0 % GT
    if useDeep==1
        aCases = [20];
        thCases= [0.1];
    else
        aCases = [1];
        thCases= [0.5];
    end
elseif size(strfind(dbName,'LFW'),1)>0 % LFW
    if useDeep==1
        aCases = [5];
        thCases= [0.2];
    else
        aCases = [1];
        thCases= [0.4];
    end
elseif size(strfind(dbName,'FERET'),1)>0  % FERET
    if useDeep==1
        aCases = [5];
        thCases= [0.2];
    else
        aCases = [1];
        thCases= [0.3];
    end
else
    disp(dbName);
end
[~,numOfCases]=size(aCases);
[~,numOfThresh]=size(thCases);

%% 3. PREPARE TRAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain = 1;
maxTrain = floor(minSamples*0.8);
%maxTrain = 4;
stepOfTran = 1;
runtimes = 1;

%% 4. EVALUATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for aii=1:size(aCases,2)
    for thii=1;size(thCases,2)
        a = aCases(aii); %
        b = 1; %
        th = thCases(thii); %
        runN;
    end
end

%% 4. END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Test done!');