function [testpts]=gen_grid_pts(grid_size,room_dim)

% grid_size=0.2;
grid_vec_x=room_dim(1,1):grid_size:room_dim(2,1);
grid_vec_y=room_dim(1,2):grid_size:room_dim(2,2);
[grid_x,grid_y]=meshgrid(grid_vec_x,grid_vec_y);
x_pts=grid_x(:);
y_pts=grid_y(:);
clear grid_vec_x grid_vec_y grid_x grid_y

len=length(x_pts);
testpts=[x_pts,y_pts];