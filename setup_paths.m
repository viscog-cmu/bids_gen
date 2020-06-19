function success = setup_paths()
success = 0;
addpath(genpath('../bids_gen'))
addpath(genpath('../matlab_modules'))
spm_rmpath; % some conflicting functions from cosmomvpa need to be removed
addpath('../external/matlab_modules/spm12'); % cleanly add spm12
success = 1;

end
