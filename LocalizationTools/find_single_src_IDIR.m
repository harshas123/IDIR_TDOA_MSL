function [mic_pair_ind] = find_single_src_IDIR(IDIR_span_compl,reqd_sector,active_sectors)

othr_sectors = setdiff(active_sectors,reqd_sector);
   [num_mic_pairs,~]=size(IDIR_span_compl);
  mic_pair_ind = []; 
   for i=1:num_mic_pairs
       if ~length(setdiff(othr_sectors,IDIR_span_compl{i,reqd_sector}))
          mic_pair_ind = [mic_pair_ind i]; 
       end
   end