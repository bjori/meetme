#!/bin/sh


EVENTSDIR="MYEVENTS"
CYBERROOMPREFIX="US-CA-FL1-"

for i in /etc/meetmerc ~/.meetmerc .meetmerc; do
	if [ -r $i ]; then
		echo "Loading config $i"
		. $i
	fi
done


mkdir -p $EVENTSDIR

CALENDAR=$1

export_room_id() {
	VIDEOID=${!1}
}
match_begin_event() {
	len=`expr "$1" : 'BEGIN:VEVENT'`
	if [ $? -eq 0 ]; then
		STATE="GOTEVENT"
		return
	fi
}
starts_in_30min() {
	starts=`expr "$1" : 'DTSTART:\(.*\)00Z'`
	if [ $? -ne 0 ]; then
		return
	fi

	timestamp=`TZ=UTC date -j -f "%Y%m%dT%H%M" $starts +%s`
	now=`date +"%s"`
	next15min=`expr $now + 900` # Next 15min
	next15min=`expr $now + 7200` # Next 2hours

	if [ $timestamp -gt $now -a $timestamp -lt $next15min ]; then
		echo "Its in the next 15min"
		STATE="STARTSIN15MIN"
		STARTSAT=$timestamp
	fi
}

have_i_seen_it_before() {
	ID=`expr "$1" : 'UID:\(.*\)'`
	if [ $? -ne 0 ]; then
		return
	fi
	ID=`echo "$ID" | tr -d '\r\n '`

	if [ -r "$EVENTSDIR/$ID" ]; then
		STATE="IVESEENIT"
	else
		STATE="ISTHEREVIDEO"
	fi
}

is_bluejeans_invited() {
	location=`expr "$1" : 'LOCATION:\(.*\)'`
	if [ $? -ne 0 ]; then
		return
	fi

	inbluejeans=`expr "$location" : '.*US-CA-FL1-\(.*\)'`

	if [ "$inbluejeans" ]; then
		inbluejeans=`echo "$inbluejeans" | tr -d '\r\n '`
		export_room_id $inbluejeans
		STATE="REGISTERIT"
	fi
}

register_meeting() {
	local file=$1
	local videoid=$2
	local startsat=$3

	echo "Registering $videoid as $file starting $startsat"
	echo "$videoid $startsat" > "$file"
}

usage() {
	echo "Usage:\n\t$ $0 path/to/calendar.ics\n"
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

if [ ! -r "$CALENDAR" ]; then
	echo "==> Cannot find '$1'"
	usage
fi

STATE="NADA"
while read i; do
	case $STATE in
		NADA)
			match_begin_event "$i"
			;;
		GOTEVENT)
			starts_in_30min "$i"
			;;
		STARTSIN15MIN)
			have_i_seen_it_before "$i"
			;;
		ISTHEREVIDEO)
			is_bluejeans_invited "$i"
			;;
		# Search for next event
		IVESEENIT)
			STATE="NADA"
			;;
	esac

	if [ $STATE = "REGISTERIT" ]; then
		register_meeting "$EVENTSDIR/$ID" $VIDEOID $STARTSAT
		STATE="NADA"
	fi

done <$CALENDAR

