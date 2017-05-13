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
inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 5;  % minimal number of training samples
maxTrains = 5;  % maximal number of training samples
runWithNTrainings; % run with n training samples

disp('Test done!');