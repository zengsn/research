%% run4Tuning.m
% To find best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loadORL;    %none
%loadCFaces;%CFaces
%loadLFW;   %LFW
%loadFERET; %FERET
%loadCOIL20;%COIL20
%loadYaleB; %YaleB
%loadCMU;   %CMU  
%loadMUCT;
load('/Users/danivy/Documents/MATLAB/datasets/matlab.mat');
numOfSamples=30;
numOfClasses=34;
row = 125;
col = 125;
dbName = 'LFW';
%loadCaltechLeaves;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambdas = [-100:0.01:100];
lambdas = [0.1];

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrain  = 8;
maxTrain  = 8;
%maxTrain  = floor(numOfSamples * 0.8);
%trainStep = ceil((maxTrain-minTrain)/5);
%x = [1:1:8]
trainStep = 1;
for numOfTrain=minTrain:trainStep:maxTrain
    prepareTrainData; % train and test data
    % TODO cross validation
    proSCRC_Plus2;
    %break; % Test 1 case
    %SCRC;
end

%% 4. END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Test done!');