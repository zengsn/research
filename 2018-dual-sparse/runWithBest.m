%% runWithBest.m
% Perform classification with best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../lcle-dl'));  % add K-SVD box
%loadORL;
%loadLFW;
%loadAR;
%loadFERET;
%loadGT;
loadYaleB_New;
%loadCMUFaces;
%loadCFaces;
%loadMUCT;
%loadCLeaves;
%loadFlavia;
%loadLeaf;
%loadOneHundredLeaf;
%loadSwedishLeaf;
%loadHerbariumIso;
%loadHerbarium;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GT
sparsityThres = 40; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in v_SRC_DL.m
% ORL
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-0.5;     % set in v_SRC_DL.m
% FERET
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-0.5;     % set in v_SRC_DL.m
% YaleB
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-0.5;     % set in v_CRC_DL.m
% LFW-LCLE
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
% CMUFaces-CRC
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in v_CSRC_DL.m
% CFaces-CRC
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in v_CSRC_DL.m
% AR
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in v_SRC_DL.m
% YaleB - v-LCLE-DL
sparsityThres = 40; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
% AR
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in v_SRC_DL.m
% LFW
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-5;     % set in v_CRC_DL.m
% GT
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-5;     % set in v_CRC_DL.m
% ORL-CRC
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=-5;     % set in v_CRC_DL.m
% ORL-CRC
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-10;     % set in v_CRC_DL.m
% LFW CR-vDL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-10;     % set in CR_vDL.m
% LFW vCR-DL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % 
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in vCR_DL.m
% GT vSR-DL,SR-vDL
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % 
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in vSR_DL.m
% CMUFaces vSR-DL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % 
alpha=1e-2;
beta=1e-2;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-0.5;     % set in SR_vDL.m
% CMUFaces SR-vDL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % 
alpha=1e-2;
beta=1e-1;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-5;     % set in SR_vDL.m
% CMUFaces-v-SR-DL
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in v_SRC_DL.m
% LFW vSR-DL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-5;     % set in vSR_DL.m
% LFW v-SR-DL
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-5;     % set in v_SR_DL.m
% LFW SR-vDL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=-5;     % set in SR_vDL.m
% MUCT SR-vDL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in SR_vDL.m
% MUCT vSR-DL
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-1;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-0.5;     % set in vSR_DL.m
% YaleBNew 1-15
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in v_SRC_DL.m
% YaleBNew 
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-5;     % set in SR_vDL.m

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain  = 1;
maxTrain  = floor(minSamples * 0.8);
maxTrain  = max(minTrain,maxTrain);
%trainStep = ceil((maxTrain-minTrain)/5);
trainStep = 1;
maxTrain = 12;
numOfResults = 0;
for numOfTrain=minTrain:trainStep:maxTrain
    prepareTrainData; % train and test data
    % 
    maxSizeOfDict = numOfTrain*numOfClasses; % this usually the best size
    maxSizeOfDict = min(maxSizeOfDict,numOfClasses*3);
    %minSizeOfDict = max(numOfClasses,numOfClasses*(numOfTrain-2));
    for sizeOfDict = numOfClasses:numOfClasses:maxSizeOfDict
    %for sizeOfDict = minSizeOfDict:numOfClasses:maxSizeOfDict
        %v_SR_DL; % evaluation
        %v_CRC_DL; % evaluation
        %v_LCLE_DL; % evaluation
        %CR_vDL;
        %vCR_DL;
        SR_vDL;
        %vSR_DL;
        % 
        numOfResults = numOfResults+1;
        if strcmp(algName,'v_SR_DL')>0 || strcmp(algName,'SR_vDL')>0 || strcmp(algName,'vSR_DL')>0 % , 
            allResults(numOfResults,:) = [numOfTrain,sizeOfDict,lambda,accuracySRC,accuracyDL,accuracyFusion];
        elseif strcmp(algName,'v_CRC_DL')>0 || strcmp(algName,'CR_vDL')>0 || strcmp(algName,'vCR_DL')>0 % , 
            allResults(numOfResults,:) = [numOfTrain,sizeOfDict,lambda,accuracyCRC,accuracyDL,accuracyFusion];
        elseif strcmp(algName,'DL_v_DL')>0 
            allResults(numOfResults,:) = [numOfTrain,sizeOfDict,lambda,accuracyDL1,accuracyDL2,accuracyFusion];
        else 
            allResults(numOfResults,:) = [numOfTrain,sizeOfDict,accuracyOrig,accuracyVirt,improve];
        end
    end
end
jsonFile = [dbName '/_' algName '_' num2str(minTrain) '-' num2str(maxTrain)];
jsonFile = [jsonFile  '.json'];
dbJson = savejson('', allResults, jsonFile);
