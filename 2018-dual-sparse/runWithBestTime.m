%% runWithBest.m
% Perform classification with best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../lcle-dl'));  % add K-SVD box
%loadORL;
loadLFW;
%loadAR;
%loadFERET;
%loadGT;
%loadYaleB;
%loadCMUFaces;
%loadCFaces;
%loadCLeaves;
%loadFlavia;
%loadLeaf;
%loadOneHundredLeaf;
%loadSwedishLeaf;
%loadHerbariumIso;
%loadHerbarium;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain  = 1;
maxTrain  = floor(minSamples * 0.8);
maxTrain  = max(minTrain,maxTrain);
%trainStep = ceil((maxTrain-minTrain)/5);
trainStep = 1;
%maxTrain = 40;
numOfResults = 0;
totalTime = 0;
totalTest = 0;
for numOfTrain=minTrain:trainStep:maxTrain
    prepareTrainData; % train and test data
    % 
    maxSizeOfDict = numOfTrain*numOfClasses; % this usually the best size
    maxSizeOfDict = min(maxSizeOfDict,numOfClasses*3);
    maxSizeOfDict = numOfClasses;
    for sizeOfDict = numOfClasses:numOfClasses:maxSizeOfDict
        time_v_SR_DL;
        %time_vSR_DL;
        %time_SR_vDL;
        totalTime = totalTime+time_vSRDL;
        totalTest = totalTest+numOfAllTest;
    end
end
speed = totalTime/totalTest;
jsonFile = [dbName '_' algName '_Test-' num2str(totalTest) '-in-' num2str(totalTime) 's-speed-' num2str(speed,'%.3f')];
jsonFile = [jsonFile  '.json'];
timeResult = [totalTest,totalTime,totalTime/totalTest];
dbJson = savejson('', timeResult, jsonFile);
