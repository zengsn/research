% runOnGT_Better.m
% GT库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'FERET';
pathPrefix='../datasets/feret/';
firstSample=imread('../datasets/feret/1.tif');
[row col]=size(firstSample);
numOfSamples=7;
numOfClasses=200;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%d') '.tif'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
%inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 4;  % minimal number of training samples
maxTrains = 4;  % maximal number of training samples
trainStep=1;
salt = .1; % 椒盐比例
runWithNBetterTrainings;
%runWithNBestTrainings; % run with n training samples
%runWithRandomNTrainings; % run with n training samples

% Cross validation
%numOfParts = 3;
%runWithNCrossValidation;

disp('Test done!');