%% run4Tuning.m
% To find best parameters

clear all;

%% 1. LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../lcle-dl'));  % add K-SVD box
%loadAR;
%loadFERET;
%loadGT;
%loadLFW;  % LFW dataset
%loadORL;
%loadMUCT;
%loadYaleB;
%loadCMUFaces;
%loadCFaces;
loadCLeaves;
%loadFlavia;
%loadLeaf;
%loadLeafsnap;
%loadOneHundredLeaf;
%loadSwedishLeaf;
%loadHerbariumIso;
%loadHerbarium;
disp('Data is ready!');

%% 2. PREPARE CASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pSparsity   = [30,40];%[30,40];
pIters4Init = [1, 2]; %[1, 2];
pKnn        = [1, 3];
pAlpha      = [1e-1, 1e-2];
pBeta       = [1e-1, 1e-2];
pGamma      = [1e-1, 1e-2];
pIterations = [10,15];

%% 3. PREPARE TRAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numOfTrain = 2; % The number of training sample of each class(including the first m images of each class)
prepareTrainData;
sizeOfDict = maxSizeOfDict;
sizeOfDict = numOfClasses;

%% 4. EVALUATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iSparsity=1:2
    sparsityThres = pSparsity(iSparsity);
    for iIter4Init=1:2
        iterations4init = pIters4Init(iIter4Init);
        for iKnn=1:2
            knn = pKnn(iKnn);
            for iAlpha=1:2
                alpha = pAlpha(iAlpha);
                for iBeta=1:2
                    beta = pBeta(iBeta);
                    for iGamma=1:2
                        gamma = pGamma(iGamma);
                        for iIter=1:2
                            iterations = pIterations(iIter);
                            SRC_DL; % run with different parameters
                        end
                    end
                end
            end
        end
    end    
end % end numOfTrain

%% 4. END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Test done!');