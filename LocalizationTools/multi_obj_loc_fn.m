function [fn]=multi_obj_loc_fn(p,Mic_pos,TDOA,which_mics,c)
% [p_opt,fval,exitflag,output] = fmincon(@(p) multi_obj_loc_fn(p,Mic_pos,TDOA,which_mics,c),centroid,A,b);

% num_mics=size(Mic_pos,1);

num_tdoas=size(which_mics,1);

if length(TDOA)~=num_tdoas
   error('Number of mic-pairs and TDOAs do not match'); 
end
fn =0;
del_tau_act = NaN*zeros(num_tdoas,1);
for k=1:num_tdoas
%    [mic2,mic1] = which_mics(k,:);
%    fn = fn+((norm(p-Mic_pos(which_mics(k,1),:))-norm(p-Mic_pos(which_mics(k,2),:)))/c - TDOA(k))^2;
    del_tau_act(k) = (norm(p-Mic_pos(which_mics(k,1),:))-norm(p-Mic_pos(which_mics(k,2),:)))/c;
end

fn = norm(del_tau_act - TDOA(:));
% fn = prod(abs(del_tau_act - TDOA(:)));
