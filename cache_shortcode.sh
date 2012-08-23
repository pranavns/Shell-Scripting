#!/bin/bash
#
# cache_mediaExplorer.sh
# bash script to view interactively the cache files having extentions,
# Demonstrated in Linux ubuntu 11.04 and bash version
# GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# 

work_delay=3s #delay : 3 seconds
function error_usage()
{
	echo -e "\nUsage  	  :  cache_mediaExplorer [option] [file extension]\
		 \noption 	  = { firefox/chromium/chrome }\
		 \nfile extension = { JPEG/PNG/GIF/BMP/XML/HTML/ASCII/PDF/UTF/Video }\n"
	exit 1; #error status echo $?
}
if test $# -ne 2 ; then #check whether argument-1 matches or not
	error_usage
elif  [ "$1" == "chromium" ] || [ "$1" == "chrome" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "chrom") #cache path for chromium/chrome -browser
elif [ "$1" == "firefox" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "firefox") #cache path for mozilla-firefox
else
	error_usage
fi
words=$2  #argument2 is given as the extension
case $words in	  #selecting proper app for viewing the extention
	JPEG)	tool=eog ;;
	PNG)	tool=eog ;;
	GIF)	tool=eog ;;
	Video)	tool=totem ;;
	PDF)	tool=evince ;;
	HTML)	tool=firefox ;;
	XML)	tool=firefox ;;
	ASCII)	tool=gedit ;;
	UTF)	tool=gedit ;;
	*)	error_usage ;;
esac
find $cpath -iname "*" | xargs file | grep $words | awk '{print $1}' | sed -e 's/:/ /g' |\
while read LINE
do
	$tool $LINE &		#process starts [use ($tool $LINE &) resulting time-scheduled]
	sleep $work_delay	#delay for certain time
	pkill $tool 1>/dev/null #kill this process 
done
