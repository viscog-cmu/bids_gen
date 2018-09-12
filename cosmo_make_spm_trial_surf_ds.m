function surf_ds = cosmo_make_spm_trial_surf_ds(experiment,sub,ses,hemi)
%COSMO_MAKE_SPM_TRIAL_SURF_DS(beta_dir)
%
%   load a cosmo surface dataset of single-trial beta weights extracted
%   with SPM. not general - requires a specific data structure to exist.
%
%   this function finishes by running cosmo_trim_spm_labels, 
%   which creates a ds.sa.targets column grouping beta weights by
%   their corresponding covariate. 
%
%   author: Nick Blauch
%   last updated: 3/21/2018

try
    load(sprintf('%s/matlab/sub-%02d_ses-%02d_single_trial_beta_data_%s.mat',deriv_dir,sub,sess_j,space))
catch ME
    error('ERROR: data structure not in place for sub-%02d ses-%02d',sub,ses)
end

beta1 = gifti([beta_dir,'/beta_0001.gii']);
if ~isa(beta1.cdata,'single')
    beta1.cdata = numeric(beta1.cdata);
end
surf_ds = cosmo_surface_dataset(beta1);

for run_num = 1:length(SPM.Sess)
    surf_ds.sa.chunks(SPM.Sess(run_num).col,1) = run_num;
end

surf_ds.samples = zeros(length(surf_ds.sa.chunks),length(surf_ds.fa.node_indices));
for beta_num = 1:length(surf_ds.sa.chunks)
    beta = gifti([beta_dir,'/beta_',sprintf('%04d',beta_num),'.gii']);
    if ~isa(beta.cdata,'single')
        beta.cdata = numeric(beta.cdata);
    end
    surf_ds.samples(beta_num,:) = beta.cdata; 
    surf_ds.sa.fname{beta_num,1} = [beta_dir,'/beta_',sprintf('%04d',beta_num),'.gii'];
    surf_ds.sa.labels{beta_num,1} = SPM.Vbeta(beta_num).descrip(24:end); %take only relevant name
end
surf_ds.sa.beta_index = (1:length(surf_ds.sa.chunks))';

surf_ds = cosmo_trim_spm_labels(surf_ds);

end