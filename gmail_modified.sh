#!/bin/bash
#
# Shell Script by Pranav.
# Interactive Gmail Application. 
# GUI is enabled with a mixture of zenity and yad utilities,
# Before running this script it must make sure that,
# the shell must be consist of curl and  mutt utilities.
# Services are provided by editing the atom mail
# Script is Demonstrated in Linux ubuntu 11.04 and bash version
# GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
#
#

REP=$(yad --title="Desktop Gmail Grabber"\
	  --text="Gmail access via desktop"\
	  --form --height=200 --width=600\
	  --field="Service:CB"\
		 "New-Mail!Mail-Number!Send-Mail!Mail-From!Mail-Subject!Mail-Summary"\
	 --field="Email-Id" --field="Password:H")

res=$? #checks exit status
if test $res -ne 0 ; then exit 1; fi

#stripping out each fields
fservice=$(echo $REP | tr "|" " " | awk '{ print $1 }')
femailid=$(echo $REP | tr "|" " " | awk '{ print $2 }')
fpasswds=$(echo $REP | tr "|" " " | awk '{ print $3 }')

#length of the fields
eleng=${#femailid}
pleng=${#fpasswds}

if test $eleng -eq 0 || test $pleng -eq 0; then
	zenity --error --title='Desktop Gmail Grabber: Caution!'\
			 --text="All fields must be non-empty"; exit 2; fi
respaddr=https://mail.google.com/mail/feed/atom

network_error() {
	zenity --error --title='Desktop Gmail Grabber: Caution!'\
		--text="Network doesn't exist" ;exit 1
}
wrong_entry() {
	zenity --error --title='Desktop Gmail Grabber: Caution!'\
		--text="Username or password is wrong!" ;exit 2
}
init_atom() {
	#cd $HOME; cat web>:
	curl -su $femailid:$fpasswds $respaddr >:
	loginfo=`cat : | wc -l`
	if test $loginfo -eq 0 ; then network_error; fi
	suc=$(cat : |  sed -n '/Unauthorized/p' | wc -l)
	if test  $suc  -ne 0 ; then wrong_entry; fi
}

#occurence of new message(mail) in the account
function newmail()
{	
	if test $loginfo -gt 8 ; then
		zenity --info --title="Desktop Gmail Grabber" --text="New mail found!"
	else
		zenity --info --title="Desktop Gmail Grabber" --text="New mail is not found!"; fi
}

#checks the number of mails by greping tab summary
function totmailno()
{
	COUNT_NO=$(sed -n '/<fullcount>/p' : | sed -e 's/<fullcount>/\ / '\
	-e 's%</fullcount>%\ % ' | awk '{ print $1 }')
	if [ "$COUNT_NO" != "0" ]; then
		zenity --info  --title='Desktop Gmail Grabber' \
			--text="You have $COUNT_NO mails to read"
	else
		zenity --info  --title='Desktop Gmail Grabber' \
			--text="You have no mails to read"
	fi; rm -f :;cd ~;
}

#list out all the senders
function mail_from()
{
	NAME_LISTS=$(sed -n '/<name>/p' : |\
	sed -e 's/<name>/\ / ' -e 's%</name>%\ % ' | awk '{ print $1 }')
	NAME_COUNT=$(echo $NAME_LISTS | tr " " "\n" | wc -l)
	if test $NAME_COUNT -eq 0; then
		zenity --info --title="Desktop Gmail Grabber" --text="you have no mail"
	else
		yad --title="Desktop Gmail Grabber" --height=500 --width=300 --text-info\
		--text="`echo -e "you have latest $NAME_COUNT mails from\n$NAME_LISTS"`"
	fi; rm :
}

#list out all the subjects
function mail_subj()
{
	sed -n '/<title>/p' : |\
	sed -e 's/<title>/\ / ' -e 's%</title>%\ % ' >/tmp/sub.$$
	SUBJ_LISTS=$(cat /tmp/sub.$$)
	SUBJ_COUNT=$(cat /tmp/sub.$$ | wc -l)
	if test $SUBJ_COUNT -eq 0; then
		zenity --info --title="Desktop Gmail Grabber"\
			 --text="you have no mail"
	else
		yad --title="Desktop Gmail Grabber" --height=500 --width=1000 --text-info \
		--text="`echo -e "you have latest $SUBJ_COUNT mails having subjects:\n\n$SUBJ_LISTS"`"
	fi; rm : /tmp/sub.$$
}

function mail_summary()
{
	sed -n '/<summary>/p' : |\
 	sed -e 's/<summary>//g' -e 's%</summary>%%g' >/tmp/summ.$$
	SUM_COUNT=$(cat /tmp/summ.$$ | wc -l)
	SUM_LISTS=$(cat /tmp/summ.$$)
	if test $SUM_COUNT -eq 0; then
		zenity --info --title="Desktop Gmail Grabber"\
			 --text="you have no mail"
	else
		yad --title="Desktop Gmail Grabber" --height=500 --width=1000 --text-info \
		--text="`echo -e "you have latest $SUM_COUNT mails having summary(short):\n\n$SUM_LISTS"`"
	fi; rm : /tmp/summ.$$
}

#sending mail
function sendmail()
{	
	sendinfo=$(yad --title="Desktop Gmail Grabber"\
			 --text="Gmail access via desktop"\
			 --form --height=200 --width=500\
	  		--field="Enter the subject(without any white sapce)" "NoSubject"\
			--field="Enter the Email Username"\
			--field="Attachment(Optional):FL")
	if test $? -eq 0 ; then
		mesg=$(yad --title="Create Message to Send"\
			   --height=200 --width=500 --text-info --editable)
	else exit 1;fi
	fsubj=$(echo $sendinfo | tr "|" " " | awk '{ print $1 }')
	fmail=$(echo $sendinfo | tr "|" " " | awk '{ print $2 }')
	fatch=$(echo $sendinfo | tr "|" " " | awk '{ print $3 }')
	if [ "$fsubj" == "" ]; then fsubj="NoSubject"; fi
	if [ "$fmail" == "" ]; then
		zenity --warning --text="Email field must be non-empty"; exit 2; fi
	if [ "$mesg" == "" ]; then
		zenity --warning --text="Content of message be non-empty"; exit 2; fi
	echo "$mesg" >:
	if [ "$fatch" == "(null)" ]; then #note exit status failed or not#>/dev/null
		mutt -s "$fsubj" "$fmail" < : >/dev/null ; null=$? 
	else #checking exit status if it does work(error redirection:-failed or not)
		mutt -s "$fsubj" "$fmail" -a "$fatch" < : >/dev/null; not_null=$?;fi 
	if [ "$null" == "0" ] || [ "$not_null" == "0" ] ; then 
		zenity --info --title="Desktop Gmail Grabber" --text="Mail send"
	else
		zenity --error --title="Desktop Gmail Grabber" --text="Mail sending:failed"
	fi; rm -f :;
}

#service branch
main_gmail() {
	init_atom
	touch :
	case $fservice in
		New-Mail) newmail ;;
		Mail-Number) totmailno ;;
		Send-Mail) sendmail ;;
		Mail-From) mail_from ;;
		Mail-Subject) mail_subj ;;
		Mail-Summary) mail_summary ;;
	esac
}
main_gmail
rm -f :>/dev/null 2>&1; exit 0
