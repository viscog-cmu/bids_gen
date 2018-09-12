function merge_fs_hemi_annotations( exp, subname, annot_name )
%MERGE_FS_HEMI_ANNOTATIONS( exp, subname, annot_name )
%
%   merge freesurfer annotation files across hemispheres
%   requires freesurfer
%
%   inputs:
%   
%   exp: experiment name under bids/ directory
%   subname: subject name
%   surfname: base annotation name, e.g., 'wang2015'. hemis will be preprended to this
%       using and .annot appended standard format, e.g. 'lh.wang2015.annot', 'rh.wang2015.annot', 'mh.wang2015.annot'
%
%

bids_dir = get_bids_dir(exp);
setenv('SUBJECTS_DIR',[bids_dir,'/derivatives/freesurfer'])
fs_sub_dir = [bids_dir,'/derivatives/freesurfer/',subname];

[vertices_L, label_L, ct_L] = read_annotation([fs_sub_dir,'/label/lh.',annot_name,'.annot']);
[vertices_R, label_R, ct_R] = read_annotation([fs_sub_dir,'/label/rh.',annot_name,'.annot']);

vertices_M = [vertices_L;vertices_R+length(vertices_L)];
label_M = [label_L;label_R];
ct_M = struct('numEntries',ct_L.numEntries + ct_R.numEntries,'orig_tab',ct_L.orig_tab, ...
    'struct_names',{[ct_L.struct_names;ct_R.struct_names]},'table',[ct_L.table;ct_R.table]);

write_annotation([fs_sub_dir,'/label/mh.',annot_name,'.annot'],vertices_M,label_M,ct_M)

end

