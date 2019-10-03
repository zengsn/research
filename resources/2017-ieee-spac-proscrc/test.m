
minTrain = 5;
maxTrain = 7;
trainStep = 1;
for numOfTrain=minTrain:trainStep:maxTrain
    %fprintf('%d\n',numOfTrain);
    if (numOfTrain == 6)
        continue;
    end
    fprintf('%d\n',numOfTrain);
end