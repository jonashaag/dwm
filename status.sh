#!/bin/sh


cached() {
  if [ ! -e /tmp/.dwm-$1-cache ] || [ 0 -eq $(($(date +'%s') % $2)) ]; then
    # cache miss
    eval "$3" > /tmp/.dwm-$1-cache
  fi
  cat /tmp/.dwm-$1-cache
}


updates() {
  cached updates 43200 '
    if [ $(cut -d . -f  1 /proc/uptime) -gt 1000 ]; then
      if [ -z "$(pgrep pacman)" ]; then
        sudo pacman -Sy > /dev/null
        N=$(pacman -Qu 2>/dev/null | wc -l)
        if [ "$N" -gt 0 ]; then
          echo "$N updates"
        fi
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
         | sed 's/\(dis\)\?charging, //' | sed 's/:[0-9]\+ / /' \
         | sed 's/, charging at zero rate - will never fully charge//'
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
  if $(mocp -i 2>/dev/null | grep -v STOP >/dev/null); then
    local tmp
    tmp=$(mocp --format '%t %ct/%tt' 2>/dev/null)
    if [ 0 -eq $? ]; then
      echo "$tmp"
    fi
  fi
}


queue() {
  echo Q $(ls ~/q | wc -l)
}

main() {
  while true
  do
    STATUS=

    for callback in queue updates fs bat moc mix clock
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
