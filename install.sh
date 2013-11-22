#! /bin/bash

if [ "$1" == "uninstall" ]
then
  if [ "$(id -u)" == "0" ]; then
    rm -rf /usr/local/bin/GRID-util 2>/dev/null
    rm -f /etc/profile.d/GRID-util.sh
    echo "GRID util uninstalled."
  else
    if [ -d "/usr/local/bin/GRID-util" ]
    then
      echo "You should uninstall as root. try sudo $0 $@" >&2
    else
      echo "No installation found. Maybe you intall GRID-util for single session."
    fi
  fi
else
  if [[ $_ != $0 ]]
  then
    echo "You should source this file for temporary setup. Try:"
    echo "source $0 $@"
    exit 1
  fi

  if [ "$(id -u)" == "0" ]; then
    cp -r $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/src /usr/local/bin/GRID-util
    echo "export PATH=\$PATH:/usr/local/bin/GRID-util" > /etc/profile.d/GRID-util.sh
    cat >/usr/local/bin/GRID-util/uninstall-GRID-util << EOF
#! /bin/bash
if [ "\$(id -u)" == "0" ]; then
  rm -rf /usr/local/bin/GRID-util 2>/dev/null
  rm -f /etc/profile.d/GRID-util.sh
  echo "GRID util uninstalled."
else
  if [ -d "/usr/local/bin/GRID-util" ]
  then
    echo "You should uninstall as root. try sudo \$0 \$@" >&2
  else
    echo "No installation found. Maybe you intall GRID-util for single session."
  fi
fi
EOF
   chmod +x /usr/local/bin/GRID-util/uninstall-GRID-util
   . /etc/profile.d/GRID-util.sh
    echo "Setup for all users."
  else
    export PATH=$PATH:$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/src
    echo "Setup is done just for the current session."
  fi
fi

