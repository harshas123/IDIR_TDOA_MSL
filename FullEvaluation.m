function [ACC, DOA_err, diff_num_sources] = FullEvaluation(Y, src_pos_gt, Y_est, src_pos_DOA)

% sector_origin = [3.00, 3.75, 1.50];
load('SAI_params.mat','mic_arr_orig')

num_active_source = sum(Y,2);
diff_num_sources = unique(num_active_source);

num_diff_sources = length(diff_num_sources);

ACC = zeros(num_diff_sources,2);
DOA_err = cell(num_diff_sources,1);

DIM = size(src_pos_gt,3);
% Loop through the instances and compute ACC and DOA Error
num_instances = size(Y,1);
ACC_instance = zeros(num_instances,1);
DOA_err_instance = cell(num_instances,1);
for instance_ind = 1:num_instances
    active_reg_ind = Y(instance_ind,:)==1;
    src_pos_active = reshape(src_pos_gt(instance_ind, active_reg_ind, :), [], DIM);
%    Coarse Localization Accuracy
    [ACC_instance(instance_ind), ~, ~, ~] = multi_label_metrics(Y(instance_ind,:)', Y_est(instance_ind,:)');
    
%    Fine Localization Accuracy
   act_DOA = compute_DOA_2D_vec(src_pos_active, mic_arr_orig); 
   if ACC_instance(instance_ind) == 100
      [est_DOA, DOA_err_instance{instance_ind}] = assign_DOA(src_pos_DOA{instance_ind}, act_DOA);
   else
       num_srcs = length(find(active_reg_ind));
       DOA_err_instance{instance_ind} = NaN*ones(1,num_srcs);
   end
   
    
end


for i = 1:num_diff_sources
    reqd_ind = find(num_active_source == diff_num_sources(i));
    ACC(i,:) = [mean(ACC_instance(reqd_ind)) std(ACC_instance(reqd_ind))];
    DOA_err{i} = [nanmean(cell2mat(DOA_err_instance(reqd_ind))); nanstd(cell2mat(DOA_err_instance(reqd_ind)))];
end