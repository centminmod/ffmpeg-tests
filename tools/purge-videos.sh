#!/bin/bash
# purge sliced cache byte ranged video files
debug='y'
cachedir='/tmp/mycache'
cachefile='/tmp/videocache_entries.txt'
purge_list_file='/tmp/videocache_purge_list.txt'
purge_cmd_file='/tmp/videocache_purge_cmds.txt'

do_purge() {
  fileuri=$1
  mode=$2
  if [[ ! -z "$fileuri" ]]; then
    echo "Found cached entries for $fileuri"
    echo
    find $cachedir -type f | while read f; do grep -Ha 'KEY: ' $f | fgrep -a "$fileuri"; done > $cachefile
    if [ -f "$cachefile" ]; then
      {
      #echo "Filename | Cache-KEY"
      awk -F ':KEY: ' '{print $1" | "$2}' $cachefile > $purge_list_file
      } 2>&1 | column -t
    fi
    if [ "$mode" = 'list' ]; then
      echo "Output Format"
      echo
      echo "# cache-key"
      echo "rm -rf cache-filename"
      echo
      if [ -f "$purge_list_file" ]; then
        awk '{print "# "$3"\nrm -rf",$1}' $purge_list_file | tee $purge_cmd_file
      fi
      echo
    fi
    if [ "$mode" = 'purge' ]; then
      if [ -f "$purge_cmd_file" ]; then
        if [[ "$debug" = [yY] ]]; then
          echo "purge [debug mode]"
          cat $purge_cmd_file
        else
          echo "purge"
          bash $purge_cmd_file
        fi
      fi
    fi
  fi
}

help() {
  echo "$0 list /path/to/filename.mp4"
  echo "$0 purge /path/to/filename.mp4"
}

case "$1" in
  list )
    if [ ! -z "$2" ]; then
      do_purge $2 list
    else
      help
    fi
    ;;
  purge )
    if [ ! -z "$2" ]; then
      do_purge $2 purge
    else
      help
    fi
    ;;
  * )
    help
    ;;
esac