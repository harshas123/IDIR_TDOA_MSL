function [h_reg]=plot_sectors(A_reg, b_reg, room_dim, h)
% INPUTS TO THE FUNCTION: 
%% 

% % # _A_reg,b_reg_ : Cell Arrays containing the sector descriptions as convex regions satisfying the 
% linear matrix inequality - A_reg{l} x <= b_reg; 1 <= l <= L.
% # _room_dim_ : Dimensions of a recatangular enclosure (meter) in the
%                following format:
%                [x_lower_lim, y_lower_lim, z_lower_lim;
%                 x_upper_lim, y_upper_lim, z_upper_lim]
% # _h_ : Figure Hanlde in which to plot the sectors

%%
num_reg_A=length(A_reg);
num_reg_b=length(b_reg);

if num_reg_A~=num_reg_b
   error('Lengths of cells A_reg and b_reg do not match'); 
end

h_reg = cell(num_reg_A, 1);
figure(h);
hold on;
for i=1:num_reg_A
    h_reg{i}=plotregion(-A_reg{i},-b_reg{i},[],[],'b',0.1);
%     group21legend(h_reg{i})
end

xlim([room_dim(1,1) room_dim(2,1)]);
ylim([room_dim(1,2) room_dim(2,2)]);
if size(room_dim,2) == 3
    zlim([room_dim(1,3) room_dim(2,3)]);
end