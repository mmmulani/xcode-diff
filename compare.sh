#!/bin/bash

# Usage:
# ./compare.sh <Path to old Xcode Developer dir> <Path to new Xcode Developer dir>

OLD_XCODE=$1
NEW_XCODE=$2

#set -x # Log all commands.
#set -e # Quit on first exception.

SCRAP_DIR="/tmp/"
TMP_OLD="/tmp/tmp_old"
TMP_NEW="/tmp/tmp_new"

find "$NEW_XCODE" -type f -perm -100 | while read executable; do
  RELATIVE_PATH="${executable:${#NEW_XCODE}}"

  ln -s "$OLD_XCODE""$RELATIVE_PATH" binary
  otool -l binary > $TMP_OLD
  md5 binary > old_md5
  rm binary
  ln -s "$NEW_XCODE""$RELATIVE_PATH" binary
  otool -l binary > $TMP_NEW
  md5 binary > new_md5
  rm binary
  if ! diff -q $TMP_OLD $TMP_NEW > /dev/null ; then
    echo "$RELATIVE_PATH" differs.
  fi
  if ! diff -q old_md5 new_md5 > /dev/null ; then
    echo "$RELATIVE_PATH" md5 sum differs.
  fi
done
