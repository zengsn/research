% runN.m
% Iterate different (n) training samples.

%% Set experimental cases
%minTrain = mFirstSamples + 1;
%minTrain = 1;
%maxTrain = floor(numOfSamples*0.8);
%maxTrain = 3;
%stepOfTran = max(ceil((maxTrain-minTrain)/8),1);
%stepOfTran = 1;
%maxTrain=minTrain; 
%runtimes = 3;
totalTimes = 0;
for numOfTrain=minTrain:stepOfTran:maxTrain
    % perform classification  
    for times=1:runtimes % run 3 times
        %randomTrain; % prepare random train data
        getTrain;
        TCRC_Norm1;
        %TCRC_Norm2;
        allResults(totalTimes+times,:) = [numOfTrain,times,a,b,th,accuracyCRC,accuracyTTLS,accuracyFusion];
    end
    % stats the average
    if runtimes>1
        avgCRC  = mean(allResults(totalTimes+1:totalTimes+runtimes,6));
        avgTTLS = mean(allResults(totalTimes+1:totalTimes+runtimes,7));
        avgTCRC = mean(allResults(totalTimes+1:totalTimes+runtimes,8));
        allAvgResults(numOfTrain-minTrain+1,:)=[numOfTrain,a,b,th,avgCRC,avgTTLS,avgTCRC];
        avgImproveCRC = (avgTCRC-avgCRC)*100/avgCRC;
        avgImproveTTLS= (avgTCRC-avgTTLS)*100/avgTTLS;
        % save to file
        jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_avg_' ];
        jsonFile = [jsonFile num2str(avgTCRC,'%.4f') '(' num2str(avgImproveCRC,'%.2f') '%,' num2str(avgImproveTTLS,'%.2f') '%)_'];
        jsonFile = [jsonFile num2str(a) ',' num2str(b) ',' num2str(th) '.json'];
        dbJson = savejson('', allResults(totalTimes+1:totalTimes+runtimes,:), jsonFile);
    end
    totalTimes = totalTimes+runtimes; % increase total times
    
end
% save to file
if maxTrain>minTrain
    jsonFile = [dbName '/' algName '_' num2str(minTrain) '-' num2str(maxTrain)];
    dbJson = savejson('', allResults, [jsonFile '.json']);
    if runtimes>1
        dbJson = savejson('', allAvgResults, [jsonFile '_avg.json']);
    end
end
