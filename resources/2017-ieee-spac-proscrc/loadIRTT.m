% runOnSenthil_Better.m
% Senthil IRTT?????? - ????????

clear all;
% ????       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'Senthil_IRTT';
pathPrefix='./datasets/Senthil_IRTT_FaceDatabase_Version1.2/';
firstSample=imread('./datasets/Senthil_IRTT_FaceDatabase_Version1.2/s1_1.jpg');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=10;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 's' num2str(cc, '%d') '_' num2str(ss, '%d') '.jpg'];
        inputData(cc,ss,:,:)=imread(path);
        index = (cc-1)*numOfSamples + ss;
        inputLabel(index,1) = cc;
    end
end
inputData=double(inputData); % ???????

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 1;  % minimal number of training samples
maxTrains = 8;  % maximal number of training samples
%runWithNTrainings; % run with n training samples

disp('Test done!');