function surf_gii = surf_add_nan_indices( surf_gii, node_mask )
%SURF_ADD_NAN_INDICES
% surf_gii = SURF_ADD_NAN_INDICES(surf_gii, node_mask)

data = zeros(size(node_mask));
data(node_mask) = surf_gii.cdata;
data(~node_mask) = nan;

surf_gii.cdata = data;

%prepare for freesurfer
if size(surf_gii.cdata,2)>1
    surf_gii.cdata = surf_gii.cdata';
end

end

