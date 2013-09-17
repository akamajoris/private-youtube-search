#!/bin/bash
ALL=0
PUBLIC=0
PRIVATE=0
NOT_FOUND=0


ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"

function getlink () {
		link=`cat /dev/urandom | tr -dc 'a-zA-Z0-9-_' | head -c11`
		test=$link
		link="http://www.youtube.com/watch?v=$link"
}
function process () {
	getlink # получаем новую ссылку
	#link="http://www.youtube.com/watch?v=wkrgsFD7c48"
	VIDEO=`curl -s $link` # получаем контент
	ISSET=`echo $VIDEO | grep -ic "name=\"title\""`
	COUNT=`echo $VIDEO | grep -ic "Это видео могут просматривать только пользователи, у которых есть ссылка"` # определяем количество совпадений строки
	
	echo "$VIDEO" > you/$test.txt
	if [ "$ISSET" -gt 0 ]
	then 
		if [ "$COUNT" -gt 0 ] # если количество совпадений больше чем нуль (видео доступно только по ссылке)
		then
			let PRIVATE=$PRIVATE+1
			echo -en $link
		else 
			let PUBLIC=$PUBLIC+1
			echo -en $link
		fi
		echo "\n"$VIDEO | grep -o '<title>.*</title>' | sed 's/\ -\ YouTube//;s/<[^>]\+>//g;s/&amp;/ /g'
		
	else 
		let NOT_FOUND=$NOT_FOUND+1; # нет такого видео
	fi
	echo "$link" >> youtube.log
	
	let ALL=$ALL+1
	
}
function update(){
	echo -ne "\r[ $COL_GREEN CHECKED: $ALL; $COL_RESET"
	echo -ne "$COL_YELLOW PUBLIC: $PUBLIC; $COL_RESET"
	echo -ne "$COL_BLUE PRIVATE: $PRIVATE; $COL_RESET"
	echo -ne "$COL_RED NOT FOUND: $NOT_FOUND $COL_RESET]"
}

while true; do
	process
	update
done



