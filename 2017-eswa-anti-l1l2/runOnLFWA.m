% runOnLFW_Better.m
% LFW库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'LFWA';
scale = 0.5;
pathPrefix='../datasets/lfw-a/';
firstSample=imread('../datasets/lfw-a/Aaron_Eckhart/Aaron_Eckhart_0001.jpg');
halfSample =imresize(firstSample,scale); % 压缩大小
%[row col]=size(rgb2gray(halfSample));
[row col]=size(halfSample);
numOfSamples=15; % 取有5个样本的对象
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
        %grayed=double(rgb2gray(colored));
        grayed=colored;
        inputData(cc,ss,:,:)= imresize(grayed(:,:),scale); % 压缩大小
    end
end
%inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 3;  % minimal number of training samples
maxTrains = 10;  % maximal number of training samples
salt = .1;
runWithNBetterTrainings; % run with n training samples
%runWithRandomNTrainings2; % run with n training samples

% Cross validation
%numOfParts = 5;
%runWithNCrossValidation;

disp('Test done!');