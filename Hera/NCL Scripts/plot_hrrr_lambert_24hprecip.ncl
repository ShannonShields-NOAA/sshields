; ===========================================
; Plots 4-panel for GFS evaluation
; Created by: Alicia M. Bentley
; Last updated: 9 June 2020
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ===========================================
begin

print("======================")
print("Script has started!")
print("======================")

;================================================================

; Define casename
  if (isdefined("eventname")) then
        print("Eventname defined on command line: "+eventname)
        casename = eventname
  else
        print("No eventname defined on command line")
        casename = "eventname"
  end if

;==================================================================

; Define data_directory
  ;if (isdefined("images_path")) then
        ;print("images_path defined on command line: "+images_path)
        ;image_dir = images_path
  ;else
        ;print("No images_path defined on command line")
        ;image_dir = "images_path"
  ;end if

;==================================================================

; Pre-defined domain definitions
  minlatlist=(/15.0,35.0,25.0,31.0,40.0,25.5,35.0,42.0,41.0,34.0,41.0,34.0,24.5,12.5,10,20,1,-40,15,10,3,28.0,34.0/)
  maxlatlist=(/60.0,75.0,50.0,43.0,50.0,37.5,44.0,50.0,49.5,43.0,48.0,42.5,35.0,35,27,47.5,60,-1,62.5,29,35,36.0,43.0/)
  minlonlist=(/-135.0,160.0,-120,-125.0,-125.0,-108.0,-108.0,-110.0,-97.0,-97.0,-77.0,-86.0,-92.0,-105,-81,-95,110,137.5,-167.5,-171,-136,-86.0,-85.0/)
  maxlonlist=(/-60.0,250.0,-72.5,-105.0,-107.0,-90.0,-92.0,-95.0,-80.5,-83.0,-66.5,-72.0,-76.0,-72.5,-55,-57.5,179,192.5,-115,-141,-82,-75.0,-73.0/)
  regionlist=(/"us","ak","uszoom","sw","nw","t","cp","np","mw","ov","ne","ma","se","gom","pr","nwatl","wpac","spac","epac","hi","epactc","carolinas","carolex"/)
  if (isdefined("scriptregion")) then
     if (scriptregion .eq. "new")
        print("New domain requested. Script will fail if the following variables are not defined with command line arguments: regionname, minlat, minlon, maxlat, maxlon.")
        scriptregion=regionname
     else
        print("Domain defined on command line: "+scriptregion)
        scriptregion=str_lower(scriptregion)
     end if
  else
     scriptregion="us"
  end if
  do c=0,dimsizes(regionlist)-1
    if (regionlist(c).eq.scriptregion) then
      minlat=minlatlist(c)
      minlon=minlonlist(c)
      maxlat=maxlatlist(c)
      maxlon=maxlonlist(c)
    end if
  end do
 
; =================================================================

