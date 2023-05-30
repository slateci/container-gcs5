#!/bin/bash
#
SCRIPT_PID=`ps auxw | awk '/gcs-setup.sh/ { print $2 }'`
kill $SCRIPT_PID 
