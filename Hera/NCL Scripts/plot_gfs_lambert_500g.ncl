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
  if (isdefined("images_path")) then
        print("images_path defined on command line: "+images_path)
        image_dir = images_path
  else
        print("No images_path defined on command line")
        image_dir = "images_path"
  end if

;==================================================================

; Pre-defined domain definitions
  minlatlist=(/15.0,35.0,25.0,31.0,40.0,25.5,35.0,42.0,41.0,34.0,36.0,34.0,24.5,12.5,10,28,1,-40,15,10,3/)
  maxlatlist=(/60.0,75.0,50.0,43.0,50.0,37.5,44.0,50.0,49.5,43.0,47.5,42.5,35.0,35,27,47.5,60,-1,62.5,29,35/)
  minlonlist=(/-135.0,160.0,-120,-125.0,-125.0,-108.0,-108.0,-110.0,-97.0,-97.0,-84.0,-86.0,-92.0,-105,-81,-95,110,137.5,-167.5,-171,-136/)
  maxlonlist=(/-60.0,250.0,-72.5,-105.0,-107.0,-90.0,-92.0,-95.0,-80.5,-83.0,-66.0,-72.0,-76.0,-72.5,-55,-65,179,192.5,-115,-141,-82/)
  regionlist=(/"us","ak","uszoom","sw","nw","t","cp","np","mw","ov","ne","ma","se","gom","pr","nwatl","wpac","spac","epac","hi","epactc"/)
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

  ;dateend=ut_inv_calendar(toint(endints(:,0)),toint(endints(:,1)),toint(endints;(:,2)),toint(endints(:,3)),0,0,timeunits,0)
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
    ;print((/fhours(h)/))
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

;Obtaining GFSv16 fcst file
       gfs_file ="/scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/download_HPSS_data/gfs."+ymdm+"/"+hourm+"/atmos/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))
       if (isfilepresent(gfs_file)) then
          print("GFSv16 fcst file found!")
       else
          print("GFSv16 fcst file is missing...")
          system("pwd")
       end if

       gfs=addfile(gfs_file,"r")


; ============================================================================
; ======================= Download data ======================================
; ============================================================================ 


   lat := gfs->lat_0
   lon := gfs->lon_0

   slpprod=gfs->HGT_P0_L100_GLL0({50000},:,:)

   slpprod=slpprod/10. ;convert from m to dam
   slpprod!0 = "lat"
   slpprod!1 = "lon"
   slpprod&lat = lat
   slpprod&lon = lon

   vortprod=gfs->ABSV_P0_L100_GLL0({50000},:,:)
   vortprod=vortprod*10^5
   vortprod!0 = "lat"
   vortprod!1 = "lon"
   vortprod&lat = lat
   vortprod&lon = lon
   ;dif = slpprod
   ;dif = slppara - slpprod
;   printVarSummary(dif)
;   printMinMax(dif,True)

   ;dif_anl = slp_anl
   ;dif_anl = slppara - slp_anl

;   slpprod = smth9_Wrap(slpprod,0.50,-0.25,False)
;   slppara = smth9_Wrap(slppara,0.50,-0.25,False)
;   slp_anl = smth9_Wrap(slp_anl,0.50,0.25,False)


; ============================================================================
; ======================= Make plot ==========================================
; ============================================================================
plot_dir = "/scratch2/NCEPDEV/stmp1/Shannon.Shields/scripts/gfsv16/"+casename+"/images/"+ymd+hour+"/"
system("mkdir -p "+plot_dir)

  wks  = gsn_open_wks("png", plot_dir+"gfs_"+scriptregion+"_500g_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h)))       
  ;gsn_define_colormap(wks,"BlueWhiteOrangeRed") 
  gsn_define_colormap(wks,"vort")
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
  res@gsnRightString="500-hPa g (dam)"
  res@gsnAddCyclic=False
  res@gsnLeftString="GFS fcst init. "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.3i",fhours(h))+")"
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
  res@pmLabelBarHeightF=.05
  res@pmLabelBarOrthogonalPosF=-0.016
  res@lbLabelFontHeightF=.008
  res@gsnLeftStringFontHeightF=.01
  res@gsnRightStringFontHeightF=.01
  res@cnFillOn=True
  res@mpFillOn=True
  res@cnFillMode="RasterFill"
  res@cnRasterSmoothingOn=True
  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnFillColors(0)=-1
  res@cnLevels=ispan(16,50,4)
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
  ;res@lbLabelStride=1
  res@cnLinesOn=False
  res@lbLabelAutoStride=True
  res@gsnFrame=False
   res@lbLabelBarOn=True
  if scriptregion.eq."us" then
    res@mpNationalLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF=2.0
  end if


  res@cnLineLabelInterval=1
  res@cnLineLabelDensityF=1.5
  plot(0) = gsn_csm_contour_map(wks,vortprod,res)       ; create a default plot

  ;resdif=True
  ;resdif=res
  ;resdif@cnFillPalette=("BlueWhiteOrangeRed")
  ;delete(resdif@cnFillColors)
  ;delete(resdif@cnLevels)
  ;resdif@cnLevels:=ispan(-50,50,10)
  ;resdif@gsnLeftString="GFSv16 fcst minus GFSv15 fcst valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  ;plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

; -----------------------------------------------

  ;resdif@gsnLeftString="GFSv16 fcst (F"+sprinti("%0.2i",fhours(h))+") minus GFS analysis (contours) valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year
  ;plot(3) = gsn_csm_contour_map(wks,dif_anl,resdif)       ; create a default plot

;---------------------------------------------------------------------

  hres=True
  hres@cnLinesOn=True
  hres@cnFillOn=False
  hres@cnInfoLabelOn=False
  hres@cnLevelSelectionMode="ExplicitLevels"
  hres@gsnMaximize=True
  hres@cnLineLabelInterval=1
  hres@gsnLeftString=""
  hres@gsnRightString=""
  hres@cnLevels=ispan(480,660,6)
  hres@gsnDraw=False
  hres@cnLabelMasking=True
  hres@cnLineLabelBackgroundColor=-1
  hres@cnLineLabelAngleF=0.0
  hres@cnLineThicknessF=4.0
  hres@cnLineLabelFontHeightF=.009
  hres@cnLineLabelsOn=True
  hres@cnLineColor="black"
  hres@cnLowLabelsOn=False
  hres@cnLowLabelBackgroundColor=-1
  hres@cnLowLabelFontColor="black"
  hres@cnHighLabelFontHeightF=.019
  hres@cnHighLabelFont = "helvetica-bold"
  hres@cnLowLabelFont = "helvetica-bold"
  hres@gsnFrame=False

  ;print("plotting height")
  plot_heightprod=gsn_csm_contour(wks,slpprod,hres)
  overlay(plot(0),plot_heightprod)

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

system("convert "+plot_dir+"gfs_"+scriptregion+"_500g_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h))+".png -trim +repage "+plot_dir+"gfs_"+scriptregion+"_500g_"+ms+"_"+casename+"_"+sprinti("%0.3i",fhours(h))+".png")              

;end do

;------------------------------------------------

print("======================")
print("Script has finished!")
print("======================")


end



