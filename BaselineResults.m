close all
clear all
clc

% Add a Few required Paths of Tools
addpath('./GCCTools/')
addpath('./GenTools/')
addpath('./LocalizationTools/')
% Main script to launch ITIR based localization.

path_mat_res = './Results/';
path_dataset = './Dataset/SpecialTestSetAnechoic/test.mat';
room_env = 'anechoic';

load(path_dataset);

num_active_source = sum(Y,2);

%% 
Fs_orig = 16000;
model_name = 'Baseline_test';

[SAI, x_loc, DOA_est] = SAI_based_loc_all_ips(X, Fs_orig, num_active_source);
%% 
path_mat = fullfile(path_mat_res, [model_name '_' room_env '.mat']);
[ACC, DOA_err, diff_num_sources] = FullEvaluation(Y, act_src_pos, SAI, DOA_est);
save(path_mat, 'ACC', 'DOA_err');
disp('#################################################################');
for i = 1:length(diff_num_sources)
   disp(['No. of Active Sources = ' num2str(diff_num_sources(i))]);
   disp(['ACC = ' num2str(ACC(i,1)) '(' num2str(ACC(i,2)) ')'])
   disp(['DOA Error (mean) = ' num2str(DOA_err{i}(1,:))])
   disp(['DOA Error (std.) = ' num2str(DOA_err{i}(2,:))])
end
disp('#################################################################');
