function [SAI, x_loc,DOA,TDOA_est] = SAI_based_2D_loc(Mic_pos, gcc, tau, Fs_gcc,...
                            A_reg, b_reg, tde_ll_samp, tde_ul_samp, ...
                            which_mics, ref_pts, c, mic_arr_orig, ...
                            num_active_src, meas_type, IDIR_span_compl,testpts,tech_type)

% All in 2D

% Step 1 : Coarse Localization
[zeta,~] = sector_activity_new(gcc, tau, tde_ll_samp, tde_ul_samp, meas_type);
SAI = process_zeta(zeta,num_active_src);

% Step 2: Fine Localization

[~,DIM] = size(Mic_pos);
active_sectors_det = find(SAI);
num_activ_src = length(active_sectors_det);
x_loc = zeros(num_activ_src,DIM);
DOA = zeros(num_activ_src,1);
TDOA_est = cell(num_activ_src,3);
for src_det_ind=1:num_activ_src
    
    % Get one of the Active Sectors
    reqd_sector = active_sectors_det(src_det_ind);
    TDOA_est{src_det_ind,3} = reqd_sector;
    
    % Get a dense sampling of the Active sector
    centroid = ref_pts(reqd_sector,:);
    try
        V = lcon2vert_ver3(A_reg{reqd_sector},b_reg{reqd_sector});
    catch msg
       A_reg{reqd_sector}(abs(A_reg{reqd_sector})<10^-7) = 0;
       V = lcon2vert_ver3(A_reg{reqd_sector},b_reg{reqd_sector});
    end
    in = inhull(testpts,V);
    x_tst = testpts(in,:);

    % Find an IDIR with only one source
    [mic_pair_index_no_olap] = find_single_src_IDIR(IDIR_span_compl,reqd_sector,active_sectors_det);
    which_mics_reqd = which_mics([mic_pair_index_no_olap],:);
    TDOA_est{src_det_ind,1} = which_mics_reqd;
    tde_ll_samp_reg = tde_ll_samp(:,reqd_sector);
    tde_ul_samp_reg = tde_ul_samp(:,reqd_sector);
    
    % Compute TDOA without association ambiguity from single source IDIRs
    [del_tau_reqd] = tde_reg_constr_gcc(gcc,tau,tde_ll_samp_reg,tde_ul_samp_reg,Fs_gcc,mic_pair_index_no_olap);
    TDOA_est{src_det_ind,2} = del_tau_reqd;
    A_sec_reg = A_reg{reqd_sector};
    b_sec_reg = b_reg{reqd_sector};
    
    % Fine Localization by optimzation on a grid of points.     
    [x_loc(src_det_ind,:),fn_min(src_det_ind)] = multi_obj_opt(Mic_pos,del_tau_reqd,which_mics_reqd,A_sec_reg,b_sec_reg,centroid,c,mic_arr_orig,x_tst,tech_type,gcc,tau,Fs_gcc);
    DOA(src_det_ind)=compute_DOA_2D_vec(x_loc(src_det_ind,:),mic_arr_orig(1:2));
end
