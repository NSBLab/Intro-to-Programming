import numpy as np
import pandas as pd

# define outdir
outdir = '/path/to/output/derivatives/directory'

# if you had less than 1000 subjects and did not have to split your sublist because of MASSIVE/slurm job quotas, run this
sublist = pd.read_csv('/path/to/sublist_fs.txt', delimiter=',', header=None).values.flatten()

# otherwise if you had more than 1000 subjects and multiple sublist files, just run this and comment out the previous code with #
#sublist1 = pd.read_csv('/path/to/sublist_fs_1.txt', delimiter=',', header=None).values.flatten()
#sublist2 = pd.read_csv('/path/to/sublist_fs_2.txt', delimiter=',', header=None).values.flatten()
#sublist = np.concatenate([sublist1, sublist2])


parcellation = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
metric_list = ['NumVert', 'SurfArea', 'GrayVol', 'ThickAvg', 'ThickStd', 'MeanCurv', 'GausCurv', 'FoldInd', 'CurvInd']

for metric in metric_list:
    for p in parcellation:
        group_array = pd.DataFrame()
        for sub in sublist:
            subject_data = pd.read_csv(f'{outdir}/{p}/{sub}.Schaefer2018_{p}Parcels_7Networks_order.txt', index_col='StructName')
            subject_data = subject_data.rename(columns={metric: sub})
            group_array = pd.concat([group_array, subject_data[sub]], axis=1)
        group_array = group_array.transpose()
        group_array.to_csv(f'{outdir}/{p}/group_{metric}.Schaefer2018_{p}Parcels_7Networks_order.csv')

# et voila

