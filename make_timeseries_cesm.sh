#!/bin/bash

module load cdo

# Computes the timeseries of individual variables [time,lat,lon,*lev]
# Computes the monthly means [month,lat,lon,*lev] -> not yet!
# Computes the area-weighted global mean timeseries [time,*lev] -> not yet!


# Author: Ben Buchovecky
# Last edited: 2023-10-02
 

## Caution! Parallel arrays! ##
caselist=("cnstVPDforPhoto_PI_SOM")
dirlist=("/glade/campaign/univ/uwas0098")

ncase=${#caselist[@]}

# Generic component-model name:
# atm,cpl,esp,glc,ice,lnd,ocn,rof,wav
atm_varlist=()
lnd_varlist=(GSSHALN GSSUNLN BTRAN2 BTRANMN EFLX_LH_TOT VPD_CAN)

# Specific component-model name:
# cam,cice,cism,clm2,cpl,dart,datm,desp,dice,dlnd,docn,drof,dwav,mosart,pop,rtm
atm_scomp="cam"
lnd_scomp="clm2"

simtype="h0"

do_means=0
do_ts=1

ts_descr="allyears"
mon_avg_descr="month_avg"
glob_avg_descr="global_avg"

now="$(date +'%Y-%m-%dT%H-%M-%S')"
bashoutpath="/glade/u/home/bbuchovecky/scripts/hist"
bashout="${bashoutpath}/make_timeseries_cesm_${now}.txt"

mkdir -p ${bashoutpath}

echo "${now}" |& tee -a ${bashout}
echo "script:      $(basename "$0")" |& tee -a ${bashout}
echo "caselist:    ${caselist[@]}" |& tee -a ${bashout}
echo "dirlist:     ${dirlist[@]}" |& tee -a ${bashout}

echo "atm_scomp:   ${atm_scomp}" |& tee -a ${bashout}
echo "atm_varlist: ${atm_varlist[@]}" |& tee -a ${bashout}

echo "lnd_scomp:   ${lnd_scomp}" |& tee -a ${bashout}
echo "lnd_varlist: ${lnd_varlist[@]}" |& tee -a ${bashout}

echo "simtype:     ${simtype}" |& tee -a ${bashout}
echo "do_means:    ${do_means}" |& tee -a ${bashout}
echo "do_ts:       ${do_ts}" |& tee -a ${bashout}

echo "ts_file:       casename.scomp.${ts_descr}.var.nc" |& tee -a ${bashout}
echo "mon_avg_file:  casename.scomp.${mon_avg_descr}.var.nc" |& tee -a  ${bashout}
echo "glob_avg_file: casename.scomp.${glob_avg_descr}.var.nc" |& tee -a ${bashout}

for (( c=0; c<${ncase}; c++ ))
do
  atm_srcdir="${dirlist[c]}/${caselist[$c]}/atm/hist"
  lnd_srcdir="${dirlist[c]}/${caselist[$c]}/lnd/hist"
	
  atm_outdir="${dirlist[c]}/${caselist[$c]}/tseries/TimeSeries"
  lnd_outdir="${dirlist[c]}/${caselist[$c]}/tseries/TimeSeries"
	
  if [ ${do_ts} == 1 ]
  then
    # Atmosphere
    echo "Starting atm timeseries" |& tee -a ${bashout}
    mkdir -p ${atm_outdir}
    for var in "${atm_varlist[@]}"
    do
      echo "    ${var}" |& tee -a ${bashout}
      cdo -mergetime [ -select,name=${var} ${atm_srcdir}/${caselist[$c]}.${atm_scomp}.${simtype}.*.nc ] ${atm_outdir}/${caselist[$c]}.${atm_scomp}.${simtype}.${ts_descr}.${var}.nc |& tee -a ${bashout}
      chmod a=r ${atm_outdir}/${caselist[$c]}.${atm_scomp}.${simtype}.${ts_descr}.${var}.nc 
    done
    echo "Done atm time series" |& tee -a ${bashout}
		
    # Land
    echo "Starting lnd timeseries" |& tee -a ${bashout}
    mkdir -p ${lnd_outdir}
    for var in "${lnd_varlist[@]}"
    do
      echo "    ${var}" |& tee -a ${bashout}
      cdo -mergetime [ -select,name=${var} ${lnd_srcdir}/${caselist[$c]}.${lnd_scomp}.${simtype}.*.nc ] ${lnd_outdir}/${caselist[$c]}.${lnd_scomp}.${simtype}.${ts_descr}.${var}.nc |& tee -a ${bashout}
      chmod a=r ${lnd_outdir}/${caselist[$c]}.${lnd_scomp}.${simtype}.${ts_descr}.${var}.nc  
    done
    echo "Done lnd time series"	|& tee -a ${bashout}
  fi
	
  if [ ${do_means} == 1 ]
  then
    # Atmosphere
    echo "Starting atm means" |& tee -a ${bashout}
    mkdir -p ${atm_outdir}/means
    # Monthly means
    # cdo -monmean ${atm_srcdir}/${caselist[$c]}.${atm_scomp}.${simtype}.*.nc ${atm_outdir}/means/${caselist[$c]}.${atm_scomp}.${simtype}.${mon_avg_descr}.${var}.nc |& tee -a ${bashout}
    # Area-weighted global means
    # cdo -fldmean,weights=FALSE [ -apply,mulcoslat ${atm_srcdir}/${caselist[$c]}.${atm_scomp}.${simtype}.*.nc ] ] ${atm_outdir}/means/${caselist[$c]}.${atm_scomp}.${simtype}.${glob_avg_descr}.${var}.nc |& tee -a ${bashout}
    echo "Done atm means" |& tee -a ${bashout}

    # Land
    echo "Starting lnd means" |& tee -a ${bashout} 
    mkdir -p ${lnd_outdir}/means
    # Monthly means
    # cdo -monmean ${lnd_srcdir}/${caselist[$c]}.${lnd_scomp}.${simtype}.*.nc ${lnd_outdir}/means/${caselist[$c]}.${lnd_scomp}.${simtype}.${mon_avg_descr}.${var}.nc |& tee -a ${bashout}
    # Area-weighted global means
    # cdo -fldmean,weights=FALSE [ -apply,mulcoslat ${lnd_srcdir}/${caselist[$c]}.${lnd_scomp}.${simtype}.*.nc ] ] ${lnd_outdir}/means/${caselist[$c]}.${lnd_scomp}.${simtype}.${glob_avg_descr}.${var}.nc |& tee -a ${bashout}
    echo "Done lnd means" |& tee -a ${bashout}
  fi
done

