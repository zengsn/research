
%% Using_the_idea_coarse_to_fine_face_recognition

% code of paper "Using the idea of the sparse representation to perform
% coarse to fine face recognition", <<Information Sciences>>

% Author: Yong Xu et al.

% Webpage: http://www.yongxu.org/lunwen.html

% Main content: According to the paper, in order to realise face recognition, this code consists of two stages 
%      and works in sparse representation method except gaining data and calculating the average error rate.
%      The first stage uses a linear combination of all the training samples to represent the test sample and 
%      exploits this linear combination to coarsely determine candidate class labels of the test sample. 
%      The second stage again uses a weighted combination of all the training samples from the candidate classes 
%      to represent the test sample and uses the representation result to perform the ultimate classification.
%      Then classifies per testing sample into the class that has a great capability in representing it and
%      produces the smallest ultimate residual.

% Face database: ORL

% Ultimate results: error_2_rate--a matrix means the average error rate,column index indicates selected candidate   
%                                 category number in the second stage.
%                   classification error rate--a figure means the rates of classification errors(%),the horizontal
%                                 axis means candidate class number, the corresponding vertical axis shows the means 
%                                 of the rates of classification errors of the global versions.
                           

clear all;
u=0.01;
p=40                             % number of persons 
q=10;                             % face images of each person
train=6;                          % number of training samples per person
test=q-train;                     % number of testing samples per person
folder='orl\orl';
picture=imread('orl\orl001.bmp');
row=size(picture,1);
col=size(picture,2);
X_N=p*train;                      % number of all training samples
Y_N=p*test;                       % number of all testing samples
X=zeros(row*col,X_N);             % the training sample set of the first phase
Y=zeros(row*col,Y_N);             % the testing sample set
E_rate=zeros(2,p);                % global  classification error rate
for i=1:p                         % get data of all samples 
    for j=1:q
        pic=[folder num2str((i-1)*q+j,'%03d')  '.bmp'];
        inpic(i,j,:,:)=imread(pic);       
    end
end
inpic=double(inpic);
C_N=combntns(1:q,train);
[row1,col1]=size(C_N);            % row1£º the number of the training sample sets
rr_N=1;                           % According to the paper, the true value of "rr_N" should be "row1". Here in order to fastly get the resut, we set it to 1
rr_n=0                           % record cycle index of "rr"
 for rr=1:rr_N                    % to run "rr_N" times, and calculate the corresponding mean error rate
    rr_n=rr_n+1;
    X_n=0;                        % for counting and signing
    Y_n=0;
 for i=1:p;
    trsample(:,:)=inpic(i,:,:);   % training sample set of per person
    for j=1:q;
        flag=0;
        for k=1:train
            if j==C_N(rr,k)
                flag=1;
                X_n=X_n+1;
                X(:,X_n)=inpic(i,j,:);
                X(:,X_n)=X(:,X_n)/norm(X(:,X_n));   % characteristic value
                X_class(1,X_n)=i;                   % signing class label of training sample
                break
            end
        end
           if flag==0;
               Y_n=Y_n+1;
                Y(:,Y_n)=inpic(i,j,:);
                Y(:,Y_n)=Y(:,Y_n)/norm(Y(:,Y_n));
                Y_class(1,Y_n)=i;                   % signing class label of testing sample
           end
    end
 end
  M_n=0;                                            % record cycle number of "M"
 for M=5:5:p                                        % "M" classes as candidates for second phase
   M_n=M_n+1;
   I2=eye(M*train);
     error1_n=zeros(1,p);                           % explain later
     error1_r=zeros(1,p);
     error2_n=zeros(1,p);
     error2_r=zeros(1,p);
   error1_rate(M_n,rr_n)=0;                         % mean classification error rate of the first phase for each "rr"
   error2_rate(M_n,rr_n)=0;                         % mean classification error rate of the second phase for each "rr"
   error_1_r(M_n,p)=0;                              % mean classification error rate per "M"
   error_2_r(M_n,p)=0;
for i=1:Y_N
    
