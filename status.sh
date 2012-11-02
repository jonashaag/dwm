#!/bin/sh


cached() {
  if [ ! -e /tmp/.dwm-$1-cache ] || [ 0 -eq $(($(date +'%s') % $2)) ]; then
    # cache miss
    eval "$3" > /tmp/.dwm-$1-cache
  fi
  cat /tmp/.dwm-$1-cache
}


updates() {
  cached updates 86400 '
    if [ -z "$(pgrep pacman)" ]; then
      pkg -Sy > /dev/null
      N=$(pkg -Qu 2>/dev/null | wc -l)
      if [ "$N" -gt 0 ]; then
        echo "$N updates"
      fi
    fi
    '
}


fs() {
  echo $(statvfs /) / $(statvfs /jonas/)
}


bat() {
  cached bat 10 "
    acpi | cut -d : -f 2- \
         | sed 's/^ //g' | tr '[:upper:]' '[:lower:]' \
         | sed 's/\(dis\)\?charging, //' | sed 's/:[0-9]\+ / /'
    "
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
  if [ 0 -eq $? ]; then
    echo "$tmp"
  fi
}


main() {
  while true
  do
    STATUS=

    for callback in updates fs bat moc mix clock
    do
      local tmp
      tmp=$($callback)
      if [ ! -z "$tmp" ]; then
        if [ -z "$STATUS" ]; then
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
