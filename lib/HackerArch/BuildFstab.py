#!/usr/bin/python3

import os


def BlockDeviceStringSplit( MyString , primDelim , secDelim ) :
	devDict = { }

	for part in MyString.split( primDelim )[ 1 : ] :
		myKey = part.split( secDelim )[ 0 ]
		myValue = part.split( secDelim )[ 1 ].strip( '"' )
		devDict.update( { myKey : myValue } )
	# =============================================================================================
	return devDict


def IsDevSsd( devStr ) :
	devSpecs = os.popen( "smartctl -a /dev/" + devStr ).readlines( )
	for line in devSpecs :
		if line.startswith( "Rotation Rate" ) :
			if line.split( ":" )[ 1 ].__contains__( "Solid State" ) :
				return True
			else :
				break
	# =============================================================================================
	return False


BlockDevs = os.popen( "blkid" ).readlines( )

# root (ext4)  ==> defaults,block_validity,journal_checksum,user_xattr      0       1
# boot (ext2)  ==> rw,auto,nouser,nodev,nosuid,noexec,barrier,acl           0       0
# tmp (ext4)   ==> rw,nouser,nodev,nosuid		                        	0       0
# home (ext4)  ==> defaults,user_xattr,i_version                            0	    2
# swap (none)  ==> defaults
# <dump>  == Enable or disable backing up of the device/partition (the command dump). This field is usually set to 0, which disables it.
# <pass num> Controls the order in which fsck checks the device/partition for errors at boot time. The root device should be 1. Other partitions should be 2,
# or 0 to disable checking.

myDevs = 0
FstabFileDict = [ ]
for devln in BlockDevs :
	blkdev = devln.split( " " )[ 0 ].split( '/' )[ 2 ].strip( ":" )
	devSplit = BlockDeviceStringSplit( devln.strip( "\n" ) , ' ' , '=' )
	if not str( blkdev ).__contains__( "sr" ) and not str( blkdev ).__contains__( "loop" ) :
		if blkdev.__contains__( 'sda1' ) :
			FstabFileDict.append( { "name"      : "boot" , "UUID" : str( devSplit[ 'UUID' ] ).strip( '"' ) , "mount" : "/boot" ,
			                        "type"      : str( devSplit[ 'TYPE' ] ).strip( '"' ) , "mountopts" : "rw,auto,nouser,nodev,nosuid,noexec,barrier,acl" , "dump" : "0" ,
			                        "pass"      : "0" } )
		elif blkdev.__contains__( 'sda2' ) :
			swapUUID = os.popen( 'mkswap /dev/sda2 | grep UUID | awk -F "=" "{print $2}" ' ).readline( ).strip( )
			FstabFileDict.append( { "name" : "swap" , "UUID" : swapUUID , "mount" : "none" , "type" : "swap" , "mountopts" : "defaults" , "dump" : "0" , "pass" : "0" } )
		elif blkdev.__contains__( 'sda5' ) :
			if IsDevSsd( blkdev ) :
				mountopts = "defaults,discard,block_validity,journal_checksum,user_xattr"
			else :
				mountopts = "defaults,block_validity,journal_checksum,user_xattr"
			FstabFileDict.append( { "name"      : "root" , "UUID" : str( devSplit[ 'UUID' ] ).strip( '"' ) , "mount" : "/" , "type" : str( devSplit[ 'TYPE' ] ).strip( '"' ) ,
			                        "mountopts" : mountopts , "dump" : "0" , "pass" : "0" } )
		elif blkdev.__contains__( 'sda6' ) :
			if IsDevSsd( blkdev ) :
				mountopts = "discard,rw,nouser,nodev,nosuid,noexec"
			else :
				mountopts = "rw,nouser,nodev,nosuid,noexec"

			FstabFileDict.append( { "name"      : "tmp" , "UUID" : str( devSplit[ 'UUID' ] ).strip( '"' ) , "mount" : "/tmp" ,
			                        "type"      : str( devSplit[ 'TYPE' ] ).strip( '"' ) , "mountopts" : mountopts , "dump" : "0" , "pass" : "0" } )
		elif blkdev.__contains__( 'sda7' ) :
			if IsDevSsd( blkdev ) :
				mountopts = "discard,defaults,user_xattr,i_version"
			else :
				mountopts = "defaults,user_xattr,i_version"

			FstabFileDict.append( { "name"      : "home" , "UUID" : str( devSplit[ 'UUID' ] ).strip( '"' ) , "mount" : "/home" ,
			                        "type"      : str( devSplit[ 'TYPE' ] ).strip( '"' ) , "mountopts" : "defaults,user_xattr,i_version" , "dump" : "0" , "pass" : "0" } )
		elif blkdev.__contains__( 'sd' ) :
			if IsDevSsd( blkdev ) :
				mountopts = "discard,defaults,nodev,nosuid"
			else :
				mountopts = "defaults,nodev,nosuid"

			myDevs += 1
			try :
				mount = "/mnt/" + str.lower( str( devSplit[ 'LABEL' ] ) )
			except KeyError :
				mount = "/mnt/" + blkdev

			FstabFileDict.append(
					{ "UUID" : str( devSplit[ 'UUID' ] ).strip( '"' ) , "mount" : mount , "type" : str( devSplit[ 'TYPE' ] ).strip( '"' ) , "mountopts" : mountopts ,
					  "dump" : "0" , "pass" : "2" } )

currentDir = os.path.curdir
# username = os.popen( "cat /etc/passwd | grep 1000 | awk -F ':' '{print $1}' " ).readline( ).strip( '\n' )
# os.system( "cp /etc/fstab " + currentDir + "/fstab.copy" )
# os.system( "chown " + username + ".users" + " " + currentDir + "/fstab.copy" )

print("Total devices found: " + str( 1 + myDevs ) + " ; writing out fstab file")
os.system( "touch /etc/fstab" )
with open( "/etc/fstab" , "w" ) as f :
	for dev in FstabFileDict :
		try :
			commentLn = "#______ " + str( dev[ 'name' ] )
		except KeyError :
			commentLn = "#______ " + str( dev[ 'mount' ] )

		deviceLn = "UUID=" + dev[ 'UUID' ] + "\t\t" + dev[ 'mount' ] + "\t\t\t" + dev[ 'type' ] + "\t\t" + dev[ 'mountopts' ] + "\t\t" + dev[ 'dump' ] + '\t' + dev[ 'pass' ]

		f.writelines( commentLn + os.linesep )
		f.writelines( deviceLn + os.linesep + os.linesep )

	f.writelines( "proc" + "\t\t\t\t\t\t\t" + "/proc" + "\t\t\t" + "proc" + "\t\t" + "nosuid,nodev,noexec,hidepid=2,gid=proc" + "\t\t\t\t" + "0\t0" + os.linesep +
	              os.linesep )
	f.writelines( "none" + "\t\t\t\t\t\t\t" + "/dev/shm" + "\t\t" + "tmpfs" + "\t\t" + "defaults,nodev,nosuid,noexec,size=8G" + "\t\t\t\t" + "0\t0" + os.linesep +
	              os.linesep )
