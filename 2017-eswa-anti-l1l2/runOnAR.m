% runOnAR.m

clear all;

% Loading data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
dbName = 'AR';
pathPrefix='../datasets/AR_gray_50by/AR';
firstSample=imread('../datasets/AR_gray_50by/AR001-1.tif');
[row col]=size(firstSample);
numOfSamples=26;
numOfClasses=120;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str(cc,'%03d') '-' num2str(ss) '.tif'];
        temp00=imread(path);
        temp0=reshape(temp00,row*col,1);
        inputData(cc,ss,:,:)=temp0;
    end
end
%inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 6;  % minimal number of training samples
maxTrains = 15;  % maximal number of training samples
trainStep = 3;
salt = .3;
runWithNBetterTrainings; % run with n training samples
%runWithRandomNTrainings2; % run with n training samples

% Cross validation
%numOfParts = 4;
%runWithNCrossValidation;

disp('Test done!');