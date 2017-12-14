clear all; clc;
addpath(genpath('utilities'));
addpath(['data']);
%% specify corruption type
corruption_type = 'random_corruption'; % {random_corruption; block_occlusion}

%% load EYB dataset
fr_dat = load(['YaleB']);
tr_num = 30;

fr_dat_split = split_train_test(fr_dat, tr_num);

clear fr_dat;

tr_descr = fr_dat_split.tr_descr./255;
tt_descr = fr_dat_split.tt_descr./255;

%% corruption settings
imh = 32; imw = 32;
switch corruption_type
    case 'random_corruption'
        cor_ratio = 0.4;
        [~, samp_num] = size(tt_descr);
        for i_t = 1 : samp_num
            xt = tt_descr(:, i_t);
            xt = reshape(xt, [imh, imw]);
            xc = Random_Pixel_Crop(uint8(255 * xt), cor_ratio);
            tt_descr(:, i_t) = double(xc(:))/255;
        end
    case 'block_occlusion'
        cor_ratio = 0.3;
        height  = floor(sqrt(imh * imw * cor_ratio));
        width   = height;
        [~, samp_num] = size(tt_descr);
        r_h = round(rand(1, samp_num) * (imh - height -1)) + 1;
        r_w = round(rand(1, samp_num) * (imw - width -1)) + 1;
        
        for i_t = 1 : samp_num
            xt = tt_descr(:, i_t);
            xt = reshape(xt, [imh, imw]);
            xc = Random_Block_Occlu(uint8(255 * xt), r_h(i_t), r_w(i_t), height, width);
            tt_descr(:, i_t) = double(xc(:))/255;
        end
    otherwise
        error(['\nUnknown corruption type: ' corruption_type])
end

tr_descr = tr_descr./( repmat(sqrt(sum(tr_descr.*tr_descr))+eps, [size(tr_descr,1),1]) );
tt_descr = tt_descr./( repmat(sqrt(sum(tt_descr.*tt_descr))+eps, [size(tr_descr,1),1]) );

fr_dat_split.tr_descr = tr_descr;
fr_dat_split.tt_descr = tt_descr;

%% parameter settings
class_num = length(unique(fr_dat_split.tr_label));

params.dataset_name      =      'Extended Yale B';
params.model_type        =      'ProCRC';%'R-ProCRC';
params.gamma             =      [1e-2];
params.lambda            =      [1e-0];
params.class_num         =      class_num;

%% run robust ProCRC
Alpha = ProCRC(fr_dat_split, params);
[pred_tt_label, pre_matrix] = ProMax(Alpha, fr_dat_split, params);

%% recognition rate
recon_rate = (sum(pred_tt_label == fr_dat_split.tt_label)) / length(fr_dat_split.tt_label);
fprintf(['\nThe recognition rate on the ', params.dataset_name, ' dataset',' with ',corruption_type, ' ratio=', num2str(cor_ratio) ', gamma=',num2str(params.gamma), ' and lambda=',num2str(params.lambda), ' is ', num2str(roundn(recon_rate,-3))])