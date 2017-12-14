function dataset_init()

global params
global data

switch params.dataset_name
    case 'Standford-40'
        variables = {'tr_descr','tr_label','tt_descr','tt_label'};
        dataset_info = load([params.dataset_name,'_VGG'],variables{:});
        params.class_num = length(unique(dataset_info.tr_label));
    case 'Flower-102'
        variables = {'tr_descr','tr_label','tt_descr','tt_label'};
        dataset_info = load([params.dataset_name,'_VGG'],variables{:});
        params.class_num = length(unique(dataset_info.tr_label));
    case 'CUB-200-2011'
        variables = {'tr_descr','tr_label','tt_descr','tt_label'};
        dataset_info = load([params.dataset_name,'_VGG'],variables{:});
        params.class_num = length(unique(dataset_info.tr_label));
    case 'Caltech-256'
        variables = {'descr','label'};
        dataset_info = load([params.dataset_name,'_VGG'],variables{:});
        params.class_num = length(unique(dataset_info.label))-1; % remove the background class 257
        dataset_info = split_train_test(dataset_info, params.tr_num, params.class_num);
end

if params.dl_flag
    params.dl_ini_type = 'pca';% {'pca', 'random'}
    params.dl_dict_type = 'dual';% {'dual', 'column', 'proj'}
    params.dl_atom_num = 20;
    params.dl_tau = 2;
    params.dl_maxiter = 30;
    
    tr_descr_org = double(dataset_info.tr_descr);
    tr_label_org = dataset_info.tr_label;
    tt_descr = double(dataset_info.tt_descr);
    tt_label = dataset_info.tt_label;
    
    [tr_descr, tr_label] = dict_learn_simple(tr_descr_org, tr_label_org, params);
    
else
    tr_descr = double(dataset_info.tr_descr);
    tr_label = dataset_info.tr_label;
    tt_descr = double(dataset_info.tt_descr);
    tt_label = dataset_info.tt_label;
end

if params.rdim_flag
    Vt = Eigenface_f(tr_descr,params.rdim_num);
    tr_descr = Vt'*tr_descr;
    tt_descr = Vt'*tt_descr;
end

if params.normalization_flag
    if params.normalization_type == 1        
        tr_descr = tr_descr./( repmat(sqrt(sum(tr_descr.*tr_descr))+eps, [size(tr_descr,1),1]) );
        tt_descr = tt_descr./( repmat(sqrt(sum(tt_descr.*tt_descr))+eps, [size(tt_descr,1),1]) );        
    elseif params.normalization_type == 2  
        rho = 20;
        tr_descr = tr_descr';
        tt_descr = tt_descr';
        tr_min = repmat(min(tr_descr), [size(tr_descr,1),1]);
        tr_max = repmat(max(tr_descr), [size(tr_descr,1),1]);
        tr_descr_nor = (tr_descr - tr_min)./(tr_max - tr_min + eps);        
        tr_min = repmat(min(tr_descr), [size(tt_descr,1),1]);
        tr_max = repmat(max(tr_descr), [size(tt_descr,1),1]);
        tt_descr_nor = (tt_descr - tr_min)./(tr_max - tr_min + eps);        
        tr_descr = tr_descr_nor'/rho;
        tt_descr = tt_descr_nor'/rho;
    end
end

data.tr_descr = tr_descr;
data.tr_label = tr_label;
data.tt_descr = tt_descr;
data.tt_label = tt_label;
