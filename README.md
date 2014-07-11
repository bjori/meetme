# MeetMe

Conference system for Mac mini connected to TVs.


Each Mac mini in a conference room should fetch its own calendar regularly via crontab.
Upon finding an upcoming event which has additional BlueJeans Room Resource attached to it
MeetMe will place the meeting into its queue and automatically launch the meeting on time.


# Reasoning?

Normal approach has so far been:
- Enter Meeting Room
- Find the keyboard
- Find the mouse
- Open Google Chrome
- Open new Incognito Window
- Open calendar.google.com
- Login
- Find my phone, for 2FA
- Locate the meeting
- Find "Joining the Meeting Room" instructions
- Join the Meeting Room

Once the meeting finishes:
- Exit Incognito
- Make sure I didn't accidentally login 
- Exit Chrome

