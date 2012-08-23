#!/bin/bash
#
# cache_mediaExplorer.sh
# bash script to view interactively the cache files having extentions,
# The file extention targets are :
#  GIF 	- Graphics interchange format
#  JPEG - Joint photographic Experts Group
#  PNG 	- Portable network Graphics
#  Video- No Specific extension(such as flv, mp4, etc)
#  HTML - Hyper Text Markup Language
#  XML 	- Extended Markup Language 
#  ASCII- Ascii text files
#  PDF	- Pdf files for text
#  UTF	- Unicode (8)
# Demonstrated in Linux ubuntu 11.04 and bash version
# GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# Pre-Installed Applications to run this script( Default apps in Ubuntu 11.04 ) are
# Eye-Of-Gnome, Firefox, Gedit, Totem & Evince
# this view flow make a delay of 3 seconds it may be modified 
# usage eg: $bash cache_mediaExplorer.sh firefox PNG
# happy scripting...
#

work_delay=3s #delay : 3 seconds

function error_usage()
{
	echo -e "\nUsage  	  :  cache_mediaExplorer [option] [file extension]\
		 \noption 	  = { firefox/chromium/chrome }\
		 \nfile extension = { JPEG/PNG/GIF/BMP/XML/HTML/ASCII/PDF/UTF/Video }\n"
	exit 1; #error status echo $?
}

#check whether argument-1 matches or not
if test $# -ne 2 ; then
	error_usage
elif  [ "$1" == "chromium" ] || [ "$1" == "chrome" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "chrom") #cache path for chromium/chrome -browser
elif [ "$1" == "firefox" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "firefox") #cache path for mozilla-firefox
else
	error_usage
fi

touch ~/tmp/temp{1,2}.$$

words=$(echo $2)  #argument2 is given as the extension

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

find $cpath -iname "*" |\
xargs file {} >~/tmp/temp1.$$
cat ~/tmp/temp1.$$ | grep $words |\
awk '{ print $1 }' | sed -e 's/:/ /g' 1>~/tmp/temp2.$$
cat ~/tmp/temp2.$$ | while read LINE
do
	$tool $LINE &		#process starts [use ($tool $LINE &) resulting time-scheduled]
	sleep $work_delay	#delay for certain time
	pkill $tool 1>/dev/null #kill this process 
done
rm -f ~/tmp/temp{1,2}.$$
exit 0
