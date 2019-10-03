function set_params(dataset_name)

global params

switch dataset_name
    case 'Standford-40'      
        params.dataset_name           =      dataset_name;
        params.model_type             =      'ProCRC';
        params.dl_flag                =      0;
        params.rdim_flag              =      0;
        params.rdim_num               =      500;
        params.normalization_flag     =      1;
        params.normalization_type     =      1;
        params.gamma                  =      [1e-3];
        params.lambda                 =      [1e-1];      
    case 'Flower-102'
        params.dataset_name           =      dataset_name;
        params.model_type             =      'ProCRC';
        params.dl_flag                =      0;
        params.rdim_flag              =      0;
        params.rdim_num               =      500;
        params.normalization_flag     =      1;
        params.normalization_type     =      1;
        params.gamma                  =      [1e-3];
        params.lambda                 =      [1e-2];
    case 'CUB-200-2011'
        params.dataset_name           =      dataset_name;
        params.model_type             =      'ProCRC';
        params.dl_flag                =      0;
        params.rdim_flag              =      0;
        params.rdim_num               =      500;
        params.normalization_flag     =      1;
        params.normalization_type     =      1;
        params.gamma                  =      [1e-3];
        params.lambda                 =      [1e-1];
    case 'Caltech-256'
        params.dataset_name           =      dataset_name;
        params.model_type             =      'ProCRC';
        params.tr_num                 =      60;
        params.dl_flag                =      0;
        params.rdim_flag              =      0;
        params.rdim_num               =      500;
        params.normalization_flag     =      1;
        params.normalization_type     =      1;
        params.gamma                  =      [1e-3];
        params.lambda                 =      [1e-1];
    otherwise
        error(['\nUnknown dataset: ' dataset_name])
end