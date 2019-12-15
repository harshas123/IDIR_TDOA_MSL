function [SAI]=process_zeta(zeta,num_activ_src)

num_sectors=size(zeta,2);
SAI = zeros(num_sectors,1);

[val,~]=min(zeta);
[val2,ind]=sort(val,'descend');
SAI(ind(1:num_activ_src)) = 1;
% thresh = val2(num_activ_src) - 3*10^-4;
% SAI(val>=thresh)=1;

% thresh=val_sort(num_activ_src);
% zeta(zeta<thresh) = 0;
% zeta(zeta>=thresh) = 1;
% 
% SAI = prod(zeta);
