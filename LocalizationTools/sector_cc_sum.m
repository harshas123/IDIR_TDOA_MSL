function [R,zeta]=sector_cc_sum(tde_ll_samp, tde_ul_samp, gcc, tau, meas_type, display_fig)

%
%gcc is the normalized non-negative cross-correlation function summing to
%one.
gcc_orig=gcc;
if ~exist('display_fig','var')
    display_fig=0;
end

if ~exist('meas_type','var')
    meas_type='MAX_RATIO';
end


if tde_ll_samp < min(tau)
    tde_ll_samp=min(tau);
end
if tde_ul_samp > max(tau)
    tde_ul_samp=max(tau);
end

reqd_interval=find(tau==tde_ll_samp):find(tau==tde_ul_samp);
gcc = gcc-min(gcc);
gcc = gcc/sum(gcc);
R = gcc(reqd_interval);
switch meas_type
    case 'MAX_RATIO' 
      zeta=max(R)/max(gcc);
    case 'MASS'
       zeta=sum(R);       
    case 'MAX' 
      zeta=max(R);
end

if display_fig
    V_GCC_lims=[tde_ll_samp,0;tde_ll_samp,max(gcc);tde_ul_samp max(gcc); tde_ul_samp 0];
    figure;
    plot(tau,gcc,'LineWidth',3); hold on;    
    hp=patch(V_GCC_lims(:,1),V_GCC_lims(:,2),[0.2 0 0]);
    set(hp,'FaceAlpha',0.2);
    grid on;
    set(gca,'FontSize',30)
    axis tight;

end


