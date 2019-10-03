
% Coarse_to_fine_KNN_AR

% Author: Yong Xu, Bio-Computing Research Center, Shenzhen Graduate School,
% Harbin Institute of Technology

% Homepage:  http://www.yongxu.org/lunwen.html


clear all;

KNN=1;   %   KNN: the k in KNN classifier

KNN=3;   %   KNN: the k in KNN classifier

KNN=5;   %   KNN: the k in KNN classifier

KNN0=9

m=26

c=120

dim=c-1;


for train_num=14:14
    %  for train_num=16:16
    %  for train_num=18:18
    %  for train_num=20:20
    
    test=m-train_num;
    
    N=c*train_num;
    N1=N;
    
    % start_number=100;
    start_number=200;
    end_number=c*train_num;
    
    folder='AR_gray_50by\AR';
    
    linshi0=imread('AR_gray_50by\AR001-1.tif');
    [row col]=size(linshi0);
    
    sb=zeros(row*col); sw=zeros(row*col);
    
    all_train_samples=[];
    for i=1:c
        for k=1:m
            filename=[folder num2str(i,'%03d') '-' num2str(k) '.tif'];
            temp00=imread(filename);
            temp0=reshape(temp00,row*col,1);
            input0(i,k,:)=temp0(:);
            
        end
    end
    input0=double(input0);
    
    for i=1:c
        for k=1:train_num
            temp1=input0(i,k,:);
            all_train_samples=[all_train_samples temp1(:)];
        end
    end
    
    
    for j=1:c
        for k=1:train_num
            linshi1(1,:)=input0(j,k,:);
            ex_data((j-1)*train_num+k,:)=input0(j,k,:)/norm(linshi1);
        end
    end
    for j=1:c
        for k=1:test
            linshi1(1,:)=input0(j,train_num+k,:);
            data((j-1)*test+k,:)=input0(j,train_num+k,:)/norm(linshi1);
        end
    end
    
    mean_allsamples=mean(all_train_samples');
    [size_1 size_2]=size(mean_allsamples);
    % sigma=zeros(size_2,size_2);
    % for kk=1:c*train_num
    %     tempory=all_train_samples(:,kk)-mean_allsamples';
    %     sigma=sigma+tempory*tempory';
    % end
    % [v,d]=eig(sigma);
    % d1=diag(d);
    % [d2,indexv]=sort(d1);
    % [aa bb]=size(v);
    %
    % mm=rank(sigma)
    %
    %
    % for qq=1:mm
    %     Vector(:,qq)=v(:,indexv(bb-qq+1));
    % end
    
    
    right_label_num=0;
    for mm=1:c
        class_train_num(mm)=train_num;
    end
    
    contribution0=zeros(row*col,c*train_num);
    
    store_matrix=inv(ex_data*ex_data'+0.01*eye(c*train_num))*ex_data;
    
    for j=1:test*c
        shiliang=data(j,:);
        
        %          solution=inv(ex_data*ex_data'+0.01*eye(c*train_num))*ex_data*shiliang';
        solution=store_matrix*shiliang';
        
        contribution0=zeros(row*col,c*train_num);
        
        for kk=1:c
            for hh=1:train_num
                contribution0(:,(kk-1)*train_num+hh)=solution((kk-1)*train_num+hh)*ex_data((kk-1)*train_num+hh,:)';
            end
        end
        
        for kk=1:c*train_num
            wucha0(kk)=norm(shiliang'-contribution0(:,kk));
        end
        [recorded_value record00]=sort(wucha0);
        record0(j,:)=record00(1,:);
        
        for qq=1:train_num*c
            record0_class(j,qq)=floor((record00(1)-1)/train_num)+1;
        end
        
    end
    
    
    % end_number=floor(c*train_num*0.1)
    end_number=300
    
    for n_number=end_number:end_number
        
        
        for j=1:test*c
            shiliang=data(j,:);
            
            for rr=1:n_number
                useful_train(rr,:)=ex_data(record0(j,rr),:);
            end
            
            %         solution=inv(useful_train*useful_train'+0.01*eye(n_number))*usefu
            %         l_train*shiliang';
            stored_solution=inv(useful_train*useful_train'+0.01*eye(n_number))*useful_train;
            
            
            solution=stored_solution*shiliang';
            
            contribution=zeros(row*col,N);%
            
            for kk=1:c
                for hh=1:n_number
                    if record0_class(j,hh)==kk
                        contribution(:,kk)=contribution(:,kk)+solution(hh)*useful_train(hh,:)';
                    end
                end
            end
            for kk=1:c
                wucha(kk)=norm(shiliang'-contribution(:,kk));
            end
            
            [min_value xx]=min(wucha);
            fen_label(j)=xx;
            
            for ii=1:n_number
                linshi=useful_train(ii,:);
                new_ex_data(ii,:)=solution(ii)*linshi;
            end
            
            for ii=1:n_number
                linshi=new_ex_data(ii,:);
                
                used_dis(ii)=norm(shiliang-linshi);
            end
            
            %           [min_val xuhao]=min(used_dis);
            [min_val xuhao]=sort(used_dis);
            
            for knn=1:KNN0
                final_fen_label(j,knn)=floor((record0(j,xuhao(knn))-1)/train_num+1);
            end
            
        end
        
    end
    
    for KNN=1:9
        %  for KNN=1:2
        
        errors=0;  final_errors=0;
        
        for i=1:test*c
            
            inte=floor((i-1)/test+1);
            label2(i)=inte;
            
            if fen_label(i)~=label2(i)
                errors=errors+1;
            end
            
            nearest_neighbor_number=zeros(c,1);
            %     for ccc=1:c
            %         for knn=1:KNN
            %             if final_fen_label(i,knn) ==ccc
            %                nearest_neighbor_number(ccc)=nearest_neighbor_number(ccc)+1;
            %             end
            %         end
            %     end
            
            for ccc=1:c
                aaa=find(final_fen_label(i,1: KNN)==ccc);
                nearest_neighbor_number(ccc)=length(aaa);
            end
            
            [zhi final_class(i)]=max(nearest_neighbor_number);
            
            if final_class(i)~=label2(i)
                final_errors=final_errors+1;
            end
            
        end
        
        accuracy0(train_num)=1-errors/c/test
        
        final_accuracy(KNN)=1-final_errors/c/test
        
        clear record0; clear record0_class; clear used_dis; clear used_ex_data;
        
    end
end