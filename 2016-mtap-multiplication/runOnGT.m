% runOnGT.m
% GT库的实验代码

clear all;

% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'GT';
pathPrefix='../datasets/Georgia Tech face database crop/';
firstSample=imread('../datasets/Georgia Tech face database crop/1_1.jpg');
%[size_a size_b size_c]=size(firstSample);
[row col]=size(rgb2gray(firstSample));
numOfSamples=15;
numOfClasses=50;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix int2str(cc) '_' int2str(ss) '.jpg'];
        colored=imread(path);
        grayed=double(rgb2gray(colored));
        inputData(cc,ss,:,:)= grayed(:,:);
    end
end
inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 9;  % minimal number of training samples
maxTrains = 12;  % maximal number of training samples
%runWithNTrainings; % run with n training samples
%runWithRandomNTrainings2; % run with n training samples

% Cross validation
numOfParts = 5;
runWithNCrossValidation;

disp('Test done!');