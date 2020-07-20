
import nibabel as nib
import numpy as np
import argparse

def main(fname_L, fname_R, fname_M):
    L = nib.load(fname_L)
    R = nib.load(fname_R)
    M_data = np.concatenate((L.darrays[0].data, R.darrays[0].data))
    M_array = nib.gifti.gifti.GiftiDataArray(M_data)
    M_gii = nib.gifti.gifti.GiftiImage(darrays=[M_array])
    M_gii.to_filename(fname_M)
    print(f'merged {fname_M}')

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--fname-L')
    parser.add_argument('--fname-R')
    parser.add_argument('--fname-M')
    args = parser.parse_args()
    main(args.fname_L, args.fname_R, args.fname_M)
