function [zeta,gcc_norm]=sector_activity_new(gcc, tau, tde_ll_samp, tde_ul_samp, meas_type)

% A_new,b_new are cell arrays denoting the regions. Each cell contains the LHS and RHS of LMI of the region forming
% the sector in a given room. Length of R is the number of sectors.

display_gcc = 0;
% meas_type = 'MAX_RATIO';
L=size(tde_ll_samp,2);
num_tdes=size(gcc,1);
zeta=zeros(num_tdes,L);

   
for k=1:num_tdes
    gcc_norm = gcc(k,:)-min(gcc(k,:));
    gcc_norm = gcc_norm/sum(gcc_norm);
    
    for l=1:L 
        [gcc_reqd,zeta(k,l)] = sector_cc_sum(tde_ll_samp(k,l),tde_ul_samp(k,l),gcc_norm,tau,meas_type,display_gcc); 
        
    end
end

