#!/bin/bash

module load cdo

# Computes the total precipitation rate [m/s], PRECT = PRECC + PRECL


# Author: Ben Buchovecky
# Last edited: 2023-09-29


srcdir="/glade/campaign/univ/uwas0098"
outdir="/glade/campaign/univ/uwas0098"

casename="cnstVPDforPhoto_PI_SOM"
gcomp="atm"
scomp="cam"
simtype="h0"

srcpath="${srcdir}/${casename}/${gcomp}/hist"
outpath="${outdir}/${casename}/proc/tseries"

now="$(date +'%Y-%m-%dT%H-%M')"
bashoutpath="/glade/u/home/bbuchovecky/scripts/hist"
bashout="${bashoutpath}/calculated_PRECT_${casename}_${now}.txt"

mkdir -p ${bashoutpath}
mkdir -p ${outpath}

echo "${now}" >> ${bashout}
echo "script:   $(basename "$0")" >> ${bashout}
echo "output:   ${outpath}/${casename}.${scomp}.${simtype}.timeseries.calculated_PRECT.nc" >> ${bashout}
echo "input:    ${srcpath}/${casename}.${scomp}.${simtype}.*.nc" >> ${bashout}
echo "casename: ${casename}" >> ${bashout}
echo "gcomp:    ${gcomp}" >> ${bashout}
echo "scomp:    ${scomp}" >> ${bashout}
echo "simtype:  ${simtype}" >> ${bashout}
echo "" >> ${bashout}

cdo -setattribute,calculated_PRECT@long_name="Total precipitation rate (PRECC+PRECL)",calculated_PRECT@units="m/s" -chname,"PRECC","calculated_PRECT" -add -mergetime [ -select,name=PRECC [ ${srcpath}/${casename}.${scomp}.${simtype}.*.nc ] ] -mergetime [ -select,name=PRECL [ ${srcpath}/${casename}.${scomp}.${simtype}.*.nc ] ] ${outpath}/${casename}.${scomp}.${simtype}.timeseries.calculated_PRECT.nc |& tee -a ${bashout}
