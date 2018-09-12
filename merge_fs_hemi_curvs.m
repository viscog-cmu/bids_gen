function merge_fs_hemi_curvs( exp, subname )
%MERGE_FS_HEMI_SURFS( exp, subname, surfname )
%
%   merge freesurfer curvature files across hemispheres
%   requires freesurfer
%
%   inputs:
%   
%   exp: experiment name under bids/ directory
%   subname: subject name
%
%

bids_dir = get_bids_dir(exp);
setenv('SUBJECTS_DIR',[bids_dir,'/derivatives/freesurfer'])
fs_sub_dir = [bids_dir,'/derivatives/freesurfer/',subname];

[curv_L, fnum_L] = read_curv([fs_sub_dir,'/surf/lh.curv']);
[curv_R, fnum_R] = read_curv([fs_sub_dir,'/surf/rh.curv']);

curv_M = [curv_L;curv_R];
fnum_M = fnum_L + fnum_R;

write_curv([fs_sub_dir,'/surf/mh.curv'],curv_M,fnum_M);


end

