function [Mic_pos] = get_mic_pos(mic_arr_type, num_mics, room_dim, mic_arr_orig, mic_height)
% INPUTS TO THE FUNCTION: 
%%
% # _mic_arr_type_: Type of Array. Choose from 'UCA', 'Random', 'Corners',
% 'Distributed'
% # _num_mics_: Number of Microphones in the Array
% # _room_dim_ : Dimensions of a recatangular enclosure (meter) in the
%                following format:
%                [x_lower_lim, y_lower_lim, z_lower_lim;
%                 x_upper_lim, y_upper_lim, z_upper_lim]
% # _mic_arr_orig_: Co-ordinates of the center of the Mic Array.
% # _mic_height_: Height at which to place mix in z dim.
%%
dim = size(room_dim,2);
if dim==2
    mic_arr_orig = [mic_arr_orig mic_height];
end
if strcmp(mic_arr_type,'UCA')
    rad_mic=0.3;
    theta_mic=0:360/num_mics:360-360/num_mics;
    theta_mic=theta_mic';
%     Mic_pos=repmat(mic_arr_orig,num_mics,1)+[rad_mic*cosd(theta_mic) rad_mic*sind(theta_mic) zeros(num_mics,1)];  
    Mic_pos=repmat(mic_arr_orig,num_mics,1)+[rad_mic*cosd(theta_mic) rad_mic*sind(theta_mic) zeros(num_mics,1)];
elseif strcmp(mic_arr_type,'Random')
%     load(['Mic_pos_rand_' num2str(num_mics) '.mat']);
    Mic_pos=[room_dim(1)*rand(num_mics,1) room_dim(2)*rand(num_mics,1) zeros(num_mics,1)];
%       Mic_pos=[room_dim(1)/2-2+2*rand(num_mics,1) room_dim(2)/2-2+2*rand(num_mics,1) zeros(num_mics,1)];
      Mic_pos = Mic_pos + repmat(mic_arr_orig - mean(Mic_pos),[num_mics,1]);%To center the array
%     load Mics_random_18_good.mat
%     Mic_pos= Mic_pos_SAI;
elseif strcmp(mic_arr_type,'Corners')
    Mic_pos = [0 0 0; room_dim(1) 0 0; 0 room_dim(2) 0; room_dim(1) room_dim(2) 0; room_dim(1)/2 0 0; 0 room_dim(2)/2 0; room_dim(1)/2 room_dim(2)/2 0;room_dim(1)/2 room_dim(2) 0;room_dim(1) room_dim(2)/2 0 ];
elseif strcmp(mic_arr_type,'Distributed')
%     load Distri_array.mat
    Mic_pos = [room_dim(1)/3, 0, 0;...
                   2*room_dim(1)/3, 0, 0;...
                   room_dim(1)/2, room_dim(2), 0;...
                   0, room_dim(2)/3, 0;...
                   0, 2*room_dim(2)/3, 0;...
                   room_dim(1), room_dim(2)/3, 0;...
                   room_dim(1), 2*room_dim(2)/3, 0;...
                   ];
   
end

if dim==2
   Mic_pos(:,3)=[];
end