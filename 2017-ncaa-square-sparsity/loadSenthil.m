% loadSenthil.m
% Senthil IRTT库的实验代码 
     
dbName = 'Senthil_IRTT';
pathPrefix='../../datasets/Senthil_IRTT_FaceDatabase_Version1.2/';
firstSample=imread('../../datasets/Senthil_IRTT_FaceDatabase_Version1.2/s1_1.jpg');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=10;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 's' num2str(cc, '%d') '_' num2str(ss, '%d') '.jpg'];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');