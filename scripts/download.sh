#!/bin/sh

# Usage: ./download.sh [url] [output-file]

while [ 1 ]; do
    wget -O $2 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue $1
    if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
    sleep 10s;
done;
