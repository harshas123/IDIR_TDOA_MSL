function [del_tau]=tde_reg_constr_gcc(gcc,tau,tde_ll_samp_reg,tde_ul_samp_reg,Fs_gcc,mic_pair_index)

% Get the required parameters
% tde_ll_samp and tde_ul_samp correspond to the TDOA limits corresponding to
% the given microphone positions and the required region where the source
% has to be located
       
num_mic_pairs=length(mic_pair_index);
del_tau=NaN*zeros(num_mic_pairs,1);
for k=1:num_mic_pairs
    reqd_interval=find(tau == tde_ll_samp_reg(mic_pair_index(k))):find(tau == tde_ul_samp_reg(mic_pair_index(k)));
    [val, Ind]=max(gcc(mic_pair_index(k),reqd_interval));

    del_tau(k)=tau(reqd_interval(Ind))/Fs_gcc;
end
            
        
    
