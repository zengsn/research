% loadCLeaves.m
% Caltech Leaves

dbName = 'CLeaves';
pathPrefix='../../datasets/caltech_leaves/';
firstSample=imread('../../datasets/caltech_leaves/image_0001.jpg');
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
        grayed = rgb2gray(halfSample);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');