#!/bin/sh

set -x

source /lfs/h2/emc/vpppg/noscrub/shannon.shields/feature_subseasonal_obs_title
_change/EVS/versions/run.ver
module reset
module load prod_envir/${prod_envir_ver}source /lfs/h2/emc/vpppg/noscrub/shannon.shields/feature_subseasonal_obs_title
_change/EVS/dev/modulefiles/global_det/global_det_stats.sh

date --date="2 days ago" +%Y%m%d > holddate.txt

ymd=`cut -c 1-8 holddate.txt`
echo $ymd

stat_analysis -lookin /lfs/h2/emc/vpppg/noscrub/emc.vpppg/evs/v2.0/stats/global_det/gfs.${ymd}/evs.stats.gfs.atmos.grid2grid.v${ymd}.stat \
/lfs/h2/emc/vpppg/noscrub/emc.vpppg/evs/v2.0/stats/global_det/cfs.${ymd}/evs.stats.cfs.atmos.grid2grid.v${ymd}.stat \
-out_stat /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/stats/evs.stats.gfs.nwpindex.grid2grid.v${ymd}.stat \
-tmp_dir /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/tmp \
-log /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/logs/test_global_det_statanalysis_nwp_index.log -v 3 -config /lfs/h2/emc/vpppg/noscrub/shannon.shields/NWP_index/STATAnalysisConfig_NWP_Index_test

exit
