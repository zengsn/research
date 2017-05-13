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

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 7;  % minimal number of training samples
maxTrains = 8;  % maximal number of training samples
runWithNTrainings; % run with n training samples
disp('Test done!');