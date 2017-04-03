% runOnYaleB.m
% Extended Yale B库
% The extended Yale Face Database B contains 16128 images of 28 human subjects 
% under 9 poses and 64 illumination conditions. 
% The data format of this database is the same as the Yale Face Database B.

clear all;
% 加载数据       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'ExtYaleB';
pathPrefix='../datasets/CroppedYaleB/yaleB';
firstSample=imread('../datasets/CroppedYaleB/yaleB01/yaleB01_P00_Ambient.pgm');
scale=0.5;
halfSample =imresize(firstSample,scale);
[row col]=size(halfSample);
numOfSamples=57;
numOfClasses=38;

types=cell(11,1);
%types{1}='_P00_Ambient'; % bad   
types{1}='_P00A-005E-10';   types{2}='_P00A-005E+10';   types{3}='_P00A-010E-20';
%types{4}='_P00A-010E+00'; % bad
types{4}='_P00A-015E+20';   types{5}='_P00A-020E-10';   types{6}='_P00A-020E-40';   
types{7}='_P00A-020E+10';   types{8}='_P00A-025E+00';   types{9}='_P00A-035E-20';  
types{10}='_P00A-035E+15';
%types{10}='_P00A-035E+40'; % bad 
types{11}='_P00A-035E+65';  
%types{12}='_P00A-050E-40'; % bad
types{12}='_P00A-050E+00';  types{13}='_P00A-060E-20';  types{14}='_P00A-060E+20';
types{15}='_P00A-070E-35';  types{16}='_P00A-070E+00';  types{17}='_P00A-070E+45';
types{18}='_P00A-085E-20';  types{19}='_P00A-085E+20';  types{20}='_P00A-095E+00';
%types{21}='_P00A-110E-20'; 
%types{21}='_P00A-110E+15';  
types{21}='_P00A-110E+40';  types{22}='_P00A-110E+65';  types{23}='_P00A-120E+00';  
types{24}='_P00A-130E+20';  types{25}='_P00A+000E-20';  types{26}='_P00A+000E-35';  
types{27}='_P00A+000E+00';  types{28}='_P00A+000E+20';  types{29}='_P00A+000E+45';  
types{30}='_P00A+000E+90';  types{31}='_P00A+005E-10';  types{32}='_P00A+005E+10';  
types{33}='_P00A+010E-20';  types{34}='_P00A+010E+00';  types{35}='_P00A+015E+20';  
types{36}='_P00A+020E-10';  types{37}='_P00A+020E-40';  types{38}='_P00A+020E+10';  
types{39}='_P00A+025E+00';  types{40}='_P00A+035E-20';  types{41}='_P00A+035E+15';  
types{42}='_P00A+035E+40';  types{43}='_P00A+035E+65';  
%types{44}='_P00A+050E-40'; % bad 
types{44}='_P00A+050E+00';  types{45}='_P00A+060E-20';  types{46}='_P00A+060E+20';  
types{47}='_P00A+070E-35';  types{48}='_P00A+070E+00';  types{49}='_P00A+070E+45';  
types{50}='_P00A+085E-20';  types{51}='_P00A+085E+20';  
%types{52}='_P00A+095E+00'; % bad
types{52}='_P00A+110E-20';  types{53}='_P00A+110E+15';  types{54}='_P00A+110E+40';  
types{55}='_P00A+110E+65';  types{56}='_P00A+120E+00';  types{57}='_P00A+130E+20';  

for cc=1:numOfClasses
    for ss=1:numOfSamples
        if cc<14 % 14th subject not exist
            path=[pathPrefix num2str(cc, '%02d') '/yaleB' num2str(cc, '%02d') types{ss} '.pgm'];
        else
            path=[pathPrefix num2str(cc+1, '%02d') '/yaleB' num2str(cc+1, '%02d') types{ss} '.pgm'];
        end
        fullSample = imread(path);
        halfSample = imresize(fullSample,scale); % 压缩大小
        inputData(cc,ss,:,:)=halfSample;
    end
end
%inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minTrains = 1;  % minimal number of training samples
maxTrains = 10;  % maximal number of training samples
trainStep=1;
salt = .3;
runWithNBetterTrainings; % run with n training samples
%runWithRandomNTrainings2; % run with n training samples

% Cross validation
%numOfParts = 5;
%runWithNCrossValidation;

disp('Test done!');