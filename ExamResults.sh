#!/bin/bash
# bash version 		 : GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# script dependancies    : pdftotext and wget
# Shell script to tabularize the University Exam result
# Register number started area (*), length : 10
# semester 3 web address : http://uoc.ac.in/exam/btech/creditresnet188.php?id=2037&regno=**********&Submit=Submit

lower_limit=1
upper_limit=73

touch results;:>results
num=$lower_limit

while test $num -le $upper_limit
do
	if test $num -le 9;then
		url="uoc.ac.in/exam/btech/creditresnet188.php?id=2037&regno=ETAKECS00$num&Submit=Submit"
	else
		url="uoc.ac.in/exam/btech/creditresnet188.php?id=2037&regno=ETAKECS0$num&Submit=Submit"
	fi

	wget --limit-rate=200k -O student.pdf $url -o /dev/null
	pdftotext -raw student.pdf student.txt

	name=$(sed -n '/NAME/p' student.txt | sed 's/:/ /'| awk '{print $4" "$5" "$6}')
	sgpa=$(sed -n '/SGPA/p' student.txt | awk '{print $7}')
	subj=$(sed -n '/3/p' 	student.txt | sed -e 1d   | awk '{print $(NF-1)}' | xargs echo)

	printf "%-10s %-10s %-10s\t" $name >>results
	echo -e "<<$sgpa>>  $subj\n" >>results
	num=`expr $num + 1`
done

cat results
rm -f student.{txt,pdf}
