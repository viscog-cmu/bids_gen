function bids_make_spm_multi_regression_files( sub, experiment, tasks, new_format, overwrite )
%BIDS_MAKE_SPM_MULTI_REGRESSION_FILE 
%   convert FMRIPREP confounds.tsv files to spm multiple conditions format
%   regressors: 6 motion regressors, aCompCor (6 comps), and FD
%   (framewise-displacement). 
%   component choices as recommended by Chris Gorkolewski on Neurostars
%   (https://neurostars.org/t/confounds-from-fmriprep-which-one-would-you-use-for-glm/326)
%
%   Author: Nicholas Blauch
%   Updated 4/19/19 to reflect new FMRIPREP naming system
%   Updated 8/7/18 to avoid rewriting pre-existing files
%   Updated 4/30/18 to take sub as an integer, and for support with
%   off-server computation using get_bids_dir

bids_dir = get_bids_dir(experiment);

% default to old format for backwards compatibility
if nargin < 4
    new_format = 0;
end
if nargin < 5
    overwrite = 0;
end

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
            if new_format
                name = sprintf('%s/func/sub-%02d_ses-%02d_task-%s_run-%02d_desc-confounds_regressors.tsv',sess_dir,sub,sess,tasks{task},exp_run+1);
            else
                name = sprintf('%s/func/sub-%02d_ses-%02d_task-%s_run-%02d_bold_confounds.tsv',sess_dir,sub,sess,tasks{task},exp_run+1);
            end
            while exist(name,'file')
                exp_run = exp_run + 1;

                fname = sprintf('%s/ses-%02d/sub-%02d_ses-%02d_task-%s_run-%02d_multiregressors.txt',out_dir,sess,sub,sess,tasks{task},exp_run);
                if exist(fname,'file')
                    name = strrep(name, sprintf('run-%02d', exp_run), sprintf('run-%02d', exp_run+1));
                    continue
                end
                
                confounds = tdfread(name);
                [translation, regressors] = analyze_confounds(confounds, new_format);
                fprintf('\n sub-%02d_ses-%02d_task-%s_run-%02d: max displacement from start: %1.3f mm \n',sub,sess,tasks{task}, exp_run, max(translation(1,:)));
                %change NAN to regressor mean for regressors with leading or other NAN.
                for regressor = 1:size(regressors,2)
                    regressors(isnan(regressors(:,regressor))',regressor) = mean(regressors(~isnan(regressors(:,regressor)),regressor));
                end
                dlmwrite(fname,regressors)
                name = strrep(name, sprintf('run-%02d', exp_run), sprintf('run-%02d', exp_run+1));
            end
        end
    end
    
else
    for task = 1:length(tasks)
        exp_run = 0;
        if new_format
            name = sprintf('%s/func/sub-%02d_task-%s_run-%02d_desc-confounds_regressors.tsv',sub_deriv_dir,sub,tasks{task},exp_run+1);
        else
            name = sprintf('%s/func/sub-%02d_task-%s_run-%02d_bold_confounds.tsv',sub_deriv_dir,sub,tasks{task},exp_run+1);
        end
        while exist(name,'file')
            exp_run = exp_run + 1;
            
            fname = sprintf('%s/sub-%02d_task-%s_run-%02d_multiregressors.txt',out_dir,sub,tasks{task},exp_run);
            if ~overwrite
                if exist(fname,'file')
                    name = strrep(name, sprintf('run-%02d', exp_run), sprintf('run-%02d', exp_run+1));
                    continue
                end
            end
            
            confounds = tdfread(name);
            [translation, regressors] = analyze_confounds(confounds, new_format);
            fprintf('\n sub-%02d_task-%s_run-%02d: max displacement from start: %1.3f mm \n',sub,tasks{task}, exp_run, max(translation(1,:)));
            %change NAN to regressor mean for regressors with leading or other NAN.
            for regressor = 1:size(regressors,2)
                regressors(isnan(regressors(:,regressor))',regressor) = mean(regressors(~isnan(regressors(:,regressor)),regressor));
            end
            dlmwrite(fname,regressors);
            
            name = strrep(name, sprintf('run-%02d', exp_run), sprintf('run-%02d', exp_run+1));
            
        end
    end
end

end

function [translation, regressors] = analyze_confounds(confounds, new_format)
    if new_format
        for ii = 1:length(confounds.t_comp_cor_00)
            confounds.FD_double(ii) = str2double(confounds.framewise_displacement(ii,:)); 
        end
        translation = dist([confounds.trans_x,confounds.trans_y,confounds.trans_z]');
        regressors = [confounds.a_comp_cor_00,confounds.a_comp_cor_01,confounds.a_comp_cor_02,confounds.a_comp_cor_03,...
            confounds.a_comp_cor_04,confounds.a_comp_cor_05,confounds.trans_x,confounds.trans_y,confounds.trans_z,confounds.rot_x,...
            confounds.rot_y,confounds.rot_z,confounds.FD_double'];                    
    else
        for ii = 1:length(confounds.tCompCor00)
            confounds.FD_double(ii) = str2double(confounds.FramewiseDisplacement(ii,:)); 
        end
        translation = dist([confounds.X,confounds.Y,confounds.Z]');
        regressors = [confounds.aCompCor00,confounds.aCompCor01,confounds.aCompCor02,confounds.aCompCor03,...
            confounds.aCompCor04,confounds.aCompCor05,confounds.X,confounds.Y,confounds.Z,confounds.RotX,...
            confounds.RotY,confounds.RotZ,confounds.FD_double'];
    end
end
