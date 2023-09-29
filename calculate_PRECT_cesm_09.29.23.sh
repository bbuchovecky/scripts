#!/bin/bash

module load cdo

# Total precipitation rate [m/s], PRECT = PRECC + PRECL

now="$(date +'%Y-%m-%dT%H%M')"
bashoutpath="/glade/u/home/bbuchovecky/scripts/hist"

srcdir="/glade/campaign/univ/uwas0098"
outdir="/glade/campaign/univ/uwas0098"

casename="cnstVPDforPhoto_PI_SOM"
gcomp="atm"
scomp="cam"
simtype="h0"

srcpath="${srcdir}/${casename}/${gcomp}/hist"
outpath="${outdir}/${casename}/proc/tseries"

echo "Source: ${srcpath}"
echo "Out:    ${outpath}"

mkdir -p ${outpath}
mkdir -p ${bashoutpath} 

cdo -setattribute,calculated_PRECT@long_name="Total precipitation rate (PRECC+PRECL)",calculated_PRECT@units="m/s" -chname,"PRECC","calculated_PRECT" -add -mergetime [ -select,name=PRECC [ ${srcpath}/${casename}.${scomp}.${simtype}.*.nc ] ] -mergetime [ -select,name=PRECL [ ${srcpath}/${casename}.${scomp}.${simtype}.*.nc ] ] ${outpath}/${casename}.${scomp}.${simtype}.timeseries.calculated_PRECT.nc |& tee ${bashoutpath}/calculated_PRECT_${casename}_${now}.txt

echo "$(basename "$0")" >> ${bashoutpath}/calculated_PRECT_${casename}_${now}.txt
echo "input: ${srcpath}/${casename}.${scomp}.${simtype}.*.nc" >> ${bashoutpath}/calculated_PRECT_${casename}_${now}.txt
echo "output: ${outpath}/${casename}.${scomp}.${simtype}.timeseries.calculated_PRECT.nc" >> ${bashoutpath}/calculated_PRECT_${casename}_${now}.txt
