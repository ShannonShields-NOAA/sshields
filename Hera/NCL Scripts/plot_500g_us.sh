#!/bin/bash
#SBATCH --account=ovp
#SBATCH --job-name=us_500g
#SBATCH --output=plot_us_500g.%j.out
#SBATCH -q batch
#SBATCH --nodes=1
#SBATCH --time=2:00:00

cd /scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/gfsv16/Feb132024storm/

/bin/rm -rf ./plot_us_500g_done

ncl 'scriptyyyymmddhh="2024020312"' 'eventname="Feb132024storm"' 'scriptregion="us"' 'fhr_inc="6"' 'fhr_start="240"' 'fhr_end="240"' 'images_path="/scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/gfsv16"' /scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/gfsv16/Feb132024storm/plot_gefs_lambert_500g.ncl

touch ./plot_us_500g_done

exit

