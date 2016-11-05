% runOnSenthil_Better.m
% Senthil IRTT库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'Senthil_IRTT';
pathPrefix='../datasets/Senthil_IRTT_FaceDatabase_Version1.2/';
firstSample=imread('../datasets/Senthil_IRTT_FaceDatabase_Version1.2/s1_1.jpg');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=10;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 's' num2str(cc, '%d') '_' num2str(ss, '%d') '.jpg'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
inputData=double(inputData); % 所有的样本数据

% 设置参数       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % 是否优化误差
minTrains = 1;  % 训练样本数
maxTrains = 8;  % 训练样本数
abs_crc_lambda; % 运行实验
disp('Test done!');