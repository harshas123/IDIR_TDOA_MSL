function [A_reg,b_reg]=reg_frm_plane_point(normal,point,ref_point)
% The region is represented as : A_reg*x <= b_reg
tmp_A=normal;
    tmp_b=normal*point';
    sgn_chk=sign(tmp_A*ref_point'-tmp_b);
    A_reg=-sgn_chk*tmp_A;
    b_reg=-sgn_chk*tmp_b;