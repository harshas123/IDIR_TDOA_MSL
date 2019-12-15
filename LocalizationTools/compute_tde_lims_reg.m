function [tde_ll_samp,tde_ul_samp]=compute_tde_lims_reg(Mic_pos,A,b,c,ref_pts,Fs,mic_arr_orig)
%% Function to compute the characteristic intervals of all the regions w.r.t. all microphone pairs

% Inputs to the function
%%
% # _Mic_pos_ : Microphone locations within the enclosure. Each Mic in a row.
% # _A, _b : num_sectors X 1 Cell Arrays describing the num_sectors convex
% polytopes. the l^th polytope is given by: A{l}x <= b{l}. 
% # _c : Speed of sound (meter per second)
% # _ref_pts: num_sectors X 2 array. Each row is a point lying within each of the num_sectors polytopes. 
% # _Fs: Sampling Frequency in Hz
% # _mic_arr_orig: The center of the enclosure. Pass this only if all the
% regions intersect at this point. Else leave it empty. 

% Outputs of the function:
%% 
% # _tde_ll_samp: num_mic_pairs X num_sectors array. 
%                   Lower limit of the Characteristic interval of mic pair 
%                   w.r.t each region given by cell array A and b;
% #_ tde_ul_samp: num_mic_pairs X num_sectors array. 
%                   Lower limit of the Characteristic interval of mic pair 
%                   w.r.t each region given by cell array A and b; 

L=length(A);
N=size(Mic_pos,1);
num_lims=N*(N-1)/2;

tde_ll_samp=NaN*zeros(num_lims,L);
tde_ul_samp=NaN*zeros(num_lims,L);
for l=1:L    
    k=1;
    centroid=ref_pts(l,:);
    for j=1:N-1
        for i=j+1:N
%             try 
%                 [V,nr_conf,nre_conf]=lcon2vert_ver3(A{l},b{l});
%                 centroid=mean(V);
%             catch
%                 centroid=centre_bckup;
%             end
            
            options = optimset('Display', 'off') ;
%             A_tmp=A{l};            
%             b{l}=b{l}-room_dim(2)/2*A_tmp(:,3);
%             A_tmp(:,3)=[];
            [x_min, fval_min_pt,exitflag,output] = fmincon(@(p)TDE_RHS(p,Mic_pos([j,i],:)),centroid,A{l},b{l},[],[],[],[],[],options);
            [x_max, fval_max_pt,exitflag,output] = fmincon(@(p)-TDE_RHS(p,Mic_pos([j,i],:)),centroid,A{l},b{l},[],[],[],[],[],options);
            if ~isempty(mic_arr_orig)
               [x_min, fval_min_orig,exitflag,output] = fmincon(@(p)TDE_RHS(p,Mic_pos([j,i],:)),mic_arr_orig,A{l},b{l},[],[],[],[],[],options);
               [x_max, fval_max_orig,exitflag,output] = fmincon(@(p)-TDE_RHS(p,Mic_pos([j,i],:)),mic_arr_orig,A{l},b{l},[],[],[],[],[],options);

                fval_min = min(fval_min_pt,fval_min_orig);
                fval_max = max(-fval_max_pt,-fval_max_orig); 
            else
                fval_min = fval_min_pt;
                fval_max = fval_max_pt;
            end
            
            tde_ll_samp(k,l)=floor(fval_min*Fs/c);%Note: unit of fval is distance
            tde_ul_samp(k,l)=ceil(fval_max*Fs/c);
            
%             Verification code
%             [h_pts]=visualize_ITIR(room_dim,Fs,c,Mic_pos([j,i],:),tde_ll_samp(k,l),tde_ul_samp(k,l),'g');
%             delete(h_pts);
            k=k+1;
        end
    end
    disp(['Computed TDOA Limits for sector ' num2str(l)]);
end





