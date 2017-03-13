% loadORL.m
% ORL库的实验代码
        
dbName = 'ORL';
pathPrefix='../../datasets/orl/orl';
firstSample=imread('../../datasets/orl/orl001.bmp');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=40;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%03d') '.bmp'];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');