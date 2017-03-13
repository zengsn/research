% loadFERET.m

dbName = 'FERET';
pathPrefix='../../datasets/feret/';
firstSample=imread('../../datasets/feret/1.tif');
[row col]=size(firstSample);
numOfSamples=7;
numOfClasses=200;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%d') '.tif'];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');