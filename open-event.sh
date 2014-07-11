#!/bin/sh

EVENTSDIR="MYEVENTS"
URLTEMPLATE="https://wwww.bluejeans.com/%s/browser"

for i in /etc/meetmerc ~/.meetmerc .meetmerc; do
	if [ -r $i ]; then
		echo "Loading config $i"
		. $i
	fi
done


abort_meeting() {
	rm $MEETINGID
	say "ABORTING MEETING"
	exit 42
}

countdown () {
	from=$1
	to=$2
	say --voice "Bells" "$from seconds"
	let from=from-1;
	for i in `seq $from $to`; do
		if [ -f $MEETINGID ]; then
			say --voice Cellos "$i"
		fi
	done
	say --voice Hysterical "1"
}

ask_ok() {
	seconds=$1

	osascript -e 'tell app "System Events" to display dialog "Any current meetings will be destroyed when next meeting starts" buttons {"Cancel", "OK"} giving up after '$seconds

	if [ $? -ne 0 ]; then
		abort_meeting
	fi

}

sleep_until() {
	until=`expr $STARTSAT - $1`
	now=`date +"%s"`

	diff=`expr $until - $now`

	if [ $diff -gt 0 ]; then
		echo "Sleeping for $diff"
		sleep $diff
	fi
}



for MEETINGID in `find $EVENTSDIR/*`; do
	now=`date +"%s"`
	read -r VIDEOID STARTSAT < $MEETINGID

	echo "Got Video $VIDEOID starting at $STARTSAT :)"

	next2min=`expr $now + 120`

	if [ $STARTSAT -gt $next2min ]; then
		echo $MEETINGID is in the future
		continue;
	fi

	sleep_until 120

	say --voice Alex "New meeting will start in... 2minutes"
	ask_ok 120

	sleep_until 60
	say --voice Junior "1 minute"

	sleep_until 10
	countdown 10 2 &
	ask_ok 11

	osascript -e 'tell application "Google Chrome" to quit'
	sleep 1

	url=$(printf $URLTEMPLATE $VIDEOID)
	open -a "Google Chrome" -n -F --args --incognito --kiosk $url
	say "Starting BlueJeans meeting now!"
	rm $MEETINGID
done

