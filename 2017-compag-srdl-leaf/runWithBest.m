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
%loadYaleB;
%loadCMUFaces;
%loadCFaces;
loadCLeaves;
%loadFlavia;
%loadLeaf;
%loadOneHundredLeaf;
%loadSwedishLeaf;
%loadHerbariumIso;
%loadHerbarium;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-5;     % set in SRC_DL.m
% FERET
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=2; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% GT
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=2; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% LFW
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-5;     % set in SRC_DL.m
% CMUFaces
sparsityThres = 40; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=2; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=-5;     % set in SRC_DL.m
% YaleB
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=2; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-10;     % set in SRC_DL.m
% CFaces
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=2; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-10;     % set in SRC_DL.m
% Flavia
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=2; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=1;     % set in SRC_DL.m
% Leaf
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-5;     % set in SRC_DL.m
% OneHundredLeaf
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% SwedishLeaf
sparsityThres = 30; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% HerbariumI : 1~8
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=1; % or 1
alpha=1e-1;
beta=1e-1;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% HerbariumI : 9~13
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-2;
iterations = 10; % iteration number
%lambda=1;     % set in SRC_DL.m
% HerbariumI : 14~25
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-2;
iterations = 15; % iteration number
%lambda=0.5;     % set in SRC_DL.m
% HerbariumI : 26~15
sparsityThres = 40; % sparsity prior
iterations4init =1; % iteration number for initialization
knn=3; % or 1
alpha=1e-1;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=-0.5;     % set in SRC_DL.m
% Herbarium 
sparsityThres = 30; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=1; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=0.5;     % set in SRC_DL.m
% CLeaves
sparsityThres = 40; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 10; % iteration number
%lambda=1;     % set in SRC_DL.m
% CLeaves
sparsityThres = 40; % sparsity prior
iterations4init =2; % iteration number for initialization
knn=3; % or 1
alpha=1e-2;
beta=1e-2;
gamma=1e-1;
iterations = 15; % iteration number
%lambda=0.5;     % set in SRC_DL.m

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain  = 1;
maxTrain  = floor(minSamples * 0.8);
maxTrain  = max(minTrain,maxTrain);
%trainStep = ceil((maxTrain-minTrain)/5);
trainStep = 1;
%maxTrain = 60;
numOfResults = 0;
for numOfTrain=minTrain:trainStep:maxTrain
    prepareTrainData; % train and test data
    % 
    maxSizeOfDict = numOfTrain*numOfClasses; % this usually the best size
    maxSizeOfDict = min(maxSizeOfDict,numOfClasses*5);
    for sizeOfDict = numOfClasses:numOfClasses:maxSizeOfDict
        SRC_DL; % evaluation
        % 
        numOfResults = numOfResults+1;
        allResults(numOfResults,:) = [numOfTrain,sizeOfDict,accuracySRC,accuracyDL,accuracyFusion,lambda];
    end
end
jsonFile = [dbName '/_SRC_DL_' num2str(minTrain) '-' num2str(maxTrain)];
jsonFile = [jsonFile  '.json'];
dbJson = savejson('', allResults, jsonFile);
