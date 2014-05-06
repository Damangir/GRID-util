export GRIDUTILDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export SAFE_TMP_DIR=$(mktemp -d)
trap "rm -rf ${SAFE_TMP_DIR}" EXIT

# check if stdout is a terminal...
if [ -t 1 ]; then
  # see if it supports colors...
  ncolors=$(tput colors)
  if test -n "$ncolors" && test $ncolors -ge 8; then
    bold="$(tput bold)"
    underline="$(tput smul)"
    standout="$(tput smso)"
    normal="$(tput sgr0)"
    black="$(tput setaf 0)"
    red="$(tput setaf 1)"
    green="$(tput setaf 2)"
    yellow="$(tput setaf 3)"
    blue="$(tput setaf 4)"
    magenta="$(tput setaf 5)"
    cyan="$(tput setaf 6)"
    white="$(tput setaf 7)"
    header_format="\n${bold}${underline}##   "
  fi
fi

retry_run()
{
  local out_file=$(mktemp -p $SAFE_TMP_DIR)
  local err_file=$(mktemp -p $SAFE_TMP_DIR)
  [ -z "$retry" ] && retry=5
  [[ "$retry" =~ '^[0-9]+$' ]] && retry=5
  for i in $(eval echo {1..$retry})
  do
    $@ 1>$out_file 2>$err_file
    local retval=$?
    [ $retval -eq 0 ] && break
  done
  if [ "$PRINTDOTS" ]
  then
    if [$retval -eq 0]
    then
      printf "."
    else
      printf "x"
    fi
  else
    cat $out_file
  fi
  cat $err_file >&2
  return $retval
}

run_all_from_file()
{
  local the_file="$1"
  export err_file=${SAFE_TMP_DIR}/"failed_"$(date '+%y%m%d_%H%M%S')".sh"
  export retry
  export -f retry_run
  local NUMCPU=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1)
  if [ "$(command -v pv)" ]
  then
    local process_size=$(wc -c < $the_file )
    pv -s $process_size -W -p -t -e $the_file | xargs -n1 -P $NUMCPU  -I{} bash -c 'retry_run "$1" || echo $1 | tee -a $err_file >&2' _ {} 2>/dev/null
  else
    echo_warning "pv is not installed in your system. It is thus not possible to monitor the progress. Please be patient, the process may take several minutes."
    export PRINTDOTS="YES"
    cat $the_file | xargs -n1 -P $NUMCPU  -I{} bash -c 'retry_run "$1" || echo $1 | tee -a $err_file >&2' _ {} 2>/dev/null
    echo "Done"
  fi
  if [ -s "${err_file}" ]
  then
    if [ "${2}" ]
    then
      mv "${err_file}" "${2}" 2>/dev/null
    else
      mv "${err_file}" . 2>/dev/null
    fi
  fi
  unset err_file
}

run_seq_from_file()
{
  local the_file="$1"
  local stdout_file=${SAFE_TMP_DIR}/"stdout_"$(date '+%y%m%d_%H%M%S')".txt"
  local stderr_file=${SAFE_TMP_DIR}/"stderr_"$(date '+%y%m%d_%H%M%S')".txt"

  while read cmd_line
  do
    printf "#####\n# RUNNING ${cmd_line}\n#####\n" 1>>$stdout_file
    printf "#####\n# RUNNING ${cmd_line}\n#####\n" 2>>$stderr_file
    retry_run "${cmd_line}" 1>>$stdout_file 2>>$stderr_file
    local retval=$?
    if [ $retval -ne 0 ]
    then
      printf "#####\n# COMMAND ${cmd_line} FAILED\n#####\n" 1>>$stdout_file
      printf "#####\n# COMMAND ${cmd_line} FAILED\n#####\n" 2>>$stderr_file      
      break
    fi
  done < $the_file

  [ -s "${stdout_file}" ] && mv "${stdout_file}" . 2>/dev/null
  [ -s "${stderr_file}" ] && mv "${stderr_file}" . 2>/dev/null
  return $retval
}



echo_wrap()
{
  fold -s -w $(tput cols) <<<"$@"
}

echo_warning()
{
  echo -e "${yellow}WARNING:${normal}"
  echo_wrap "$@"
}
echo_error()
{
  echo -e "${red}ERROR:${normal}"
  echo_wrap "$@"
}
echo_fatal()
{
  echo -e "${red}FATAL ERROR:${normal}"
  echo_wrap "$@"
  exit 1
}

runname()
{
  echo -n "${1}"
  reqcol=$(echo $(tput cols)-${#1}|bc)  
}
rundone()
{
  local OKMSG="[OK] "
  local FAILMSG="[FAIL] "
  [ -n "$2" ] && OKMSG="[$2] "
  [ -n "$3" ] && FAILMSG="[$3] "
  if [ $1 -eq 0 ]
  then
    printf "$green%${reqcol}s$normal\n" "$OKMSG"
  else
    printf "$red%${reqcol}s$normal\n" "$FAILMSG"  
  fi
  return $1
}
