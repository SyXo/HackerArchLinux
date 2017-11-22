use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Setup;
require ConsolePrintTemplates;
use Cwd;
use IO::File;
use LWP::UserAgent;
use HTTP::Request;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( CodeCopy AddStagingAutostart RemoveStagingAutostart AddInstallAutostart RemoveInstallAutostart );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &CodeCopy &AddStagingAutostart &RemoveStagingAutostart &AddInstallAutostart &RemoveInstallAutostart ) ] );

sub CodeCopy {
	my $pwd = sprintf( "%s" , getcwd());
	my $libDir = sprintf( "%s/lib" , $pwd );
	my $stagingDir = sprintf( "%s/staging" , $pwd );
	my $installDir = sprintf( "%s/install" , $pwd );
	my $ricingDir = sprintf( "%s/ricing" , $pwd );

	ConsolePrintTemplates::CategoryHeading( "Setting up entry into the newly install system" );

	ConsolePrintTemplates::OperHeading( "Copying base HackerArch lib folder to new root" );
	system( "cp -R $libDir /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "New root must have files in order to continue!" );

	ConsolePrintTemplates::OperHeading( "Copying staging folder to new root" );
	system( "cp -R $stagingDir /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "New root must have files in order to continue!" );

	ConsolePrintTemplates::OperHeading( "Copying install folder to new root" );
	system( "cp -R $installDir /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "New root must have files in order to continue!" );

	ConsolePrintTemplates::OperHeading( "Copying ricing folder to new root" );
	system( "cp -R $ricingDir /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "New root must have files in order to continue!" );

	ConsolePrintTemplates::OperHeading( "Copying staging script to new root" );
	system( "cp ArchStaging.pl /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "New root must have files in order to continue!" );

	ConsolePrintTemplates::OperHeading( "Copying install script" );
	system( "cp ArchInstall.pl /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "Install cannot continue without script file!" );

	ConsolePrintTemplates::OperHeading( "Copying extras (blackarch, sublime, AUR) script" );
	system( "cp ArchExtras.pl /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "Install cannot continue without script file!" );

	ConsolePrintTemplates::OperHeading( "Copying ricing script" );
	system( "cp ArchRicing.pl /mnt/root &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "Install cannot continue without script file!" );
}

sub AddStagingAutostart {
	ConsolePrintTemplates::CategoryHeading( 'Adding "staging" autostart point' );

	ConsolePrintTemplates::OperHeading( "Writing to file" );
	my $FHandle = IO::File->new( "+>> /mnt/etc/bash.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n";
		print $FHandle "cd /root/lib/ConsolePrintTemplates" , "\n";
		print $FHandle "make &>/dev/null" , "\n";
		print $FHandle "make install &>/dev/null" , "\n";
		print $FHandle "cd" , "\n";
		print $FHandle "perl ArchStaging.pl" , "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveStagingAutostart {
	ConsolePrintTemplates::CategoryHeading( 'Removing the "staging" autostart point' );

	ConsolePrintTemplates::OperHeading( "Reading file" );
	my $FHandle = IO::File->new( "< /etc/bash.bashrc" );
	my @bashrc;
	if ( defined $FHandle ) {
		@bashrc = <$FHandle>;
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file . " );
	}

	for ( 1 .. 6 ) {
		print "pop ";
		pop @bashrc;
	}
	print "\n";

	ConsolePrintTemplates::OperHeading( "Writing back to file" );
	$FHandle = IO::File->new( "+> /etc/bash.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file . " );
	}

	ConsolePrintTemplates::CategoryFooter( 'Successfully removed "staging" entry point' );
}

sub AddInstallAutostart {
	ConsolePrintTemplates::OperTitle( 'Preparing installed system for autostart' );

	my $FHandle = IO::File->new( "+> /mnt/etc/issue " );
	if ( defined $FHandle ) {
		print $FHandle "Please login as root for the install to coninue ..." , "\n\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperHeading( 'Adding "install" autostart point' );

	$FHandle = IO::File->new( "+> /mnt/root/.extend.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "perl /root/ArchInstall.pl" , "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveInstallAutostart {
	ConsolePrintTemplates::CategoryHeading( 'Removing  "install" autostart point' );
	`shred -u /root/.extend.bashrc &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );
}

sub AddExtrasInstallAutostart {
	ConsolePrintTemplates::CategoryHeading( 'Adding "extras install" autostart point' );

	my $FHandle = IO::File->new( "+> /root/.extend.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "perl /root/ArchExtras.pl" , "\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveExtrasInstallAutostart {
	ConsolePrintTemplates::OperHeading( "Resetting banner file" );

	my $FHandle = IO::File->new( "+> /etc/issue" );
	if ( defined $FHandle ) {
		print $FHandle  "Fedora Linux lts" , "\n\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , " Cannot write to file. " )
	}

	ConsolePrintTemplates::CategoryHeading( 'Removing  "install" autostart point' );
	`shred -u /root/.extend.bashrc &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );
}

sub DownloadFile {
	my ($Url , $FileSavePath) = @_;
	ConsolePrintTemplates::OperTitle( "Downloading file " );

	my $ua = LWP::UserAgent->new(
		'ssl_opts'          => { 'verify_hostname' => 0 } ,
		'protocols_allowed' => [ 'https' ] ,
	);
	$ua->show_progress( 1 );

	my $req = HTTP::Request->new( 'GET' => $Url );
	my $response = $ua->request( $req );
	my $file = $response->decoded_content( 'charset' => 'none' );

	ConsolePrintTemplates::OperTitle( "Saving file to local disk" );
	my $FHandle = IO::File->new( "+> " . $FileSavePath );
	if ( defined $FHandle ) {
		binmode( $FHandle );
		print $FHandle $file;
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub SearchWebpageLink {
	my ($Url , $reSearch , $FileSaveto) = @_;
	my $mech = WWW::Mechanize->new;

	ConsolePrintTemplates::OperHeading( "GET webpage from url" );
	$mech->get( $Url );
	if ( $mech->status() == 200 ) {
		ConsolePrintTemplates::SuccessMessage();

		ConsolePrintTemplates::OperTitle( "Searching webpage for search criteria" );
		my @page_links = $mech->find_all_links( 'text_regex' => qr/$reSearch/ );
		my $filename = "";
		foreach ( @page_links ) {
			$filename = $_->[0];
			DownloadFile( $Url . $filename , $FileSaveto );
		}
	}
}
