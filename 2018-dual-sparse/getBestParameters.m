function [sparsityThres,iterations4init,knn,alpha,beta,gamma,iterations,bestLambda] = getBestParameters(dbName,algName)
if strcmp(dbName,'GT') % GT
    if strcmp(algName,'v_SR_DL')
        sparsityThres = 40; % sparsity prior
        iterations4init =2; % iteration number for initialization
        knn=1; % or 1
        alpha=1e-1;
        beta=1e-2;
        gamma=1e-1;
        iterations = 10; % iteration number
        %lambda=-0.5;     % set in v_SR_DL.m
    elseif strcmp(algName,'vSR_DL')
        sparsityThres = 30; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=1; %
        alpha=1e-2;
        beta=1e-2;
        gamma=1e-1;
        iterations = 10; % iteration number
        %lambda=-0.5;     % set in vSR_DL.m
    end
elseif strcmp(dbName,'CMUFaces') % CMUFaces
    if strmp(dbName,'v_SR_DL')
        sparsityThres = 30; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=1; % or 1
        alpha=1e-2;
        beta=1e-2;
        gamma=1e-1;
        iterations = 10; % iteration number
        %lambda=-0.5;     % set in v_SRC_DL.m
    elseif strcmp(algName,'vSR_DL')
        sparsityThres = 40; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=1; %
        alpha=1e-2;
        beta=1e-2;
        gamma=1e-2;
        iterations = 10; % iteration number
        %lambda=-0.5;     % set in vSR_vDL.m
    elseif strmp(dbName,'SR_vDL')
        sparsityThres = 40; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=3; %
        alpha=1e-2;
        beta=1e-1;
        gamma=1e-2;
        iterations = 10; % iteration number
        %lambda=-5;     % set in SR_vDL.m
    end
elseif strcmp(dbName,'LFW') % LFW
    if strcmp(algName, 'v_SR_DL')
        sparsityThres = 30; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=3; % or 1
        alpha=1e-2;
        beta=1e-1;
        gamma=1e-1;
        iterations = 15; % iteration number
        %lambda=-5;     % set in v_SR_DL.m
    elseif strcmp(algName, 'vSR_DL')
        sparsityThres = 40; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=1; % or 1
        alpha=1e-2;
        beta=1e-1;
        gamma=1e-2;
        iterations = 10; % iteration number
        %lambda=-5;     % set in vSR_DL.m
    elseif strcmp(algName, 'SR_vDL')
        sparsityThres = 40; % sparsity prior
        iterations4init =1; % iteration number for initialization
        knn=1; % or 1
        alpha=1e-2;
        beta=1e-2;
        gamma=1e-2;
        iterations = 15; % iteration number
        %lambda=-5;     % set in SR_vDL.m
    end
elseif strcmp(dbName,'MUCTCrop') % MUCTCrop
    if strcmp(algName, 'v_SR_DL')
        sparsityThres   = 30; % sparsity prior
        iterations4init = 1;  % iteration number for initialization
        knn     = 1;          % or 1
        alpha   = 1e-1;
        beta    = 1e-2;
        gamma   = 1e-1;
        iterations = 10;      % iteration number
        bestLambda = -0.5;    % set in v_SR_DL.m
    elseif strcmp(algName, 'vSR_DL')
        sparsityThres   = 30; % sparsity prior
        iterations4init = 1;  % iteration number for initialization
        knn     = 1;          % or 1
        alpha   = 0;
        beta    = 0;
        gamma   = 1e-2;
        iterations = 10;      % iteration number
        bestLambda = -0.5;    % set in vSR_DL.m
    elseif strcmp(algName, 'SR_vDL')
        sparsityThres   = 30; % sparsity prior
        iterations4init = 1;  % iteration number for initialization
        knn     = 1;          % or 1
        alpha   = 0.1;
        beta    = 0;
        gamma   = 1e-2;
        iterations = 15;      % iteration number
        bestLambda = -0.5;    % set in vSR_DL.m
    end
elseif strcmp(dbName,'MUCTCropo3') % MUCTCropo3
    if strcmp(algName, 'v_SR_DL')
        sparsityThres   = 40; % sparsity prior
        iterations4init = 2;  % iteration number for initialization
        knn     = 1;          % or 1
        alpha   = 1e-2;
        beta    = 1e-1;
        gamma   = 1e-1;
        iterations = 15;      % iteration number
        bestLambda = -0.5;    % set in v-SR-DL.m
    elseif strcmp(algName, 'vSR_DL')
        sparsityThres   = 40; % sparsity prior
        iterations4init = 2;  % iteration number for initialization
        knn     = 1;          % or 2
        alpha   = 1e-2;
        beta    = 1e-2;
        gamma   = 1e-1;
        iterations = 15;      % iteration number
        bestLambda = -0.5;    % set in vSR-vDL.m
    elseif strcmp(algName, 'SR_vDL')
        sparsityThres   = 30; % sparsity prior
        iterations4init = 1;  % iteration number for initialization
        knn     = 1;          % or 2
        alpha   = 1e-2;
        beta    = 0;
        gamma   = 0;
        iterations = 10;      % iteration number
        bestLambda = -0.5;    % set in SR_vDL.m
    end
end
end