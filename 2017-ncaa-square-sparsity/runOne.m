%% runWithBest.m
% Perform classification with best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../../Lab4_Benchmark/FISTA'));  % 
%loadCFaces;
%loadGT;
loadFERET;
%loadAR;

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caltech Faces
salt = 0.3;
% GT
%salt = 0.1;
% FERET
%salt = 0.1;
% AR
%salt = 0.3;
salt = 0;

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain  = 1;
maxTrain  = floor(numOfSamples * 0.8);
%maxTrain = 15;
%trainStep = ceil((maxTrain-minTrain)/5);
trainStep = 1;
for numOfTrain=minTrain:trainStep:maxTrain
    %prepareNoisyData;
    prepareData;
    SQF_SRC;
    %SQF_CRC;
end

jsonFile = [dbName '/' type '_' num2str(minTrain) '-' num2str(maxTrain) '_salt=' num2str(salt) '.json'];
dbJson = savejson('', result, jsonFile);

disp('Test done!');
