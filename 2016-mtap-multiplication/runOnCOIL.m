% runOnCOIL_Better.m
% COIL库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
dbName = 'COIL';
pathPrefix='../datasets/coil-20-proc/';
firstSample=imread('../datasets/coil-20-proc/obj1__0.png');
[row col]=size(firstSample);
numOfSamples=30;%72;
numOfClasses=20;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 'obj' num2str(cc, '%d') '__' num2str(ss-1, '%d') '.png'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
inputData=double(inputData); % 所有的样本数据

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 4;  % minimal number of training samples
maxTrains = 4;  % maximal number of training samples
runWithNTrainings; % run with n training samples

disp('Test done!');