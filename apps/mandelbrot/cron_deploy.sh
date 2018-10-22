#!/bin/bash

# Script to be run as a cron job on a machine that will act as a web server, hosting this application.
# This script will keep fpga-server mandelbrot server running w/ the latest code in master.
# To install from the server in ubuntu 16.04, update script parameters, below, then:
#  > sudo cp cron_deploy.sh /etc/cron.hourly
# And reboot.
# To test the script:
#  > sudo /etc/cron.hourly

#!/bin/bash

# Script to be run as a cron job on a machine that will act as a web server, hosting this application.
# This script will keep fpga-server mandelbrot server running w/ the latest code in master.
# To install from the server in ubuntu 16.04, update script parameters, below, then:
#  > sudo cp cron_deploy.sh /etc/cron.hourly/mandelbrot.sh
# And reboot.
# To test the script:
#  > sudo /etc/cron.hourly

# Script parameters:
REPO_ROOT=/root



fail () {
    echo $1
    exit 1
}

cd "$REPO_ROOT/fpga-webserver" || fail "Failed to cd $REPO_ROOT/fpga-webserver."

# Exit if there are no changes in master.
git fetch
OUT=`cd $REPO_ROOT/fpga-webserver; git status`
if ! [[ $OUT =~ Your\ branch\ is\ behind ]] ; then
  echo "Up to date with master."
  UPDATE=true
else
  # Changes to pull. Pull them and take down the web server.
  UPDATE=false
  
  # Pull changes.
  git pull origin master || fail "Failed to pull changes from master."

  # Compile
  make build
  
  # Kill running launch command.
  OUT=`ps -ao pid,comm | grep launch`
  if [[ $OUT =~ ^[[:space:]]*([0-9]+)\ launch$ ]] ; then
      kill ${BASH_REMATCH[1]} || fail "Failed to kill running web server."
  else
    if [[ $OUT =~ launch$ ]] ; then
      echo "Perhaps there are multiple web servers running? Will not launch a new one."
      echo $OUT
      exit 1
    else
      echo "Failed to find running web server. Launching a new one."
    fi
  fi
  
  # Wait, to make sure the socket is freed. (Don't know if this is needed, but it seems like a good idea.)
  sleep 1
fi

# Confirm no running web server.
OUT=`ps -ao pid,comm | grep launch`
if [[ $OUT =~ ^[[:space:]]*([0-9]+)\ launch$ ]] ; then
  # Server is running.
  if [[ $UPDATE = true ]] ; then
    echo "Failed to kill running web server. Not launching new one."
    exit 1
  else
    exit 0
  fi
fi

# Launch.
cd apps/mandelbrot/build && make launch &
