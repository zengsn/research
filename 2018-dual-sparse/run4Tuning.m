%% run4Tuning.m
% To find best parameters

clear all;

useDeep = 0;
isTuning= 1;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../lcle-dl'));  % add K-SVD box
%loadAR;
%loadFERET;
%loadGT;
%loadLFW;  % LFW dataset
%loadORL;
%loadMUCT;
%loadMUCTo3;
loadMUCTCrop;
%loadMUCTCropo3;
%loadMUCTCropRGB;
%loadMUCTCropRGBo3;
%loadYaleB;
%loadYaleB_New;
%loadCMUFaces;
%loadCFaces;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pSparsity   = [30,40];%[30,40];
pIters4Init = [1, 2]; %[1, 2];
pKnn        = [1, 3];
pAlpha      = [0, 1e-1, 1e-2];
pBeta       = [0, 1e-1, 1e-2];
pGamma      = [0, 1e-1, 1e-2];
pIterations = [10,15];

%% 3. PREPARE TRAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numOfTrain = 8; % The number of training sample of each class(including the first m images of each class)
prepareTrainData;
if useDeep==1
    prepareTrainDataDeep;
end
maxSizeOfDict=numOfClasses*numOfTrain;
maxSizeOfDict=numOfClasses*3;
sizeOfDict = maxSizeOfDict;
sizeOfDict = numOfClasses*floor(numOfTrain*0.5);
%sizeOfDict = numOfClasses;

%% 4. EVALUATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iSparsity=1:size(pSparsity,2)
    sparsityThres = pSparsity(iSparsity);
    for iIter4Init=1:size(pIters4Init,2)
        iterations4init = pIters4Init(iIter4Init);
        for iKnn=1:size(pKnn,2)
            knn = pKnn(iKnn);
            for iAlpha=1:size(pAlpha,2)
                alpha = pAlpha(iAlpha);
                for iBeta=1:size(pBeta,2)
                    beta = pBeta(iBeta);
                    for iGamma=1:size(pGamma,2)
                        gamma = pGamma(iGamma);
                        for iIter=1:size(pIterations,2)
                            iterations = pIterations(iIter);
                            %v_SR_DL; % run with different parameters
                            %SR_vDL;
                            vSR_DL;
                        end
                    end
                end
            end
        end
    end    
end % end numOfTrain

%% 4. END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Test done!');