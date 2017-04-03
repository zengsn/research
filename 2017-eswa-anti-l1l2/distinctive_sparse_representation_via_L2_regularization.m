
%% distinctive_sparse_representation_via_L2_regularization
% This code is implemented on the ORL dataset. 
% If you need to use this work, please refer the following literature:
% Y. Xu, Z. Zhong, J. Yang, J. You, D. Zhang. A New Discriminative Sparse Representation Method for Robust Face Recognition 
% via  L2 Regularization,IEEE Transactions on Neural Networks and Learning Systems,DOI: 10.1109/TNNLS.2016.2580572.

clear all;
clc;


for train_num=2:6

    %% parametet setting
     gama=1e-3
     class_num=40;
     sample_num=10;   
     test_num=sample_num-train_num;
     errors=0;

    %% read the dataset
     folder='.\orl\orl';
     img=imread('.\orl\orl001.bmp');
     [row col]=size(img);
     clear img;
     for i=1:class_num
         for j=1:sample_num
             filename=[folder num2str((i-1)*sample_num+j,'%03d') '.bmp'];
             input0(i,j,:,:)=imread(filename);
         end
     end
     input0=double(input0);

    %% seperate the training samples and test samples
     for jj=1:class_num
         for k=1:train_num
             tempt0(1,:)=input0(jj,k,:);
             ex_data((jj-1)*train_num+k,:)=input0(jj,k,:)/norm(tempt0);
             Label_train((jj-1)*train_num+k)=jj;
         end
     end
     for jj=1:class_num
         for k=1:test_num
             tempt0(1,:)=input0(jj,k+train_num,:);
             data((jj-1)*test_num+k,:)=tempt0(1,:)/norm(tempt0);
             Label_test((jj-1)*test_num+k)=jj;
         end
     end
     ex_data1=ex_data';
     data1=data';

    %% solve the equation (11)
     [size1 size2]=size(ex_data1);
     M=eye(train_num*class_num);
     X=zeros(train_num*class_num);
     for i=1:class_num
         xi=ex_data1(:,(i-1)*train_num+1:i*train_num);
         M((i-1)*train_num+1:i*train_num,(i-1)*train_num+1:i*train_num)=xi'*xi;
     end
     X=ex_data*ex_data';
     T=inv((1+2*gama)*X+2*gama*class_num*M);

    %% classify the test samples
     for i=1:class_num*test_num
         y(:,1)=data1(:,i);
         solution=T*ex_data*y;

         contribution0=zeros(size1,class_num);

         for kk=1:class_num
             for hh=1:train_num
                 contribution0(:,kk)=solution((kk-1)*train_num+hh)*ex_data1(:,(kk-1)*train_num+hh)+contribution0(:,kk);
             end
         end
         for kk=1:class_num
             wucha0(kk)=norm(y-contribution0(:,kk));
         end
         [recorded_value record00]=min(wucha0);
         record0_class(i)=record00;

         inte=floor((i-1)/test_num)+1;
         label2(i)=inte;
         if record0_class(i)~=label2(i)
             errors=errors+1;
         end
     end
     errors_ratio=errors/test_num/class_num;
     train_num
     accuracy=1-errors_ratio
     clear;
end
  


