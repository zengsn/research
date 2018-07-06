%% loadMUCTCrop.m
% MUCT data with landmarks, already aligned and croped.

load '/Volumes/SanDisk128B/datasets-mat/MUCTCropRGB_32x24.mat';
inputDataRGB=inputData;
inputData=zeros(row*col,numOfAllSamples);
for ii=1:numOfAllSamples
    oneSample=inputDataRGB(:,ii);
    r=reshape(oneSample(1          :1*row*col,1),row,col);
    g=reshape(oneSample(1+1*row*col:2*row*col,1),row,col);
    b=reshape(oneSample(1+2*row*col:3*row*col,1),row,col);
    rgbSample(:,:,1)=r;
    rgbSample(:,:,2)=g;
    rgbSample(:,:,3)=b;
    graySample=rgb2gray(rgbSample);
    columniation = reshape(graySample,row*col,1);
    inputData(:,ii)=columniation;
end
dbName  = 'MUCTCrop';
dbName_0= dbName;
dbNameD = 'MUCTCropRGB'; % for deep feature files
h5Row = 320;
h5Col = 240;
clear inputDataRGB;
isRGB = 0; 
%row=64;
%col=48;
%numOfClasses=276; % total classes
minSamples=10;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class

minTrain = 1;
maxTrain = 8;
trainStep= 1;