function [normal_new]=rotate_plane(normal,theta,rot_axis)
% theta is in degrees
% rot_axis is a unit vector along the axis of rotation
% comp_par_axis=(rot_axis'*normal)*rot_axis;
% comp_perp_axis=normal-comp_par_axis;
% 
% alpha=atnad(normal(2)/normal(1));
% normal_new=[cosd() sind() normal(3)];

% Implementation of Rodrigues' rotation formula
normal_new=normal*cosd(theta) ...
           + cross(rot_axis,normal)*sind(theta)...
           + rot_axis*(rot_axis*normal')*(1-cosd(theta));