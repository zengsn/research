% runOnORL.m

clear all;

% Loading data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
dbName = 'ORL';
pathPrefix='../datasets/orl/orl';
firstSample=imread('../datasets/orl/orl001.bmp');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=40;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%03d') '.bmp'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
%inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 1;  % minimal number of training samples
maxTrains = 8;  % maximal number of training samples
trainStep=1;
salt = .3; % ½·ÑÎ±ÈÀý
runWithNBetterTrainings; % run with n training samples
%runWithRandomNTrainings2; % run with n training samples

% Cross validation
%numOfParts = 5;
%runWithNCrossValidation;

disp('Test done!');