load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;; domain definitions
;; new domains could be defined by adding entries in the next 5 lines
  minlatlist=(/15.0,35.0,25.0,31.0,40.0,25.5,35.0,42.0,41.0,34.0,41.0,34.0,24.5,12.5,10,20,1,-40,15,35.0,42.0,28.0,34.0/)
  maxlatlist=(/60.0,75.0,50.0,43.0,50.0,37.5,44.0,50.0,49.5,43.0,48.0,42.5,35.0,35,27,47.5,60,-1,62.5,47.0,49.1,36.0,43.0/)
  minlonlist=(/-135.0,160.0,-120,-125.0,-125.0,-108.0,-108.0,-110.0,-97.0,-97.0,-77.0,-86.0,-92.0,-105,-81,-95,110,137.5,-167.5,-85.0,-127.3,-86.0,-85.0/)
  maxlonlist=(/-60.0,250.0,-72.5,-105.0,-107.0,-90.0,-92.0,-95.0,-80.5,-83.0,-66.5,-72.0,-76.0,-72.5,-55,-57.5,179,192.5,-115,-69.0,-116.3,-75.0,-73.0/)
  regionlist=(/"us","ak","uszoom","sw","nw","t","cp","np","mw","ov","ne","ma","se","gom","pr","nwatl","wpac","spac","epac","nema","nwzoom","carolinas","carolex"/)
  if (isdefined("scriptregion")) then
     if (scriptregion .eq. "new")
        print("New domain requested. Script will fail if the following variables are not defined with command line arguments: regionname, minlat, minlon, maxlat, maxlon.")
        scriptregion=str_lower(regionname)
     else
        print("domain defined on command line")
        scriptregion=str_lower(scriptregion)
     end if
  else
     scriptregion="uszoom"
  end if
  do c=0,dimsizes(regionlist)-1
    if (regionlist(c).eq.scriptregion) then
      minlat=minlatlist(c)
      minlon=minlonlist(c)
      maxlat=maxlatlist(c)
      maxlon=maxlonlist(c)
    end if
  end do


  scriptyear=toint(str_get_cols(scriptyyyymmddhh,0,3))
  scriptmonth=toint(str_get_cols(scriptyyyymmddhh,4,5))
  scriptday=toint(str_get_cols(scriptyyyymmddhh,6,7))
  scripthour=toint(str_get_cols(scriptyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datemodel=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)



  variables=(/"slp","250wind","500","850wind","850t","2mt","2mdew","10mwind","sfcgust", \
              "shear","cape","pw","cloud","skin","sst","6hprecip","24hprecip","totalprecip", \
              "ptype", "6hsnod","24hsnod","totalsnod","6hweasd","24hweasd","totalweasd"/)

  if (isdefined("variable")) then
     print("variable defined on command line")
     var_str=str_lower(variable)
  else
     print("Must define variable on command line")
     exit()
  end if

; if (any(var_str .ne. variables(:))) then
;    print("WARNING! Requested variable will not plot. Check variable string.")
; end if

  plot_contours = False
  plot_barbs = False
  if (var_str .eq. "slp" .or. var_str .eq. "500" .or. var_str .eq. "850t" .or. var_str .eq. "2mt") then
     plot_contours = True
  else if (str_get_cols(var_str,-4,-1) .eq. "wind" .or. var_str .eq. "shear") then
     plot_barbs = True
  end if
  end if


  nohrsc_change_date1 = cd_inv_calendar(2016,9,30,12,00,00,timeunits,0)   ; Specify date when 24-h NOHRSC GRIB2 analyses become available
  nohrsc_change_date2 = cd_inv_calendar(2017,9,26,00,00,00,timeunits,0)   ; Specify date when 6-h NOHRSC analyses become available
  plot_NAM = False
  plot_ST4 = False
  plot_NOHRSC = False
  plot_URMA = False
  plot_WXT = False
  ;if (str_get_cols(var_str,-6,-1) .eq. "precip") then
     ;plot_ST4 = True
  ;end if
  if ((str_get_cols(var_str,-4,-1) .eq. "snod") .or. (str_get_cols(var_str,-5,-1) .eq. "weasd")) then
     plot_NOHRSC = True
  end if
  if (var_str .eq. "cloud") then
     plot_URMA = True
  end if
  if (var_str .eq. "ptype") then
     plot_WXT = True
  end if
  if (str_get_cols(var_str,0,2) .eq. "850" .or. str_get_cols(var_str,0,1) .eq. "2m" .or. var_str .eq. "10mwind" .or. var_str .eq. "sfcgust" .or. var_str .eq. "shear" .or. var_str .eq. "cape" .or. var_str .eq. "skin" .or. var_str .eq. "sst") then
     plot_NAM = False
  end if


  if (isdefined("diff")) then
     diff_str=str_lower(diff)
     if ((diff_str .eq. "anl1") .or. (diff_str .eq. "anl2")) then
        plot_diff = True
     else
        print("WARNING! Bad difference string passed in. Retry to plot difference plots.")
        exit()
     end if
  else
     plot_diff = False
  end if


  if ((plot_ST4 .or. plot_NOHRSC .or. plot_URMA .or. plot_WXT) .and. plot_diff) then
     print("WARNING! Can't plot difference using precip/snow/cloud analysis. Exiting.")
     exit()
  end if
  if ((var_str .eq. "skin") .and. plot_diff) then
     print("WARNING! Can't plot difference using skin temp analysis. Exiting.")
     exit()
  end if






;;; check to see if starting forecast hour was defined with command line argument
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


;;; check to see if ending forecast hour was defined with command line argument
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

;;; check to see if forecast hour increment was defined with command line argument
  ;if (isdefined("fhr_inc")) then
     ;print("Forecast hour increment defined on command line")
     ;fhri = toint(fhr_inc)
  ;else
     ;fhri=6
  ;end if

  fdates=toint(datestart) ;ispan(toint(datestart),toint(dateend),fhri)
  fhours=toint(datestart)-toint(datemodel) ;ispan(toint(datestart)-toint(datemod;el),toint(dateend)-toint(datemodel),fhri)


  count = 0
  date_array=new((/2/),string)
  if (var_str .eq. "24hprecip") then
     field1_array=new((/4,721,1440/),float)
     field2_array=new((/4,721,1440/),float)
     field3_array=new((/4,721,1440/),float)
     ec_array=new((/dimsizes(fdates),721,1440/),float)
     anlfield2_array=new((/4,881,1121/),float)
  else if (var_str .eq. "totalprecip") then
     field1_array=new((/dimsizes(fhours),721,1440/),float)
     field2_array=new((/dimsizes(fhours),721,1440/),float)
     field3_array=new((/dimsizes(fhours),721,1440/),float)
     field4_array=new((/dimsizes(fhours),721,1440/),float)
     anlfield2_array=new((/dimsizes(fhours),881,1121/),float)
     field1_array=0.
     field2_array=0.
     field3_array=0.
     field4_array=0.
     anlfield2_array=0.
  else if ((str_get_cols(var_str,-4,-1) .eq. "snod") .or. (str_get_cols(var_str,-5,-1) .eq. "weasd")) then
     field1_array=new((/dimsizes(fhours),721,1440/),float)
     field2_array=new((/dimsizes(fhours),721,1440/),float)
     field3_array=new((/dimsizes(fhours),721,1440/),float)
     field4_array=new((/dimsizes(fhours),721,1440/),float)
     if (datemodel .ge. nohrsc_change_date1) then
        anlfield2_array=new((/dimsizes(fhours),1377,2145/),float)
     else
        anlfield2_array=new((/dimsizes(fhours),850,1500/),float)
     end if
     anlfield2_array=0.
  end if
  end if
  end if


    h=0 ;do h=0,dimsizes(fdates)-1
    print((/fhours(h)/))
    thisdate=fdates(h)
    thisdate@units=timeunits
    modelstrings=tostring(ut_calendar(thisdate,-3))
    ms=tostring(ut_calendar(datemodel,-3))

    ;model date  (initialization time)
    yearm=str_get_cols(ms,0,3)
    monthm=str_get_cols(ms,4,5)
    daym=str_get_cols(ms,6,7)
    hourm=str_get_cols(ms,8,9)
    mdhm=str_get_cols(ms,4,9)
    ymdm=str_get_cols(ms,0,7)

    ;date of forecast hour   (valid time)
    year=str_get_cols(modelstrings,0,3)
    month=str_get_cols(modelstrings,4,5)
    day=str_get_cols(modelstrings,6,7)
    hour=str_get_cols(modelstrings,8,9)
    mdh=str_get_cols(modelstrings,4,9)
    ymd=str_get_cols(modelstrings,0,7)
    monthind=toint(month)

    if (fhours(h) .eq. 0) then
       date_array(:) = modelstrings
    else
       date_array(1) = modelstrings
    end if 

    ;date of forecast hour   (previous valid time - for URMA panels)
    ;year0=str_get_cols(date_array(0),0,3)
    ;month0=str_get_cols(date_array(0),4,5)
    ;day0=str_get_cols(date_array(0),6,7)
    ;hour0=str_get_cols(date_array(0),8,9)
    ;mdh0=str_get_cols(date_array(0),4,9)
    ;ymd0=str_get_cols(date_array(0),0,7)
    ;monthind0=toint(month0)

    months=(/"","January","February","March","April","May","June","July","August","September","October","November","December"/)
    ;months=(/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","No;v","Dec"/)

    ;date_array(0) = modelstrings

print(" ")
  print("Int: YYYYMMDDHH (FXXX): "+ymdm+hourm+" (F"+sprinti("%0.3i",fhours(h))+")")

;;;;;Obtaining ECMWF fcst file 

    anl_str1 = "EC"
    ;if ((mod(fhours(h),12) .eq. 0) .and. (plot_ST4 .eq. False) .and. (plot_NOHR;SC .eq. False) .and. (plot_URMA .eq. False)) then
       plot_EC = True
   ; else
       ;plot_EC = False
       ;if ((plot_ST4 .eq. False) .and. (plot_NOHRSC .eq. False) .and. (plot_URM;A .eq. False)) then
          ;print("skipping "+anl_str1+" - no analysis")
       ;end if
    ;end if

    if (plot_EC) then
       ecfile = "/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gfsv16/elsa/"+ms+"/ecmwf/U1D07"+daym+hourm+"0007"+day+hour+"001.grb"
       if (isfilepresent(ecfile)) then
          print("found "+anl_str1+" file")
          ec=addfile(ecfile,"r")
       else
          print(anl_str1+" file not found. Retrieve data and rerun.")
          exit()
       end if
    else if (plot_URMA) then
       anl_str1 = "URMA"
       anlfile1 = "urma2p5."+ymd0+".t"+hour0+"z.2dvaranl_ndfd.grb2"
       if (isfilepresent(anlfile1)) then
          print("found "+anl_str1+" analysis file")
          anl1=addfile(anlfile1,"r")
       else
          print(anl_str1+" analysis file not found. Retrieve data and rerun.")
          exit()
       end if
    end if
    end if



    if (plot_NAM) then
       anl_str2 = "NAM"
       anlfile2 = "nam."+ymd+".t"+hour+"z.awip3200.tm00.grib2"
    else if (plot_ST4) then
       anl_str1 = "Stage IV"
       anl_str2 = "Stage IV"
       anlfile2 = "ST4."+modelstrings+".06h.grb"
    else if (plot_NOHRSC) then
       anl_str1 = "NOHRSC"
       anl_str2 = "NOHRSC"
       if (datemodel .ge. nohrsc_change_date2) then
          anlfile2 = "sfav2_CONUS_6h_"+modelstrings+"_grid184.grb2"
       else if ((datemodel .ge. nohrsc_change_date1) .and. (datemodel .lt. nohrsc_change_date2)) then
          anlfile2 = "sfav2_CONUS_24h_"+modelstrings+"_grid184.grb2"
       else if (datemodel .lt. nohrsc_change_date1) then
          anlfile2 = "sfav2_CONUS_24h_"+modelstrings+".nc"
       end if
       end if
       end if
    else if (plot_URMA) then
       anl_str2 = "URMA"
       anlfile2 = "urma2p5."+ymd+".t"+hour+"z.2dvaranl_ndfd.grb2"
    else
       anl_str2 = "GFS"
       anlfile2 = "gfs."+ymd+".t"+hour+"z.pgrb2.0p25.f000.grib2"
    end if
    end if
    end if
    end if

    if (isfilepresent(anlfile2)) then
       print("found "+anl_str2+" analysis file")
       anl2=addfile(anlfile2,"r")
    else if ((plot_ST4 .or. plot_NOHRSC .or. plot_URMA) .and. fhours(h) .eq. 0) then
       print("0-hr forecast. Skipping "+anl_str2+" analysis for now.")
    else if ((plot_NOHRSC) .and. (datemodel .lt. nohrsc_change_date2) .and. (str_get_cols(var_str,0,1) .eq. "6h")) then 
       print(anl_str2+" analysis does not exist. Analysis will not plot")
    else if ((plot_NOHRSC) .and. ((datemodel .ge. nohrsc_change_date1) .and. (datemodel .lt. nohrsc_change_date2)) .and. (str_get_cols(var_str,0,4) .eq. "total") .and. (mod(fhours(h),24) .ne. 0)) then 
       print(anl_str2+" analysis does not exist. Analysis will not plot")
    else if ((plot_NOHRSC) .and. ((datemodel .ge. nohrsc_change_date1) .and. (datemodel .lt. nohrsc_change_date2)) .and. (str_get_cols(var_str,0,2) .eq. "24h") .and. (mod(fhours(h),12) .ne. 0)) then 
       print(anl_str2+" analysis does not exist. Analysis will not plot")
    else if ((plot_NOHRSC) .and. (datemodel .lt. nohrsc_change_date1) .and. ((str_get_cols(var_str,0,2) .eq. "24h") .or. (str_get_cols(var_str,0,4) .eq. "total")) .and. (mod(fhours(h),24) .ne. 0) .and. (scripthour .eq. 12)) then 
       print(anl_str2+" analysis does not exist. Analysis will not plot")
    else if ((plot_NOHRSC) .and. (datemodel .lt. nohrsc_change_date1) .and. ((str_get_cols(var_str,0,2) .eq. "24h") .or. (str_get_cols(var_str,0,4) .eq. "total")) .and. (mod(fhours(h),24) .eq. 0) .and. (scripthour .ne. 12)) then 
       print(anl_str2+" analysis does not exist. Analysis will not plot")
    else
       ;print(anl_str2+" analysis not found")
       ;exit()
    end if
    end if
    end if
    end if
    end if
    end if
    end if

plot_dir = "/scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/ecmwf/images/Elsa/"+ymd+hour+"/"
system("mkdir -p "+plot_dir)
  
  if (plot_diff) then
     graphic_name = "physics_eval_"+scriptregion+"_"+var_str+"_diff"+str_get_cols(diff_str,3,3)+"_"+ms+"_"+sprinti("%0.1i",(h))
  else
     graphic_name = plot_dir+"/ec_"+scriptregion+"_"+var_str+"_"+ms+"_Elsa_"+sprinti("%0.3i",fhours(h))
  end if
  wks = gsn_open_wks("png",graphic_name)         ; open a png file
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
  res@gsnAddCyclic=False
  res@mpOutlineDrawOrder="PostDraw"
  res@mpFillColor="grey75"
  res@cnInfoLabelOn=False
  res@mpFillDrawOrder="PreDraw"
  res@cnLabelMasking=True
  res@mpGeophysicalLineColor="black"
  res@mpGeophysicalLineThicknessF=2.0
  res@mpNationalLineThicknessF=2.0
  ;res@cnFillMode="RasterFill"
  ;res@cnRasterSmoothingOn=True
  res@mpUSStateLineThicknessF=2.0
  res@mpCountyLineThicknessF=.5
  ;res@mpUSStateLineThicknessF=3.0
  res@mpNationalLineColor="black"
  res@mpUSStateLineColor="black"
  res@cnLineLabelsOn=False
  res@pmLabelBarHeightF=.07
  res@pmLabelBarOrthogonalPosF=-0.016
  res@lbLabelFontHeightF=.013
  res@gsnLeftStringFontHeightF=.012
  res@gsnRightStringFontHeightF=.012
  res@cnFillOn=True
  res@mpFillOn=True
  res@cnFillMode="RasterFill"
  res@cnRasterSmoothingOn=True
  res@cnLevelSelectionMode="ExplicitLevels"
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
  else if scriptregion.eq."wpac" .or. scriptregion .eq. "japan" then
    res@mpLambertMeridianF  = 145.0        ; central meridian
  else if scriptregion.eq."spac" then
    res@mpLambertMeridianF  = 160.0        ; central meridian
  else if scriptregion.eq."pr" then
    res@mpLambertMeridianF  = 294.0        ; central meridian
  else if scriptregion.eq."hawaii" then
    res@mpLambertMeridianF  = 205.0        ; central meridian
  end if
  end if
  end if
  end if
  end if
  res@lbLabelStride=1
  res@cnLinesOn=False
  res@lbLabelAutoStride=False ;True
  res@gsnFrame=False
   res@lbLabelBarOn=True
  if scriptregion.eq."us" then
    res@mpNationalLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF=2.0
  end if
  res@cnLineLabelInterval=1
  res@cnLineLabelDensityF=1.5

 
  resdif=True
  resdif=res
  resdif@cnFillPalette=("BlueWhiteOrangeRed")

  plot_res=True
  plot_res=res

  hres=True
  hres@cnLinesOn=True
  hres@cnFillOn=False
  hres@cnInfoLabelOn=False
  hres@cnLevelSelectionMode="ExplicitLevels"
  hres@gsnMaximize=True
  hres@cnLineLabelInterval=1
  hres@gsnLeftString=""
  hres@gsnRightString=""
  hres@gsnDraw=False
  hres@cnLabelMasking=True
  hres@cnLineLabelBackgroundColor=-1
  hres@cnLineLabelAngleF=0.0
  hres@cnLineThicknessF=4.0
  hres@cnLineLabelFontHeightF=.012
  hres@cnLineLabelsOn=True
  hres@cnLineColor="black"
  hres@cnLowLabelBackgroundColor=-1
  hres@cnLowLabelFontColor="black"
  hres@cnHighLabelFontHeightF=.020
  hres@gsnFrame=False


  wres=True
  wres@vcRefMagnitudeF=10.0
  wres@gsnLeftString=""
  ;wres@vcVectorDrawOrder="PostDraw"
  wres@gsnRightString=""
  wres@gsnDraw=False
  wres@gsnFrame=False
  wres@vcRefLengthF=.035
  wres@vcMinDistanceF=.045
  wres@vcGlyphStyle="WindBarb"
  wres@vcWindBarbLineThicknessF=2.0
  wres@vcMonoWindBarbColor=True
  wres@vcWindBarbColor="black"
  ;wres@vcLineArrowColor="black"
  ;wres@vcWindBarbTickLengthF=.4
  wres@vcRefAnnoOn=False
  ;print("plotting wind")
  ;if scriptregion.eq."us" then
    wres@vcRefLengthF=.025
    wres@vcWindBarbLineThicknessF=2.0
    wres@vcMinDistanceF=.03
  ;end if

  wres2=True
  wres2=wres
  wres2@vcWindBarbLineThicknessF=5
  wres2@vcWindBarbColor="white"
  if scriptregion.eq."us" then
    wres2@vcWindBarbLineThicknessF=5
  end if




  if (var_str .eq. "slp") then

     ;field1=phys1->MSLET_P0_L101_GLL0
     ;field2=phys2->MSLET_P0_L101_GLL0
     ;field3=phys3->MSLET_P0_L101_GLL0
     ;field4=phys4->MSLET_P0_L101_GLL0
     ecslp=ec->MSL_GDS0_SFC
     ;anlfield2=anl2->MSLET_P0_L101_GLL0

     ;field1=field1/100.
     ;field2=field2/100.
     ;field3=field3/100.
     ;field4=field4/100.
     ecslp=ecslp/100.
     ;anlfield2=anlfield2/100.

     gsn_define_colormap(wks,"thetae") 
     res@gsnRightString="SLP"
     res@gsnLeftString="EC fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
     res@cnLevels=fspan(920,1060,36)
     res@cnLowLabelsOn=True

     ;resdif@gsnRightString="SLP"
     ;resdif@cnLevels:=fspan(-10,10,11)

     hres@cnLevels=fspan(920,1060,36)
     hres@cnLowLabelsOn=True

     ;plot_line0=gsn_csm_contour(wks,field1,hres)
     if (plot_EC) then
        plot(0)=gsn_csm_contour_map(wks,ecslp,res)
        plot_heightec=gsn_csm_contour(wks,ecslp,hres)
        overlay(plot(0),plot_heightec)
     end if
     ;plot_line2=gsn_csm_contour(wks,field3,hres)
     ;plot_line3=gsn_csm_contour(wks,field2,hres)
     ;plot_line4=gsn_csm_contour(wks,anlfield2,hres)
     ;plot_line5=gsn_csm_contour(wks,field4,hres)


  else if (var_str .eq. "250wind") then

     u1=phys1->UGRD_P0_L100_GLL0({25000},:,:)
     u2=phys2->UGRD_P0_L100_GLL0({25000},:,:)
     u3=phys3->UGRD_P0_L100_GLL0({25000},:,:)
     u4=phys4->UGRD_P0_L100_GLL0({25000},:,:)
     anlu1=anl1->U_GDS0_ISBL({250},:,:)
     anlu2=anl2->UGRD_P0_L100_GLL0({25000},:,:)
     u1=u1*1.94
     u2=u2*1.94
     u3=u3*1.94
     u4=u4*1.94
     anlu1=anlu1*1.94
     anlu2=anlu2*1.94

     v1=phys1->VGRD_P0_L100_GLL0({25000},:,:)
     v2=phys2->VGRD_P0_L100_GLL0({25000},:,:)
     v3=phys3->VGRD_P0_L100_GLL0({25000},:,:)
     v4=phys4->VGRD_P0_L100_GLL0({25000},:,:)
     anlv1=anl1->V_GDS0_ISBL({250},:,:)
     anlv2=anl2->VGRD_P0_L100_GLL0({25000},:,:)
     v1=v1*1.94
     v2=v2*1.94
     v3=v3*1.94
     v4=v4*1.94
     anlv1=anlv1*1.94
     anlv2=anlv2*1.94

     field1=u1
     field2=u2
     field3=u3
     field4=u4
     anlfield1=anlu1
     anlfield2=anlu2

     field1=(u1^2+v1^2)^0.5
     field2=(u2^2+v2^2)^0.5
     field3=(u3^2+v3^2)^0.5
     field4=(u4^2+v4^2)^0.5
     anlfield1=(anlu1^2+anlv1^2)^0.5
     anlfield2=(anlu2^2+anlv2^2)^0.5

     gsn_define_colormap(wks,"jetu")
     res@gsnRightString="250-hPa wind (kt)"
     res@cnFillColors(0):=-1
     res@cnLevels=ispan(40,200,20)

     resdif@gsnRightString="250-hPa wind (kt)"
     resdif@cnLevels:=fspan(-50,50,11)

     hres@cnLevels=ispan(40,200,20)
     hres@cnLowLabelsOn=False

     plot_windb0=gsn_csm_vector(wks,u1,v1,wres2)
     plot_winda0=gsn_csm_vector(wks,u1,v1,wres)

     if (plot_EC) then
        plot_windb1=gsn_csm_vector(wks,anlu1,anlv1,wres2)
        plot_winda1=gsn_csm_vector(wks,anlu1,anlv1,wres)
     end if

     plot_windb2=gsn_csm_vector(wks,u3,v3,wres2)
     plot_winda2=gsn_csm_vector(wks,u3,v3,wres)

     plot_windb3=gsn_csm_vector(wks,u2,v2,wres2)
     plot_winda3=gsn_csm_vector(wks,u2,v2,wres)

     plot_windb4=gsn_csm_vector(wks,anlu2,anlv2,wres2)
     plot_winda4=gsn_csm_vector(wks,anlu2,anlv2,wres)

     plot_windb5=gsn_csm_vector(wks,u4,v4,wres2)
     plot_winda5=gsn_csm_vector(wks,u4,v4,wres)


  else if (var_str .eq. "500") then

     ;hght1=phys1->HGT_P0_L100_GLL0({50000},:,:)
     ;hght2=phys2->HGT_P0_L100_GLL0({50000},:,:)
     ;hght3=phys3->HGT_P0_L100_GLL0({50000},:,:)
     ;hght4=phys4->HGT_P0_L100_GLL0({50000},:,:)
     ec500=ec->GH_GDS0_ISBL({500},:,:)
     ;anlhght2=anl2->HGT_P0_L100_GLL0({50000},:,:)

     ;hght1=hght1/10.
     ;hght2=hght2/10.
     ;hght3=hght3/10.
     ;hght4=hght4/10.
     ec500=ec500/10.
     ;anlhght2=anlhght2/10.

     ;field1=phys1->ABSV_P0_L100_GLL0({50000},:,:)
     ;field2=phys2->ABSV_P0_L100_GLL0({50000},:,:)
     ;field3=phys3->ABSV_P0_L100_GLL0({50000},:,:)
     ;field4=phys4->ABSV_P0_L100_GLL0({50000},:,:)
     ecvort=ec->VO_GDS0_ISBL({500},:,:)
     ;anlfield2=anl2->ABSV_P0_L100_GLL0({50000},:,:)

     ;field1=field1*10^5
     ;field2=field2*10^5
     ;field3=field3*10^5
     ;field4=field4*10^5
     ecvort=ecvort*10^5
     ;anlfield2=anlfield2*10^5

     gsn_define_colormap(wks,"vort") 
     res@gsnRightString="500-hPa"
     res@gsnLeftString="EC fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
     res@cnFillColors(0)=-1
     res@cnLevels=ispan(16,50,4)

     ;resdif@gsnRightString="500-hPa"
     ;resdif@cnLevels:=fspan(-16,16,17)

     hres@cnLevels=ispan(480,660,6)
     hres@cnLowLabelsOn=False

     ;plot_line0=gsn_csm_contour(wks,hght1,hres)
     if (plot_EC) then
        plot(0)=gsn_csm_contour_map(wks,ecvort,res)
        plot_heightec=gsn_csm_contour(wks,ec500,hres)
        overlay(plot(0),plot_heightec)
     end if
     ;plot_line2=gsn_csm_contour(wks,hght3,hres)
     ;plot_line3=gsn_csm_contour(wks,hght2,hres)
     ;plot_line4=gsn_csm_contour(wks,anlhght2,hres)
     ;plot_line5=gsn_csm_contour(wks,hght4,hres)


  else if (var_str .eq. "850wind") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        u1=phys1->UGRD_P0_L100_GLC0({85000},:,:)
        u2=phys2->UGRD_P0_L100_GLC0({85000},:,:)
        u3=phys3->UGRD_P0_L100_GLC0({85000},:,:)
        u4=phys4->UGRD_P0_L100_GLC0({85000},:,:)
     else
        u1=phys1->UGRD_P0_L100_GLL0({85000},:,:)
        u2=phys2->UGRD_P0_L100_GLL0({85000},:,:)
        u3=phys3->UGRD_P0_L100_GLL0({85000},:,:)
        u4=phys4->UGRD_P0_L100_GLL0({85000},:,:)
     end if
     anlu1=anl1->U_GDS0_ISBL({850},:,:)
     anlu2=anl2->UGRD_P0_L100_GLC0({85000},:,:)
     u1=u1*1.94
     u2=u2*1.94
     u3=u3*1.94
     u4=u4*1.94
     anlu1=anlu1*1.94
     anlu2=anlu2*1.94

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        v1=phys1->VGRD_P0_L100_GLC0({85000},:,:)
        v2=phys2->VGRD_P0_L100_GLC0({85000},:,:)
        v3=phys3->VGRD_P0_L100_GLC0({85000},:,:)
        v4=phys4->VGRD_P0_L100_GLC0({85000},:,:)
     else
        v1=phys1->VGRD_P0_L100_GLL0({85000},:,:)
        v2=phys2->VGRD_P0_L100_GLL0({85000},:,:)
        v3=phys3->VGRD_P0_L100_GLL0({85000},:,:)
        v4=phys4->VGRD_P0_L100_GLL0({85000},:,:)
     end if
     anlv1=anl1->V_GDS0_ISBL({850},:,:)
     anlv2=anl2->VGRD_P0_L100_GLC0({85000},:,:)
     v1=v1*1.94
     v2=v2*1.94
     v3=v3*1.94
     v4=v4*1.94
     anlv1=anlv1*1.94
     anlv2=anlv2*1.94

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlu2@lat2d = lat2d
     anlv2@lat2d = lat2d
     anlu2@lon2d = lon2d
     anlu2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        u1@lat2d = lat2d
        u1@lon2d = lon2d
        v1@lat2d = lat2d
        v1@lon2d = lon2d
        u2@lat2d = lat2d
        u2@lon2d = lon2d
        v2@lat2d = lat2d
        v2@lon2d = lon2d
        u3@lat2d = lat2d
        u3@lon2d = lon2d
        v3@lat2d = lat2d
        v3@lon2d = lon2d
        u4@lat2d = lat2d
        u4@lon2d = lon2d
        v4@lat2d = lat2d
        v4@lon2d = lon2d
     end if

     field1=u1
     field2=u2
     field3=u3
     field4=u4
     anlfield1=anlu1
     anlfield2=anlu2

     field1=(u1^2+v1^2)^0.5
     field2=(u2^2+v2^2)^0.5
     field3=(u3^2+v3^2)^0.5
     field4=(u4^2+v4^2)^0.5
     anlfield1=(anlu1^2+anlv1^2)^0.5
     anlfield2=(anlu2^2+anlv2^2)^0.5

     gsn_define_colormap(wks,"MPL_s3pcpn_l")
     res@gsnRightString="850-hPa wind (kt)"
     res@cnFillColors=(/0,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,65,102/)

  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
   ; res@cnLevels=ispan(6,60,3)
   ; res@cnLevels=ispan(8,80,4)
     res@cnLevels=ispan(10,100,5)
   ; res@cnLevels=ispan(12,120,6)
   ; res@cnLevels=ispan(14,140,7)
   ; res@cnLevels=ispan(16,160,8)

     resdif@gsnRightString="850-hPa wind (kt)"
     resdif@cnLevels:=fspan(-25,25,11)

     plot_windb0=gsn_csm_vector(wks,u1,v1,wres2)
     plot_winda0=gsn_csm_vector(wks,u1,v1,wres)

     if (plot_EC) then
        plot_windb1=gsn_csm_vector(wks,anlu1,anlv1,wres2)
        plot_winda1=gsn_csm_vector(wks,anlu1,anlv1,wres)
     end if

     plot_windb2=gsn_csm_vector(wks,u3,v3,wres2)
     plot_winda2=gsn_csm_vector(wks,u3,v3,wres)

     plot_windb3=gsn_csm_vector(wks,u2,v2,wres2)
     plot_winda3=gsn_csm_vector(wks,u2,v2,wres)

     plot_windb4=gsn_csm_vector(wks,anlu2,anlv2,wres2)
     plot_winda4=gsn_csm_vector(wks,anlu2,anlv2,wres)

     plot_windb5=gsn_csm_vector(wks,u4,v4,wres2)
     plot_winda5=gsn_csm_vector(wks,u4,v4,wres)


  else if (var_str .eq. "850t") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1=phys1->TMP_P0_L100_GLC0({85000},:,:)
        field2=phys2->TMP_P0_L100_GLC0({85000},:,:)
        field3=phys3->TMP_P0_L100_GLC0({85000},:,:)
        field4=phys4->TMP_P0_L100_GLC0({85000},:,:)
     else
        field1=phys1->TMP_P0_L100_GLL0({85000},:,:)
        field2=phys2->TMP_P0_L100_GLL0({85000},:,:)
        field3=phys3->TMP_P0_L100_GLL0({85000},:,:)
        field4=phys4->TMP_P0_L100_GLL0({85000},:,:)
     end if
     anlfield1=anl1->T_GDS0_ISBL({850},:,:)
     anlfield2=anl2->TMP_P0_L100_GLC0({85000},:,:)

     field1=field1-273.15
     field2=field2-273.15
     field3=field3-273.15
     field4=field4-273.15
     anlfield1=anlfield1-273.15
     anlfield2=anlfield2-273.15

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlfield2@lat2d = lat2d
     anlfield2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1@lat2d = lat2d
        field1@lon2d = lon2d
        field2@lat2d = lat2d
        field2@lon2d = lon2d
        field3@lat2d = lat2d
        field3@lon2d = lon2d
        field4@lat2d = lat2d
        field4@lon2d = lon2d
     end if

     gsn_define_colormap(wks,"temp")
     res@gsnRightString="850-hPa T (~S~o~N~C)"  
     res@cnLevels=fspan(-40,40,41)

     resdif@gsnRightString="850-hPa T (~S~o~N~C)"  
     resdif@cnLevels:=fspan(-10,10,11)

     hres@cnLevels=(/0/)
     hres@cnLineThicknessF=2.0
     hres@cnLineLabelFontColor="white"
     hres@cnLineColor="white"
     hres@cnLowLabelsOn=False
     hres@cnLowLabelFontColor="white"

     plot_line0=gsn_csm_contour(wks,field1,hres)
     if (plot_EC) then
        plot_line1=gsn_csm_contour(wks,anlfield1,hres)
     end if
     plot_line2=gsn_csm_contour(wks,field3,hres)
     plot_line3=gsn_csm_contour(wks,field2,hres)
     plot_line4=gsn_csm_contour(wks,anlfield2,hres)
     plot_line5=gsn_csm_contour(wks,field4,hres)


  else if (var_str .eq. "2mt") then

     ;if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        ;field1=phys1->TMP_P0_L103_GLC0({2},:,:)
        ;field2=phys2->TMP_P0_L103_GLC0({2},:,:)
        ;field3=phys3->TMP_P0_L103_GLC0({2},:,:)
        ;field4=phys4->TMP_P0_L103_GLC0({2},:,:)
     ;else
        ;field1=phys1->TMP_P0_L103_GLL0({2},:,:)
        ;field2=phys2->TMP_P0_L103_GLL0({2},:,:)
        ;field3=phys3->TMP_P0_L103_GLL0({2},:,:)
        ;field4=phys4->TMP_P0_L103_GLL0({2},:,:)
     ;end if
     ec2mt=ec->2T_GDS0_SFC
     ;anlfield2=anl2->TMP_P0_L103_GLC0({2},:,:)

     ;field1=(field1-273.15)*1.8+32.0
     ;field2=(field2-273.15)*1.8+32.0
     ;field3=(field3-273.15)*1.8+32.0
     ;field4=(field4-273.15)*1.8+32.0
     ec2mt=(ec2mt-273.15)*1.8+32.0
     ;anlfield2=(anlfield2-273.15)*1.8+32.0

     ;lat2d := anl2->gridlat_0
     ;lon2d := anl2->gridlon_0
     ;anlfield2@lat2d = lat2d
     ;anlfield2@lon2d = lon2d
     ;if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        ;field1@lat2d = lat2d
        ;field1@lon2d = lon2d
        ;field2@lat2d = lat2d
        ;field2@lon2d = lon2d
        ;field3@lat2d = lat2d
        ;field3@lon2d = lon2d
        ;field4@lat2d = lat2d
        ;field4@lon2d = lon2d
     ;end if

     gsn_define_colormap(wks,"NWcasetemp")
     res@gsnRightString="2-m T (~S~o~N~F)"
     res@gsnLeftString="EC fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.3i",fhours(h))+")"  
     res@cnLevels=fspan(-16,134,51)
     ;res@cnLevels=(/-16,-4,8,20,32,44,56,68,80,92,104,116,128/)
     plot(0) = gsn_csm_contour_map(wks,ec2mt,res)
     ;resdif@gsnRightString="2-m T (~S~o~N~F)"  
     ;resdif@cnLevels:=fspan(-20,20,21)

     zres=True
     zres@cnLinesOn=True
     zres@cnFillOn=False
     zres@cnInfoLabelOn=False
     zres@cnLevelSelectionMode="ExplicitLevels"
     zres@gsnMaximize=True
     zres@cnLineLabelInterval=1
     zres@gsnLeftString=""
     zres@gsnRightString=""
     zres@cnLevels=(/32/)
     zres@gsnDraw=False
     zres@cnLabelMasking=True
     zres@cnLineLabelBackgroundColor=-1
     zres@cnLineLabelAngleF=0.0
     zres@cnLineThicknessF=3.0
     zres@cnLineLabelFontHeightF=.009
     zres@cnLineLabelsOn=False
     zres@cnLineLabelFontColor="white"
     zres@cnLineColor="white"
     zres@cnLowLabelsOn=False
     zres@cnLowLabelBackgroundColor=-1
     zres@cnLowLabelFontColor="black"
     zres@cnHighLabelFontHeightF=.019
     zres@cnHighLabelFont = "helvetica-bold"
     zres@cnLowLabelFont = "helvetica-bold"
     zres@gsnFrame=False

     ;plot_line0=gsn_csm_contour(wks,field1,hres)
     if (plot_EC) then
        plot_zeroec=gsn_csm_contour(wks,ec2mt,zres)
        overlay(plot(0),plot_zeroec)
     end if
     ;plot_line2=gsn_csm_contour(wks,field3,hres)
     ;plot_line3=gsn_csm_contour(wks,field2,hres)
     ;plot_line4=gsn_csm_contour(wks,anlfield2,hres)
     ;plot_line5=gsn_csm_contour(wks,field4,hres)


  else if ((var_str .eq. "skin") .or. (var_str .eq. "sst")) then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1=phys1->TMP_P0_L1_GLC0
        field2=phys2->TMP_P0_L1_GLC0
        field3=phys3->TMP_P0_L1_GLC0
        field4=phys4->TMP_P0_L1_GLC0
        land=phys1->LAND_P0_L1_GLC0
     else
        field1=phys1->TMP_P0_L1_GLL0
        field2=phys2->TMP_P0_L1_GLL0
        field3=phys3->TMP_P0_L1_GLL0
        field4=phys4->TMP_P0_L1_GLL0
        land=phys1->LAND_P0_L1_GLL0
     end if
     anlfield1=anl1->SSTK_GDS0_SFC
     anlfield2=anl2->WTMP_P0_L1_GLC0
     anl2land=anl2->LAND_P0_L1_GLC0

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlfield2@lat2d = lat2d
     anlfield2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1@lat2d = lat2d
        field1@lon2d = lon2d
        field2@lat2d = lat2d
        field2@lon2d = lon2d
        field3@lat2d = lat2d
        field3@lon2d = lon2d
        field4@lat2d = lat2d
        field4@lon2d = lon2d
     end if

     if (var_str .eq. "skin") then
  
        plot_EC = False

        field1=(field1-273.15)*1.8+32.0
        field2=(field2-273.15)*1.8+32.0
        field3=(field3-273.15)*1.8+32.0
        field4=(field4-273.15)*1.8+32.0
        anlfield1=anlfield1*0.
        anlfield2=anlfield2*0.

        mask_opt = 1

        gsn_define_colormap(wks,"temp")
        res@gsnRightString="Skin T (~S~o~N~F)"  
        res@cnLevels=fspan(-40,140,37)
     
        resdif@gsnRightString="Skin T (~S~o~N~F)"  
        resdif@cnLevels:=fspan(-20,20,21)

     else if (var_str .eq. "sst") then
        field1=field1-273.15
        field2=field2-273.15
        field3=field3-273.15
        field4=field4-273.15
        anlfield1=anlfield1-273.15
        anlfield2=anlfield2-273.15

        mask_opt = 0

        gsn_define_colormap(wks,"temp")
        res@gsnRightString="SST (~S~o~N~C)"  
        res@cnLevels=fspan(0,40,41)
     
        resdif@gsnRightString="SST (~S~o~N~C)"  
        resdif@cnLevels:=fspan(-10,10,21)

     end if
     end if

     field1=mask(field1,land,mask_opt)
     field2=mask(field2,land,mask_opt)
     field3=mask(field3,land,mask_opt)
     field4=mask(field4,land,mask_opt)
     anlfield2=mask(anlfield2,anl2land,mask_opt)


  else if (var_str .eq. "2mdew") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1=phys1->DPT_P0_L103_GLC0
        field2=phys2->DPT_P0_L103_GLC0
        field3=phys3->DPT_P0_L103_GLC0
        field4=phys4->DPT_P0_L103_GLC0
     else
        field1=phys1->DPT_P0_L103_GLL0
        field2=phys2->DPT_P0_L103_GLL0
        field3=phys3->DPT_P0_L103_GLL0
        field4=phys4->DPT_P0_L103_GLL0
     end if
     anlfield1=anl1->2D_GDS0_SFC
     anlfield2=anl2->DPT_P0_L103_GLC0

     field1=(field1-273.15)*1.8+32.0
     field2=(field2-273.15)*1.8+32.0
     field3=(field3-273.15)*1.8+32.0
     field4=(field4-273.15)*1.8+32.0
     anlfield1=(anlfield1-273.15)*1.8+32.0
     anlfield2=(anlfield2-273.15)*1.8+32.0

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlfield2@lat2d = lat2d
     anlfield2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1@lat2d = lat2d
        field1@lon2d = lon2d
        field2@lat2d = lat2d
        field2@lon2d = lon2d
        field3@lat2d = lat2d
        field3@lon2d = lon2d
        field4@lat2d = lat2d
        field4@lon2d = lon2d
     end if

     gsn_define_colormap(wks,"dew")
     res@gsnRightString="2-m Td"
     res@cnLevels=fspan(-35,85,41)

     resdif@gsnRightString="2-m Td"
     resdif@cnLevels:=fspan(-20,20,21)


  else if (var_str .eq. "10mwind") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        u1=phys1->UGRD_P0_L103_GLC0({10},:,:)
        u2=phys2->UGRD_P0_L103_GLC0({10},:,:)
        u3=phys3->UGRD_P0_L103_GLC0({10},:,:)
        u4=phys4->UGRD_P0_L103_GLC0({10},:,:)
     else
        u1=phys1->UGRD_P0_L103_GLL0({10},:,:)
        u2=phys2->UGRD_P0_L103_GLL0({10},:,:)
        u3=phys3->UGRD_P0_L103_GLL0({10},:,:)
        u4=phys4->UGRD_P0_L103_GLL0({10},:,:)
     end if
     anlu1=anl1->10U_GDS0_SFC
     anlu2=anl2->UGRD_P0_L103_GLC0({10},:,:)
     u1=u1*1.94
     u2=u2*1.94
     u3=u3*1.94
     u4=u4*1.94
     anlu1=anlu1*1.94
     anlu2=anlu2*1.94

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        v1=phys1->VGRD_P0_L103_GLC0({10},:,:)
        v2=phys2->VGRD_P0_L103_GLC0({10},:,:)
        v3=phys3->VGRD_P0_L103_GLC0({10},:,:)
        v4=phys4->VGRD_P0_L103_GLC0({10},:,:)
     else
        v1=phys1->VGRD_P0_L103_GLL0({10},:,:)
        v2=phys2->VGRD_P0_L103_GLL0({10},:,:)
        v3=phys3->VGRD_P0_L103_GLL0({10},:,:)
        v4=phys4->VGRD_P0_L103_GLL0({10},:,:)
     end if
     anlv1=anl1->10V_GDS0_SFC
     anlv2=anl2->VGRD_P0_L103_GLC0({10},:,:)
     v1=v1*1.94
     v2=v2*1.94
     v3=v3*1.94
     v4=v4*1.94
     anlv1=anlv1*1.94
     anlv2=anlv2*1.94

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlu2@lat2d = lat2d
     anlv2@lat2d = lat2d
     anlu2@lon2d = lon2d
     anlu2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        u1@lat2d = lat2d
        u1@lon2d = lon2d
        v1@lat2d = lat2d
        v1@lon2d = lon2d
        u2@lat2d = lat2d
        u2@lon2d = lon2d
        v2@lat2d = lat2d
        v2@lon2d = lon2d
        u3@lat2d = lat2d
        u3@lon2d = lon2d
        v3@lat2d = lat2d
        v3@lon2d = lon2d
        u4@lat2d = lat2d
        u4@lon2d = lon2d
        v4@lat2d = lat2d
        v4@lon2d = lon2d
     end if

     field1=u1
     field2=u2
     field3=u3
     field4=u4
     anlfield1=anlu1
     anlfield2=anlu2

     field1=(u1^2+v1^2)^0.5
     field2=(u2^2+v2^2)^0.5
     field3=(u3^2+v3^2)^0.5
     field4=(u4^2+v4^2)^0.5
     anlfield1=(anlu1^2+anlv1^2)^0.5
     anlfield2=(anlu2^2+anlv2^2)^0.5

     gsn_define_colormap(wks,"MPL_s3pcpn_l")
     res@gsnRightString="10-m wind (kt)"
     res@cnFillColors=(/0,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,65,102/)

  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
   ; res@cnLevels=ispan(6,60,3)
   ; res@cnLevels=ispan(8,80,4)
     res@cnLevels=ispan(10,100,5)
   ; res@cnLevels=ispan(12,120,6)

     resdif@gsnRightString="10-m wind (kt)"
     resdif@cnLevels:=fspan(-25,25,11)

     plot_windb0=gsn_csm_vector(wks,u1,v1,wres2)
     plot_winda0=gsn_csm_vector(wks,u1,v1,wres)

     if (plot_EC) then
        plot_windb1=gsn_csm_vector(wks,anlu1,anlv1,wres2)
        plot_winda1=gsn_csm_vector(wks,anlu1,anlv1,wres)
     end if

     plot_windb2=gsn_csm_vector(wks,u3,v3,wres2)
     plot_winda2=gsn_csm_vector(wks,u3,v3,wres)

     plot_windb3=gsn_csm_vector(wks,u2,v2,wres2)
     plot_winda3=gsn_csm_vector(wks,u2,v2,wres)

     plot_windb4=gsn_csm_vector(wks,anlu2,anlv2,wres2)
     plot_winda4=gsn_csm_vector(wks,anlu2,anlv2,wres)

     plot_windb5=gsn_csm_vector(wks,u4,v4,wres2)
     plot_winda5=gsn_csm_vector(wks,u4,v4,wres)


  else if (var_str .eq. "sfcgust") then

     plot_EC = False

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1=phys1->GUST_P0_L1_GLC0(:,:)
        field2=phys2->GUST_P0_L1_GLC0(:,:)
        field3=phys3->GUST_P0_L1_GLC0(:,:)
        field4=phys4->GUST_P0_L1_GLC0(:,:)
     else
        field1=phys1->GUST_P0_L1_GLL0(:,:)
        field2=phys2->GUST_P0_L1_GLL0(:,:)
        field3=phys3->GUST_P0_L1_GLL0(:,:)
        field4=phys4->GUST_P0_L1_GLL0(:,:)
     end if
     anlfield1=anl1->10FG_GDS0_SFC
     anlfield2=anl2->GUST_P0_L1_GLC0(:,:)

     field1=field1*1.94
     field2=field2*1.94
     field3=field3*1.94
     field4=field4*1.94
     anlfield1=anlfield1*1.94
     anlfield2=anlfield2*1.94

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlfield2@lat2d = lat2d
     anlfield2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1@lat2d = lat2d
        field1@lon2d = lon2d
        field2@lat2d = lat2d
        field2@lon2d = lon2d
        field3@lat2d = lat2d
        field3@lon2d = lon2d
        field4@lat2d = lat2d
        field4@lon2d = lon2d
     end if

     gsn_define_colormap(wks,"MPL_s3pcpn_l")
     res@gsnRightString="Sfc wind gusts (kt)"
     res@cnFillColors=(/0,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,65,102/)

  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
   ; res@cnLevels=ispan(6,60,3)
   ; res@cnLevels=ispan(8,80,4)
     res@cnLevels=ispan(10,100,5)
   ; res@cnLevels=ispan(12,120,6)

     resdif@gsnRightString="Sfc wind gusts (kt)"
     resdif@cnLevels:=fspan(-25,25,11)


  else if (var_str .eq. "shear") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        uu1=phys1->UGRD_P0_L100_GLC0({50000},:,:)
        uu2=phys2->UGRD_P0_L100_GLC0({50000},:,:)
        uu3=phys3->UGRD_P0_L100_GLC0({50000},:,:)
        uu4=phys4->UGRD_P0_L100_GLC0({50000},:,:)

        vu1=phys1->VGRD_P0_L100_GLC0({50000},:,:)
        vu2=phys2->VGRD_P0_L100_GLC0({50000},:,:)
        vu3=phys3->VGRD_P0_L100_GLC0({50000},:,:)
        vu4=phys4->VGRD_P0_L100_GLC0({50000},:,:)

        ul1=phys1->UGRD_P0_L103_GLC0({10},:,:)
        ul2=phys2->UGRD_P0_L103_GLC0({10},:,:)
        ul3=phys3->UGRD_P0_L103_GLC0({10},:,:)
        ul4=phys4->UGRD_P0_L103_GLC0({10},:,:)

        vl1=phys1->VGRD_P0_L103_GLC0({10},:,:)
        vl2=phys2->VGRD_P0_L103_GLC0({10},:,:)
        vl3=phys3->VGRD_P0_L103_GLC0({10},:,:)
        vl4=phys4->VGRD_P0_L103_GLC0({10},:,:)
     else
        uu1=phys1->UGRD_P0_L100_GLL0({50000},:,:)
        uu2=phys2->UGRD_P0_L100_GLL0({50000},:,:)
        uu3=phys3->UGRD_P0_L100_GLL0({50000},:,:)
        uu4=phys4->UGRD_P0_L100_GLL0({50000},:,:)

        vu1=phys1->VGRD_P0_L100_GLL0({50000},:,:)
        vu2=phys2->VGRD_P0_L100_GLL0({50000},:,:)
        vu3=phys3->VGRD_P0_L100_GLL0({50000},:,:)
        vu4=phys4->VGRD_P0_L100_GLL0({50000},:,:)

        ul1=phys1->UGRD_P0_L103_GLL0({10},:,:)
        ul2=phys2->UGRD_P0_L103_GLL0({10},:,:)
        ul3=phys3->UGRD_P0_L103_GLL0({10},:,:)
        ul4=phys4->UGRD_P0_L103_GLL0({10},:,:)

        vl1=phys1->VGRD_P0_L103_GLL0({10},:,:)
        vl2=phys2->VGRD_P0_L103_GLL0({10},:,:)
        vl3=phys3->VGRD_P0_L103_GLL0({10},:,:)
        vl4=phys4->VGRD_P0_L103_GLL0({10},:,:)
     end if

     anluu1=anl1->U_GDS0_ISBL({500},:,:)
     anluu2=anl2->UGRD_P0_L100_GLC0({50000},:,:)

     anlvu1=anl1->V_GDS0_ISBL({500},:,:)
     anlvu2=anl2->VGRD_P0_L100_GLC0({50000},:,:)

     anlul1=anl1->10U_GDS0_SFC
     anlul2=anl2->UGRD_P0_L103_GLC0({10},:,:)

     anlvl1=anl1->10V_GDS0_SFC
     anlvl2=anl2->VGRD_P0_L103_GLC0({10},:,:)

     u1=ul1
     u2=ul2
     u3=ul3
     u4=ul4
     anlu1=anlul1

     u1=(uu1-ul1)*1.94
     u2=(uu2-ul2)*1.94
     u3=(uu3-ul3)*1.94
     u4=(uu4-ul4)*1.94
     anlu1=(anluu1-anlul1)*1.94
     anlu2=(anluu2-anlul2)*1.94

     v1=vl1
     v2=vl2
     v3=vl3
     v4=vl4
     anlv1=anlvl1

     v1=(vu1-vl1)*1.94
     v2=(vu2-vl2)*1.94
     v3=(vu3-vl3)*1.94
     v4=(vu4-vl4)*1.94
     anlv1=(anlvu1-anlvl1)*1.94
     anlv2=(anlvu2-anlvl2)*1.94

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlu2@lat2d = lat2d
     anlv2@lat2d = lat2d
     anlu2@lon2d = lon2d
     anlu2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        u1@lat2d = lat2d
        u1@lon2d = lon2d
        v1@lat2d = lat2d
        v1@lon2d = lon2d
        u2@lat2d = lat2d
        u2@lon2d = lon2d
        v2@lat2d = lat2d
        v2@lon2d = lon2d
        u3@lat2d = lat2d
        u3@lon2d = lon2d
        v3@lat2d = lat2d
        v3@lon2d = lon2d
        u4@lat2d = lat2d
        u4@lon2d = lon2d
        v4@lat2d = lat2d
        v4@lon2d = lon2d
     end if

     field1=ul1
     field2=ul2
     field3=ul3
     field4=ul4
     anlfield1=anlul1
     anlfield2=anlu2

     field1=(u1^2+v1^2)^0.5
     field2=(u2^2+v2^2)^0.5
     field3=(u3^2+v3^2)^0.5
     field4=(u4^2+v4^2)^0.5
     anlfield1=(anlu1^2+anlv1^2)^0.5
     anlfield2=(anlu2^2+anlv2^2)^0.5

     gsn_define_colormap(wks,"MPL_s3pcpn_l")
     res@gsnRightString="10-m to 500-hPa shear (kt)"
     res@cnFillColors=(/0,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,65,102/)
     res@cnLevels=ispan(10,82,4)

     resdif@gsnRightString="10-m to 500-hPa shear (kt)"
     resdif@cnLevels:=fspan(-25,25,11)

     plot_windb0=gsn_csm_vector(wks,u1,v1,wres2)
     plot_winda0=gsn_csm_vector(wks,u1,v1,wres)

     if (plot_EC) then
        plot_windb1=gsn_csm_vector(wks,anlu1,anlv1,wres2)
        plot_winda1=gsn_csm_vector(wks,anlu1,anlv1,wres)
     end if

     plot_windb2=gsn_csm_vector(wks,u3,v3,wres2)
     plot_winda2=gsn_csm_vector(wks,u3,v3,wres)

     plot_windb3=gsn_csm_vector(wks,u2,v2,wres2)
     plot_winda3=gsn_csm_vector(wks,u2,v2,wres)

     plot_windb4=gsn_csm_vector(wks,anlu2,anlv2,wres2)
     plot_winda4=gsn_csm_vector(wks,anlu2,anlv2,wres)

     plot_windb5=gsn_csm_vector(wks,u4,v4,wres2)
     plot_winda5=gsn_csm_vector(wks,u4,v4,wres)


  else if (var_str .eq. "cape") then

     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1=phys1->CAPE_P0_L1_GLC0
        field2=phys2->CAPE_P0_L1_GLC0
        field3=phys3->CAPE_P0_L1_GLC0
        field4=phys4->CAPE_P0_L1_GLC0
     else
        field1=phys1->CAPE_P0_L1_GLL0
        field2=phys2->CAPE_P0_L1_GLL0
        field3=phys3->CAPE_P0_L1_GLL0
        field4=phys4->CAPE_P0_L1_GLL0
     end if
     anlfield1=anl1->CAPE_GDS0_SFC
     anlfield2=anl2->CAPE_P0_L1_GLC0

     lat2d := anl2->gridlat_0
     lon2d := anl2->gridlon_0
     anlfield2@lat2d = lat2d
     anlfield2@lon2d = lon2d
     if (plot_diff .and. (diff_str .eq. "anl2") .and. plot_NAM) then
        field1@lat2d = lat2d
        field1@lon2d = lon2d
        field2@lat2d = lat2d
        field2@lon2d = lon2d
        field3@lat2d = lat2d
        field3@lon2d = lon2d
        field4@lat2d = lat2d
        field4@lon2d = lon2d
     end if

     gsn_define_colormap(wks,"MPL_s3pcpn_l")
     res@gsnRightString="SBCAPE"
     res@cnFillColors=(/0,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,65,102/)
     if scriptregion.eq."ak" then
        res@cnLevels:=(/1,50,100,150,200,250,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000/)
     else
        res@cnLevels:=(/1,50,100,150,200,250,500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000/)
     end if
   ; res@lbLabelAutoStride=False

     resdif@gsnRightString="SBCAPE"
     resdif@cnLevels:=(/-2000,-1500,-1000,-750,-500,-250,-100,0,100,250,500,750,1000,1500,2000/)


  else if (var_str .eq. "pw") then

     field1=phys1->PWAT_P0_L200_GLL0
     field2=phys2->PWAT_P0_L200_GLL0
     field3=phys3->PWAT_P0_L200_GLL0
     field4=phys4->PWAT_P0_L200_GLL0
     anlfield1=anl1->TCW_GDS0_SFC
     anlfield2=anl2->PWAT_P0_L200_GLL0

     field1=field1*0.03937
     field2=field2*0.03937
     field3=field3*0.03937
     field4=field4*0.03937
     anlfield1=anlfield1*0.03937
     anlfield2=anlfield2*0.03937

     gsn_define_colormap(wks,"pw")
     res@gsnRightString="PWAT (in)"
     res@cnLevels=(/.25,.5,.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0/)

     resdif@gsnRightString="PWAT (in)"
     resdif@cnLevels:=(/-1.0,-.75,-.5,-.25,-.1,0,.1,.25,.5,.75,1.0/)


  else if (var_str .eq. "cloud") then

     if (fhours(h) .eq. 0) then
        field1=phys1->TMP_P0_L103_GLL0({2},:,:)
        field2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field3=phys1->TMP_P0_L103_GLL0({2},:,:)
        field4=phys1->TMP_P0_L103_GLL0({2},:,:)
        anlfield2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield2=anlfield2*0.
        anlfield1:=anlfield2
     else if (fhours(h) .eq. 6) then
        field1=phys1->TCDC_P8_L10_GLL0_avg
        field2=phys2->TCDC_P8_L10_GLL0_avg
        field3=phys3->TCDC_P8_L10_GLL0_avg
        field4=phys4->TCDC_P8_L10_GLL0_avg
     else
        field1=phys1->TCDC_P8_L10_GLL0_avg6h
        field2=phys2->TCDC_P8_L10_GLL0_avg6h
        field3=phys3->TCDC_P8_L10_GLL0_avg6h
        field4=phys4->TCDC_P8_L10_GLL0_avg6h
     end if
     end if


     if (fhours(h) .ge. 6) then
        anlfield1:=anl1->TCDC_P0_L200_GLC0
        anlfield2:=anl2->TCDC_P0_L200_GLC0
        lat2d = anl2->gridlat_0
        lon2d = anl2->gridlon_0
        anlfield1@lat2d = lat2d
        anlfield1@lon2d = lon2d
        anlfield2@lat2d = lat2d
        anlfield2@lon2d = lon2d
     end if

     gsn_define_colormap(wks,"precip_11lev")
     res@cnFillColors(0)=-1
  ;  res@cnLevels=fspan(5,100,20)
     res@cnLevels=fspan(10,100,10)
     res@gsnRightString="6-h Averaged Total Cloud (%)"


  else if (var_str .eq. "6hprecip") then

     if (fhours(h).eq.0) then
        field1=phys1->TMP_P0_L103_GLL0({2},:,:)
        field2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field3=phys1->TMP_P0_L103_GLL0({2},:,:)
        field4=phys1->TMP_P0_L103_GLL0({2},:,:)
        anlfield1=phys1->TMP_P0_L103_GLL0({2},:,:)
        anlfield2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield1*0.
        anlfield2=anlfield2*0.

     else if (fhours(h).eq.6) then
        field1:=phys1->APCP_P8_L1_GLL0_acc
        field2:=phys2->APCP_P8_L1_GLL0_acc
        field3:=phys3->APCP_P8_L1_GLL0_acc
        field4:=phys4->APCP_P8_L1_GLL0_acc
        anlfield2:=anl2->A_PCP_GDS5_SFC_acc6h(:,:)
        anlfield1:=anlfield2

     else
        field1=phys1->APCP_P8_L1_GLL0_acc6h
        field2=phys2->APCP_P8_L1_GLL0_acc6h
        field3=phys3->APCP_P8_L1_GLL0_acc6h
        field4=phys4->APCP_P8_L1_GLL0_acc6h
        anlfield2=anl2->A_PCP_GDS5_SFC_acc6h(:,:)
        anlfield1=anlfield2

     end if
     end if

     field1=field1*0.03937
     field2=field2*0.03937
     field3=field3*0.03937
     field4=field4*0.03937
     if (fhours(h) .gt. 0) then
        lat2d = anl2->g5_lat_0
        lon2d = anl2->g5_lon_1
        anlfield1@lat2d = lat2d
        anlfield1@lon2d = lon2d
        anlfield2@lat2d = lat2d
        anlfield2@lon2d = lon2d
     end if
     anlfield1=anlfield1*0.03937
     anlfield2=anlfield1

     accum_str = "6-h"     
     res@gsnRightString="6-h QPF"
     res@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
   ; res@cnLevels=(/.01,0.50,1.00,1.50,2.00,3.0,4.00,5.0,6.00,8.0,10.,15.0,20.0,25.0,30.0,35.0,40.0,45.0,50.0,60.0/)
   ; res@cnLevels=(/.01,0.25,0.50,0.75,1.00,1.5,2.00,3.0,4.00,5.0,6.0,8.00,10.0,12.5,15.0,20.0,25.0,30.0,40.0,45.0/)
   ; res@cnLevels=(/.01,0.25,0.50,1.00,1.50,2.0,3.00,4.0,5.00,6.0,7.0,8.00,9.00,10.0,12.5,15.0,17.5,20.0,25.0,30.0/)
     res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0,14.0,16.0,18.0,20.0/)
   ; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.00,4.00,5.00,6.00,7.00,7.50,8.00,9.00,10.0/)


  else if (var_str .eq. "24hprecip") then

     if (fhours(h).eq.0) then
        precipprod=ec->TMP_P0_L103_GLL0({2},:,:)
        precipprod=precipprod*0.0
        ec_array(h,:,:) = precipprod
        precipplotprod=precipprod
        precipplotprod=ec_array(0,:,:)

     else if (fhours(h).eq.6) then
        precipprod=ec->TP_GDS0_SFC
        precipprod=precipprod*39.37
        ec_array(h,:,:) = precipprod
        precipplotprod=precipprod
        precipplotprod=ec_array(0,:,:)

     ;else if (h.lt.dimsizes(fdates)-1) then
       ;var = "TP_GDS0_SFC"
       ;print("var: "+var)
        ;precipprod=ec->$var$
        ;ec_array(h,:,:) = precipprod
        ;precipplotprod=(/precipprod/)
        ;precipplotprod=ec_array(0,:,:)
        ;lat := ec->g0_lat_0
        ;lon := ec->g0_lon_1
        ;precipplotprod!0 = "lat"
        ;precipplotprod!1 = "lon"
        ;precipplotprod&lat = lat
        ;precipplotprod&lon = lon

     else if (fhours(h).ge.24) then
       lat := ec->g0_lat_0
       lon := ec->g0_lon_1
       var = "TP_GDS0_SFC"
       print("var: "+var)
        precipprod=ec->$var$
        thisdate_m24h=thisdate
        thisdate_m24h=thisdate - 24
        newstrings=tostring(ut_calendar(thisdate_m24h,-3))
        nyear=str_get_cols(newstrings,0,3)
        nmonth=str_get_cols(newstrings,4,5)
        nday=str_get_cols(newstrings,6,7)
        nhour=str_get_cols(newstrings,8,9)
        nmdh=str_get_cols(newstrings,4,9)
        nymd=str_get_cols(newstrings,0,7)
        nmonthind=toint(nmonth)
        print("Previous Date: YYYYMMDDHH : "+nymd+nhour+" ")
        ecp_file ="/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gfsv16/elsa/"+ms+"/ecmwf/U1D07"+daym+hourm+"0007"+nday+nhour+"001.grb"
         if (isfilepresent(ecp_file)) then
          print("EC previous fcst file found!")
         else
          print("EC previous fcst file is missing...")
          system("pwd")
         end if
        ecp=addfile(ecp_file,"r")
        varp = "TP_GDS0_SFC"
        precipprodp=ecp->$varp$
        precipplotprod=precipprod-precipprodp
        ;ec_array(h,:,:) = precipprod
        ;precipplotprod=(/precipprod/)
        ;precipplotprod=ec_array(h,:,:)+ec_array(h-1,:,:)+ec_array(h-2,:,:)+ec_a;rray(h-3,:,:)
        precipplotprod=precipplotprod*39.37
        precipplotprod!0 = "lat"
        precipplotprod!1 = "lon"
        precipplotprod&lat = lat
        precipplotprod&lon = lon

     end if
     end if
     end if
     ;end if

     accum_str = "24-h"
     gsn_define_colormap(wks,"temp")     
     res@gsnRightString="24-h QPF (in.)"
     res@gsnLeftString="EC fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.3i",fhours(h))+")"
     res@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
   ; res@cnLevels=(/.01,0.50,1.00,1.50,2.00,3.0,4.00,5.0,6.00,8.0,10.,15.0,20.0,25.0,30.0,35.0,40.0,45.0,50.0,60.0/)
   ; res@cnLevels=(/.01,0.25,0.50,0.75,1.00,1.5,2.00,3.0,4.00,5.0,6.0,8.00,10.0,12.5,15.0,20.0,25.0,30.0,40.0,45.0/)
     ;res@cnLevels=(/.01,0.25,0.50,1.00,1.50,2.0,3.00,4.0,5.00,6.0,7.0,8.00,9.00,10.0,12.5,15.0,17.5,20.0,25.0,30.0/)
   ; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0,14.0,16.0,18.0,20.0/)
   ; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.00,4.00,5.00,6.00,7.00,7.50,8.00,9.00,10.0/)
     res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0/)

     plot(0) = gsn_csm_contour_map(wks,precipplotprod,res)

  else if (var_str .eq. "totalprecip") then

     if (fhours(h).eq.0) then
        field1=phys1->TMP_P0_L103_GLL0({2},:,:)
        field2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field3=phys1->TMP_P0_L103_GLL0({2},:,:)
        field4=phys1->TMP_P0_L103_GLL0({2},:,:)
        anlfield1=phys1->TMP_P0_L103_GLL0({2},:,:)
        anlfield2=phys1->TMP_P0_L103_GLL0({2},:,:)
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield1*0.
        anlfield2=anlfield2*0.

     else if (fhours(h).eq.6) then
        field1:=phys1->APCP_P8_L1_GLL0_acc
        field2:=phys2->APCP_P8_L1_GLL0_acc
        field3:=phys3->APCP_P8_L1_GLL0_acc
        field4:=phys4->APCP_P8_L1_GLL0_acc
        anlfield2:=anl2->A_PCP_GDS5_SFC_acc6h(:,:)
        field1=field1*0.03937
        field2=field2*0.03937
        field3=field3*0.03937
        field4=field4*0.03937
        anlfield2=anlfield2*0.03937
        anlfield1:=anlfield2
     else
        temp1=phys1->APCP_P8_L1_GLL0_acc6h
        temp2=phys2->APCP_P8_L1_GLL0_acc6h
        temp3=phys3->APCP_P8_L1_GLL0_acc6h
        temp4=phys4->APCP_P8_L1_GLL0_acc6h
        anltemp2=anl2->A_PCP_GDS5_SFC_acc6h(:,:)
        field1=field1+(temp1*0.03937)
        field2=field2+(temp2*0.03937)
        field3=field3+(temp3*0.03937)
        field4=field4+(temp4*0.03937)
        anlfield2=anlfield2+(anltemp2*0.03937)
        anlfield1=anlfield2
     end if
     end if

     if (fhours(h) .eq. 6) then
        lat2d = anl2->g5_lat_0
        lon2d = anl2->g5_lon_1
        anlfield1@lat2d = lat2d
        anlfield1@lon2d = lon2d
        anlfield2@lat2d = lat2d
        anlfield2@lon2d = lon2d
     end if

     accum_str = sprinti("%0.1i",fhours(h))+"-h" 
     res@gsnRightString=accum_str+" QPF"
     res@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
  ;; Change Contour Levels Here
  ;; Last line without a semicolon will be used in all plots
     res@cnLevels=(/.01,0.50,1.00,1.50,2.00,3.0,4.00,5.0,6.00,8.0,10.,15.0,20.0,25.0,30.0,35.0,40.0,45.0,50.0,60.0/)
   ; res@cnLevels=(/.01,0.25,0.50,0.75,1.00,1.5,2.00,3.0,4.00,5.0,6.0,8.00,10.0,12.5,15.0,20.0,25.0,30.0,40.0,45.0/)
   ; res@cnLevels=(/.01,0.25,0.50,1.00,1.50,2.0,3.00,4.0,5.00,6.0,7.0,8.00,9.00,10.0,12.5,15.0,17.5,20.0,25.0,30.0/)
   ; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.50,2.0,2.50,3.0,4.0,5.00,6.00,8.00,10.0,12.0,14.0,16.0,18.0,20.0/)
   ; res@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.00,4.00,5.00,6.00,7.00,7.50,8.00,9.00,10.0/)


  else if (var_str .eq. "ptype") then

     field1=new((/721,1440/),float)
     field2=new((/721,1440/),float)
     field3=new((/721,1440/),float)
     field4=new((/721,1440/),float)

     ra1=phys1->CRAIN_P0_L1_GLL0
     zr1=phys1->CFRZR_P0_L1_GLL0
     ip1=phys1->CICEP_P0_L1_GLL0
     sn1=phys1->CSNOW_P0_L1_GLL0
     ra2=phys2->CRAIN_P0_L1_GLL0
     zr2=phys2->CFRZR_P0_L1_GLL0
     ip2=phys2->CICEP_P0_L1_GLL0
     sn2=phys2->CSNOW_P0_L1_GLL0
     ra3=phys3->CRAIN_P0_L1_GLL0
     zr3=phys3->CFRZR_P0_L1_GLL0
     ip3=phys3->CICEP_P0_L1_GLL0
     sn3=phys3->CSNOW_P0_L1_GLL0
     ra4=phys4->CRAIN_P0_L1_GLL0
     zr4=phys4->CFRZR_P0_L1_GLL0
     ip4=phys4->CICEP_P0_L1_GLL0
     sn4=phys4->CSNOW_P0_L1_GLL0

     field1(:,:)=where(sn1 .eq. 1, 1, field1(:,:))
     field1(:,:)=where(ip1 .eq. 1, 2, field1(:,:))
     field1(:,:)=where(zr1 .eq. 1, 3, field1(:,:))
     field1(:,:)=where(ra1 .eq. 1, 4, field1(:,:))
     field2(:,:)=where(sn2 .eq. 1, 1, field2(:,:))
     field2(:,:)=where(ip2 .eq. 1, 2, field2(:,:))
     field2(:,:)=where(zr2 .eq. 1, 3, field2(:,:))
     field2(:,:)=where(ra2 .eq. 1, 4, field2(:,:))
     field3(:,:)=where(sn3 .eq. 1, 1, field3(:,:))
     field3(:,:)=where(ip3 .eq. 1, 2, field3(:,:))
     field3(:,:)=where(zr3 .eq. 1, 3, field3(:,:))
     field3(:,:)=where(ra3 .eq. 1, 4, field3(:,:))
     field4(:,:)=where(sn4 .eq. 1, 1, field4(:,:))
     field4(:,:)=where(ip4 .eq. 1, 2, field4(:,:))
     field4(:,:)=where(zr4 .eq. 1, 3, field4(:,:))
     field4(:,:)=where(ra4 .eq. 1, 4, field4(:,:))

     if (plot_WXT) then
        anlfield1:=field1*0.
        anlfield2:=field2*0.
     end if

     copy_VarCoords(ra1,field1)
     copy_VarCoords(ra1,field2)
     copy_VarCoords(ra1,field3)
     copy_VarCoords(ra1,field4)
     copy_VarCoords(ra1,anlfield1)
     copy_VarCoords(ra1,anlfield2)

     res@gsnRightString="Instant. P-Type"
     res@cnLevels=(/1.5,2.5,3.5/)
     res@cnFillColors=(/"deepskyblue1","darkorchid1","deeppink1","green3"/)
     res@lbLabelStrings=(/"snow (1)","ice pellets (2)","freezing rain (3)","rain (4)"/)
     res@lbLabelAlignment="BoxCenters"

