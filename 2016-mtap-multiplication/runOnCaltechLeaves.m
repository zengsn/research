% runOnCaltechLeaves.m
% Caltech Face库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'Caltech_Leaves';
pathPrefix='../datasets/caltech_leaves/';
firstSample=imread('../datasets/caltech_leaves/image_0001.jpg');
halfSample =imresize(firstSample,0.5); % 压缩大小
[row col]=size(rgb2gray(halfSample));
numOfSamples=10;
numOfClasses=0; % 需要对数据进行处理

% 读取标注记录
labelFile = [pathPrefix 'labels.txt']; % 样本标记
fid = fopen(labelFile);
labelData = textscan(fid, '%d %d', 'delimiter', ',');
fclose(fid);
[numOfLines, two] = size(labelData{1});

for lii=1:numOfLines % 遍历每一行
    num1=labelData{1}(lii);
    num2=labelData{2}(lii);
    numOfClassSamples = num2-num1+1;
    if numOfClassSamples>numOfSamples % 有足够的样本
        numOfClasses = numOfClasses+1; % 找到一个合格的类
        classLabels(numOfClasses)=num1;% 记录类的第一个样本位置 
    end
end

for cc=1:numOfClasses
    numOfFirst = classLabels(cc);
    for ss=1:numOfSamples        
        path=[pathPrefix 'image_' num2str(numOfFirst+ss-1, '%04d') '.jpg'];
        colored=imread(path);
        halfSample =imresize(colored,0.5); % 压缩大小
        inputData(cc,ss,:,:) = rgb2gray(halfSample);
    end
end
inputData=double(inputData); % 所有的样本数据

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 1;  % minimal number of training samples
maxTrains = 8;  % maximal number of training samples
runWithNTrainings; % run with n training samples
disp('Test done!');