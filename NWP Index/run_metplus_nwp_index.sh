#!/bin/sh

set -x

source /lfs/h2/emc/vpppg/noscrub/shannon.shields/feature_subseasonal_python_test/EVS/versions/run.ver
module reset
module load prod_envir/${prod_envir_ver}
source /lfs/h2/emc/vpppg/noscrub/shannon.shields/feature_subseasonal_python_test/EVS/dev/modulefiles/global_det/global_det_stats.sh

export DATE=20250421
export RUN=atmos
export VERIF_CASE=grid2grid
export STEP=stats
export COMPONENT=global_det
export COMIN=/lfs/h2/emc/vpppg/noscrub/emc.vpppg/evs/v2.0/stats/global_det
export COMOUT=/lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index
export METPLUS_PATH=/apps/ops/para/libs/intel/19.1.3.304/metplus/6.0.0
export MET_ROOT=/apps/ops/para/libs/intel/19.1.3.304/met/12.0.1
export MET_TMP_DIR=/lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/tmp
export JOB_GROUP=calc_nwp_index
export MODEL=gfs
export REFERENCE=cfs

/apps/ops/para/libs/intel/19.1.3.304/metplus/6.0.0/ush/run_metplus.py -c /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/machine.conf -c /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/StatAnalysis_NWP_Index.conf

exit
