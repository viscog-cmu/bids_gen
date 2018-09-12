function ds_M = cosmo_merge_hemis( ds_L, ds_R )
% ds_M = COSMO_MERGE_HEMIS(ds_L,ds_R)
%
%   merge hemispheres.
%
%   code for this function was taken from the FAQ of cosmomvpa, written by N. Oosterhoff 
%  
%   see also: merge_fs_hemi_labels

[~, index]=cosmo_dim_find(ds_L, 'node_indices');
nverts_left=max(ds_L.a.fdim.values{index});

% get the offset to set the feature attribute index later
offset_left=numel(ds_L.a.fdim.values{index});

% update node indices to support indexing data from two hemispheres
node_indices=[ds_L.a.fdim.values{index}, ...
                nverts_left+ds_R.a.fdim.values{index}];
ds_L.a.fdim.values{index}=node_indices;
ds_R.a.fdim.values{index}=node_indices;

% update node indices for right hemisphere
assert(all(ds_L.fa.node_indices<=offset_left)); % safety check
ds_R.fa.node_indices=ds_R.fa.node_indices+offset_left;

% merge hemisphes
ds_M = cosmo_stack({ds_L,ds_R},2);


end

