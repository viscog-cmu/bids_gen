function  merge_fs_hemi_surfs( exp, subname, surfname )
%MERGE_FS_HEMI_SURFS( exp, subname, surfname )
%
%   merge freesurfer surfaces across hemispheres
%   requires freesurfer
%
%   inputs:
%   
%   exp: experiment name under bids/ directory
%   subname: subject name
%   surfname: base surf name, e.g., 'inflated'. hemis will be preprended to this
%       using standard format, e.g. 'lh.inflated', 'rh.inflated', 'mh.inflated'
%
%

if contains(surfname,'inflated')
    x_shift = 85;
else
    x_shift = 0;
end

bids_dir = get_bids_dir(exp);
setenv('SUBJECTS_DIR',[bids_dir,'/derivatives/freesurfer'])
fs_sub_dir = [bids_dir,'/derivatives/freesurfer/',subname];

[vertex_coords_L, faces_L] = freesurfer_read_surf([fs_sub_dir,'/surf/lh.',surfname]);
[vertex_coords_R, faces_R] = freesurfer_read_surf([fs_sub_dir,'/surf/rh.',surfname]);

%modify R before merging
faces_M = [faces_L;faces_R + length(vertex_coords_L)];
vertex_coords_M = [vertex_coords_L;[vertex_coords_R + repmat([x_shift, 0 0],length(vertex_coords_R),1)]];

write_surf([fs_sub_dir,'/surf/mh.',surfname],vertex_coords_M,faces_M)
save(gifti(struct('faces',faces_M,'vertices',vertex_coords_M)),[fs_sub_dir,'/surf/mh.',surfname,'.gii'])


end

