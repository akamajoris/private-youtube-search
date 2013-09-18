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
		# test=$link
		link="http://www.youtube.com/watch?v=$link"
}
function process () {
	getlink
	VIDEO=`curl -s --header "Accept-Language: en" $link` 
	ISSET=`echo $VIDEO | grep -ic "name=\"title\""`
	COUNT=`echo $VIDEO | grep -ic "Only those with the link can see it"` 
	# echo "$VIDEO" > you/$test.txt # for debug
	if [ "$ISSET" -gt 0 ]
	then 
		echo "$link" >> youtube.log # for debug
		if [ "$COUNT" -gt 0 ]
		then
			let PRIVATE=$PRIVATE+1
			echo -en $link
		else 
			let PUBLIC=$PUBLIC+1
			echo -en $link
		fi
		echo $VIDEO | grep -o '<title>.*</title>' | sed 's/\ -\ YouTube//;s/<[^>]\+>//g;s/&amp;/ /g'
		
	else 
		let NOT_FOUND=$NOT_FOUND+1 
	fi
	
	
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




