function Alpha = ProCRC(data, params)

tr_descr   =   data.tr_descr;
tt_descr   =   data.tt_descr;
tr_label   =   data.tr_label;

gamma      =   params.gamma
lambda     =   params.lambda;
class_num  =   params.class_num;
tt_num     =   length(data.tt_label);

model_type =   params.model_type;

%% compute symmetric matrix
% tr_sym_mat = zeros(size(tr_descr, 2), size(tr_descr, 2));
% for ci = 1 : class_num
%     ind_ci = find(tr_label == ci);
%     tr_descr_bar = zeros(size(tr_descr));
%     tr_descr_bar(:,ind_ci) = tr_descr(:, ind_ci);
%     tr_descr_bar = tr_descr - tr_descr_bar;
%     tr_sym_mat = tr_sym_mat + gamma * (tr_descr_bar' * tr_descr_bar);
% end
%
% tr_sym_mat = tr_sym_mat + tr_descr' * tr_descr + lambda * eye(size(tr_sym_mat, 2));

% be equivalent to the above
tr_blocks = cell(1, class_num);

for ci = 1: class_num
    tr_blocks{ci} = tr_descr(:,tr_label == ci)' * tr_descr(:,tr_label == ci);
end

tr_block_diag_mat = blkdiag(tr_blocks{:});
tr_sym_mat = (gamma * (class_num - 2) + 1) * (tr_descr' * tr_descr) + gamma * tr_block_diag_mat + lambda * eye(size(tr_descr, 2));

%% compute projection matrix
%T = invChol_mex(tr_sym_mat) * tr_descr'; %fast symmetric positive definite matrix inverse, use this for large-scale datasets
T = tr_sym_mat \ tr_descr';

switch model_type
    case 'ProCRC'
        %% compute coding vectors
        Alpha = T * tt_descr;
    case 'R-ProCRC' 
        Alpha  = [];
        iter_R = 10;
        tr_sym_mat_xx = tr_sym_mat - tr_descr' * tr_descr - lambda * eye(size(tr_descr, 2));
        %parfor j = 1 : tt_num % use parfor for parallelization  
        for j = 1 : tt_num % use parfor for parallelization
            alpha = T * tt_descr(:,j);
            % print progress
            fprintf('%d ', j);
            if mod(j,20)==0
                fprintf('\n');
            end
            for iter = 1 : iter_R
                W_alpha = diag(1./max(abs(alpha), 1e-4));
                %W_alpha = eye(size(tr_descr, 2));
                W_x = diag(1./max( abs(tr_descr * alpha - tt_descr(:,j)), 1e-6));
                %alpha = invChol_mex(tr_sym_mat_xx + tr_descr' * W_x * tr_descr + lambda * W_alpha) * (tr_descr' * W_x * tt_descr(:,j));
                alpha = (tr_sym_mat_xx + tr_descr' * W_x * tr_descr + lambda * W_alpha) \ (tr_descr' * W_x * tt_descr(:,j));
            end
            Alpha = [Alpha, alpha];
        end
        fprintf('\n');
    otherwise
        error(['\nUnknown ProCRC model for type: ',model_type]);
end
end