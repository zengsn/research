% loadGT.m
% GT库的实验代码

dbName = 'GT';
pathPrefix='../../datasets/Georgia Tech face database crop/';
firstSample=imread('../../datasets/Georgia Tech face database crop/1_1.jpg');
%[size_a size_b size_c]=size(firstSample);
[row col]=size(rgb2gray(firstSample));
numOfSamples=15;
numOfClasses=50;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix int2str(cc) '_' int2str(ss) '.jpg'];
        colored=imread(path);
        grayed=rgb2gray(colored);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');