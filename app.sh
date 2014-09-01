#!/bin/bash
#
# Service script for a Node.js application running under Forever.
#
# This is suitable for Fedora, Red Hat, CentOS and similar distributions.
# It will not work on Ubuntu or other Debian-style distributions!
#
# There is some perhaps unnecessary complexity going on in the relationship between
# Forever and the server process. See: https://github.com/indexzero/forever
#
# 1) Forever starts its own watchdog process, and keeps its own configuration data
# in /var/run/forever.
#
# 2) If the process dies, Forever will restart it: if it fails but continues to run,
# it won't be restarted.
#
# 3) If the process is stopped via this script, the pidfile is left in place; this
# helps when issues happen with failed stop attempts.
#
# 4) Which means the check for running/not running is complex, and involves parsing
# of the Forever list output.
#
# chkconfig: 345 80 20
# description: my application description
# processname: my_application_name
# pidfile: /var/run/my_application_name.pid
# logfile: /var/log/my_application_name.log
#

NAME=app
SOURCE_DIR=/vagrant
SOURCE_FILE=app.js
DEBUG_PORT=5858

user=node
forever_dir=/var/run/forever
pidfile=$forever_dir/$NAME.pid
logfile=/var/log/$NAME.log

node=node
forever=forever
sed=sed


start() {
  echo "Starting $NAME node instance: "

  if [ "$foreverid" == "" ]; then
    # Create the log and pid files, making sure that
    # the target use has access to them
    touch $logfile
    chown $user $logfile

    touch $pidfile
    chown $user $pidfile

    # Launch the application
    cd $SOURCE_DIR
    sudo \
      $forever start -p $forever_dir --pidFile $pidfile -l $logfile \
      -a -d $SOURCE_FILE 2>&1
    RETVAL=$?
  else
    echo "Instance already running"
    RETVAL=0
  fi
}

startdbg() {
  echo "Starting $NAME node instance: "

  if [ "$foreverid" == "" ]; then
    # Create the log and pid files, making sure that
    # the target use has access to them
    touch $logfile
    chown $user $logfile

    touch $pidfile
    chown $user $pidfile

    # Launch the application
    cd $SOURCE_DIR
    sudo \
      $forever start -p $forever_dir --pidFile $pidfile -l $logfile \
      -a -d $SOURCE_FILE --debug=$DEBUG_PORT 2>&1
    RETVAL=$?
  else
    echo "Instance already running"
    RETVAL=0
  fi
}

stop() {
  echo -n "Shutting down $NAME node instance : "
  if [ "$foreverid" != "" ]; then
    sudo $forever stop $foreverid
    foreverid=""
  else
    echo "Instance is not running";
  fi
  RETVAL=$?
}

if [ -f $pidfile ]; then
  read pid < $pidfile
else
  pid=""
fi

if [ "$pid" != "" ]; then
  # Gnarly sed usage to obtain the foreverid.
  sed2="s/.*\[\([0-9]\+\)\].*\s\+$pid\s.*/\1/g"
  foreverid=`sudo $forever list | grep " $pid " | sed "$sed2"`
else
  foreverid=""
fi

case "$1" in
  start)
    start
    ;;
  start-dbg)
    startdbg
  ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage:  {start|start-dbg|stop|status}"
    exit 1
    ;;
esac
exit $RETVAL