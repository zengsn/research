%% runWithBest.m
% Perform classification with best parameters

clear all;

useDeep = 0;
isTuning= 0;
isRandom= 0;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../lcle-dl'));  % add K-SVD box
%loadORL;
%loadLFW;
%loadAR;
%loadFERET;
%loadGT;
%loadYaleB_New;
%loadCMUFaces;
%loadCFaces;
%loadMUCT;
%loadMUCTo3;
loadMUCTCrop;
%loadMUCTCropo3;
%loadMUCTCropRGB;
%loadMUCTCropRGBo3;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3. RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%minTrain  = 1;
%maxTrain  = floor(minSamples * 0.8);
%maxTrain  = max(minTrain,maxTrain);
%trainStep = ceil((maxTrain-minTrain)/5);
%trainStep = 1;
%maxTrain = 12;
numOfResults = 0;
numOfRepeats = 10;
if isRandom==0
    numOfRepeats=1; % do not repeat
end
for rii=1:numOfRepeats % repeat 10 times
    for numOfTrain=minTrain:trainStep:maxTrain
        prepareTrainData; % train and test data
        if useDeep==1
            prepareTrainDataDeep;
        end
        %
        maxSizeOfDict = numOfTrain*numOfClasses; % this usually the best size
        %maxSizeOfDict = min(maxSizeOfDict,numOfClasses*3);
        %minSizeOfDict = max(numOfClasses,numOfClasses*(numOfTrain-2));
        lastDict = 0;
        for dii = 1:3 % 3 different atoms
            if dii==1 % 1*numOfClasses
                sizeOfDict = numOfClasses;
                lastDict = dii;
            elseif numOfTrain/2>lastDict % 1/2 numOfTrain
                sizeOfDict = ceil(numOfTrain/2)*numOfClasses;
                lastDict = ceil(numOfTrain/2);
            elseif numOfTrain>lastDict % numOfTrain*numOfClasses
                sizeOfDict = numOfTrain*numOfClasses;
                lastDict = numOfTrain;
            else  % don't run
                continue;
            end
            %for sizeOfDict = numOfClasses:stepOfDict:numOfTrain*numOfClasses
            %for sizeOfDict = minSizeOfDict:numOfClasses:maxSizeOfDict
            sizeOfDict % 
            %v_SR_DL; % evaluation
            %vSR_DL;
            SR_vDL;
            numOfResults = numOfResults+1;
            allResults(numOfResults,:) = [numOfTrain,sizeOfDict,lambda,accuracySRC,accuracyDL,accuracyFusion];
        end
    end
end
jsonFile = [dbName '/_' algName '_' num2str(minTrain) '-' num2str(maxTrain)];
jsonFile = [jsonFile  '.json'];
dbJson = savejson('', allResults, jsonFile);
if exist('sendEmail','file')==2
    sendEmail(jsonFile,mat2str(allResults),jsonFile);
end