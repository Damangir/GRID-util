#! /bin/bash
# Copyright (C) 2013 Soheil Damangir - All Rights Reserved
# You may use and distribute and adopt this code under the terms of the
# Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
# under the following conditions:
#
# Attribution — You must attribute the work in the manner specified by the
# author or licensor (but not in any way that suggests that they endorse you
# or your use of the work).
#
# Noncommercial — You may not use this work for commercial purposes.
# No Derivative Works — You may not alter, transform, or build upon this
# work
#
# Share Alike — If you alter, transform, or build upon this work, you may 
# distribute the resulting work only under the same or similar license to this
# one.
#
# To view a copy of the license, visit
# http://creativecommons.org/licenses/by-nc-sa/3.0/
#  


usage()
{
cat << EOF
${bold}usage${normal}: $(basename $0) OPTIONS

Creates job file for files in a directory.

${bold}OPTIONS$normal:
   -g      Grid directory  (in the grid)
   -p      Pattern for files to be added to jobfile (default *.nii.gz)
   -o      Output Jobfile (default only prints it)
   -r      Retry count on copy failure (default 5)
   
   -h      Show this message
EOF
}

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/util.sh

[ -z "$1" ] && usage && exit

grid_dir=$PANDORA_GRID_HOME
pattern="*.nii.gz"
retry=5
jobfile=

while getopts “g:p:r:o:h” OPTION
do
  case $OPTION in
    g)
      grid_dir=$OPTARG
      ;;
    p)
      pattern=$OPTARG
      ;;
    o)
      touch $OPTARG &>/dev/null
      [ "$?" -eq "0" ] && jobfile=$OPTARG
      ;;
    r)
      [[ "$OPTARG" =~ '^[0-9]+$' ]] && retry=$OPTARG
      ;;
    h)
      usage
      exit
      ;;
    ?)
      usage
      exit
      ;;
  esac
done
export retry
if [[ "$grid_dir" != /grid/vo.neugrid.eu/* ]]
then
  echo_fatal "Grid directory should start with /grid/vo.neugrid.eu/. If you meant to point to your grid home use \$PANDORA_GRID_HOME as the handler (in the way you use ~ in your local computer). E.g. \$PANDORA_GRID_HOME/input"
fi
runname "Generating list of files to be added to jobfile. It may take a few minute."
FILES=$( retry_run "lcg-ls lfn:${grid_dir}" | grep -E "${pattern}" )
if [ $? -ne 0 ]
then
  rundone 1
  echo_fatal "Can not read the files from lfn:${grid_dir}"
fi
rundone 0

if [ -w "$jobfile" ]
then
  >$jobfile
  echo "# Job file automaticlly created using $(basename $0)." >>$jobfile
  echo "# $(wc -w <<<$FILES ) jobs" >>$jobfile
  echo "# InputDir: lfn:${grid_dir}" >>$jobfile
else
  echo "# Job file automaticlly created using $(basename $0)."
  echo "# $(wc -l <<<$FILES ) jobs"
  echo "# InputDir: lfn:${grid_dir}"
fi

for toadd in $FILES
do
  toadd=$(basename $toadd)
  jobline="${toadd%%.*} ${toadd}"
  if [ -w "$jobfile" ]
  then
    echo "$jobline" >> $jobfile
  else
    echo "$jobline"
  fi
done
