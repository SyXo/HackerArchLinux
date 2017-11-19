import os
import urllib
import urllib2

current_dir = os.path.dirname( __file__ )

req = urllib2.Request( 'https://www.mozilla.org/en-US/firefox/organizations/all' )
response = urllib2.urlopen( req )
the_page = str.split( response.read( ) , '\n' )

linkUrl = ""
for ctr in range( 0 , len( the_page ) ) :
	if the_page[ ctr ].__contains__( 'Download for Linux 64-bit in English (US)' ) :
		linkUrl = str( the_page[ ctr ] ).strip( ).split( ' ' )[ 1 ].replace( "href=" , "" ).strip( '"' )
		break

# print linkUrl

# urllib.urlretrieve( linkUrl , "firefox.tar.bz2" )

u = urllib.urlopen( linkUrl )
meta = u.info( )
file_size = int( meta.getheaders( "Content-Length" )[ 0 ] )

print "%s bytes..." % file_size ,
f = open( "firefox.tar.bz2" , 'wb' )

blockSize = 8192  # 100000 # urllib.urlretrieve uses 8192
count = 0
while True :
	chunk = u.read( blockSize )
	if not chunk : break
	f.write( chunk )
	count += 1
	if file_size > 0 :
		percent = int( count * blockSize * 100 / file_size )
		if percent > 100 : percent = 100
		print "%2d%%" % percent ,
		if percent < 100 :
			print "\b\b\b\b\b" ,  # Erase "NN% "
		else :
			print "Done."

f.flush( )
f.close( )
if not file_size :
	print "ERROR! Failed to download Firefox ESR."
	exit( 1 )

exit( 0 )
