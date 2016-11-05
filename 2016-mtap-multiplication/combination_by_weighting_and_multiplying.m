

% combination_by_weighting_on_GT.m

clear all;

addpath 'src_solution';

% miu=1.0e-3;

% db_name = 'gt';
% path='Georgia Tech face database crop/';
% test1=imread('Georgia Tech face database crop/1_1.jpg');
% [size_a size_b size_c]=size(test1);
% [row col]=size(rgb2gray(test1));

db_name = 'orl';
path='orl/orl';
test1=imread('orl/orl001.bmp');
[row col]=size(test1);

%db_name = 'feret';
%path='feret/';
%test1=imread('feret/1.tif');
%[row col]=size(test1);

clear test1;

% GT
%sample_num=15;
%class_num=50;
% ORL
sample_num=10;
class_num=40;
% FERET
%sample_num=7;
%class_num=200;

defined_number=50;      %% The largest dimensionality of the features obtained using the proposed method.

%M=class_num; N=train_num;

for cc=1:class_num
    % GT
    %path20=[path  int2str(cc)];
    
    for sn=1:sample_num
        % GT
        %path2=[path20 '_' int2str(sn) '.jpg'];        
        %test0=imread(path2);        
        %test1=double(rgb2gray(test0));        
        %input0(cc,sn,:,:)= test1(:,:);
        % ORL
        path2=[path num2str((cc-1)*sample_num+sn,'%03d')  '.bmp'];
        % FERET
        %path2=[path num2str((cc-1)*sample_num+sn,'%d')  '.tif'];
           
        input0(cc,sn,:,:)=imread(path2);
    end
end
input0=double(input0);

