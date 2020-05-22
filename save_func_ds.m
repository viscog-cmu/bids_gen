function save_func_ds(subs,space,use_tstat,use_mask,overwrite,experiment)

bids_dir = get_bids_dir(experiment);

if use_tstat
    t_tag = '_tstat';
else
    t_tag = '';
end

if ~use_mask
    m_tag = '_nomask';
else
    m_tag = '';
end

for sub = subs
    try
        decoding_task_count = 0;
        sub_dir = sprintf('%s/derivatives/matlab/cosmomvpa/ds/sub-%02d',bids_dir,sub);
        if ~exist(sub_dir,'dir')
            mkdir(sub_dir)
        end
        cortex_mask = cosmo_fmri_dataset(sprintf('%s/derivatives/freesurfer/sub-%02d/mri/T1w.cortex.nii',...
          bids_dir,sub));
        fn = sprintf('%s/spm-floc_vol-%s%s%s.mat', ...
            sub_dir, space, t_tag, m_tag);
        if exist(fn, 'file') && ~overwrite
            continue
        end
        model_dir = sprintf('%s/derivatives/matlab/spm/sub-%02d/SPM-floc_vol-%s', ...
            bids_dir,sub,space);
        func_ds = cosmo_trim_spm_labels(cosmo_fmri_dataset([model_dir,'/SPM.mat:beta']));
        [~, nan_mask] = cosmo_remove_useless_data(func_ds,1,'all');
        mask = cortex_mask.samples & nan_mask;
        mask_ds = func_ds;
        mask_ds.samples = mask;
        if ~exist(sprintf('%s/mask.nii', sub_dir), 'file') || overwrite
            cosmo_map2fmri(mask_ds, sprintf('%s/mask.nii', sub_dir));
            fprintf('\n saved mask nii for sub-%02d', sub)
        end
        if ~exist(sprintf('%s/mask.mat', sub_dir), 'file') || overwrite
            save(sprintf('%s/mask.mat', sub_dir), 'mask')
            fprintf('\n saved mask mat for sub-%02d', sub)
        end    
        if use_tstat
            ms = load_untouch_nii([model_dir,'/ResMS.nii']);
            T = load([model_dir,'/tstat_constants.mat']);
            func_ds.samples = T.scalar'.*(func_ds.samples./sqrt(ms.img(:)'));
        end
        if use_mask
            func_ds = cosmo_slice(func_ds,find(mask),2);
        end
        save(fn, 'func_ds')
        cosmo_map2fmri(func_ds, replace(fn,'.mat', '.nii.gz'));
        [~,name,~] = fileparts(fn);
        fprintf('\n Saved: sub-%02d %s', sub, name)
    catch
        fprintf('\n sub -%02d failed', sub)
        continue
    end
end
