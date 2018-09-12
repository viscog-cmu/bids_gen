function cosmo_map2gii( cosmo_ds, fname )
%CHECKSAVE_GIFTI( cdata, fname )
%
% saves data from surface cosmo dataset into gifti format

data = nan(length(cosmo_ds.a.fdim.values{1}),1);
data(cosmo_ds.fa.node_indices) = cosmo_ds.samples;

gii = gifti(struct('cdata',data));
save(gii,fname)


end

