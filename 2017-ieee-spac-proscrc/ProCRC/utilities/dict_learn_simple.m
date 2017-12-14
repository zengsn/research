function [dict_dat, dict_label] = dict_learn_simple(tr_dat, tr_label, params)

ini_type   =   params.dl_ini_type;
dict_type  =   params.dl_dict_type;
atom_num   =   params.dl_atom_num;
tau        =   params.dl_tau;
maxiter    =   params.dl_maxiter;
class_num  =   params.class_num;

dict_dat   = [];
dict_label = [];

for ci = 1:class_num  % use parfor for parallelization  
    tr_dat_ci = tr_dat(:,tr_label==ci);
    % dictionary initialization
    switch ini_type
        case 'pca'
            [dict_ini_ci,~,mean_ci] =  Eigenface_f(tr_dat_ci, atom_num - 1);
            dict_ini_ci             =  [dict_ini_ci mean_ci./norm(mean_ci)];
        case 'random'
            dict_ini_ci             =  normcol_equal(randn(size(tr_dat_ci,1), atom_num));
        otherwise
            error(['\nUnknown dictionary initialization type: ' ini_type])
    end
    
    dict_ci      =    alternating_dl(tr_dat_ci, dict_ini_ci, dict_type, tau, maxiter);    
    dict_dat     =    [dict_dat dict_ci];
    dict_label   =    [dict_label ci*ones(1,size(dict_ci,2))];    
end

function dict = alternating_dl(dat, dict_ini, dict_updater, p_tau, p_maxiter)

num_atom = size(dict_ini,2);

dict = dict_ini;

for k = 1 : p_maxiter
    %% update coef    
    coef = (dict' * dict + p_tau * eye(size(dict,2))) \ (dict' * dat);    
    %% update dictionary
    switch dict_updater
        case 'dual'
            dict = l2ls_learn_basis_dual(dat, coef, 1);
        case 'column'
            new_dict    =   [];
            for i =  1:num_atom
                ai      =    coef(i,:);
                Y       =    dat - dict * coef + dict(:,i) * ai;
                di      =    Y * ai';
                if norm(di,2) < 1e-6
                    di         =    zeros(size(di));
                    new_dict   =    [new_dict di];
                else
                    di         =    di./norm(di,2);
                    new_dict   =    [new_dict di];
                end
                dict(:,i)  =    di;
            end
            dict = new_dict;
        case 'proj'
            dict = (dat * coef') / (coef * coef' + eps * eye(size(coef,1)));
            dict = normcol_equal(dict);
        otherwise
            error(['\nUnknown dictionary update type: ' dict_updater])
    end
end