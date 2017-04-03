%% run4Best.m
% Run experiment on one dataset for best parameters.

clear all;

%% Load dataset
loadLFW;

%% Set parameters
G=[1e-2,1e-3,1e-4];
S=[0.1, 1];
S=[1]; % sigma=1
[~, numG] = size(G);
[~, numS] = size(S);
%gama=1e-4;
%iterations=50;

%% Run with different training samples
minTrain  = 7;
maxTrain  = floor(numOfSamples * 0.8);
%maxTrain = 15;
%trainStep = ceil((maxTrain-minTrain)/5);
trainStep = 1;
for numOfTrain=minTrain:trainStep:maxTrain
    numOfTest = numOfSamples-numOfTrain;
    
    % prepare noisy train and test data
    prepareNoisyData;
    % perform classification
    highestL1 = 0;
    highestL2 = 0;
    bestGamma = 0;
    bestSigma = 0;
    numOfCases = 0;
    for gii=1:numG
        gamma = G(1,gii);
        for sii=1:numS
            sigma=S(1,sii);
            % run classification
            numOfCases = numOfCases+1;
            AntinoiseSR_L1; % ASRL1 and DSRL2
            resultOne(numOfCases,1)=gamma;
            resultOne(numOfCases,2)=sigma;
            resultOne(numOfCases,3)=accuracyL1;
            resultOne(numOfCases,4)=accuracyL2;
            % save results
            jsonFile = [dbName '/ASRL1_' num2str(numOfTrain) '_' num2str(accuracyL1,'%.5f') '_g' num2str(gamma) ',s' num2str(sigma) ',salt' num2str(salt) '.json']; 
            dbJson = savejson('', [gamma,sigma,accuracyL1,accuracyL2], jsonFile);
            % save best results
            if highestL1<accuracyL1
                highestL1=accuracyL1;
                highestL2=accuracyL2;
                bestGamma = gii;
                bestSigma = sii;
            end
        end
    end
    % record results of all cases for one 
    jsonFile = [dbName '/ASRL1_'  num2str(numOfTrain) '_salt' num2str(salt) '.json'];
    dbJson = savejson('', resultOne, jsonFile);
    % record best results
    accuracyL1 = highestL1;
    accuracyL2 = highestL2;
    result(numOfTrain,1)=G(1,bestGamma);
    result(numOfTrain,2)=S(1,bestSigma);
    result(numOfTrain,3)=accuracyL1;
    result(numOfTrain,4)=accuracyL2;
    result % print
    
    gamma = G(1,bestGamma);
    sigma = S(1,bestSigma);
    improve = (accuracyL1-accuracyL2)*100/accuracyL2;
    
    if improve >= 0
        jsonFile = [dbName '/ASRL1_' num2str(numOfTrain) '_g' num2str(gamma) ',s' num2str(sigma) '_+' num2str(improve,2) '%.json'];    
    else
        jsonFile = [dbName '/ASRL1_' num2str(numOfTrain) '_g' num2str(gamma) ',s' num2str(sigma) '_' num2str(improve,2) '%.json'];
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end
if maxTrain > minTrain % record all results
    jsonFile = [dbName '/ASRL1_' num2str(minTrain) '-' num2str(maxTrain) '_salt=' num2str(salt) '.json'];
    dbJson = savejson('', result, jsonFile);
end