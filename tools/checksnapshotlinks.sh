#!/bin/bash -eu

BASE=/mutable
REPAIR=false
if [ "${1:-}" = "repair" ]
then
  REPAIR=true
fi

function recentpathfor {
  recent=${1#*/}
  filename=${recent##*/}
  filedate=${filename:0:10}
  echo "DriveCam/$filedate/$filename"
}

find -L /backingfiles/snapshots/ -type f -name \*.mp4 | sort -r | {
  while read -r path
  do
    name=$path #${path##/*TeslaCam/}
    if [[ $name == GearGuardVideo/* || $name == DriveCam/* ]]
    then
      if [ ! -L "$BASE/$name" ]
      then
        echo No link for "$path"
        if [ "$REPAIR" = "true" ]
        then
          dir=$BASE/$name
          dir=${dir%/*}
          mkdir -p "$dir"
          ln -sf "$path" "$BASE/$name"
        fi
      fi
      recentpath=$BASE/$(recentpathfor "$name")
      if [ ! -L "$recentpath" ]
      then
        echo No RecentClips link for "$path"
        if [ "$REPAIR" = "true" ]
        then
          recentdir=${recentpath%/*}
          mkdir -p "$recentdir"
          ln -sf "$path" "$recentpath"
        fi
      fi
    elif [[ $name == DriveCam/* ]]
    then
      recentpath=$BASE/$(recentpathfor "$name")
      if [ ! -L "$recentpath" ]
      then
        echo No link for "$path"
        if [ "$REPAIR" = "true" ]
        then
          recentdir=${recentpath%/*}
          mkdir -p "$recentdir"
          ln -sf "$path" "$recentpath"
        fi
      fi
    fi
  done
}
