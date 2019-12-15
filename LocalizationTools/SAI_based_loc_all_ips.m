function [SAI, x_loc, DOA] = SAI_based_loc_all_ips(mic_sigs, Fs, num_active_src)

load SAI_params.mat

meas_type = 'MAX_RATIO';
type_gcc = 'PHAT';
[num_instances, ~, ~] = size(mic_sigs);
num_sectors = size(tde_ll_samp, 2);

SAI = zeros(num_instances, num_sectors);
x_loc = cell(num_instances,1);
DOA = cell(num_instances,1);
for instance_id = 1:num_instances
    mic_sigs_mat = squeeze(mic_sigs(instance_id,:,:));
    [gcc, tau, Fs_gcc] = gcc_all_mic_pairs(Mic_pos, Fs, speed_sound, type_gcc, mic_sigs_mat);

    % Fine Localization
    [SAI(instance_id, :), x_loc{instance_id},DOA{instance_id},~] = SAI_based_2D_loc(Mic_pos, gcc, tau, Fs_gcc,...
                            A_reg, b_reg, tde_ll_samp, tde_ul_samp, ...
                            which_mics, ref_pts, speed_sound, mic_arr_orig, ...
                            num_active_src(instance_id), meas_type, IDIR_span_compl, testpts, tech_type);
    disp(['Done Instance No: ' num2str(instance_id)]);
end
