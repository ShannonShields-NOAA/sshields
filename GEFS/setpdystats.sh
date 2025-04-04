#!/bin/sh

set -x

PDY=20250404 
echo $PDY > holdpdy.txt
pdy=`cut -c 1-8 holdpdy.txt`

pdym40=$(date -d "$pdy - 40 days" +"%Y%m%d")
echo "export PDYm40=$pdym40" > PDYstats
pdym39=$(date -d "$pdy - 39 days" +"%Y%m%d")
echo "export PDYm39=$pdym39" >> PDYstats
pdym38=$(date -d "$pdy - 38 days" +"%Y%m%d")
echo "export PDYm38=$pdym38" >> PDYstats
pdym37=$(date -d "$pdy - 37 days" +"%Y%m%d")
echo "export PDYm37=$pdym37" >> PDYstats
pdym36=$(date -d "$pdy - 36 days" +"%Y%m%d")
echo "export PDYm36=$pdym36" >> PDYstats
pdym35=$(date -d "$pdy - 35 days" +"%Y%m%d")
echo "export PDYm35=$pdym35" >> PDYstats
pdym34=$(date -d "$pdy - 34 days" +"%Y%m%d")
echo "export PDYm34=$pdym34" >> PDYstats
pdym33=$(date -d "$pdy - 33 days" +"%Y%m%d")
echo "export PDYm33=$pdym33" >> PDYstats
pdym32=$(date -d "$pdy - 32 days" +"%Y%m%d")
echo "export PDYm32=$pdym32" >> PDYstats
pdym31=$(date -d "$pdy - 31 days" +"%Y%m%d")
echo "export PDYm31=$pdym31" >> PDYstats
pdym30=$(date -d "$pdy - 30 days" +"%Y%m%d")
echo "export PDYm30=$pdym30" >> PDYstats
pdym29=$(date -d "$pdy - 29 days" +"%Y%m%d")
echo "export PDYm29=$pdym29" >> PDYstats
pdym28=$(date -d "$pdy - 28 days" +"%Y%m%d")
echo "export PDYm28=$pdym28" >> PDYstats
pdym27=$(date -d "$pdy - 27 days" +"%Y%m%d")
echo "export PDYm27=$pdym27" >> PDYstats
pdym26=$(date -d "$pdy - 26 days" +"%Y%m%d")
echo "export PDYm26=$pdym26" >> PDYstats
pdym25=$(date -d "$pdy - 25 days" +"%Y%m%d")
echo "export PDYm25=$pdym25" >> PDYstats
pdym24=$(date -d "$pdy - 24 days" +"%Y%m%d")
echo "export PDYm24=$pdym24" >> PDYstats
pdym23=$(date -d "$pdy - 23 days" +"%Y%m%d")
echo "export PDYm23=$pdym23" >> PDYstats
pdym22=$(date -d "$pdy - 22 days" +"%Y%m%d")
echo "export PDYm22=$pdym22" >> PDYstats
pdym21=$(date -d "$pdy - 21 days" +"%Y%m%d")
echo "export PDYm21=$pdym21" >> PDYstats
pdym20=$(date -d "$pdy - 20 days" +"%Y%m%d")
echo "export PDYm20=$pdym20" >> PDYstats
pdym19=$(date -d "$pdy - 19 days" +"%Y%m%d")
echo "export PDYm19=$pdym19" >> PDYstats
pdym18=$(date -d "$pdy - 18 days" +"%Y%m%d")
echo "export PDYm18=$pdym18" >> PDYstats
pdym17=$(date -d "$pdy - 17 days" +"%Y%m%d")
echo "export PDYm17=$pdym17" >> PDYstats
pdym16=$(date -d "$pdy - 16 days" +"%Y%m%d")
echo "export PDYm16=$pdym16" >> PDYstats
pdym15=$(date -d "$pdy - 15 days" +"%Y%m%d")
echo "export PDYm15=$pdym15" >> PDYstats
pdym14=$(date -d "$pdy - 14 days" +"%Y%m%d")
echo "export PDYm14=$pdym14" >> PDYstats
pdym13=$(date -d "$pdy - 13 days" +"%Y%m%d")
echo "export PDYm13=$pdym13" >> PDYstats
pdym12=$(date -d "$pdy - 12 days" +"%Y%m%d")
echo "export PDYm12=$pdym12" >> PDYstats
pdym11=$(date -d "$pdy - 11 days" +"%Y%m%d")
echo "export PDYm11=$pdym11" >> PDYstats
pdym10=$(date -d "$pdy - 10 days" +"%Y%m%d")
echo "export PDYm10=$pdym10" >> PDYstats
pdym9=$(date -d "$pdy - 9 days" +"%Y%m%d")
echo "export PDYm9=$pdym9" >> PDYstats
pdym8=$(date -d "$pdy - 8 days" +"%Y%m%d")
echo "export PDYm8=$pdym8" >> PDYstats
pdym7=$(date -d "$pdy - 7 days" +"%Y%m%d")
echo "export PDYm7=$pdym7" >> PDYstats
pdym6=$(date -d "$pdy - 6 days" +"%Y%m%d")
echo "export PDYm6=$pdym6" >> PDYstats
pdym5=$(date -d "$pdy - 5 days" +"%Y%m%d")
echo "export PDYm5=$pdym5" >> PDYstats
pdym4=$(date -d "$pdy - 4 days" +"%Y%m%d")
echo "export PDYm4=$pdym4" >> PDYstats
pdym3=$(date -d "$pdy - 3 days" +"%Y%m%d")
echo "export PDYm3=$pdym3" >> PDYstats
pdym2=$(date -d "$pdy - 2 days" +"%Y%m%d")
echo "export PDYm2=$pdym2" >> PDYstats

exit
