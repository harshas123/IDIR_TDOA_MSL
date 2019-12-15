function [gcc,tau] = mycorr(x,y,maxlag,type,src_sig)
%% Implementation of Generalized Cross Correlation (GCC) class of functions

% INPUTS TO THE FUNCTION:
%%
% 
% # _x,y_ = Vectors for which the GCC needs to be computed or Matrices with
% same number of columns.
% # _maxlag_ = Number of lags of the cross-correlation function
% # _type_ = 'PHAT' of 'CCC' or 'SCOT'

% OUTPUTS OF THE FUNCTION:
%%
% 
% # _gcc_ = GCC function
% # _tau_ = lags corresponding to the GCC function
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

[lenx,num_frames_x] = size(x);
[leny,num_frames_y] = size(y);

if num_frames_y == 1
   y = repmat(y,1,num_frames_x);
end

if (num_frames_x ~= num_frames_y)  
   error('X and Y should have same number of frames i.e. number of columns'); 
end

% x = reshape(x,1,lenx);
% y = reshape(y,1,leny);
% At this point num_frames_x = num_frames_y

if lenx>leny
   y=[y ;zeros(lenx-leny,num_frames_x)];
   len=lenx;
else
    x=[x ;zeros(leny-lenx,num_frames_x)];
    len=leny;
end
fftsize=2^nextpow2(2*len-1);
X=fft(x,fftsize); 

Y=fft(y,fftsize);
% X and Y will be of same size
switch type
    case 'CCC'
        phi=1;
    case 'PHAT'
        phi=(max(abs(X.*conj(Y)),eps)).^-1;
    case 'Coherence'
        phi=(sqrt(max(X.*conj(X).*Y.*conj(Y),eps))).^-1;
    case 'BAT-PHAT'
        phi = abs(fft(src_sig,fftsize)).^-2;
end

gcc=(ifft(phi.*X.*conj(Y)));
% z=z./max(abs(z));
% M=len;
tau=-maxlag:maxlag;
if length(tau) >= fftsize
	gcc = [zeros(maxlag-len+1,num_frames_x); gcc(end-len+2:end,:) ;gcc(1:len,:) ; zeros(maxlag-len+1,num_frames_x)];
else
	gcc = [gcc(end-maxlag+1:end,:); gcc(1:maxlag+1,:)];
end