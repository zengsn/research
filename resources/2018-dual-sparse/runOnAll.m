% runOnAll.m

clear all;

useDeep = 1;

% use different deep models
for iModel=1:3
    if iModel==1
        deepModel = 'FaceNet';
    elseif iModel==2
        deepModel = 'ResNet_v1_101.logits';
    elseif iModel==3
        deepModel = 'ResNet_v1_101.global_pool';
    end
    % iterate different databases
    for iDb=1:4
        clear inputData;
        clear inputLabel;
        clear eachClass;
        if iDb==1
            loadCMUFaces;
        elseif iDb==2
            loadGT;
        elseif iDb==3
            loadLFW0;
        elseif iDb==4
            loadMUCT;
        end  
        dbName %
        disp('Data is ready!');
        % run
        run4Tuning;
    end
end