% stats.m
% stats the results and ouput the Table content for LaTeX

clear all;

% GT
res=loadjson('GT-k=0.5/TCRC_1-12.json');
avg=loadjson('GT-k=0.5/TCRC_1-12_avg.json');
% FERET
%res=loadjson('FERET-k=0.3/TCRC_1-5.json');
%avg=loadjson('FERET-k=0.3/TCRC_1-5_avg.json');
% LFW
%res=loadjson('LFW-k=0.4/TCRC_1-8.json');
%avg=loadjson('LFW-k=0.4/TCRC_1-8_avg.json');

% Stats
[maxTrain,~]=size(avg);
for i=1:maxTrain
    all(i,1) = i; % train
    % CRC
    mi=min(res(3*(i-1)+1:3*(i-1)+3,6)); % min
    ma=max(res(3*(i-1)+1:3*(i-1)+3,6)); % max
    me=mean(res(3*(i-1)+1:3*(i-1)+3,6));% mean
    all(i,2) = me;% CRC
    all(i,3) = mean([ma-me,me-mi]); % diff
    % TTLS
    mi=min(res(3*(i-1)+1:3*(i-1)+3,7)); % min
    ma=max(res(3*(i-1)+1:3*(i-1)+3,7)); % max
    me=mean(res(3*(i-1)+1:3*(i-1)+3,7));% mean
    all(i,4) = me;% TTLS
    all(i,5) = mean([ma-me,me-mi]); % diff
    % TCRC
    mi=min(res(3*(i-1)+1:3*(i-1)+3,8)); % min
    ma=max(res(3*(i-1)+1:3*(i-1)+3,8)); % max
    me=mean(res(3*(i-1)+1:3*(i-1)+3,8));% mean
    all(i,6) = me;% TTLS
    all(i,7) = mean([ma-me,me-mi]); % diff
    % Impr
    impr=(res(3*(i-1)+1:3*(i-1)+3,8)-res(3*(i-1)+1:3*(i-1)+3,6)) ./ res(3*(i-1)+1:3*(i-1)+3,6);
    mi=min(impr);
    ma=max(impr);
    me=mean(impr);
    all(i,8) = me;% Impro
    all(i,9) = mean([ma-me,me-mi]); % diff
end

% print
allT=all'; tr=1; % train
[rows, cols] = size(allT);
for i=1:ceil(cols/3)
    for j=1:4
        if j==1 fprintf('CRC ');
        elseif j==2 fprintf('TTLS ');
        elseif j==3 fprintf('TCRC ');
        else fprintf('Impr ');
        end
        
        for t=1:3
            %if (tr<cols*4)
            if (i-1)*3+t<=cols
                fprintf('\t& %.2f$\\pm$%.2f \\%% ',allT(2*j,(i-1)*3+t)*100,allT(2*j+1,(i-1)*3+t)*100);
                %tr = tr+1;
            else
                fprintf('\t& ');
            end
        end
        
        fprintf('\t\\\\\n');
    end
    fprintf('\n');
end
