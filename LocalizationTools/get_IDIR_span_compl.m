function [IDIR_span_compl] = get_IDIR_span_compl(Mic_pos, A_reg, b_reg, tde_ll_samp, tde_ul_samp, c, Fs)

[num_mic_pairs, num_sectors] = size(tde_ll_samp);
IDIR_span_compl = cell(num_mic_pairs,num_sectors,1);

% Generate 1000 Random points in each sector
N = 1000;
pts_thresh = 0.15*N;% 15 % of total points
DIM = size(Mic_pos,2);
sec_pts= zeros(N,DIM,num_sectors);
for l=1:num_sectors
    [sec_pts(:,:,l)]=cprnd(N,A_reg{l},b_reg{l});
end

for l=1:num_sectors
    othr_sectors = setdiff(1:num_sectors,l);
   for k=othr_sectors
      [act_delay,~]=compute_act_delay(Mic_pos,sec_pts(:,:,k),c);
      act_delay = round(act_delay*Fs);
      span_mat = act_delay >= repmat(tde_ll_samp(:,l),1,N) & act_delay <= repmat(tde_ul_samp(:,l),1,N);
      conf_span_IDIR = sum(span_mat,2);
      IDIR_span_compl_ind = find(conf_span_IDIR <= pts_thresh);
      for m=1:length(IDIR_span_compl_ind)
         IDIR_span_compl{IDIR_span_compl_ind(m),l} = [IDIR_span_compl{IDIR_span_compl_ind(m),l} k];  
      end
%       =[IDIR_span_compl{IDIR_span_compl_ind, l} , k]; 
   end
   disp(['IDIR Complement of Sector ' num2str(l) ' Done.']);
end