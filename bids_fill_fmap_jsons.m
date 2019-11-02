function  bids_fill_fmap_jsons( experiment, sub, ses, intended_tasks )
%BIDS_FILL_FMAP_JSONS(experiment,sub)
%   -fill in the "IntendedFor" field in fmap .json files
%   necessary for distortion correction with FMRIPREP
%   -requires get_bids_dir, jsonlab toolbox
%   -for now, cannot distinguish between field maps acquired for one vs.
%   another set of scans (have not needed it & no standard naming
%   framework)
%   -assumes that all functional data is stored within /func
%   -REQUIRES MATLAB < 2017A (savejson is broken for new editions)
%
%   input args:
%   experiment: name of bids experiment
%   sub: sub number (assumes ID is sprintf('sub-%02d,sub))
%   ses: ses # - if no session format, use ses=0
%   intended_tasks: cell array of tasks to search for, e.g. {'func,'floc'}
%
%   author: Nicholas Blauch
%   date: 6/1/2018

    %set fmap and func directories to appropriate locations
    %func dir is with respect to the subject dir per bids spec
    bids_dir = get_bids_dir(experiment);
    if ses>0
        subses_dir = sprintf('%s/sub-%02d/ses-%02d',bids_dir,sub,ses);
        func_dir = sprintf('ses-%02d/func',ses);
        ses_tag = sprintf('ses-%02d_',ses);
    else
        subses_dir = sprintf('%s/sub-%02d',bids_dir,sub);
        func_dir = 'func';
        ses_tag = '';
    end
    fmap_dir = fullfile(subses_dir,'fmap');

    %determine number of each possible task (could be 0)
    scans = tdfread(sprintf('%s/sub-%02d_%sscans.tsv',subses_dir,sub,ses_tag), '\t');
    filenames = string(scans.filename);
    func_scans = cellstr(filenames(contains(filenames,'func/'),:));
    runs_per_task = zeros(size(intended_tasks));
    for task_i=1:length(intended_tasks)     
        task = intended_tasks{task_i};
        runs_per_task(task_i) = sum(contains(func_scans,[task,'_']));
    end

    %find json files to edit
    a = dir(fmap_dir);
    json_files = fullfile(fmap_dir,{a(contains({a.name},'.json')).name});

    %determine necessary edits
    json_field = cell(sum(runs_per_task),1);
    count = 0;
    for task_i = 1:length(intended_tasks)
        task = intended_tasks{task_i};
        for run_j = 1:runs_per_task(task_i)
            count = count + 1;
            if ses>0
                json_field{count} = sprintf('%s/sub-%02d_ses-%02d_task-%s_run-%02d_bold.nii.gz',...
                    func_dir,sub,ses,task,run_j);
            else
                json_field{count} = sprintf('%s/sub-%02d_task-%s_run-%02d_bold.nii.gz',...
                    func_dir,sub,task,run_j);
            end
        end
    end

    for ii=1:length(json_files)
        json = loadjson(json_files{ii});
        json.IntendedFor = char(json_field);
        savejson('',json,json_files{ii});
    end

end
