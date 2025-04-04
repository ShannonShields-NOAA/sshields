#!/bin/sh

set -x

PDY=20250404 
echo $PDY > holdpdy.txt
pdy=`cut -c 1-8 holdpdy.txt`

pdym91=$(date -d "$pdy - 91 days" +"%Y%m%d")
echo "export PDYm91=$pdym91" > PDYplots
pdym32=$(date -d "$pdy - 32 days" +"%Y%m%d")
echo "export PDYm32=$pdym32" >> PDYplots
pdym2=$(date -d "$pdy - 2 days" +"%Y%m%d")
echo "export PDYm2=$pdym2" >> PDYplots

exit
