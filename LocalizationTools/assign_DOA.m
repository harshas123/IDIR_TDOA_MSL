function [est_DOA, min_doa_err] = assign_DOA(DOA, act_DOA)

num_src = length(DOA);

diff_doa = abs((act_DOA(:) - DOA(:)'));
diff_doa(diff_doa>180) = 360 - diff_doa(diff_doa > 180);
min_doa_err = zeros(length(act_DOA),1);
est_DOA = NaN*zeros(length(act_DOA),1);
for src_num = 1:num_src
    [val,col] = min(diff_doa,[],2); 
   [tmp,row]=min(val);
   min_doa_err(row) = tmp;
   est_DOA(row) = DOA(col(row));
   diff_doa(:,col(row))=1000;
   diff_doa(row,:)=1000;
end

est_DOA = est_DOA';
min_doa_err = sort(min_doa_err');