import os

username = os.popen( "cat /etc/passwd |grep 1000| awk -F \":\" ' {print $1} ' " ).readline( ).strip( '\n' )
fileStr = "/home/" + username + "/.config/i3/touchpad-id"

with open( fileStr , "r" ) as f :
	touchpadId = f.readline( ).strip( )
	toggleid = f.readline( ).strip( )
	state = f.readline( ).strip( )

if state == "0" :
	os.system( "xinput set-prop " + touchpadId + " " + toggleid + " 1" )
	state = "1"
else :
	os.system( "xinput set-prop " + touchpadId + " " + toggleid + " 0" )
	state = "0"

with open( fileStr , "w+" ) as f :
	f.writelines( touchpadId + os.linesep )
	f.writelines( toggleid + os.linesep )
	f.writelines( state + os.linesep )