;  res@pmLabelBarHeightF=.05
;  res@lbLabelFontHeightF=.008


; 6-h NOHRSC available beginning Winter 2017-18
  else if (((str_get_cols(var_str,-4,-1) .eq. "snod") .or. (str_get_cols(var_str,-5,-1) .eq. "weasd")) .and. (datemodel .ge. nohrsc_change_date2)) then

     if (str_get_cols(var_str,-4,-1) .eq. "snod") then
        field1=phys1->SNOD_P0_L1_GLL0
        field2=phys2->SNOD_P0_L1_GLL0
        field3=phys3->SNOD_P0_L1_GLL0
        field4=phys4->SNOD_P0_L1_GLL0
        field1=field1*39.3701
        field2=field2*39.3701
        field3=field3*39.3701
        field4=field4*39.3701
        snow_type = "SNOD"
     else if (str_get_cols(var_str,-5,-1) .eq. "weasd") then
        field1=phys1->WEASD_P0_L1_GLL0
        field2=phys2->WEASD_P0_L1_GLL0
        field3=phys3->WEASD_P0_L1_GLL0
        field4=phys4->WEASD_P0_L1_GLL0
        field1=field1*0.03937*10
        field2=field2*0.03937*10
        field3=field3*0.03937*10
        field4=field4*0.03937*10
        snow_type = "WEASD"
     end if
     end if

     field1_array(h,:,:) = field1
     field2_array(h,:,:) = field2
     field3_array(h,:,:) = field3
     field4_array(h,:,:) = field4

     if (fhours(h) .eq. 0) then
        anlfield1=phys1->SNOD_P0_L1_GLL0
        anlfield2=phys1->SNOD_P0_L1_GLL0
     else
        anlfield1:=anl2->ASNOW_P8_L1_GLC0_acc(:,:)
        anlfield2:=anl2->ASNOW_P8_L1_GLC0_acc(:,:)
        anlfield2=anlfield2*39.3701
        lat2d=anl2->gridlat_0
        lon2d=anl2->gridlon_0
        anlfield1@lat2d=lat2d
        anlfield1@lon2d=lon2d
        anlfield2@lat2d=lat2d
        anlfield2@lon2d=lon2d
        anlfield2_array(h,:,:) = anlfield2
     end if


     if (fhours(h) .eq. 0) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,0) .eq. "6") .and. (fhours(h) .ge. 6)) then
        field1=field1_array(h,:,:)-field1_array(h-1,:,:)
        field2=field2_array(h,:,:)-field2_array(h-1,:,:)
        field3=field3_array(h,:,:)-field3_array(h-1,:,:)
        field4=field4_array(h,:,:)-field4_array(h-1,:,:)
        anlfield1=dim_sum_n(anlfield2_array(h-1:h,:,:),0)
        anlfield2=dim_sum_n(anlfield2_array(h-1:h,:,:),0)
      ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(h-1,:,:)
      ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(h-1,:,:)
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .lt. 24)) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .ge. 24)) then
        field1=field1_array(h,:,:)-field1_array(h-4,:,:)
        field2=field2_array(h,:,:)-field2_array(h-4,:,:)
        field3=field3_array(h,:,:)-field3_array(h-4,:,:)
        field4=field4_array(h,:,:)-field4_array(h-4,:,:)
        anlfield1=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
        anlfield2=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
      ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
      ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
     else if (str_get_cols(var_str,0,4) .eq. "total") then
        field1=field1_array(h,:,:)-field1_array(0,:,:)
        field2=field2_array(h,:,:)-field2_array(0,:,:)
        field3=field3_array(h,:,:)-field3_array(0,:,:)
        field4=field4_array(h,:,:)-field4_array(0,:,:)
        anlfield1=dim_sum_n(anlfield2_array(0:h,:,:),0)
        anlfield2=dim_sum_n(anlfield2_array(0:h,:,:),0)
      ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
      ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
     end if
     end if
     end if
     end if
     end if


     if (str_get_cols(var_str,0,0) .eq. "6") then
        accum_str = "6-h"     
     else if (str_get_cols(var_str,0,1) .eq. "24") then
        accum_str = "24-h"     
     else if (str_get_cols(var_str,0,4) .eq. "total") then
        accum_str = sprinti("%0.1i",fhours(h))+"-h" 
     end if
     end if
     end if

     res@gsnRightString=accum_str+" "+snow_type
     res@cnFillColors=(/"transparent","cyan","cyan3","dodgerblue","dodgerblue3","dodgerblue4","purple1","purple3","purple4","orchid1","orchid3","orchid4","peachpuff","peachpuff3","peachpuff4","brown1","brown3","brown4","azure2","azure3","azure4","white"/)
     res@cnLevels=(/1,2,3,4,5,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36/)



