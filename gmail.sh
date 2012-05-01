#!/bin/bash
#
# Shell Script Application written by Pranav
# Access Gmail without a Browser
# Enabled via zenity and yad dialog display utilities,
# for providing an interactive environment,
# which are recommended due to their ease to use.
# Before running this script it must make sure that,
# your shell must be enrich by curl and  mutt utilities.
# Demonstrated in Linux ubuntu 11.04 and bash version
# GNU bash, version 4.2.8(1)-release (i686-pc-linux-gnu)
# email: <http://pranavns416@gmail.com>
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
			 --text="All fields must be non-empty"
	exit 1;
fi

respaddr=https://mail.google.com/mail/feed/atom
network_error() {
	zenity --error --title='Desktop Gmail Grabber: Caution!'\
		--text="Network doesn't exist" ;exit 1
}

#occurence of new message(mail) in the account
function newmail()
{
	curl -su $femailid:$fpasswds $respaddr >:
	loginfo=`cat : | wc -l`
	if test $loginfo -eq 0 ; then network_error
	elif test $loginfo -gt 8 ; then
		zenity --info --title="Desktop Gmail Grabber" --text="New mail found!"
	else
		zenity --info --title="Desktop Gmail Grabber" --text="New mail is not found!"
	fi
}

#checks the number of mails by greping tab summary
function totmailno()
{	
	curl -su $femailid:$fpasswds $respaddr >:
	loginfo=`cat :| wc -l`
	if test $loginfo  -eq 0 ; then network_error; fi		
	COUNT_NO=$(sed -n '/<fullcount>/p' : | sed -e 's/<fullcount>/\ / '\
	-e 's%</fullcount>%\ % ' | awk '{ print $1 }')
	if [ "$COUNT_NO" != "0" ]; then
		zenity --info  --title='Desktop Gmail Grabber' \
			--text="You have $COUNT_NO mails to read"
	else
		zenity --info  --title='Desktop Gmail Grabber' \
			--text="You have no mails to read"
	fi
	rm -f :;cd ~;
}

#list out all the senders
function mail_from()
{
	curl -su $femailid:$fpasswds $respaddr >:
	len=$(cat : | wc -l)
	if test $len -eq 0 ;then network_error; fi
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
	curl -su $femailid:$fpasswds $respaddr >:
	len=$(cat : | wc -l)
	if test $len -eq 0 ;then network_error; fi
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

#list of summary in short
function mail_summary()
{
	cd $HOME; cat web>:
	#curl -su $femailid:$fpasswds $respaddr >:
	len=$(cat : | wc -l)
	if test $len -eq 0 ;then network_error; fi
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
	curl -su $femailid:$fpasswds $respaddr >:
	len=$(cat : | wc -l)
	if test $len -eq 0 ;then network_error; fi
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
		zenity --warning --text="Email field must be non-empty"
		exit 1; fi
	if [ "$mesg" == "" ]; then
		zenity --warning --text="Content of message be non-empty"
		exit 1; fi
	echo "$mesg" >:
	if [ "$fatch" == "(null)" ]; then
		cat : | mutt -s "$fsubj" "$fmail" >/dev/null ; null=$? #note exit status failed/not
	else
		cat : | mutt -s "$fsubj" "$fmail" -a "$fatch" >/dev/null
		not_null=$?; fi #checking exit status if it does work(error occured redirection:failed/not)
	if [ "$null" == "0" ] || [ "$not_null" == "0" ] ; then 
		zenity --info --title="Desktop Gmail Grabber" --text="Mail send"
	else
		zenity --error --title="Desktop Gmail Grabber" --text="Mail sending:failed"
	fi; rm -f :;
}

#service branch
gmail() {
	case $fservice in
		New-Mail) newmail ;;
		Mail-Number) totmailno ;;
		Send-Mail) sendmail ;;
		Mail-From) mail_from ;;
		Mail-Subject) mail_subj ;;
		Mail-Summary) mail_summary ;;
	esac
}
gmail;exit 0
