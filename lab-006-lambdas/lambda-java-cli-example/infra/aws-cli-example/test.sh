#!/bin/bash

#!/bin/bash
#echo "select the operation ************"
#echo "  1)DEV 1"
#echo "  2)HOMOL 2"
#echo "  3)PROD 3"
#echo "  4) 4"
#
#read -p "escolha uma opção: " n
#
#case $n in
#  1) echo "You chose Option 1";;
#  2) echo "You chose Option 2";;
#  3) echo "You chose Option 3";;
#  4) echo "You chose Option 4";;
#  *) echo "invalid option";;
#esac

#selections=(
#"Selection A"
#"Selection B"
#"Selection C"
#)
#
#choose_from_menu "Please make a choice:" selected_choice "${selections[@]}"
#echo "Selected choice: $selected_choice"


#selection=$(zenity --list "Option 1" "Option 2" "Option 3" --column="" --text="Text above column(s)" --title="My menu")
#
#case "$selection" in
#"Option 1")zenity --info --text="Do something here for No1";;
#"Option 2")zenity --info --text="Do something here for No2";;
#"Option 3")zenity --info --text="Do something here for No3";;
#esac

  ALIASES=("DEV" "HOM" "PROD")

  echo "Escolha um ALIAS abaixo"
  select alias in ${ALIASES[*]}; do
      echo $alias
      break
  done