; 24-h NOHRSC GRIB2 available beginning Winter 2016-17
  else if (((str_get_cols(var_str,-4,-1) .eq. "snod") .or. (str_get_cols(var_str,-5,-1) .eq. "weasd")) .and. (datemodel .ge. nohrsc_change_date1 .and. datemodel .lt. nohrsc_change_date2)) then

     if (str_get_cols(var_str,-4,-1) .eq. "snod") then
        field1=phys1->SNOD_P0_L1_GLL0
        field2=phys2->SNOD_P0_L1_GLL0
        field3=phys3->SNOD_P0_L1_GLL0
        field4=phys4->SNOD_P0_L1_GLL0
        field1=field1*39.3701
        field2=field2*39.3701
        field3=field3*39.3701
        field4=field4*39.3701
        snow_type = "SNOD"
     else if (str_get_cols(var_str,-5,-1) .eq. "weasd") then
        field1=phys1->WEASD_P0_L1_GLL0
        field2=phys2->WEASD_P0_L1_GLL0
        field3=phys3->WEASD_P0_L1_GLL0
        field4=phys4->WEASD_P0_L1_GLL0
        field1=field1*0.03937*10
        field2=field2*0.03937*10
        field3=field3*0.03937*10
        field4=field4*0.03937*10
        snow_type = "WEASD"
     end if
     end if

     field1_array(h,:,:) = field1
     field2_array(h,:,:) = field2
     field3_array(h,:,:) = field3
     field4_array(h,:,:) = field4

     if ((fhours(h) .eq. 0) .or. (str_get_cols(var_str,0,1) .eq. "6h")) then
        anlfield1=phys1->SNOD_P0_L1_GLL0
        anlfield2=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,4) .eq. "total") .and. (mod(fhours(h),24) .ne. 0)) then
        anlfield1:=phys1->SNOD_P0_L1_GLL0
        anlfield2:=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,2) .eq. "24h") .and. (mod(fhours(h),12) .ne. 0)) then
        anlfield1:=phys1->SNOD_P0_L1_GLL0
        anlfield2:=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else
        anlfield1:=anl2->ASNOW_P8_L1_GLC0_acc(:,:)
        anlfield2:=anl2->ASNOW_P8_L1_GLC0_acc(:,:)
        anlfield2=anlfield2*39.3701
        lat2d=anl2->gridlat_0
        lon2d=anl2->gridlon_0
        anlfield1@lat2d=lat2d
        anlfield1@lon2d=lon2d
        anlfield2@lat2d=lat2d
        anlfield2@lon2d=lon2d
        anlfield2_array(h,:,:) = anlfield2
     end if
     end if
     end if


     if (fhours(h) .eq. 0) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
     else if ((str_get_cols(var_str,0,0) .eq. "6") .and. (fhours(h) .ge. 6)) then
        field1=field1_array(h,:,:)-field1_array(h-1,:,:)
        field2=field2_array(h,:,:)-field2_array(h-1,:,:)
        field3=field3_array(h,:,:)-field3_array(h-1,:,:)
        field4=field4_array(h,:,:)-field4_array(h-1,:,:)
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .lt. 24)) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .ge. 24)) then
        field1=field1_array(h,:,:)-field1_array(h-4,:,:)
        field2=field2_array(h,:,:)-field2_array(h-4,:,:)
        field3=field3_array(h,:,:)-field3_array(h-4,:,:)
        field4=field4_array(h,:,:)-field4_array(h-4,:,:)

        if (mod(fhours(h),12) .eq. 0) then
           anlfield1=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
           anlfield2=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
         ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
         ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
        else
           anlfield1=anlfield2*0.
           anlfield2=anlfield2*0.
        end if

     else if (str_get_cols(var_str,0,4) .eq. "total") then
        field1=field1_array(h,:,:)-field1_array(0,:,:)
        field2=field2_array(h,:,:)-field2_array(0,:,:)
        field3=field3_array(h,:,:)-field3_array(0,:,:)
        field4=field4_array(h,:,:)-field4_array(0,:,:)

        if (mod(fhours(h),24) .eq. 0) then
           anlfield1=dim_sum_n(anlfield2_array(0:h,:,:),0)
           anlfield2=dim_sum_n(anlfield2_array(0:h,:,:),0)
         ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
         ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
        else
           anlfield1=anlfield2*0.
           anlfield2=anlfield2*0.
        end if

     end if
     end if
     end if
     end if
     end if


     if (str_get_cols(var_str,0,0) .eq. "6") then
        accum_str = "6-h"     
     else if (str_get_cols(var_str,0,1) .eq. "24") then
        accum_str = "24-h"     
     else if (str_get_cols(var_str,0,4) .eq. "total") then
        accum_str = sprinti("%0.1i",fhours(h))+"-h" 
     end if
     end if
     end if

     res@gsnRightString=accum_str+" "+snow_type
     res@cnFillColors=(/"transparent","cyan","cyan3","dodgerblue","dodgerblue3","dodgerblue4","purple1","purple3","purple4","orchid1","orchid3","orchid4","peachpuff","peachpuff3","peachpuff4","brown1","brown3","brown4","azure2","azure3","azure4","white"/)
     res@cnLevels=(/1,2,3,4,5,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36/)



