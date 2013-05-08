#!/bin/sh


text_widget() {
  xterm -class dwm-bg -geometry $3 -e "
    tput civis -- invisible # hide cursor
    watch -t -n 5 \"echo '' $1; echo \"-$1-\" | sed s/./-/g; $2\"
  "
}


uni() {
  text_widget "Uni" "ls ~/q/uni" 50x7+900+50
}


todo() {
  gvim -geometry 80x30+100+100 -class dwm-bg ~/todo.txt
}


main() {
  IFS=:
  for widget in uni todo
  do
    $widget &
  done
}

main
