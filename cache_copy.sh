#!/bin/bash
#
# cache_copy.sh
# bash script to copy the cache files of specified extension
# the cache file extensions must belong to the following list:
# extension: JPEG/PNG/GIF/BMP/XML/HTML/ASCII/PDF/UTF/Video 
# The files are copied to a new directory having name "DIR_<EXTENSION you given>"
# For eg: if you give command $bash cache_copy.sh firefox PNG
# Then a new directory named DIR_PNG is created and all the files move into it
# Demonstrated in Linux ubuntu 11.04 and bash version
# GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# 

function error_usage()
{
	echo -e "\nUsage  	  :  cache_copy [option] [file extension]\
		 \noption 	  = { firefox/chromium/chrome }\
		 \nfile extension = { JPEG/PNG/GIF/XML/HTML/ASCII/PDF/Video }\n"
	exit 1;
}
if test $# -ne 2 ; then #check whether argument-1 matches or not
	error_usage
elif [ "$1" == "chromium" ]||[ "$1" == "chrome" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "chrom") #cache path for chromium/chrome -browser
elif [ "$1" == "firefox" ] ; then
	cpath=$(find $HOME -name "Cache" | grep "firefox") #cache path for mozilla-firefox
else
	error_usage
fi
case $2 in
	JPEG) ;; PNG)  ;; ASCII) ;; GIF) ;; Video);; HTML) ;; XML) ;; PDF) ;;
	*) error_usage ;;
esac
mkdir $HOME/DIR_$2
find $cpath -iname "*" | xargs file | grep $2 | awk '{print $1}' | sed -e 's/:/ /g' |\
while read LINE
do
	cp $LINE $HOME/DIR_$2
done
