% loadCOIL.m
% COIL库的实验代码

dbName = 'COIL';
pathPrefix='../../datasets/coil-20-proc/';
firstSample=imread('../../datasets/coil-20-proc/obj1__0.png');
[row col]=size(firstSample);
numOfSamples=30;%72;
numOfClasses=20;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 'obj' num2str(cc, '%d') '__' num2str(ss-1, '%d') '.png'];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');