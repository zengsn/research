% runShrunkData.m
% run with shrunk datasets

clear all;

%% dataset configuration
%loadCLeaves;
%loadLeaf;
%loadHerbariumIso;
%loadSwedishLeaf;
load 'C:\Users\lenovo\Documents\MATLAB\Lab0_Data\FERET_32x32.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=32;
col=32;
numOfSamples=7;
numOfClasses=200;
%% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minTrains = 1;  % minimal number of training samples
%maxTrains = 8;  % maximal number of training samples
%stepOfTrain=1;
salt = 0;
%prepareTrainData;
runWithNTrainings2; % run with n training samples