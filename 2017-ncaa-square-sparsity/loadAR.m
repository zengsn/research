% loadAR.m

dbName = 'AR';
pathPrefix='../../datasets/AR_gray_50by/AR';
firstSample=imread('../../datasets/AR_gray_50by/AR001-1.tif');
[row col]=size(firstSample);
numOfSamples=26;
numOfClasses=120;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str(cc,'%03d') '-' num2str(ss) '.tif'];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % all input data

disp('Data is ready!');