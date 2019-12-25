function [tau]=TDE_RHS(p,Mic_pos)

tau=sqrt(sum((ones(size(p,1),1)*Mic_pos(2,:)-p).^2,2))-sqrt(sum((ones(size(p,1),1)*Mic_pos(1,:)-p).^2,2));