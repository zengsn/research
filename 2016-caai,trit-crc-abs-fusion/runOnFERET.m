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
inputData=double(inputData); % 所有的样本数据

% 设置参数       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % 是否优化误差
minTrains = 1;  % 训练样本数
maxTrains = 5;  % 训练样本数
abs_crc_lambda; % 运行实验
disp('Test done!');