; Obtaining the date of the forecast requested 
  scriptyear=toint(str_get_cols(scriptyyyymmddhh,0,3))
  scriptmonth=toint(str_get_cols(scriptyyyymmddhh,4,5))
  scriptday=toint(str_get_cols(scriptyyyymmddhh,6,7))
  scripthour=toint(str_get_cols(scriptyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datemodel=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)

;===================================================================

;;; Check to see if starting forecast hour was defined with command line argument
  if (isdefined("fhr_start")) then
     print("Starting forecast defined on command line")
     fhrb = toint(fhr_start)
     startdate1=datemodel+fhrb
     startdate1@units=timeunits
     startints=ut_calendar(startdate1,0)
     datestart=ut_inv_calendar(toint(startints(:,0)),toint(startints(:,1)),toint(startints(:,2)),toint(startints(:,3)),0,0,timeunits,0)
  else
     datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  end if




;;; Check to see if ending forecast hour was defined with command line argument
  ;if (isdefined("fhr_end")) then
     ;print("Ending forecast defined on command line")
     ;fhr_diff = toint(fhr_end) - toint(fhr_start) 
     ;fhre = toint(fhr_diff)
  ;else
     ;fhre=toint(0)
  ;end if

  ;enddate1=datestart+fhre
  ;enddate1@units=timeunits
  ;endints=ut_calendar(enddate1,0)

  ;dateend=ut_inv_calendar(toint(endints(:,0)),toint(endints(:,1)),toint(endints(:,2)),toint(endints(:,3)),0,0,timeunits,0)
  ;datemodel@units=timeunits




;;; Check to see if forecast hour increment was defined with command line argument
  ;if (isdefined("fhr_inc")) then
     ;print("Forecast hour increment defined on command line")
     ;fhri = toint(fhr_inc)
  ;else
     ;fhri=6
  ;end if

  fdates=toint(datestart) ;ispan(toint(datestart),toint(dateend),fhri)
  fhours=toint(datestart)-toint(datemodel) ;ispan(toint(datestart)-toint(datemod;el),toint(dateend)-toint(datemodel),fhri)


    h=0 ;do h=0,dimsizes(fdates)-1
    print((/fhours(h)/))
    thisdate=fdates(h)
    thisdate@units=timeunits
    modelstrings=tostring(ut_calendar(thisdate,-3))
    ms=tostring(ut_calendar(datemodel,-3))
    ;model date (initialization)
    yearm=str_get_cols(ms,0,3)
    monthm=str_get_cols(ms,4,5)
    daym=str_get_cols(ms,6,7)
    hourm=str_get_cols(ms,8,9)
    mdhm=str_get_cols(ms,4,9)
    ymm=str_get_cols(ms,0,5)
    ymdm=str_get_cols(ms,0,7)
    ;date of forecast hour (valid time)
    year=str_get_cols(modelstrings,0,3)
    month=str_get_cols(modelstrings,4,5)
    day=str_get_cols(modelstrings,6,7)
    hour=str_get_cols(modelstrings,8,9)
    mdh=str_get_cols(modelstrings,4,9)
    ymd=str_get_cols(modelstrings,0,7)
    monthind=toint(month)
    months=(/"","January","February","March","April","May","June","July","August","September","October","November","December"/)

  print(" ")
  print("Int: YYYYMMDDHH (FXXX): "+ymdm+hourm+" (F"+sprinti("%0.3i",fhours(h))+")")
; ==========================================================================

;Obtaining HRRR fcst file
       hrrr_file ="/scratch2/NCEPDEV/stmp1/Shannon.Shields/data/MEG_20210715/"+ymdm+"/"+hourm+"/hrrr.t"+hourm+"z.wrfsfcf"+sprinti("%0.2i",fhours(h))+".grib2"
       if (isfilepresent(hrrr_file)) then
          print("HRRR fcst file found!")
       else
          print("HRRR fcst file is missing...")
          system("pwd")
       end if

       hrrr=addfile(hrrr_file,"r")

; ----------------------------------------------------------------------------------

  if (scriptregion .eq. "pr" .or. scriptregion .eq. "ak" .or. scriptregion .eq. "epac" .or. scriptregion .eq. "wpac" .or. scriptregion .eq. "spac" .or. scriptregion .eq. "us" .or. scriptregion .eq. "nwatl" .or. scriptregion .eq. "atl" .or. scriptregion .eq. "hi" .or. scriptregion .eq. "epactc") then
     CONUS_dom = False
  else
     CONUS_dom = True
  end if

print("scriptregion: "+scriptregion+" | CONUS_dom: "+CONUS_dom(0))

;-------------

;if (CONUS_dom .eq. True) then

       ;print("CONUS_dom .eq. True, so looking for Stage-IV analysis...")

       ;anlfile = "../analyses/ST4."+modelstrings+".06h.grb"
       ;if (isfilepresent(anlfile)) then
          ;print("Stage-IV analysis file found!")
       ;else
          ;print("Stage-IV analysis file is missing...")
          ;system("pwd")
       ;end if

       ;anl=addfile(anlfile,"r")

;else if (CONUS_dom .eq. False) then

       ;print("CONUS_dom .eq. False, so looking for GFS analysis...")

;print("thisdate: "+thisdate)
;thisdate_m6h = thisdate
;thisdate_m6h = thisdate - 6
;print("thisdate_m6h: "+thisdate_m6h)

    ;newstrings=tostring(ut_calendar(thisdate_m6h,-3))
    ; GFS precip analysis date (6h forecast from 6 hours before)
    ;nyear=str_get_cols(newstrings,0,3)
    ;nmonth=str_get_cols(newstrings,4,5)
    ;nday=str_get_cols(newstrings,6,7)
    ;nhour=str_get_cols(newstrings,8,9)
    ;nmdh=str_get_cols(newstrings,4,9)
    ;nymd=str_get_cols(newstrings,0,7)
    ;nmonthind=toint(nmonth)

  ;print("Analysis Date: YYYYMMDDHH (FXXX): "+nymd+nhour+" (F006))")

       ;anlfile ="../analyses/gfs."+nymd+".t"+nhour+"z.pgrb2.0p25.f006.grib2"
       ;print("anlfile: "+anlfile)

       ;if (isfilepresent(anlfile)) then
          ;print("GFS analysis file found!")
       ;else
          ;print("GFS analysis file is missing...")
       ;end if

       ;anl=addfile("../analyses/gfs."+nymd+".t"+nhour+"z.pgrb2.0p25.f006.grib2";,"r")

;end if
;end if


; ============================================================================
; ======================= Download data ======================================
; ============================================================================ 

   print("h: "+h+" fhours(h): "+fhours(h))

;if (h.eq.0) then
  ;gfsv15_array = new((/dimsizes(fdates),721,1440/),float)
  ;gfsv16_array = new((/dimsizes(fdates),721,1440/),float)
  ;gfsanl_array = new((/dimsizes(fdates),721,1440/),float)
  ;st4anl_array = new((/dimsizes(fdates),881,1121/),float)
;end if

   if (fhours(h).eq.0) then
      precipprod=prod_gfs->TMP_P0_L103_GLL0({2},:,:)
      precippara=para_gfs->TMP_P0_L103_GLL0({2},:,:)
      precipprod=precipprod*0.0
      precippara=precippara*0.0
      gfsv15_array(h,:,:) = precipprod
      gfsv16_array(h,:,:) = precippara

      precipplotprod=precipprod
      precipplotpara=precippara
      precipplot_anl=precipprod

      precipplotprod=gfsv15_array(0,:,:)
      precipplotpara=gfsv16_array(0,:,:)
      precipplot_anl=precipplotprod


   else if (fhours(h).eq.6) then
      precipprod=prod_gfs->APCP_P8_L1_GLL0_acc
      precippara=para_gfs->APCP_P8_L1_GLL0_acc
      precipprod=precipprod*.03937
      precippara=precippara*.03937
      gfsv15_array(h,:,:) = precipprod
      gfsv16_array(h,:,:) = precippara

      precipplotprod=precipprod
      precipplotpara=precippara
      precipplot_anl=precipprod

      precipplotprod=gfsv15_array(0,:,:)
      precipplotpara=gfsv16_array(0,:,:)
      precipplot_anl=precipplotprod


   else if (fhours(h).gt.6 .and. fhours(h).lt.24) then
   
     var = "APCP_P8_L1_GLL0_acc"+fhours(h)+"h"
     print("var: "+var)

      precipprod=prod_gfs->$var$
      precippara=para_gfs->$var$
      precipprod=precipprod*.03937
      precippara=precippara*.03937
      gfsv15_array(h,:,:) = precipprod
      gfsv16_array(h,:,:) = precippara

      precipplotprod=precipprod
      precipplotpara=precippara
      precipplot_anl=precipprod

      precipplotprod=gfsv15_array(0,:,:)
      precipplotpara=gfsv16_array(0,:,:)
      precipplot_anl=precipplotprod


   else if (fhours(h).ge.24) then

     var = "APCP_P8_L1_GLC0_acc"+fhours(h)+"h"
     print("var: "+var)

      precipprod=hrrr->$var$
      fhrp=fhrb-24
      print(fhrp)
      hrrrp_file ="/scratch2/NCEPDEV/stmp1/Shannon.Shields/data/MEG_20210715/"+ymdm+"/"+hourm+"/hrrr.t"+hourm+"z.wrfsfcf"+fhrp+".grib2"
       if (isfilepresent(hrrrp_file)) then
          print("HRRR previous fcst file found!")
       else
          print("HRRR previous fcst file is missing...")
          system("pwd")
       end if
      hrrrp=addfile(hrrrp_file,"r")
      varp = "APCP_P8_L1_GLC0_acc"+fhrp+"h"
      print("var: "+varp)
      precipprodp=hrrrp->$varp$
      precipplotprod=precipprod-precipprodp
      precipplotprod=precipplotprod*.03937
      lat2d = hrrr->gridlat_0
      lon2d = hrrr->gridlon_0
      precipplotprod@lat2d = lat2d
      precipplotprod@lon2d = lon2d
      ;gfsv15_array(h,:,:) = precipprod

      ;precipplotprod=precipprod
      ;precipplotpara=precippara

      ;precipplotprod=gfsv15_array(h,:,:)-gfsv15_array(h-4,:,:)
      ;precipplotpara=gfsv16_array(h,:,:)-gfsv16_array(h-4,:,:)

   end if
   end if
   end if
   end if



      ;if (CONUS_dom .eq. True) then

    ;st4_date = cd_inv_calendar(2020,7,19,00,00,00,timeunits,0)      ; Specify d;ate formating changed
;    print("st4_date: "+st4_date)
    ;cur_date = cd_inv_calendar(toint(year),toint(month),toint(day),toint(hour),;00,00,timeunits,0)
;    print("cur_date: "+cur_date)

          ;if (fhours(h).eq.0) then

             ;if (cur_date .lt. st4_date) then
                 ;precip_anl=anl->A_PCP_GDS5_SFC_acc6h(:,:)
                 ;precip_anl=precip_anl*0.0
                 ;lat2d = anl->g5_lat_0
                 ;lon2d = anl->g5_lon_1
             ;else
                 ;precip_anl=anl->APCP_P8_L1_GST0_acc(:,:)
                 ;precip_anl=precip_anl*0.0
                 ;lat2d = anl->gridlat_0
                 ;lon2d = anl->gridlon_0
             ;end if
             ;precip_anl@lat2d = lat2d
             ;precip_anl@lon2d = lon2d
             ;st4anl_array(h,:,:) = precip_anl

          ;else if (fhours(h).ge.6) then
             ;if (cur_date .lt. st4_date) then
                 ;precip_anl=anl->A_PCP_GDS5_SFC_acc6h(:,:)
                 ;precip_anl=precip_anl*.03937
                 ;lat2d = anl->g5_lat_0
                 ;lon2d = anl->g5_lon_1
             ;else
                 ;precip_anl=anl->APCP_P8_L1_GST0_acc(:,:)
                 ;precip_anl=precip_anl*.03937
                 ;lat2d = anl->gridlat_0
                 ;lon2d = anl->gridlon_0
             ;end if
             ;precip_anl@lat2d = lat2d
             ;precip_anl@lon2d = lon2d
             ;st4anl_array(h,:,:) = precip_anl+st4anl_array(h-1,:,:)
;             printMinMax(st4anl_array(h,:,:),True)

             ;if (fhours(h).ge.24) then
                 ;precipplot_anl:=st4anl_array(h,:,:)-st4anl_array(h-4,:,:)
                 ;printMinMax(precipplot_anl,True)
;                 lat2d = anl->g5_lat_0
;                 lon2d = anl->g5_lon_1
                 ;precipplot_anl@lat2d = lat2d
                 ;precipplot_anl@lon2d = lon2d
             ;end if

          ;end if
          ;end if


      ;else if (CONUS_dom .eq. False) then

          ;if (fhours(h).eq.0) then
             ;precip_anl=anl->APCP_P8_L1_GLL0_acc
             ;precip_anl=precip_anl*0.0
             ;gfsanl_array(h,:,:) = precip_anl

          ;else if (fhours(h).ge.6) then

             ;precip_anl=anl->APCP_P8_L1_GLL0_acc
             ;precip_anl=precip_anl*.03937
             ;gfsanl_array(h,:,:) = precip_anl+gfsanl_array(h-1,:,:)

             ;if (fhours(h).ge.24) then
                 ;precipplot_anl=gfsanl_array(h,:,:)-gfsanl_array(h-4,:,:)
             ;end if

          ;end if
          ;end if

      ;end if
      ;end if



;-----------------
   ;dif = precipplotprod
   ;dif = precipplotpara - precipplotprod

;   dif_anl = slp_anl
;   dif_anl = slppara - slp_anl

;   slpprod = smth9_Wrap(slpprod,0.50,-0.25,False)
;   slppara = smth9_Wrap(slppara,0.50,-0.25,False)
;   slp_anl = smth9_Wrap(slp_anl,0.50,0.25,False)


; ============================================================================
; ======================= Make plot ==========================================
; ============================================================================
plot_dir = "/scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/gfsv16/"+casename+"/images/"+ymd+hour+"/"
system("mkdir -p "+plot_dir)

  wks  = gsn_open_wks("png", plot_dir+"hrrr_"+scriptregion+"_24hprecip_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h)))       
  ;gsn_define_colormap(wks,"BlueWhiteOrangeRed") 
  gsn_define_colormap(wks,"temp")
  ;gsn_define_colormap(wks,"MPL_jet") 

  plot=new(1,"graphic")

  res  = True

  res@mpMinLatF                = minlat
  res@mpMaxLatF                = maxlat
  res@mpMinLonF                = minlon
  res@mpMaxLonF                = maxlon
  ;res@mpOutlineBoundarySets="AllBoundaries"
  res@mpOutlineBoundarySets="GeophysicalAndUSStates"
  res@mpDataBaseVersion="MediumRes"
  res@gsnMaximize=True
  res@tmXBLabelFontHeightF=.008
  res@tmYLLabelFontHeightF=.008
  res@gsnRightString="24-h QPF (in.)"
  res@gsnAddCyclic=False
  res@gsnLeftString="HRRR fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.3i",fhours(h))+")"
  res@mpOutlineDrawOrder="PostDraw"
  res@mpFillColor="grey75"
  res@cnInfoLabelOn=False
  res@mpFillDrawOrder="PreDraw"
  res@cnLabelMasking=True
  res@mpGeophysicalLineColor="black"
  res@mpGeophysicalLineThicknessF=2.0
  res@mpNationalLineThicknessF=2.0
  ;res@cnRasterSmoothingOn=True
  res@mpUSStateLineThicknessF=2.0
  res@mpCountyLineThicknessF=.5
  ;res@mpUSStateLineThicknessF=3.0
  res@mpNationalLineColor="black"
  res@mpUSStateLineColor="black"
  res@cnLineLabelsOn=False
  res@pmLabelBarHeightF=.07 ;.05
  res@pmLabelBarOrthogonalPosF=-0.016
  res@lbLabelFontHeightF=.013 ;.008
  res@gsnLeftStringFontHeightF=.012 ;.01
  res@gsnRightStringFontHeightF=.012 ;.01
  res@cnFillOn=True
  res@mpFillOn=True
  res@cnFillMode="RasterFill"
  res@cnRasterSmoothingOn=True
  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
  res@cnLinesOn=True
  res@mpLimitMode="LatLon"
  res@gsnDraw=False
  ;res@mpProjection="Mercator"
  res@mpProjection="LambertConformal"
  if scriptregion.eq."spac" then
     res@mpLambertParallel1F = -33.0         ; two parallels
     res@mpLambertParallel2F = -45.0
  else
     res@mpLambertParallel1F = 33.0         ; two parallels
     res@mpLambertParallel2F = 45.0
  end if

  res@mpLambertMeridianF  = -95.0        ; central meridian
  if scriptregion.eq."ak" .or. scriptregion.eq."epac" then
    res@mpLambertMeridianF  = 215.0        ; central meridian
  else if scriptregion.eq."wpac" then
    res@mpLambertMeridianF  = 145.0        ; central meridian
  else if scriptregion.eq."spac" then
    res@mpLambertMeridianF  = 160.0        ; central meridian
  else if scriptregion.eq."pr" then
    res@mpLambertMeridianF  = 294.0        ; central meridian
  else if scriptregion.eq."atl" then
    res@mpLambertMeridianF  = 355.0        ; central meridian
    res@gsnAddCyclic =  True
  else if scriptregion.eq."hi" then
    res@mpLambertMeridianF  = 202.0        ; central meridian
  else if scriptregion.eq."epactc" then
    res@mpLambertMeridianF  = 260.0        ; central meridian
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  res@mpLimitMode         = "LatLon"
  res@lbLabelStride=1
  res@cnLinesOn=False
  res@lbLabelAutoStride=False ;True
  res@gsnFrame=False
   res@lbLabelBarOn=True
  if scriptregion.eq."us" then
    res@mpNationalLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF=2.0
  end if

;; Change Contour Levels Here
;; Last line without a semicolon will be used in all plots
; res@cnLevels=(/.01,0.50,1.00,1.50,2.00,3.0,4.00,5.0,6.00,8.0,10.,15.0,20.0,25.0,30.0,35.0,40.0,45.0,50.0,60.0/)
; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.00,1.5,2.00,3.0,4.00,5.00,6.0,8.00,10.0,15.0,20.0,25.0,30.0,40.0,45.0/)
; res@cnLevels=(/.01,0.10,0.25,0.50,1.00,1.50,2.0,3.00,4.0,5.00,6.0,7.0,8.00,9.00,10.0,15.0,17.5,20.0,25.0,30.0/)
 ;res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0,14.0,16.0,18.0,20.0/)
; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.00,4.00,5.00,6.00,7.00,7.50,8.00,9.00,10.0/)
  res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0/)

  res@cnLineLabelInterval=1
  res@cnLineLabelDensityF=1.5
  plot(0) = gsn_csm_contour_map(wks,precipplotprod,res)  ; create a default plot

;---------------------------------------------------------------------

  ;res@gsnLeftString="GFSv16 fcst init. "+hourm+"Z "+daym+" "+months(toint(month;m))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F";+sprinti("%0.2i",fhours(h))+")"
  ;plot(1) = gsn_csm_contour_map(wks,precipplotpara,res) ; create a default plot

;-------------------------------------------------

  ;resdif=True
  ;resdif=res
  ;resdif@cnFillPalette=("BlueWhiteOrangeRed")
  ;delete(resdif@cnFillColors)
  ;delete(resdif@cnLevels)
  ;resdif@cnLevels:=(/-3,-2,-1.5,-1,-.75,-.5,-.25,-.1,0,.1,.25,.5,.75,1,1.5,2,3/;)
  ;resdif@gsnLeftString="GFSv16 fcst minus GFSv15 fcst valid "+hour+"Z "+day+ " ;"+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  ;plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

; -----------------------------------------------

  if (CONUS_dom .eq. True) then
     model_string = "Stage-IV"
     ;print("Plotting Stage-IV takes a long time...")
  else if (CONUS_dom .eq. False) then
     model_string = "GFS"
  end if
  end if

  ;res@gsnLeftString=model_string+" analysis valid "+hour+"Z "+day+ " "+months(m;onthind)+ " " +year
  ;plot(3) = gsn_csm_contour_map(wks,precipplot_anl,res) ; create a default plot

;-------------------------------------------------

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  resP@gsnFrame=False
  gsn_panel(wks,plot,(/1,1/),resP)
 
print("Framing figure")
frame(wks)
print("Deleting workstation")
delete(wks)

system("convert "+plot_dir+"hrrr_"+scriptregion+"_24hprecip_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h))+".png -trim +repage "+plot_dir+"hrrr_"+scriptregion+"_24hprecip_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h))+".png")              

;end do

;------------------------------------------------

print("======================")
print("Script has finished!")
print("======================")


end



