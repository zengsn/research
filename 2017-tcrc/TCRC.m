% TCRC.m

algName = 'TCRC';

%% parameters
% numOfTrain
% trainData
% trainLabel
% testData
% testLabel

[numOfAllTrain,~]=size(trainLabel);
[numOfAllTest,~]=size(testLabel);
fprintf('numOfAllTrain=%d,\tnumOfAllTest=%d,\t numOfClasses=%d \n', numOfAllTrain, numOfAllTest, numOfClasses);

%% fusion parameters
%aCases = [1,5,10,20,30,40,50,60,70,80];
%aCases = [0.5,0.1,0.05,0.03,0.025,0.02,0.01,0.001];
%aCases = [0.001,0.01,0.05,0.1,0.5];
%aCases = [5];
%[~,numOfCases]=size(aCases);
%thCases=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
%thCases=[0.1,0.2,0.3,0.4];
%thCases=[0.5,0.6,0.7,0.8];
%thCases=[0.1];
%[~,numOfThresh]=size(thCases);

% (T*T'+aU)-1 * T
clear preserved;
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;

%
errorsCRC = 0;
errorsTTLS = 0; % errors
errorsFusion = 0; % errors

%% CRC
disp('Collaborative representation ...');
if exist('lastTrain','var') && lastTrain==numOfTrain
    fprintf('---> Already done in %.3f (s) with accracy = %.4f \n', time_CRC, accuracyCRC);
else
    tic
    clear testSample;
    clear solutionCRC;
    contributionsCRC = zeros(dim,numOfClasses,numOfAllTest);
    for kk=1:numOfAllTest
        testSample=testData(kk,:);
        % CRC ????(T*T'+aU)^-1 * T * D(i)'
        solutionCRC=preserved*testSample';
        clear contributionCRC;
        for cc=1:numOfClasses
            contributionCRC(:,cc)=zeros(dim,1);
            for tt=1:numOfTrain % C(i) = sum(S(i)*T)
                contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            end
        end
        % save for fusion later
        contributionsCRC(:,:,kk) = contributionCRC(:,:);
        % deviation
        clear deviationCRC;
        for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
            deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc))/norm(contributionCRC);
            %deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc)); % same
        end
        % recognition
        [min_value labelCRC]=min(deviationCRC);
        if labelCRC ~= testLabel(kk,1)
            errorsCRC=errorsCRC+1;
        end
    end
    accuracyCRC = 1-errorsCRC/numOfAllTest;
    time_CRC = toc;
    fprintf('---> Done in %.3f (s) with accracy = %.4f \n', time_CRC, accuracyCRC);
    lastTrain = numOfTrain; % same training samples output the same result
end

%% TTLS
disp('Truncated TLS ... ');
if exist('isTune','var') && exist('lastTrain','var') && lastTrain==numOfTrain && exist('lastK','var') && lastK==k
    fprintf('---> Already done in %.3f (s) with accracy = %.4f \n', time_TTLS, accuracyTTLS);
else
    tic
    clear solutionTTLS;
    contributionsTTLS = zeros(dim,numOfClasses,numOfAllTest);
    for kk=1:numOfAllTest
        testSample=testData(kk,:);
        % SRC by T-TLS
        solutionTTLS = TTLS(trainData', testSample', k);
        clear contributionTTLS;
        for cc=1:numOfClasses
            contributionTTLS(:,cc)=zeros(dim,1);
            for tt=1:numOfTrain % C(i) = sum(S(i)*T)
                contributionTTLS(:,cc)=contributionTTLS(:,cc)+solutionTTLS((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            end
        end
        % save for fusion later
        contributionsTTLS(:,:,kk) = contributionTTLS(:,:);
        % deviation
        clear deviationTTLS;
        for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
            deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc))/norm(contributionTTLS);
            %deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc)); % same
        end
        % recognition
        [min_value labelTTLS]=min(deviationTTLS);
        if labelTTLS ~= testLabel(kk,1)
            errorsTTLS=errorsTTLS+1;
        end
    end
    accuracyTTLS = 1-errorsTTLS/numOfAllTest;
    time_TTLS = toc;
    fprintf('---> Done in %.3f (s) with accracy = %.4f \n', time_TTLS, accuracyTTLS);
    lastK = k;
end

%% fusion
disp('Perform fusion ...');
clear contributionFusion;
for kk=1:numOfAllTest
    testSample=testData(kk,:);
    for cc=1:numOfClasses
        contributionCRC(:,cc) = contributionsCRC(:,cc,kk);
        contributionTTLS(:,cc) = contributionsTTLS(:,cc,kk);
        contributionFusion(:,cc)= a*contributionCRC(:,cc)+b*contributionTTLS(:,cc); % Fusion
    end
    clear deviationFusion;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/norm(contributionFusion)/(a+b));
        %deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/(a+b)); % same
    end
    % recognition
    [min_value labelFusion]=min(deviationFusion);
    if labelFusion ~= testLabel(kk,1)
        errorsFusion=errorsFusion+1;
    end
end
% accuracy
accuracyFusion = 1-errorsFusion/numOfAllTest;
fprintf('---> Done in %.3f (s) with accracy = %.4f \n\n', time_CRC+time_TTLS, accuracyFusion);

improveCRC = (accuracyFusion-accuracyCRC)*100/accuracyCRC;
improveTTLS= (accuracyFusion-accuracyTTLS)*100/accuracyTTLS;

% result path
if ~isequal(exist(dbName, 'dir'),7)
    mkdir(dbName);
end

% save result to file
jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') ];
jsonFile = [jsonFile '(' num2str(improveCRC,'%.2f') '%,' num2str(improveTTLS,'%.2f') '%)' ];
jsonFile = [jsonFile '_' num2str(a) ',' num2str(b) ',' num2str(k) '_' num2str(times) '.json'];
result   = [numOfTrain,a,b,k,accuracyCRC,accuracyTTLS,accuracyFusion,trainIndices];
dbJson = savejson('', result, jsonFile);
%result; % print
%sendEmail(jsonFile,mat2str(resultInCase),jsonFile);