; 24-h NOHRSC NetCDF available beginning Winter 2016-17
  else if (((str_get_cols(var_str,-4,-1) .eq. "snod") .or. (str_get_cols(var_str,-5,-1) .eq. "weasd")) .and. (datemodel .lt. nohrsc_change_date1)) then

     if (str_get_cols(var_str,-4,-1) .eq. "snod") then
        field1=phys1->SNOD_P0_L1_GLL0
        field2=phys2->SNOD_P0_L1_GLL0
        field3=phys3->SNOD_P0_L1_GLL0
        field4=phys4->SNOD_P0_L1_GLL0
        field1=field1*39.3701
        field2=field2*39.3701
        field3=field3*39.3701
        field4=field4*39.3701
        snow_type = "SNOD"
     else if (str_get_cols(var_str,-5,-1) .eq. "weasd") then
        field1=phys1->WEASD_P0_L1_GLL0
        field2=phys2->WEASD_P0_L1_GLL0
        field3=phys3->WEASD_P0_L1_GLL0
        field4=phys4->WEASD_P0_L1_GLL0
        field1=field1*0.03937*10
        field2=field2*0.03937*10
        field3=field3*0.03937*10
        field4=field4*0.03937*10
        snow_type = "WEASD"
     end if
     end if

     field1_array(h,:,:) = field1
     field2_array(h,:,:) = field2
     field3_array(h,:,:) = field3
     field4_array(h,:,:) = field4

     if ((fhours(h) .eq. 0) .or. (str_get_cols(var_str,0,1) .eq. "6h")) then
        anlfield1=phys1->SNOD_P0_L1_GLL0
        anlfield2=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if (((str_get_cols(var_str,0,4) .eq. "total") .or. (str_get_cols(var_str,0,2) .eq. "24h")) .and. (mod(fhours(h),24) .ne. 0)) then
        anlfield1:=phys1->SNOD_P0_L1_GLL0
        anlfield2:=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if (scripthour .ne. 12) then
        anlfield1:=phys1->SNOD_P0_L1_GLL0
        anlfield2:=phys1->SNOD_P0_L1_GLL0
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else
        anlfield1:=anl2->Data(:,:)
        anlfield2:=anl2->Data(:,:)
        anlfield2=anlfield2*39.3701
      ; lat2d=anl2->lat
      ; lon2d=anl2->lon
      ; anlfield1@lat2d=lat2d
      ; anlfield1@lon2d=lon2d
      ; anlfield2@lat2d=lat2d
      ; anlfield2@lon2d=lon2d
        lat2d=anl2->lat
        lon2d=anl2->lon
      ; lat1d@units = "degrees_north"
      ; lat1d@long_name = "lat"
      ; lon1d@units = "degrees_east"
      ; lon1d@long_name = "lon"
      ; anlfield2!0 = "lon"
      ; anlfield2!1 = "lat"
      ; anlfield2&lat = lat1d
      ; anlfield2&lon = lon1d
        anlfield2_array(h,:,:) = anlfield2
     end if
     end if
     end if


     if (fhours(h) .eq. 0) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
     else if ((str_get_cols(var_str,0,0) .eq. "6") .and. (fhours(h) .ge. 6)) then
        field1=field1_array(h,:,:)-field1_array(h-1,:,:)
        field2=field2_array(h,:,:)-field2_array(h-1,:,:)
        field3=field3_array(h,:,:)-field3_array(h-1,:,:)
        field4=field4_array(h,:,:)-field4_array(h-1,:,:)
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .lt. 24)) then
        field1=field1*0.
        field2=field2*0.
        field3=field3*0.
        field4=field4*0.
        anlfield1=anlfield2*0.
        anlfield2=anlfield2*0.
     else if ((str_get_cols(var_str,0,1) .eq. "24") .and. (fhours(h) .ge. 24)) then
        field1=field1_array(h,:,:)-field1_array(h-4,:,:)
        field2=field2_array(h,:,:)-field2_array(h-4,:,:)
        field3=field3_array(h,:,:)-field3_array(h-4,:,:)
        field4=field4_array(h,:,:)-field4_array(h-4,:,:)

        if (mod(fhours(h),24) .eq. 0) then
           anlfield1=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
           anlfield2=dim_sum_n(anlfield2_array(h-4:h,:,:),0)
         ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
         ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(h-4,:,:)
        else
           anlfield1=anlfield2*0.
           anlfield2=anlfield2*0.
        end if

     else if (str_get_cols(var_str,0,4) .eq. "total") then
        field1=field1_array(h,:,:)-field1_array(0,:,:)
        field2=field2_array(h,:,:)-field2_array(0,:,:)
        field3=field3_array(h,:,:)-field3_array(0,:,:)
        field4=field4_array(h,:,:)-field4_array(0,:,:)

        if (mod(fhours(h),24) .eq. 0) then
           anlfield1=dim_sum_n(anlfield2_array(0:h,:,:),0)
           anlfield2=dim_sum_n(anlfield2_array(0:h,:,:),0)
         ; anlfield1=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
         ; anlfield2=anlfield2_array(h,:,:)-anlfield2_array(0,:,:)
        else
           anlfield1=anlfield2*0.
           anlfield2=anlfield2*0.
        end if

     end if
     end if
     end if
     end if
     end if


     if (str_get_cols(var_str,0,0) .eq. "6") then
        accum_str = "6-h"
     else if (str_get_cols(var_str,0,1) .eq. "24") then
        accum_str = "24-h"
     else if (str_get_cols(var_str,0,4) .eq. "total") then
        accum_str = sprinti("%0.1i",fhours(h))+"-h"
     end if
     end if
     end if

     res@gsnRightString=accum_str+" "+snow_type
     res@cnFillColors=(/"transparent","cyan","cyan3","dodgerblue","dodgerblue3","dodgerblue4","purple1","purple3","purple4","orchid1","orchid3","orchid4","peachpuff","peachpuff3","peachpuff4","brown1","brown3","brown4","azure2","azure3","azure4","white"/)
     res@cnLevels=(/1,2,3,4,5,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36/)


  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if



  ;if (plot_diff) then
     ;anl_str = anl_str1
     ;if ((diff_str .eq. "anl1") .and. plot_EC) then                            ; do difference using EC analysis
        ;field1 = field1-anlfield1
        ;field2 = field2-anlfield1
        ;field3 = field3-anlfield1
        ;field4 = field4-anlfield1

        ;if (var_str .eq. "500") then
           ;field1 = hght1-anlhght1
           ;field2 = hght2-anlhght1
           ;field3 = hght3-anlhght1
           ;field4 = hght4-anlhght1
        ;end if

     ;else if ((diff_str .eq. "anl1") .and. (plot_EC .eq. False)) then          ; skip difference using EC at 06/18z times
        ;field1 = field1*0.
        ;field2 = field2*0.
        ;field3 = field3*0.
        ;field4 = field4*0.
        ;resdif@cnConstFLabelString="No "+hour+"Z "+anl_str1+" Analysis"
     ;else if (diff_str .eq. "anl2") then                                       ; do difference using GFS or NAM analysis
        ;field1 = field1-anlfield2
        ;field2 = field2-anlfield2
        ;field3 = field3-anlfield2
        ;field4 = field4-anlfield2
        ;anl_str = anl_str2
        ;if (var_str .eq. "500") then
           ;field1 = hght1-anlhght2
           ;field2 = hght2-anlhght2
           ;field3 = hght3-anlhght2
           ;field4 = hght4-anlhght2
        ;end if
     ;end if
     ;end if
     ;end if
     ;plot_res = resdif
  ;else
     ;plot_res = res
  ;end if




  ;res@gsnRightStringFontColor = "red3"
  ;res@gsnLeftStringFontColor = "red3"
  ;if ((plot_EC .eq. False) .and. (plot_ST4 .eq. False) .and. (plot_NOHRSC .eq. False) .and. (plot_URMA .eq. False) .and. (plot_WXT .eq. False)) then
     ;anlfield1=anlfield1*0
     ;res@cnConstFLabelString="No "+hour+"Z "+anl_str1+" Analysis"
     ;res@gsnLeftString=anl_str1+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",0)+")"
  ;else
     ;res@gsnLeftString=anl_str1+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",0)+")"
  ;end if
  if (plot_ST4) then
     res@gsnLeftString=anl_str1+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year
     res@gsnRightString=accum_str+" QPE"
  else if (plot_NOHRSC) then
     res@gsnLeftString=anl_str1+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year
     res@gsnRightString=accum_str+" Snowfall"
     if (fhours(h) .gt. 0) then
        res@cnConstFLabelString="Valid "+accum_str+" "+anl_str1+" Analysis Does Not Exist"
     end if
  else if (plot_WXT) then
     res@gsnLeftString="METAR P-Type Obs valid "+hour+"Z "+day+ " "+months(monthind0)+ " " +year
     res@gsnRightString="Instant. P-Type"
  else if (plot_URMA) then
     res@gsnLeftString=anl_str1+" Anl valid "+hour0+"Z "+day0+ " "+months(monthind0)+ " " +year0
     res@gsnRightString="Instant. Total Cloud (%)"
  end if
  end if
  end if
  end if
  ;plot(1) = gsn_csm_contour_map(wks,anlfield1,res)       ; create a default plot

  if (plot_ST4 .or. plot_NOHRSC) then
     res@gsnLeftString=anl_str1+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year
  else if (plot_WXT) then
     res@gsnLeftString="METAR P-Type Obs valid "+hour+"Z "+day+ " "+months(monthind0)+ " " +year
  else if (plot_URMA) then
     res@gsnLeftString=anl_str1+" Anl valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year
  else
     ;res@gsnLeftString=anl_str2+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",0)+")"
     ;res@cnConstFLabelString="Analysis not plotted"
  end if
  end if
  end if
  ;plot(4) = gsn_csm_contour_map(wks,anlfield2,res)       ; create a default plot


  ;if (plot_contours) then
     ;if (plot_diff .eq. False) then
        ;overlay(plot(0),plot_line0)
        ;overlay(plot(2),plot_line2)
        ;overlay(plot(3),plot_line3)
        ;overlay(plot(5),plot_line5)
     ;end if
     ;if (plot_EC) then
        ;overlay(plot(1),plot_line1)
     ;end if
     ;overlay(plot(4),plot_line4)
  ;else if (plot_barbs) then
     ;if (plot_diff .eq. False) then
        ;overlay(plot(0),plot_windb0)
        ;overlay(plot(0),plot_winda0)
        ;overlay(plot(2),plot_windb2)
        ;overlay(plot(2),plot_winda2)
        ;overlay(plot(3),plot_windb3)
        ;overlay(plot(3),plot_winda3)
        ;overlay(plot(5),plot_windb5)
        ;overlay(plot(5),plot_winda5)
     ;end if
     ;if (plot_EC) then
        ;overlay(plot(1),plot_windb1)
        ;overlay(plot(1),plot_winda1)
     ;end if
     ;overlay(plot(4),plot_windb4)
     ;overlay(plot(4),plot_winda4)
  ;end if
  ;end if


  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
