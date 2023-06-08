# rewrite of bids_make_spm_multi_regression_files.m for python, ignoring the old format, and extending to allow for one-hot motion regression, and % variance-driven selection of number of CompCor components. does not support multiple session format currently.

import os
import sys
import numpy as np
import pandas as pd
import argparse
import glob
import pickle
import json
from scipy.spatial.distance import pdist, squareform

def analyze_confounds(confounds, confounds_json, compcorvar=None, compcornum=6, fdthresh=None, dvarthresh=None, frames=1, autooutlier=True):
    assert compcorvar is not None or compcornum is not None and not (compcorvar is not None and compcornum is not None), 'Must specify either compcorvar or compcornum, but not both'
    if compcorvar is not None:
        assert compcorvar <= .5, 'compcorvar must be less than or equal to .5'
        thresh_reached = False
        ii = 0
        while not thresh_reached:
            cumvar = confounds_json[f'a_comp_cor_{ii:02d}']['CumulativeVarianceExplained']
            if cumvar > compcorvar:
                thresh_reached = True
                compcornum = ii+1
            else:
                ii += 1
    translation = pdist(np.stack((confounds.trans_x, confounds.trans_y, confounds.trans_z),1))
    max_vals = {'max_translation':np.max(squareform(translation)[0,:]), 
                'max_FD': np.max(confounds.framewise_displacement), 
                'max_DVARS': np.max(confounds.std_dvars),
                'mean_DVARS': np.mean(confounds.std_dvars),
                'compcornum': compcornum,
                }
    all_confounds = [f'a_comp_cor_{ii:02d}' for ii in range(compcornum)]
    all_confounds += [f'trans_{ii}' for ii in ['x', 'y', 'z']]
    all_confounds += [f'rot_{ii}' for ii in ['x', 'y', 'z']]
    all_confounds += ['framewise_displacement']
    regressors = confounds[all_confounds].to_numpy()
    if fdthresh is not None or dvarthresh is not None:
        assert not autooutlier, 'Cannot specify both fdthresh/dvarthresh and autooutlier'
        fdthresh = np.inf if fdthresh is None else fdthresh
        dvarthresh = np.inf if dvarthresh is None else dvarthresh
        bad_tps = np.argwhere(
            np.logical_or(
                confounds.framewise_displacement.to_numpy() > fdthresh,
                confounds.std_dvars.to_numpy() > dvarthresh,
            )).flatten()
        exclude_tps = []
        if len(bad_tps) > 0:
            for tp in bad_tps:
                exclude_tps += list(range(tp-frames, tp+frames+1))
            exclude_tps = np.unique(exclude_tps)
            onehot_exclude_tps = np.eye(confounds['dvars'].shape[0])[:,exclude_tps]
            regressors = np.hstack((regressors, onehot_exclude_tps))
        max_vals['n_motion_outliers'] = len(exclude_tps)
    elif autooutlier:
        cols = [col for col in confounds.columns if 'motion_outlier' in col]
        regressors = np.hstack((regressors, confounds[cols].to_numpy()))
        max_vals['n_motion_outliers'] = len(cols)
    max_vals['n_confounds'] = regressors.shape[1]
    return pd.DataFrame(regressors), max_vals

def main(args):
    # compute backwards-compatible string tag for testing multiple versions of correction
    tag = ''
    if args.compcorvar is not None:
        tag += f'_ccvar-{args.compcorvar}'
    if args.compcornum != 6 and args.compcornum is not None:
        tag += f'_ccnum-{args.compcornum}'
    if args.fdthresh is not None:
        tag += f'_fdthresh-{args.fdthresh}'
    if args.autooutlier:
        tag += '_autooutlier'

    bids_dir = os.path.join(os.environ['BIDS'], args.experiment)
    sub_deriv_dir = os.path.join(bids_dir, 'derivatives', 'fmriprep', f'sub-{args.sub:02d}')
    out_dir = os.path.join(bids_dir, 'derivatives', 'matlab', 'spm', 'multiple_regressors', f'sub-{args.sub:02d}')
    for ii, task in enumerate(args.tasks):
        num_runs = len(glob.glob(f'{sub_deriv_dir}/func/*task-{task}*confounds_regressors.tsv'))
        for exp_run in range(1,num_runs+1):
            in_file = os.path.join(sub_deriv_dir, 'func', f'sub-{args.sub:02d}_task-{task}_run-{exp_run:02d}_desc-confounds_regressors.tsv')
            out_file = os.path.join(out_dir, f'sub-{args.sub:02d}_task-{task}_run-{exp_run:02d}{tag}_multiregressors.txt')
            if not os.path.exists(out_file) or args.overwrite:
                confounds = pd.read_csv(in_file, sep='\t')
                confounds_json = json.load(open(in_file.replace('.tsv', '.json')))
                regressors, max_vals = analyze_confounds(confounds, confounds_json,
                                                             compcorvar=args.compcorvar, compcornum=args.compcornum, fdthresh=args.fdthresh, frames=args.frames, autooutlier=args.autooutlier)
                regressors.to_csv(out_file, sep=',', index=False, header=False, float_format='%.7f')
                with open(out_file.replace('.txt', '_info.json'), 'w') as f:
                    json.dump(max_vals, f)
                print(f'wrote {out_file}')
                print(f'sub-{args.sub:02d}\ntask-{task}\nrun-{exp_run:02d}')
                for name, val in max_vals.items():
                    print(f'\t{name}: {val}')
            else:
                print(f'File {out_file} already exists, skipping')

parser = argparse.ArgumentParser(description='Generate SPM multi-regression files for BIDS dataset')
parser.add_argument('--experiment', type=str)
parser.add_argument('--sub', type=int)
parser.add_argument('--tasks', nargs='*', type=str)
parser.add_argument('--overwrite', action='store_true')
parser.add_argument('--compcorvar', type=float, default=None)
parser.add_argument('--compcornum', type=int, default=None)
parser.add_argument('--fdthresh', type=float, default=None, help='threshold for identifying outlier frames based on framewise displacement')
parser.add_argument('--dvarthresh', type=float, default=None, help='threshold for identifying outlier frames based on DVARS')
parser.add_argument('--frames', type=int, default=1, help='number of frames to exclude on each side of outlier frames')
parser.add_argument('--autooutlier', action='store_true', help='automatically identify outlier frames based FMRIPREP defaults of FD > 0.5, DVARS>1.5, frames=0')
args = parser.parse_args()

main(args)