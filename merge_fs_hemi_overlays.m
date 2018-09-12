function [ output_args ] = merge_fs_hemi_overlays( fname_L, fname_R, fname_M )
%MERGE_FS_HEMI_OVERLAYS( fname_L, fname_R, fname_M )
% 
%   merge generic gifti overlays. no naming scheme is assumed.
%

overlay_L = gifti(fname_L);
overlay_R = gifti(fname_R);

overlay_M = gifti(struct('cdata',[overlay_L.cdata;overlay_R.cdata]));

save(overlay_M,fname_M)


end

