
function get_func_tstats(subs,space,sm_fwhm,experiment)

% compute beta > base t-contrasts for all SPM covariates, but not nuisance
% regressors. compute the scalar between beta and tstat for quick (optional) beta->tstat
% conversion later

bids_dir = get_bids_dir(experiment);

if sm_fwhm > 0
    sm_tag=sprintf('_sm-%dmm',sm_fwhm);
else
    sm_tag='';
end

for sub = subs
        if ~exist(sprintf('%s/derivatives/matlab/sub-%02d',bids_dir,sub),'dir')
            mkdir(sprintf('%s/derivatives/matlab/sub-%02d',bids_dir,sub))
        end
        model_dir = sprintf('%s/derivatives/matlab/spm/sub-%02d/SPM-floc_vol-%s%s',bids_dir,sub,space,sm_tag);
        fname = sprintf('%s/tstat_constants.mat',model_dir);
        if exist(fname,'file')
            continue
        end

        ds = cosmo_trim_spm_labels(cosmo_fmri_dataset([model_dir,'/SPM.mat:beta']));
        beta_indices = (ds.sa.beta_index)'; %row vec for loops
        nbetas = length(beta_indices);

        clear matlabbatch
        matlabbatch{1}.spm.stats.con.spmmat = {[model_dir,'/SPM.mat']};
        matlabbatch{1}.spm.stats.con.delete = 1;
        for beta_i = 1:length(beta_indices)
            beta = beta_indices(beta_i);
            matlabbatch{1}.spm.stats.con.consess{beta_i}.tcon.name = ['beta-',num2str(beta)];
            matlabbatch{1}.spm.stats.con.consess{beta_i}.tcon.sessrep = 'none';
            matlabbatch{1}.spm.stats.con.consess{beta_i}.tcon.convec = [zeros(1,beta-1),1,zeros(1,nbetas-beta)];
        end
        spm_jobman('run',matlabbatch)

        scalar = zeros(1,nbetas);
        res = load_untouch_nii([model_dir,'/ResMS.nii']);
        for beta_ind = 1:length(beta_indices)
            beta_i = beta_indices(beta_ind);
            beta = load_untouch_nii(sprintf('%s/beta_%04d.nii',model_dir,beta_i));
            tval = load_untouch_nii(sprintf('%s/spmT_%04d.nii',model_dir,beta_ind));
            scalar(beta_ind) = median(tval.img(:)./((beta.img(:)./sqrt(res.img(:)))),'omitnan');
        end
        save(fname,'scalar');
        fprintf('\n acquired sub-%02d t-statistics \n',sub)

end