% Test with different training numbers
train_start = 1;
train_end   = 6;
for train_num=train_start:train_end
    
    test_num=sample_num-train_num;
    
    fprintf('%d, %d * %d = %d.\n', train_num, test_num, class_num, test_num*class_num);
    
    % 取出相应原始训练集和测试集
    for cc=1:class_num
        for trr=1:train_num
            zanshi(1,:)=input0(cc,trr,:);
            ex_data((cc-1)*train_num+trr,:)=zanshi/norm(zanshi);
        end
    end
    for cc=1:class_num
        for tee=1:test_num
            zanshi(1,:)=input0(cc,tee+train_num,:);
            data((cc-1)*test_num+tee,:)=zanshi/norm(zanshi);
        end
    end
    
    n_number=class_num*train_num
    
    useful_train=ex_data;
    % (T*T'+aU)-1 * T
    preserved=inv(useful_train*useful_train'+0.01*eye(n_number))*useful_train;
    
    % 4 SRCs (L1LS, FISTA, DALM & DALM_fast)
    for ii=1:test_num*class_num
        shiliang=data(ii,:);
        % (T*T'+aU)^-1 * T * D(i)'
        solution_c=preserved*shiliang';
        
        fprintf('%d ', ii);
        if mod(ii,20)==0
            fprintf('\n');
        end
        
        %%%%%%%%%%%%%如下不同的SRC解法可任选一种
        [solution_s_L, total_iter] =    SolveL1LS(useful_train',shiliang');
        [solution_s_F, total_iter] =    SolveFISTA(useful_train',shiliang');
        [solution_s_D, total_iter] =    SolveDALM(useful_train',shiliang');
        [solution_s_Df, total_iter] =    SolveDALM_fast(useful_train',shiliang');
        
        %disp(['Solutions of test sample ' num2str(ii) ' by L1LS, FISTA, DALM and DALM fast.']);
        
        for kk=1:class_num
            contribution_L(:,kk)=zeros(row*col,1);
            contribution_F(:,kk)=zeros(row*col,1);
            contribution_D(:,kk)=zeros(row*col,1);
            contribution_Df(:,kk)=zeros(row*col,1);
            contribution2_L(:,kk)=zeros(row*col,1);
            contribution2_F(:,kk)=zeros(row*col,1);
            contribution2_D(:,kk)=zeros(row*col,1);
            contribution2_Df(:,kk)=zeros(row*col,1);
            contribution_s_L(:,kk)=zeros(row*col,1);
            contribution_s_F(:,kk)=zeros(row*col,1);
            contribution_s_D(:,kk)=zeros(row*col,1);
            contribution_s_Df(:,kk)=zeros(row*col,1);
            contribution_c(:,kk)=zeros(row*col,1);
            
            for hh=1:train_num
                % C(i) = sum(S(i)*T)
                contribution_s_L(:,kk)=contribution_s_L(:,kk)+solution_s_L((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
                contribution_s_F(:,kk)=contribution_s_F(:,kk)+solution_s_F((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
                contribution_s_D(:,kk)=contribution_s_D(:,kk)+solution_s_D((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
                contribution_s_Df(:,kk)=contribution_s_Df(:,kk)+solution_s_Df((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
                
                contribution_c(:,kk)=contribution_c(:,kk)+solution_c((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
                
                contribution_L(:,kk)=contribution_L(:,kk)+(4*solution_s_L((kk-1)*train_num+hh)+solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution_F(:,kk)=contribution_F(:,kk)+(4*solution_s_F((kk-1)*train_num+hh)+solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution_D(:,kk)=contribution_D(:,kk)+(4*solution_s_D((kk-1)*train_num+hh)+solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution_Df(:,kk)=contribution_Df(:,kk)+(4*solution_s_Df((kk-1)*train_num+hh)+solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                
                contribution2_L(:,kk)=contribution2_L(:,kk)+(solution_s_L((kk-1)*train_num+hh)*solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution2_F(:,kk)=contribution2_F(:,kk)+(solution_s_F((kk-1)*train_num+hh)*solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution2_D(:,kk)=contribution2_D(:,kk)+(solution_s_D((kk-1)*train_num+hh)*solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
                contribution2_Df(:,kk)=contribution2_Df(:,kk)+(solution_s_Df((kk-1)*train_num+hh)*solution_c((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
            end
        end
        
        for kk=1:class_num
            % r(i) = |D(i)-C(i)|
            deviation_s_L(kk)=norm(shiliang'-contribution_s_L(:,kk));
            deviation_s_F(kk)=norm(shiliang'-contribution_s_F(:,kk));
            deviation_s_D(kk)=norm(shiliang'-contribution_s_D(:,kk));
            deviation_s_Df(kk)=norm(shiliang'-contribution_s_Df(:,kk));
            
            deviation_c(kk)=norm(shiliang'-contribution_c(:,kk));
            
            deviation_L(kk)=norm(shiliang'-contribution_L(:,kk)/5);
            deviation_F(kk)=norm(shiliang'-contribution_F(:,kk)/5);
            deviation_D(kk)=norm(shiliang'-contribution_D(:,kk)/5);
            deviation_Df(kk)=norm(shiliang'-contribution_Df(:,kk)/5);
            
            deviation2_L(kk)=norm(shiliang'-contribution2_L(:,kk)/5);
            deviation2_F(kk)=norm(shiliang'-contribution2_F(:,kk)/5);
            deviation2_D(kk)=norm(shiliang'-contribution2_D(:,kk)/5);
            deviation2_Df(kk)=norm(shiliang'-contribution2_Df(:,kk)/5);
        end
        [min_value xx_L]=min(deviation_L);
        fen_label_L(ii)=xx_L;
        [min_value xx_F]=min(deviation_F);
        fen_label_F(ii)=xx_F;
        [min_value xx_D]=min(deviation_D);
        fen_label_D(ii)=xx_D;
        [min_value xx_Df]=min(deviation_Df);
        fen_label_Df(ii)=xx_Df;
        
        [min_value xx2_L]=min(deviation2_L);
        fen_label2_L(ii)=xx2_L;
        [min_value xx2_F]=min(deviation2_F);
        fen_label2_F(ii)=xx2_F;
        [min_value xx2_D]=min(deviation2_D);
        fen_label2_D(ii)=xx2_D;
        [min_value xx2_Df]=min(deviation2_Df);
        fen_label2_Df(ii)=xx2_Df;
        
        [min_value yy_L]=min(deviation_s_L);
        fen_label_s_L(ii)=yy_L;
        [min_value yy_F]=min(deviation_s_F);
        fen_label_s_F(ii)=yy_F;
        [min_value yy_D]=min(deviation_s_D);
        fen_label_s_D(ii)=yy_D;
        [min_value yy_Df]=min(deviation_s_Df);
        fen_label_s_Df(ii)=yy_Df;
        
        [min_value zz]=min(deviation_c);
        fen_label_c(ii)=zz;
    end
    
    errors_L=0;     errors_F=0;     errors_D=0;     errors_Df=0;
    errors2_L=0;    errors2_F=0;    errors2_D=0;    errors2_Df=0;
    errors_s_L=0;   errors_s_F=0;   errors_s_D=0;   errors_s_Df=0;
    errors_c=0;
    for ii=1:test_num*class_num
        inte=floor((ii-1)/test_num+1);
        label2(ii)=inte;
        
        if fen_label_L(ii)~=label2(ii)
            errors_L=errors_L+1;
        end
        if fen_label_F(ii)~=label2(ii)
            errors_F=errors_F+1;
        end
        if fen_label_D(ii)~=label2(ii)
            errors_D=errors_D+1;
        end
        if fen_label_Df(ii)~=label2(ii)
            errors_Df=errors_Df+1;
        end
        
        if fen_label2_L(ii)~=label2(ii)
            errors2_L=errors2_L+1;
        end
        if fen_label2_F(ii)~=label2(ii)
            errors2_F=errors2_F+1;
        end
        if fen_label2_D(ii)~=label2(ii)
            errors2_D=errors2_D+1;
        end
        if fen_label2_Df(ii)~=label2(ii)
            errors2_Df=errors2_Df+1;
        end
        
        if fen_label_s_L(ii)~=label2(ii)
            errors_s_L=errors_s_L+1;
        end
        if fen_label_s_F(ii)~=label2(ii)
            errors_s_F=errors_s_F+1;
        end
        if fen_label_s_D(ii)~=label2(ii)
            errors_s_D=errors_s_D+1;
        end
        if fen_label_s_Df(ii)~=label2(ii)
            errors_s_Df=errors_s_Df+1;
        end
        
        if fen_label_c(ii)~=label2(ii)
            errors_c=errors_c+1;
        end
    end
    
    errors_ratio_L=errors_L/class_num/test_num
    errors_ratio_F=errors_F/class_num/test_num
    errors_ratio_D=errors_D/class_num/test_num
    errors_ratio_Df=errors_Df/class_num/test_num
    
    errors_ratio2_L=errors2_L/class_num/test_num
    errors_ratio2_F=errors2_F/class_num/test_num
    errors_ratio2_D=errors2_D/class_num/test_num
    errors_ratio2_Df=errors2_Df/class_num/test_num
    
    errors_ratio_s_L=errors_s_L/class_num/test_num 
    errors_ratio_s_F=errors_s_F/class_num/test_num 
    errors_ratio_s_D=errors_s_D/class_num/test_num 
    errors_ratio_s_Df=errors_s_Df/class_num/test_num    
    
    errors_ratio_c=errors_c/class_num/test_num
    
    % results
    result_errors(train_num,1)=errors_ratio_c;
    result_errors(train_num,2)=errors_ratio_s_L;
    result_errors(train_num,3)=errors_ratio_L;
    result_errors(train_num,4)=errors_ratio2_L;
    result_errors(train_num,5)=errors_ratio_s_F;
    result_errors(train_num,6)=errors_ratio_F;
    result_errors(train_num,7)=errors_ratio2_F;
    result_errors(train_num,8)=errors_ratio_s_D;
    result_errors(train_num,9)=errors_ratio_D;
    result_errors(train_num,10)=errors_ratio2_D;
    result_errors(train_num,11)=errors_ratio_s_Df;
    result_errors(train_num,12)=errors_ratio_Df;
    result_errors(train_num,13)=errors_ratio2_Df;
    
    for rii=1:13
        fprintf('%1.4f \t', result_errors(train_num,rii));
    end
    fprintf('\n')
    
end

json_file = [db_name '.json'];
db_json = savejson('', result_errors, json_file);

data=loadjson(json_file);
%result_json = data[db_name];

disp('Test done!');

