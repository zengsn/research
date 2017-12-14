function dataset_split = split_train_test(dataset, tr_num, class_num)

if nargin < 3
  class_num = length(unique(dataset.label));
end

tr_idx = [];
tt_idx = [];

for i = 1 : class_num
    idx_label = find(dataset.label == i);
    num = length(idx_label);    
    idx_rand = randperm(num);
    
    tr_idx = [tr_idx idx_label(idx_rand(1 : tr_num))];
    tt_idx = [tt_idx idx_label(idx_rand(tr_num+1 : end))];
end

dataset_split.tr_descr   =   dataset.descr(:, tr_idx);
dataset_split.tr_label   =   dataset.label(tr_idx);

dataset_split.tt_descr   =   dataset.descr(:, tt_idx);
dataset_split.tt_label   =   dataset.label(tt_idx);