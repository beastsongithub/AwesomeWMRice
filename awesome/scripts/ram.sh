#!/usr/bin/sh
#
while true 
do
    free | grep Mem | awk '{print $3/$2}'
    sleep 4
done
