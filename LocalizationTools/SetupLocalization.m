close all;
clear all;

% Constants Filename
fname = 'ExperimentalConstants.mat';


% Generic
loc_space = 3; % 2 for '2D' or 3 for '3D'
speed_sound = 340;
font_size = 30;

room_dim = [0, 0, 0; 6, 7.5, 4.5];
Fs = 16000;
Fs_gcc = 44100;
if size(room_dim,1) ~= 2
    error('Room dim must have 2 rows in this format : [x_lower_lim, y_lower_lim, z_lower_lim; x_upper_lim, y_upper_lim, z_upper_lim]');
end

if size(room_dim, 2) ~=  loc_space
    error('room_dim and loc_space do not match!')
end
% Enclosure related
room_env = 'anechoic';
reverb_time = 0.3;

% Sectors related
num_sectors = 8;
num_pts_per_sector = 360;

% Microphone Related
mic_arr_orig = mean(room_dim);
mic_arr_type = 'UCA'; % 'UCA', 'Random', 'Corners', 'Distributed'
num_mics = 8;
mic_height = 1.5;
if loc_space == 3
    mic_arr_orig(3) = mic_height;
end

% Source Related
path_dbase = '../Database/Test/';
same_azimuth_mic_array = true;

wav_files = dir([path_dbase '*.wav']);
num_sources = length(wav_files);
src_sigs = cell(num_sources, 1);
for k = 1:num_sources
    [tmp, Fs_act] = audioread([path_dbase, wav_files(k).name]);
    if Fs_act ~= Fs
        src_sigs{k} = resample(tmp, Fs, Fs_act);
    else
        src_sigs{k} = tmp;
    end
        
end
shuff_src_ind  = randperm(num_sources);

% Partition related

split_perc = struct;
split_perc.('train') = 0.70;
split_perc.('dev') = 0.10;
split_perc.('test') = 0.10;

partitions = fields(split_perc);

% Setup the Room
[A_reg, b_reg, ref_pts] = create_sectors_improved(room_dim, num_sectors, 0, [], mic_arr_orig, []);

% Setup the room and Microphone Positions
[Mic_pos]= get_mic_pos(mic_arr_type, num_mics, room_dim, mic_arr_orig, mic_height);

% For Baseline system
[tde_ll_samp, tde_ul_samp] = compute_tde_lims_reg(Mic_pos, A_reg, b_reg, speed_sound, ref_pts, Fs_gcc, mic_arr_orig);

% Generate the Source Positions in each sector Randomly and divide them
% into Train, dev and test.
src_info = struct;
curr_src_id = 1;
for part_id = 1:length(partitions)
   src_info.(partitions{part_id}) = struct;
   num_src_partiton = floor(split_perc.(partitions{part_id}) * num_sources);
   src_info.(partitions{part_id}).('src_ind') = shuff_src_ind(curr_src_id:min(curr_src_id + num_src_partiton, curr_src_id + num_sources));
   % Generate points in Each sector and assign them to Train dev and test.
   src_info.(partitions{part_id}).('src_pos') = cell(num_sectors,1);
   for sec_ind = 1: num_sectors
      num_pts =  floor(split_perc.(partitions{part_id}) * num_pts_per_sector);
      src_pos = cprnd(num_pts, A_reg{sec_ind}, b_reg{sec_ind});
      if same_azimuth_mic_array
         % Make all source points to be on the same azimuthal plane as Mic
          % Array
          src_pos(:,3) = mic_height; 
      end
      src_info.(partitions{part_id}).('src_pos'){sec_ind} = src_pos;
   end
   curr_src_id = curr_src_id + num_src_partiton;
end


% Plot and Visualize the Localization setup and scenario
h = figure;
[h_room, h_src, h_mics] = plot_loc_scenario(Mic_pos, [], room_dim, font_size);

[h_reg] = plot_sectors(A_reg, b_reg, room_dim, h);

plot_sources_each_sector_partion(src_info, h)

set(h, 'Units', 'normalized', 'Position',[0,0,1,1]);
x = input('Looks Good?');
if isempty(x)
   
   disp(['Saving Params in ' fname]);
   save(fname) 
   disp('Saving Localization setup params in LocalizationSetup.mat for convenience.')
   save(['LocalizationSetup_' num2str(num_pts_per_sector) '.mat'],'Mic_pos','room_dim', 'speed_sound', 'Fs', 'A_reg', 'b_reg', 'ref_pts', 'mic_arr_orig', 'tde_ll_samp', 'tde_ul_samp');
else
    disp('Not saving any params')
end
