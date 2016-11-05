% runOnCMUFaces_Better.m
% CMU Faces库的实验代码 - 寻找有优化的参数

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'CMU_Faces';
pathPrefix='../datasets/cmufaces/';
firstSample=imread('../datasets/cmufaces/an2i/an2i_left_angry_open_2.pgm');
[row col]=size(firstSample);
numOfSamples=0; % 54
numOfClasses=0; % 需要对数据进行处理

% 读取目录
subjects=dir(pathPrefix);
[numOfFiles, one] = size(subjects);
%sampleNames = struct; % 记录所有出现的样本名称
subjectNames = cell(20,1);
allSampleNames = cell(100,1);
numOfAllNames = 0; % 已找到的名字
for fii=1:numOfFiles % 遍历文件
    filename = subjects(fii).name;
    if isvarname(filename) % 都是以字母开头的字符串
        numOfClasses = numOfClasses+1; % 是一个类
        subjectNames{numOfClasses}=filename;
        samples=dir([pathPrefix '/' filename]);
        [numOfClassSamples, one] = size(samples);        
        % 查找全部对象都有的样本、名称
        for sii=1:numOfClassSamples % 遍历样本
            imageName = samples(sii).name;
            imageName = strrep(imageName, '.pgm', '');
            if isvarname(imageName)
                sampleName = strrep(imageName, filename, '');
                if numOfAllNames==0
                    numOfAllNames = 1;
                    allSampleNames{numOfAllNames} = sampleName;
                else % 检查样本名称
                    hasSame = 0;
                    for snii=1:numOfAllNames  % 遍历插入新名字
                        name = allSampleNames{snii};
                        if strcmp(sampleName, name) == 1 
                            hasSame = 1;
                            break; % 已有
                        end
                    end
                    if hasSame == 0 % 找到新名字
                        numOfAllNames = numOfAllNames+1;
                        allSampleNames{numOfAllNames} = sampleName;
                    end
                end
            end
        end
    end
end

% 找到全部类都有的样本名称
sampleNames = cell(50,1); % 实际不止50个
for snii=1:numOfAllNames % 检查所有名称
    sampleName = allSampleNames{snii};
    allHave = 1; % 全部都有
    for cc=1:numOfClasses % 遍历所有类
        subjectName = subjectNames{cc};
        imageFile = [pathPrefix '/' subjectName '/' subjectName sampleName '.pgm'];
        if exist(imageFile, 'file') ~= 2
            allHave = 0; % 没有这个样本
            break;
        end
    end
    if allHave == 1 % 全部都有
        numOfSamples = numOfSamples+1;
        sampleNames{numOfSamples} = sampleName;
    end
end

% 加载数据
for cc=1:numOfClasses
    subjectName = subjectNames{cc};
    for ss=1:numOfSamples   
        sampleName = sampleNames{ss};
        imageFile = [pathPrefix subjectName '/' subjectName sampleName '.pgm'];
        sampleData=imread(imageFile);
        halfSample =imresize(sampleData,[60 64]); % 压缩大小
        inputData(cc,ss,:,:) = halfSample;
    end
end
inputData=double(inputData); % 所有的样本数据


% 设置参数       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % 是否优化误差
minTrains = 1;  % 训练样本数
maxTrains = 8;  % 训练样本数
abs_crc_lambda; % 运行实验
disp('Test done!');