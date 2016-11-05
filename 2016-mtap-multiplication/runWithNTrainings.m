% runWithNTrainings.m
% Run experiment with different number of training samples

for numOfTrain=minTrains:maxTrains
    numOfTest = numOfSamples-numOfTrain;
    
    % perform classification without random training samples
    Multiplication; 
    
    
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
   
    
    % perform classification with random training samples
    %{
    resultAvg = zeros(1,3);
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
    
    improveSRC = (resultAvg(1,1)-resultAvg(1,3))*100/resultAvg(1,1);
    improveCRC = (resultAvg(1,2)-resultAvg(1,3))*100/resultAvg(1,2);
    
    if resultAvg(1,3)<resultAvg(1,1) && resultAvg(1,3)<resultAvg(1,2)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    elseif resultAvg(1,3)<resultAvg(1,1)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s+' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    elseif resultAvg(1,3)<resultAvg(1,2)
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%.json'];
    else
        jsonFile = ['=' dbName '_avg_' num2str(numOfTrain) '_s' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%.json'];
    end
    dbJson = savejson('', resultAvg(numOfTrain,:), jsonFile);
    %}
end

jsonFile = ['=' dbName '_.json'];
dbJson = savejson('', result, jsonFile);