#!/bin/sh
#
# **********************************************************
# publish.sh - Publish the latest github commits to the book
# **********************************************************
# Exit the script on error.
set -e
git pull
python3 -m runestone build --all
python3 -m runestone deploy > /dev/null
