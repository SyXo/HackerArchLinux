#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use IO::File;

require ConsolePrintTemplates;
use File::Find;

if ( $> ) {
	ConsolePrintTemplates::ErrorOutMessage( 1 , "This installation script must be run with root (or sudo) privileges" );
}

ConsolePrintTemplates::OperHeading( "Installing necessary dependencies" );
system( "pip install ipcalc" );

system( "python2 " . getcwd() . "/libs/bt3ins.py" );

my $dir = "/opt/BT3-2.5/certs";
if ( !-e $dir || !-d $dir ) {
	mkdir $dir;
}
elsif ( -e $dir ) {
	ConsolePrintTemplates::OperTitle( "Folder already exists." );
}

chdir $dir;

ConsolePrintTemplates::OperHeading( "Generating server key and certificate" );
system( "openssl req -nodes -new -x509 -days 3650 -keyout server.key -out server.crt" );
ConsolePrintTemplates::CheckReturn( 1 , "Failed to generate!" );

ConsolePrintHeadings::OperHeading( "Generating PEM" );
system( "cat server.crt server.key > server.pem" );
ConsolePrintHeadings::CheckReturn( 1 , "Failed to generate!" );

chown "root" , "root" , File::Finder->in( getcwd());
chmod 755 , File::Finder->in( getcwd());