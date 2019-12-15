close all
clear all
clc

% Purpose of this script is to generate loadable params for Sector Activity
% Index based algorithm to map 3d params to 2d params.

% Mic_pos, mic_sigs, speed_sound, Fs, tde_ll_samp, tde_ul_samp, num_active_src

load 'ExperimentalConstants.mat';

% Convert to 2d.
room_dim(:,3) = [];
Mic_pos(:,3) = [];
mic_arr_orig = mic_arr_orig(1:2);

tech_type = 'Grid Search';%'Grid Search', 'NL-opt', 'GCF-SAI','OSLS'
grid_size = 0.2;
[testpts]=gen_grid_pts(grid_size,room_dim);

which_mics = fliplr(combnk(1:num_mics,2));

Fs_gcc = 44100;

% Region Related
off_set = 0;
[A_reg, b_reg, ref_pts] = create_sectors_2D(room_dim, num_sectors, mic_arr_orig, off_set);

[tde_ll_samp, tde_ul_samp] = compute_tde_lims_reg(Mic_pos, A_reg, b_reg, speed_sound, ref_pts, Fs_gcc, mic_arr_orig);

[IDIR_span_compl] = get_IDIR_span_compl(Mic_pos, A_reg, b_reg, tde_ll_samp, tde_ul_samp, speed_sound, Fs);


save('SAI_params.mat', 'room_dim', 'Mic_pos', 'mic_arr_orig', 'speed_sound', 'Fs_gcc', 'A_reg', 'b_reg', 'ref_pts', 'tde_ll_samp', 'tde_ul_samp', 'IDIR_span_compl', 'which_mics', 'testpts', 'tech_type');