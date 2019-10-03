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
inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % 是否优化误差
minTrains = 1;  % 训练样本数
maxTrains = 15;  % 训练样本数
numOfStep = 1;  % 训练样本数循环步长
Gabor_NN_CRC;     % 运行实验
disp('Test done!');