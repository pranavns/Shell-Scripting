#!/bin/bash
# bash version 		 : GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# script dependancies    : pdftotext and wget
# filename		 : examResMini.sh
# The Shell script is tabularize the University Semester Examination results
# The main purpose is to reduce the results in a tabular form in which futhur data manipulation become simple
# Tabular form with data fields ==> <registerNo> <sgpa> <grades> <candidateName>
# Output redirection ==> "$bash examResMini.sh > filename" 

for i in {01..73}	#lower and upper bounds
do
	url="uoc.ac.in/exam/btech/creditresnet188.php?id=2037&regno=ETAKECS0$i&Submit=Submit"
	while (true)				     #For ensuring that the file is not null
	do
		wget --limit-rate=200k -O student.pdf $url -o /dev/null
		if [ -s student.pdf ]; then break; fi
	done
	pdftotext -raw student.pdf student.txt
	name=$(sed -n '/NAME/p' student.txt | sed 's/:/ /'| awk '{print $4" "$5" "$6}')
	sgpa=$(sed -n '/SGPA/p' student.txt | awk '{print $7}')
	grad=$(sed -n '/3/p'    student.txt | sed -e '/REGISTER No/d' -e '/SGPA/d' | awk '{print $(NF-1)}' | xargs echo)
	echo -e "ETAKECS0$i\t$sgpa\t$grad    $name"
done

rm -f student.{txt,pdf}
