function [A_reg,b_reg,ref_pts]= create_sectors_2D(room_dim,num_sectors,mic_pos_orig, off_set)
% In 2D
% mic_pos_orig should be 2D vector
% room_dim should be a 2X2 matrix:
% [x_lower_lim, y_lower_lim;
%  x_upper_lim, y_upper_lim]


A_reg = cell(num_sectors,1);
b_reg = cell(num_sectors,1);

A_room = [eye(2);-eye(2)];
b_room = [room_dim(2,:)';-room_dim(1,:)'];

theta = 360/num_sectors;%Sector angular width
theta_line = (0:theta:361)+ off_set;
% offset = 10;
theta_pts = (theta/2:theta:360-(theta/2)) + off_set;

slope = tand(theta_line);
ref_pts = repmat(mic_pos_orig,length(theta_pts),1)+2*[cosd(theta_pts') sind(theta_pts')];

for l=1:num_sectors
    A_tmp = A_room;
    b_tmp = b_room;
    if isinf(slope(l))
       if ref_pts(l,1) >= mic_pos_orig(1) 
           A1 = [-1 0];
           y_intercept = -mic_pos_orig(1);
       else
           A1 = [1 0];
           y_intercept = mic_pos_orig(1);
       end
    else
        A1 = [-slope(l) 1];
       y_intercept = A1*mic_pos_orig';
    end
    if A1*ref_pts(l,:)' <= y_intercept
       A_tmp = [A_tmp;A1];
       b_tmp = [b_tmp; y_intercept];
    else
       A_tmp = [A_tmp; -A1];
       b_tmp = [b_tmp; -y_intercept];
    end
   if isinf(slope(l+1))
       if ref_pts(l,1) >= mic_pos_orig(1) 
           A2 = [-1 0];
           y_intercept = -mic_pos_orig(1);
       else
           A2 = [1 0];
           y_intercept = mic_pos_orig(1);
       end
    else
        A2 = [-slope(l+1) 1];
        y_intercept = A2*mic_pos_orig';
    end
   
   if A2*ref_pts(l,:)' <= y_intercept
       A_tmp = [A_tmp;A2];
       b_tmp = [b_tmp; y_intercept];
   else
       A_tmp = [A_tmp; -A2];
       b_tmp = [b_tmp; -y_intercept];
   end
   A_reg{l} = A_tmp;
   b_reg{l} = b_tmp;
end




