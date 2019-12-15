function [gcc,tau,Fs_new] = gcc_all_mic_pairs(Mic_pos,Fs,c,type_gcc,mic_sigs)
%% Compute GCC and the TDOA for multiple pairs of microphone signals

% INPUTS TO THE FUNCTION: 
%%
%
% # _mic_sigs_: It is a matrix of dimension T X M, with each sensor
%                  signal in one column. The signals have to be of the same
%                  length.
% # _Fs_ : Sampling frequency
% # _c_ : Velocity of sound in m/s (generally 340)
% # _type_gcc_ = 'PHAT' for Phase Transform.
%              'CCC' for Classical Cross Correlation; 
%              'SCOT' also works and is similar to PHAT.
% # _Mic_pos_ : 3-D coordinates of the two microphones in the same order
%             as the signals given in mic_sigs. Each Mic position is
%             specified in a row.

% OUTPUTS OF THE FUNCTION:
%%
%
% # _gcc_ : The generalized cross correlation function used to estimate TDOA.
%         Contains MC2 rows, with each row containing the GCC across a pair
%         of mics. The pair of mics corresponding to each of GCC is given
%         by the _which_mics_ matrix output by the "compute_act_delay"
%         function.
% # _tau_: Set of time delays where the cross correlation is computed.
% # _Fs_new_ : The resampled frequency
%%
% AUTHOR

% Code written by: Harshavardhan Sundar
% Ph. D. Scholar,
% Speech and Audio Group, 
% Department of Electrical Communication Engineering
% Indian Institute of Science,
% Bangalore, India - 560012% 
% email: harshas123@gmail.com
%%
[num_mics,dim]=size(Mic_pos);
Fs_new=44100;

% Find the farthest microphones
for i=1:num_mics
    dist(:,i)=sqrt(sum((Mic_pos-repmat(Mic_pos(i,:),num_mics,1)).^2,2));
    mic_sig_resamp(:,i)=resample(mic_sigs(:,i),Fs_new,Fs);
end
maxlags=ceil(max(dist(:))*Fs_new/c);
tau=-maxlags:maxlags;
% type_gcc='PHAT';

% Windowing using hanning to avoid edge effects.
sig_len = size(mic_sig_resamp,1);
mic_sig_resamp = mic_sig_resamp .* repmat(hanning(sig_len), [1,num_mics]);
% max_dist=max(reshape(sum((repmat(Mic_pos,[1,1,num_mics])-repmat(reshape(Mic_pos',[1,3,num_mics]),[num_mics,1,1])).^2,2),num_mics*num_mics,1));
% 
% maxlags=ceil(sqrt(max_dist)*Fs/c);
% tau=-maxlags:maxlags;
num_lags=length(tau);
% maxlags=400;
num_pairs=nchoosek(num_mics,2);
gcc=zeros(num_pairs,num_lags);
k=1;
for j=1:num_mics-1
   for i=j+1:num_mics
       gcc(k,:)=mycorr(mic_sig_resamp(:,i),mic_sig_resamp(:,j),maxlags,type_gcc);
       k=k+1;
   end
end


