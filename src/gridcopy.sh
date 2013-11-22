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
${bold}usage${normal}: $0 options

Copies batch of files back and forth to the grid.

${bold}OPTIONS$normal:
   -l      Local directory (in interface, e.g. ~/MyShares/n4u/to-process)
   -g      Grid directory  (in the grid)
   -p      Pattern for files to be copied (default *.nii.gz)

   -d      Download images from the GRID
   -u      Upload images to the GRID (default)
   -r      Retry count on copy failure (default 5)
   
   -f      Run from fail file generated with previous runs. This option will 
           supress all other options.
   
   -h      Show this message
EOF
}

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/util.sh

local_dir=~
grid_dir=$PANDORA_GRID_HOME
pattern="*.nii.gz"
upload="YES"
download=
retry=5
fail_file="copy_fail_"$(date '+%y%m%d_%H%M%S')".sh"
run_file=${SAFE_TMP_DIR}/run_file.sh

while getopts “l:g:p:dur:f:h” OPTION
do
  case $OPTION in
    l)
      local_dir=$OPTARG
      ;;

    g)
      grid_dir=$OPTARG
      ;;

    p)
      pattern=$OPTARG
      ;;

    d)
      upload=
      download="YES"
      ;;

    u)
      upload="YES"
      download=
      ;;

    r)
      [[ "$OPTARG" =~ '^[0-9]+$' ]] && retry=$OPTARG
      ;;
    f)
      [ -r "$OPTARG" ] && fail_file=$OPTARG
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

if [ -r "$fail_file" ]
then
  cp "$fail_file" "$run_file"
  fail_file="copy_fail_"$(date '+%y%m%d_%H%M%S')".sh"
else
  # Sanity check
  [ -d "$local_dir" ] && echo_fatal "Local directory (${local_dir}) should be directory."

  if [ "${upload}" ]
  then
    ! [ -r "$local_dir" ] && echo_fatal "Local directory (${local_dir}) should be readable for uploading."
  fi
  if [[ "$grid_dir" != /grid/vo.neugrid.eu/* ]]
  then
    echo_fatal "Grid directory should start with /grid/vo.neugrid.eu/. If you meant to point to your grid home use \$PANDORA_GRID_HOME as the handler (in the way you use ~ in your local computer). E.g. \$PANDORA_GRID_HOME/input"
  fi
  >$run_file
  if [ "${upload}" ]
  then
    # COPY FROM USER INTERFACE TO STORAGE ELEMENT
    echo_wrap "Copying files with pattern ${pattern} from local interface ($local_dir) to the grid ($grid_dir)"

    runname "Generating list of files to be copied. It may take a few minute."
    FILES=$(find "$local_dir" -maxdepth 1 -wholename "*$pattern*" -type f)
    if [ $? -ne 0 ]
    then
      rundone 1
      echo_fatal "Can not read the files from lfn:${grid_dir}"
    fi
    rundone 0

    for tocopy in $FILES
    do
      command_to_run="lcg-cr --vo vo.neugrid.eu -l lfn:${grid_dir}/$(basename $tocopy) file:${tocopy}"
      echo $command_to_run >> $run_file
    done

  else
    # COPY FROM STORAGE ELEMENT TO USER INTERFACE
    echo_wrap "Copying files with pattern ${pattern} from the grid ($grid_dir) to local interface ($local_dir)"

    runname "Generating list of files to be copied. It may take a few minute."
    FILES=$( retry_run lcg-ls lfn:${grid_dir} | grep -E ${pattern} )
    if [ $? -ne 0 ]
    then
      rundone 1
      echo_fatal "Can not read the files from lfn:${grid_dir}"
    fi
    rundone 0

    for tocopy in $FILES
    do
      command_to_run="lcg-cp lfn:${grid_dir}/$(basename $tocopy) ${local_dir}/$(basename $tocopy)"
      echo $command_to_run >> $run_file
    done
  fi
fi

run_from_file $run_file $fail_file
exit_val=$?
if [ -s "$fail_file" ]
then
  echo_wrap "There is/are $( wc -l < $fail_file ) failing(s) in the batch process. The failing processes are written in $fail_file."
  echo_wrap "You can re-run them using $0 -f $fail_file"
fi
exit $exit_val
