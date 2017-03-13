% loadYale.m
% Yale库的实验代码 

dbName = 'Yale';
pathPrefix='../../datasets/yalefaces/';
firstSample=imread('../../datasets/yalefaces/subject01.centerlight');
[row col]=size(firstSample);
numOfSamples=11;
numOfClasses=15;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        types=cell(11,1);
        types{1}='centerlight';     types{2}='glasses';     types{3}='happy';
        types{4}='leftlight';       types{5}='noglasses';   types{6}='normal';
        types{7}='rightlight';      types{8}='sad';         types{9}='sleepy';
        types{10}='surprised';      types{11}='wink';
        path=[pathPrefix 'subject' num2str(cc, '%02d') '.' types{ss}];
        grayed=imread(path);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % 所有的样本数据

disp('Data is ready!');