; resP@txPerimOn=True
; resP@txJust="TopCenter"
; resP@txPosYF=0.8
  resP@gsnPanelLabelBar=False
  resP@gsnFrame=False

  ;if (plot_diff) then
     ;tname = "FV3GFS forecasts initialized at "+hourm+"Z "+daym+" "+months(toin;t(monthm))+ " "+yearm+" (F"+sprinti("%0.2i",fhours(h))+")"+ \
;                 " minus "+anl_str+" Analysis valid at "+hour+"Z "+day+ " "+mon;ths(monthind)+" "+year
;  else
     ;tname = "FV3GFS forecasts initialized at "+hourm+"Z "+daym+" "+months(toin;t(monthm))+ " " +yearm+ \
;             " and valid at "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ "; (F"+sprinti("%0.2i",fhours(h))+")"
  ;end if
  ;resP@txString = tname
  gsn_panel(wks,plot,(/1,1/),resP)



 
print("drawing figure")
;draw(plot)
print("framing figure")
frame(wks)
print("deleting workstation")
delete(wks)
if (plot_NAM) then
   delete(lat2d)
   delete(lon2d)
   delete(anl2)
   if (str_get_cols(var_str,-4,-1) .eq. "wind" .or. var_str .eq. "shear") then
      delete(anlu2)
      delete(anlv2)
   end if
   delete(anlfield2)
   delete(plot)
   delete(resP)
   delete(wres)
   delete(hres)
