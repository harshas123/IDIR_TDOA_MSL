function [A_reg,b_reg,ref_pts]=create_sectors_improved(room_dim,num_sectors,display_fig,h,mic_pos_orig,off_set)
%% Function to create sectors within an enclosure.

% INPUTS TO THE FUNCTION: 
%%
%
% # _room_dim_ : Dimensions of a recatangular enclosure (meter) in the
%                following format:
%                [x_lower_lim, y_lower_lim, z_lower_lim;
%                 x_upper_lim, y_upper_lim, z_upper_lim]
% # _num_sectors_ : Number of sectors to be created
% # _display_fig_ : Binary Flag to display figure containing the enlsoure and
%                   sectors (if 1)
% # _h_ : Figure Handle
% # _mic_pos_orig_ : Co-ordinates of the center of the UCA

% OUTPUTS OF THE FUNCTION:
%%
%
% # _A_reg,b_reg_ : Cell Arrays containing the sector descriptions as convex regions satisfying the 
% linear matrix inequality - A_reg{l} x <= b_reg; 1 <= l <= L.
% # ref_pts : The co-ordinates of the centroids of each of the L sectors
%               in an L X 3 matrix.

%%
% AUTHOR

% Code written by: Harshavardhan Sundar
% Ph. D. Scholar,
% Speech and Audio Group, 
% Department of Electrical Communication Engineering
% Indian Institute of Science,
% Bangalore, India - 560012% 
% email: harshas123@gmail.com
%%

A_room=[eye(3);-eye(3)];
b_room=[room_dim(2,:)';-room_dim(1,:)'];

sec_orig=mic_pos_orig;
normal(1,:)=[0 1 0];
rot_axis=[0 0 1];
theta=360/num_sectors;
theta_pts = (theta/2:theta:360-(theta/2));
ref_pts_rad = 0.5;
ref_pts=repmat(sec_orig,length(theta_pts),1)+ref_pts_rad*[cosd(theta_pts') sind(theta_pts') zeros(length(theta_pts),1)];
% theta = theta + off_set;
for i=1:num_sectors
    [A(1,:),b(1)]=reg_frm_plane_point(normal(i,:),sec_orig,ref_pts(i,:));
    [normal(i+1,:)]=rotate_plane(normal(i,:),theta,rot_axis);
    [A(2,:),b(2)]=reg_frm_plane_point(normal(i+1,:),sec_orig,ref_pts(i,:));    
    A=[A;A_room];
    b=[b(:);b_room];
    
%     [X_conf,nr_conf,nre_conf]=lcon2vert_ver3(A,b);
%     [A_reg{i},b_reg{i},Aeq,beq]=vert2lcon_improved(X_conf);
    A_reg{i}=A;
    b_reg{i}=b;

    if display_fig
        figure(h);
        h1=plotregion(-A,-b,[],[],'b',0.3);
        hold on;
        plot3(ref_pts(i,1),ref_pts(i,2),ref_pts(i,3),'kd','MarkerFaceColor','k','MarkerSize',4)
        xlim([room_dim(1,1) room_dim(2,1)])
        ylim([room_dim(1,2) room_dim(2,2)])
        zlim([room_dim(1,3) room_dim(2,3)]);
        delete(h1);
    end

    clear A b;
end
