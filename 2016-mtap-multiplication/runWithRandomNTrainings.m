% runWithNTrainings.m
% Run experiment with different number of training samples
resultAvg = zeros(maxTrains,3);
for numOfTrain=minTrains:maxTrains
    numOfTest = numOfSamples-numOfTrain;
    
    % perform classification without random training samples
    %Multiplication; 
    
    %{
    result(numOfTrain,1)=errorsRatioSRC;
    result(numOfTrain,2)=errorsRatioCRC;
    result(numOfTrain,3)=errorsRatioFusion;
    result % print
    
    improveSRC = (errorsRatioSRC-errorsRatioFusion)*100/errorsRatioSRC;
    improveCRC = (errorsRatioCRC-errorsRatioFusion)*100/errorsRatioCRC;
    
    if errorsRatioFusion<errorsRatioSRC && errorsRatioFusion<errorsRatioCRC
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    elseif errorsRatioFusion<errorsRatioSRC
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    elseif errorsRatioFusion<errorsRatioCRC
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    else
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
    %}
    
    % perform classification with random training samples
    
    for rr=1:5 % run 5 times and obtain average of result
        MultiplicationRandom;        
        resultAvg(numOfTrain,1)=resultAvg(numOfTrain,1)+errorsRatioSRC;
        resultAvg(numOfTrain,2)=resultAvg(numOfTrain,2)+errorsRatioCRC;
        resultAvg(numOfTrain,3)=resultAvg(numOfTrain,3)+errorsRatioFusion;
        resultAvg % print
    end
       
    % compute the average
    resultAvg(numOfTrain,1)=resultAvg(numOfTrain,1)/5;
    resultAvg(numOfTrain,2)=resultAvg(numOfTrain,2)/5;
    resultAvg(numOfTrain,3)=resultAvg(numOfTrain,3)/5;
    resultAvg % print
    
    improveSRC = (resultAvg(numOfTrain,1)-resultAvg(numOfTrain,3))*100/resultAvg(numOfTrain,1);
    improveCRC = (resultAvg(numOfTrain,2)-resultAvg(numOfTrain,3))*100/resultAvg(numOfTrain,2);
    
    if resultAvg(numOfTrain,3)<resultAvg(numOfTrain,1) && resultAvg(numOfTrain,3)<resultAvg(numOfTrain,2)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    elseif resultAvg(numOfTrain,3)<resultAvg(numOfTrain,1)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    elseif resultAvg(numOfTrain,3)<resultAvg(numOfTrain,2)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    else
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    end
    dbJson = savejson('', resultAvg(numOfTrain,:), jsonFile);
end

jsonFile = ['=' dbName '_avg.json'];
dbJson = savejson('', resultAvg, jsonFile);