end if
if ((plot_ST4 .or. plot_NOHRSC) .and. (str_get_cols(var_str,0,1) .eq. "6h") .and. (fhours(h) .gt. 0) .and. (datemodel .ge. nohrsc_change_date2)) then
   delete(lat2d)
   delete(lon2d)
   delete(anl2)
   delete(anlfield1)
   delete(anlfield2)
   delete(plot)
   delete(resP)
   delete(wres)
   delete(hres)
end if
;if ((plot_ST4 .or. plot_NOHRSC) .and. (str_get_cols(var_str,0,2) .eq. "24h") .and. (fhours(h) .ge. 24)) then
if ((plot_ST4 .or. plot_NOHRSC) .and. (str_get_cols(var_str,0,2) .eq. "24h") .and. (fhours(h) .ge. 24) .and. (all(anlfield2 .ne. 0))) then
   delete(lat2d)
   delete(lon2d)
   delete(anl2)
   delete(anlfield1)
   delete(anlfield2)
   delete(plot)
   delete(resP)
   delete(wres)
   delete(hres)
end if
if (plot_URMA .and. (fhours(h) .gt. 0)) then
   delete(lat2d)
   delete(lon2d)
   delete(anl2)
   delete(anlfield1)
   delete(anlfield2)
   delete(plot)
   delete(resP)
   delete(wres)
   delete(hres)
end if



system("convert "+graphic_name+".png -trim +repage "+graphic_name+".png")
;end do
end



