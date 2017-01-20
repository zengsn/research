% runOnLFW_Better.m
% LFW库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'LFW';
scale = 0.3;
pathPrefix='../datasets/lfw-deepfunneled/';
firstSample=imread('../datasets/lfw-deepfunneled/Aaron_Eckhart/Aaron_Eckhart_0001.jpg');
halfSample =imresize(firstSample,scale); % 压缩大小
[row col]=size(rgb2gray(halfSample));
numOfSamples=10; % 取有5个样本的对象
numOfClasses=0; % 类别数据需要统计
indiesOfClasses = []; % 记录数据位置
% 读出有5个样本的数据
fileID = fopen('../datasets/lfw-names.txt');
namesAndImages = textscan(fileID,'%s %d');
fclose(fileID);
names = namesAndImages{1,1};
nums = namesAndImages{1,2};
[nRow, nCol] = size(names);
for jj=1:nRow % 遍历所有数据
    numOfImages = nums(jj);
    if numOfImages >= numOfSamples  % 样本数据足够
        numOfClasses = numOfClasses + 1;
        indiesOfClasses(numOfClasses)=jj;
    end
end

for cc=1:numOfClasses
    for ss=1:numOfSamples
        indexOfClass = indiesOfClasses(cc); %disp(indexOfClass);
        %path=[pathPrefix names(indexOfClass) '/' names(indexOfClass) '_' num2str(ss, '%04d') '.jpg'];
        path=strcat(pathPrefix,names(indexOfClass),'/',names(indexOfClass),'_',num2str(ss, '%04d'),'.jpg');
        colored=imread(path{1});
        grayed=double(rgb2gray(colored));
        inputData(cc,ss,:,:)= imresize(grayed(:,:),scale); % 压缩大小
    end
end
inputData=double(inputData); % 所有的样本数据

% 设置参数       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % 是否优化误差
minTrains = 1;  % 训练样本数
maxTrains = 8;  % 训练样本数
abs_crc_lambda; % 运行实验
disp('Test done!');