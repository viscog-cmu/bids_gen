function [roi_mask, roi_exists] = get_vol_ROI_mask( roi_name, roi_source, sub )
%[roi_mask, roi_exists] = GET_VOL_ROI_MASK( roi_name, roi_source, sub )


wang_atlas = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/T1w.wang2015_atlas.nii',getenv('SUBJECTS_DIR'),sub));
benson_atlas = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/T1w.template_areas.nii',getenv('SUBJECTS_DIR'),sub));
votc_mask = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/T1w.VOTC.nii',getenv('SUBJECTS_DIR'),sub));

all_rois_Wang2015 = {'V1v' 'V1d' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4' 'VO1' 'VO2' 'PHC1' 'PHC2' , ...
    'TO2' 'TO1' 'LO2' 'LO1' 'V3B' 'V3A' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' 'IPS5' 'SPL1' 'FEF'};
rois_benson = {'V1','V2','V3'};

roi_exists = 1;

switch roi_source
    case 'wang2015'
        roi_mask = wang_atlas.samples == find(strcmp(roi_name,all_rois_Wang2015));
    case 'benson'
        roi_mask = benson_atlas.samples == find(strcmp(roi_name,rois_benson));
    case 'floc'
        try
            roi_mask = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/%s.nii',getenv('SUBJECTS_DIR'),sub,roi_name));
            roi_mask = roi_mask.samples == 1;
        catch
            roi_mask = nan;
            roi_exists = 0;
        end
    case 'FFA-all'
        try
            pFFA_mask = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/pFFA.nii',getenv('SUBJECTS_DIR'),sub));
            pFFA_mask = (pFFA_mask.samples == 1);
        catch
            pFFA_mask = zeros(1,length(wang_atlas.samples));
        end
        try
            FFA_mask = cosmo_fmri_dataset(sprintf('%s/sub-%02d/mri/FFA.nii',getenv('SUBJECTS_DIR'),sub));
            FFA_mask = (FFA_mask.samples == 1);
        catch
            FFA_mask = zeros(1,length(wang_atlas.samples));
        end
        roi_mask = pFFA_mask | FFA_mask;
        if sum(roi_mask) == 0
            roi_mask = nan; roi_exists = 0;
        end
    case 'VOTC'
        roi_mask = votc_mask.samples > 0;
end


end

