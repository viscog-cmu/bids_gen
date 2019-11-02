function ds = cosmo_trim_spm_labels(ds)
%COSMO_TRIM_SPM_LABELS
%
%   trim labels gathered from SPM.mat:beta using cosmo_fmri_dataset
%   this results in labels reflecting repeated covariates across runs
%   also creates and adds a 'targets' vector to ds.sa
%
%   if nuisance regressors are applied in GLM, this will rid the cosmo_mvpa
%   data structure of nuisnace beta weights, leaving only beta weights
%   corresponding to experimental covariates. 
%
%   author: Nick Blauch
%   last updated 1/2/2018

labels = ds.sa.labels;

for ii = 1:length(labels)
    if ds.sa.chunks < 10
        labels{ii} = labels{ii}(7:end-6);
    elseif ds.sa.chunks <100
        labels{ii} = labels{ii}(8:end-6);
    elseif ds.sa.chunks < 1000
        labels{ii} = labels{ii}(9:end-6);
    end
end

unique_labels = unique(labels,'stable');
targets = zeros(length(labels),1);
for i_label = 1:length(unique_labels)
    targets(strcmp(labels,unique_labels{i_label})) = i_label;
end

ds.sa.labels = labels;
ds.sa.targets = targets;

non_nuisance_indices = ~strcmp(ds.sa.labels,'');

ds = cosmo_slice(ds,non_nuisance_indices);

end