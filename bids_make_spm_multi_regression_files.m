function bids_make_spm_multi_regression_files( sub, experiment, tasks )
%BIDS_MAKE_SPM_MULTI_REGRESSION_FILE 
%   convert FMRIPREP confounds.tsv files to spm multiple conditions format
%   regressors: 6 motion regressors, aCompCor (5 comps), and FD
%   (framewise-displacement). 
%   component choices as recommended by Chris Gorkolewski on Neurostars
%   (https://neurostars.org/t/confounds-from-fmriprep-which-one-would-you-use-for-glm/326)
%
%   Author: Nicholas Blauch
%   Updated 8/7/18 to avoid rewriting pre-existing files
%   Updated 4/30/18 to take sub as an integer, and for support with
%   off-server computation using get_bids_dir

bids_dir = get_bids_dir(experiment);

sub_deriv_dir = sprintf('%s/derivatives/fmriprep/sub-%02d',bids_dir,sub);
out_dir =sprintf('%s/derivatives/matlab/spm/multiple_regressors/sub-%02d',bids_dir,sub);
if ~exist(out_dir,'dir')
    mkdir(out_dir)
end
multisess_format = ~(~exist([sub_deriv_dir,'/ses-01'],'dir'));
n_sess = 0;
if multisess_format
    ii = 1;
    while exist(sprintf('%s/ses-%02d',sub_deriv_dir,ii),'dir')
        n_sess = ii;
        ii = ii + 1;
    end
end

if multisess_format
    for sess = 1:n_sess
        sess_dir = sprintf('%s/ses-%02d',sub_deriv_dir,sess);
        if ~exist(sprintf('%s/ses-%02d',out_dir,sess),'dir')
            mkdir(sprintf('%s/ses-%02d',out_dir,sess))
        end
        for task = 1:length(tasks)
            exp_run = 0;
            while exist(sprintf('%s/func/sub-%02d_ses-%02d_task-%s_run-%02d_bold_confounds.tsv',sess_dir,sub,sess,tasks{task},exp_run+1),'file')
                exp_run = exp_run + 1;

                fname = sprintf('%s/ses-%02d/sub-%02d_ses-%02d_task-%s_run-%02d_multiregressors.txt',out_dir,sess,sub,sess,tasks{task},exp_run);
                if exist(fname,'file')
                    continue
                end
                
                confounds = tdfread(sprintf('%s/func/sub-%02d_ses-%02d_task-%s_run-%02d_bold_confounds.tsv',sess_dir,sub,sess,tasks{task},exp_run));
                
                for ii = 1:length(confounds.tCompCor00)
                   confounds.FD_double(ii) = str2double(confounds.FramewiseDisplacement(ii,:)); 
                end
                
                translation = dist([confounds.X,confounds.Y,confounds.Z]');
                fprintf('\n sub-%02d_ses-%02d_task-%s_run-%02d: max displacement from start: %1.3f mm \n',sub,sess,tasks{task}, exp_run, max(translation(1,:)));
                
                regressors = [confounds.aCompCor00,confounds.aCompCor01,confounds.aCompCor02,confounds.aCompCor03,...
                    confounds.aCompCor04,confounds.aCompCor05,confounds.X,confounds.Y,confounds.Z,confounds.RotX,...
                    confounds.RotY,confounds.RotZ,confounds.FD_double'];
                
                %change NAN to regressor mean for regressors with leading or other NAN.
                for regressor = 1:size(regressors,2)
                    regressors(isnan(regressors(:,regressor))',regressor) = mean(regressors(~isnan(regressors(:,regressor)),regressor));
                end
                
                dlmwrite(fname,regressors)
                
            end
        end
    end
    
else
    for task = 1:length(tasks)
        exp_run = 0;
        while exist(sprintf('%s/func/sub-%02d_task-%s_run-%02d_bold_confounds.tsv',sub_deriv_dir,sub,tasks{task},exp_run),'file')
            exp_run = exp_run + 1;
            
            fname = sprintf('%s/sub-%02d_task-%s_run-%02d_multiregressors.txt',out_dir,sub,tasks{task},exp_run);
            if exist(fname,'file')
                continue
            end
            
            confounds = tdfread(sprintf('%s/func/sub-%02d_task-%s_run-%02d_bold_confounds.tsv',sub_deriv_dir,sub,tasks{task},exp_run));
            
            for ii = 1:length(confounds.tCompCor00)
                confounds.FD_double(ii) = str2double(confounds.FramewiseDisplacement(ii,:));
            end
            
            regressors = [confounds.tCompCor00,confounds.tCompCor01,confounds.tCompCor02,confounds.tCompCor03,...
                confounds.tCompCor04,confounds.tCompCor05,confounds.X,confounds.Y,confounds.Z,confounds.RotX,...
                confounds.RotY,confounds.RotZ,confounds.FD_double'];
            
            %change NAN to regressor mean for regressors with leading or other NAN.
            for regressor = 1:size(regressors,2)
                regressors(isnan(regressors(:,regressor))',regressor) = mean(regressors(~isnan(regressors(:,regressor)),regressor));
            end
            
            dlmwrite(fname,regressors);
            
        end
    end
end

end

