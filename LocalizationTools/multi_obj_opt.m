function [p_opt,fn_min]=multi_obj_opt(Mic_pos,TDOA,which_mics,A,b,centroid,c,mic_arr_orig,x_tst,tech_type,gcc,tau,Fs_gcc)
% [x_loc(src_det_ind,:)] = multi_obj_opt(Mic_pos,del_tau_reqd,which_mics_reqd,A_sec_reg,b_sec_reg,centroid,c,mic_arr_orig);
% [fn]=multi_obj_loc_fn(p,Mic_pos,TDOA,which_mics,c);
% Aineq,bineq
% [p_opt,fval,exitFlag,output,population,scores] = gamultiobj(@(p) multi_obj_loc_fn(p,Mic_pos,TDOA,which_mics,c),2,A,b,[],[],[],[]);

% display(['Maximum number of constraint violations =' options.maxconstraint]);
% display(['Termination Message =' options.message]);

% N=1000;
% [x_tst]=cprnd(N,A,b);

if strcmp(tech_type,'NL-opt')
   [p_opt,fval,exitflag,output] = fmincon(@(p) multi_obj_loc_fn(p,Mic_pos,TDOA,which_mics,c),centroid,A,b);
    if exitflag==-2 
       error('No solution found'); 
    elseif exitflag==-5
        error('Time Limit exceeded');
    end   
elseif strcmp(tech_type,'Grid Search')
%     dist = sqrt(sum(((x_tst-mic_arr_orig).^2),2));
%     dist_thresh = 1.5;
%     x_tst(dist < dist_thresh,:) = [];
    N = size(x_tst,1);
    fn = zeros(N,1);
    for m=1:N
       fn(m) = multi_obj_loc_fn(x_tst(m,:),Mic_pos,TDOA,which_mics,c); 
    end
    fn_min = min(fn);
%     figure(12);
%     plot(fn,'LineWidth',4);hold on;
%     grid on;
    fn = fn - fn_min;
    fn = fn/max(fn);
    [val,ind]=min(fn);
    p_opt = x_tst(ind,:);
%     [val,ind] = sort(fn);
%     reqd_pts_near_min = (abs(fn - val(1)) < 0.03);
%     if length(reqd_pts_near_min) > 1
%         p_opt = mean(x_tst(reqd_pts_near_min,:),1);
%     else
%         p_opt = x_tst(ind(1),:); 
%     end
% %     if abs(val(1) - val(2)) < 2*10^-4
% %        p_opt = mean(x_tst(ind(1:5),:),1) ;
% %     else
% %        p_opt = x_tst(ind,:); 
% %     end
% %     
% %     p_opt = mean(x_tst(reqd_pts_near_min,:),1);

    
elseif strcmp(tech_type,'GCF-SAI')
    [act_delay,~]=compute_act_delay(Mic_pos,x_tst,c);
    [p_opt,~,~,~] = compute_GCF_loc_allpts(gcc,tau,x_tst,act_delay,Fs_gcc,0,mic_arr_orig);
elseif strcmp(tech_type,'OSLS')
    num_mics = size(Mic_pos,1);
    % Choose a reference microphone: The choice is given by the microphone
    % index which occurs most number of times amondst the associated TDOAs.
    [nout,xout] = hist(which_mics(:),1:num_mics);
    [val,ind] = max(nout);
    ref_mic = xout(ind);

    % Choose the appropriate TDOAs w.r.t to the reference microphone:
    mic_pair_corr_order_ind = find(which_mics(:,2)==ref_mic);
    mic_pair_rever_order_ind = find(which_mics(:,1)==ref_mic);
%     which_mics_linear = [which_mics(mic_pair_corr_order_ind,:); which_mics(mic_pair_rever_order_ind,:)];
    del_tau = [TDOA(mic_pair_corr_order_ind);-TDOA(mic_pair_rever_order_ind)];
    Mic_pos_lin_frame = [Mic_pos(ref_mic,:);Mic_pos([which_mics(mic_pair_corr_order_ind,1);which_mics(mic_pair_rever_order_ind,2)],:)];
    num_mics_lin_frame = size(Mic_pos_lin_frame,1);
    W = eye(num_mics_lin_frame-1);
    [p_opt,~,~]= lin_loc_ben_latest(Mic_pos_lin_frame,del_tau,W,1,c);
    p_opt = p_opt(1:2);
end