%------------------------------------The first stage------------------------------------
%---Uses a linear combination (Ctr) of all the training samples (X) to represent the test
%---sample (Y) and coarsely determines "M" candidate class labels of the test sample.
%---------------------------------------------------------------------------------------

I1=eye(X_N);
ctribt=zeros(row*col,X_N);                          % record contributions in expressing the test samples of per taining sample
Ctr=zeros(row*col,p);                               % record contributions in expressing the test samples of per class
e=zeros(1,p);                                       % record residuals of per class 
A=inv(X'*X+u*I1)*X'*Y(:,i);                         % evaluate coefficient matrix of the first phase
   for j=1:X_N 
      ctribt(:,j)=A(j,1)*X(:,j);                    % evaluate the contribution in expressing the test sample using per training samples 
   end
   for j=0:(p-1)
       for n=1:train                
          Ctr(:,j+1)=Ctr(:,j+1)+ctribt(:,j*train+n);% evaluate the sum contribution using training samples of "j" class
       end
   end                   
   for n=1:p
       e(1,n)=norm(Y(:,i)-Ctr(:,n));                % calculate the residual of per class 
   end
    [a,b]=sort(e,2);                                % sort residuals in ascending order 
    L=b(:,1:M);                                     % take the minimum "M" classes as candidates 
    if L(1,1)~=Y_class(1,i)
       error1_n(Y_class(1,i))=error1_n(Y_class(1,i))+1;
    end
    
%---------------------------------The second stage-----------------------------------
%---First represents the test sample (Y) as a linear combination (g) of the training
%---samples of the first "M" candidate classes (X2), then classify the test sample 
%---into a class that has a great capability in representing it.
%-------------------------------------------------------------------------------------

    X2=zeros(row*col,M*train);
    X2_n=0;
    for j=1:X_N                                     % take all training samples of the "M" classes  as candidate training sample set
        for k=1:M 
            if X_class(1,j)==L(1,k)
               X2_n=X2_n+1;
               X2(:,X2_n)=X(:,j);
               X2_class(1,X2_n)=L(1,k);             % signing the class lable of per training sample of the "M" classes
             end
        end        
    end
       B=inv(X2'*X2+u*I2)*X2'*Y(:,i);               % calculate  coefficient matrix of the second phase
       g=zeros(row*col,M);
       for k=1:M
           for n=1:train*M
               if X2_class(1,n)==L(1,k)
                 g(:,k)=g(:,k)+B(n,1)*X2(:,n);      % calculate contribution in representing the testing sample of per class 
               end                              
           end
           D(1,k)=norm(Y(:,i)-g(:,k));              % record residuals of per class
       end
       [DM,lab]=min(D,[],2);                        % take minimum residual
       Y_lab(i)=L(1,lab);                           % classify into the class that produces the smallest ultimate residual.
       if Y_lab(i)~=Y_class(1,i)
           error2_n(Y_class(1,i))= error2_n(Y_class(1,i))+1;  % calculate classification error of per class
       end
end
for i=1:p
    error1_r(i)=error1_n(i)/(p*test);                % calculate classification error rate of per class for each "M & rr"
    error2_r(i)=error2_n(i)/(p*test);
end
    error1_rate(M_n,rr_n)=sum(error1_r);             % calculate sum of classification error rate of per class for each "M & rr"
    error2_rate(M_n,rr_n)=sum(error2_r);
    error_1_rate(M_n,rr_n)=mean(error1_rate(M_n,:)); % mean calculate classification error rate per "M"
    error_2_rate(M_n,rr_n)=mean(error2_rate(M_n,:));
 if rr_n==rr_N
    E_rate(1,M)=error_1_rate(M_n,rr_N);
    E_rate(2,M)=error_2_rate(M_n,rr_N);
 end
 end 
 end
 
 %--------------------------------Output the solution------------------------------
 
 E_rate(2,:)
 M=5:5:p;
 R=E_rate(2,M)*100;
 plot(M,R,'-rd'),xlabel('M'),ylabel('error rate')
 title('classification error rate (%)')
 axis([0 40 5 8.5])
 grid on
 legend('number of taining samples per person: 6')