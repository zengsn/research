% As for the requirement of the VGG features, please contact me by cssjcai@gmail.com.
clear all; clc;
addpath(genpath('utilities'));
addpath(['data']);
%% specify dataset name
dataset_name = 'Standford-40'; % {Standford-40; Flower-102; CUB-200-2011; Caltech-256}

%% parameter settings 
global params
set_params(dataset_name);

%% load features and labels
global data
dataset_init();

%% run ProCRC
Alpha = ProCRC(data, params);
[pred_tt_label, ~] = ProMax(Alpha, data, params);

%% classification accuracy
accuracy = (sum(pred_tt_label == data.tt_label)) / length(data.tt_label);
fprintf(['\nThe accuracy on the ', params.dataset_name, ' dataset ',' with gamma=',num2str(params.gamma), ' and lambda=',num2str(params.lambda), ' is ', num2str(roundn(accuracy,-3))])