#!/bin/sh

fs() {
  echo $(statvfs /) / $(statvfs /jonas/)
}

bat() {
  if [ ! -e /tmp/.dwm-bat-cache ] || [ 0 -eq $(($(date +'%s') % 10)) ]
  then
    acpi | cut -d : -f 2- | sed 's/^ //g' | tr '[:upper:]' '[:lower:]' | sed 's/\(dis\)\?charging, //' | sed 's/:[0-9]\+ / /' > /tmp/.dwm-bat-cache
  fi
  cat /tmp/.dwm-bat-cache
}

mix() {
  volume=$(amixer get PCM | egrep -o '[0-9]+%' | uniq)
  muted=$(amixer get Master | grep '\[off\]' >/dev/null && echo [m])
  echo $volume $muted
}

clock() {
  date +'%a %b %d %H:%M:%S'
}

moc() {
  local tmp
  tmp=$(mocp --format '%t -- %a %ct/%tt' 2>/dev/null)
  if [ 0 -eq $? ]
  then
    echo "$tmp"
  fi
}


main() {
  while true
  do
    STATUS=

    for callback in fs bat moc mix clock
    do
      local tmp
      tmp=$($callback)
      if [ ! -z "$tmp" ]
      then
        if [ -z "$STATUS" ]
        then
          STATUS="$tmp"
        else
          STATUS="$STATUS | $tmp"
        fi
      fi
    done

    xsetroot -name "$STATUS"
    sleep 1
  done
}

main
