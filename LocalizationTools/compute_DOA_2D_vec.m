function [DOA] = compute_DOA_2D_vec(x_loc,orig)

diff_vec = x_loc - orig;
DOA = atan2d(diff_vec(:,2), diff_vec(:,1));

DOA(DOA < 0) = DOA(DOA < 0) + 360;