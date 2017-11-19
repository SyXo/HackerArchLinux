use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Setup;
use Cwd;
use IO::File;

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

	HackerArch::FuncHeaders::CategoryHeading( "Setting up entry into the newly install system" );

	HackerArch::FuncHeaders::OperHeading( "Copying base HackerArch lib folder to new root" );
	system( "cp -R $libDir /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying staging folder to new root" );
	system( "cp -R $stagingDir /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying install folder to new root" );
	system( "cp -R $installDir /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying ricing folder to new root" );
	system( "cp -R $ricingDir /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying staging script to new root" );
	system( "cp ArchStaging.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying install script" );
	system( "cp ArchInstall.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );

	HackerArch::FuncHeaders::OperHeading( "Copying extras (blackarch, sublime, AUR) script" );
	system( "cp ArchExtras.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );

	HackerArch::FuncHeaders::OperHeading( "Copying ricing script" );
	system( "cp ArchRicing.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );
}

sub AddStagingAutostart {
	HackerArch::FuncHeaders::CategoryHeading( 'Adding "staging" autostart point' );

	HackerArch::FuncHeaders::OperHeading( "Writing to file" );
	my $FHandle = IO::File->new( "+>> /mnt/etc/bash.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n";
		print $FHandle "cd /root" , "\n";
		print $FHandle "perl ArchStaging.pl" , "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveStagingAutostart {
	HackerArch::FuncHeaders::CategoryHeading( 'Removing the "staging" autostart point' );

	HackerArch::FuncHeaders::OperHeading( "Reading file" );
	my $FHandle = IO::File->new( "< /mnt/etc/bash.bashrc" );
	my @bashrc;
	if ( defined $FHandle ) {
		@bashrc = <$FHandle>;
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file . " );
	}

	for ( 1 .. 4 ) {
		print "pop ";
		pop @bashrc;
	}
	print "\n";

	HackerArch::FuncHeaders::OperHeading( "Writing back to file" );
	$FHandle = IO::File->new( "+> /mnt/etc/bash.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file . " );
	}

	HackerArch::FuncHeaders::CategoryFooter( 'Successfully removed "staging" entry point' );
}

sub AddInstallAutostart {
	HackerArch::FuncHeaders::OperTitle( 'Preparing installed system for autostart' );

	my $FHandle = IO::File->new( "+> /mnt/etc/issue " );
	if ( defined $FHandle ) {
		print $FHandle "Please login as root for the install to coninue ..." , "\n\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	HackerArch::FuncHeaders::OperHeading( 'Adding "install" autostart point' );

	$FHandle = IO::File->new( "+> /mnt/root/.extend.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "perl /root/ArchInstall.pl" , "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveInstallAutostart {
	HackerArch::FuncHeaders::CategoryHeading( 'Removing  "install" autostart point' );
	`shred -u /root/.extend.bashrc &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );
}

sub AddExtrasInstallAutostart {
	HackerArch::FuncHeaders::CategoryHeading( 'Adding "extras install" autostart point' );

	my $FHandle = IO::File->new( "+> /root/.extend.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "perl /root/ArchExtras.pl" , "\n";

		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
}

sub RemoveExtrasInstallAutostart {
	HackerArch::FuncHeaders::OperHeading( "Resetting banner file" );

	my $FHandle = IO::File->new( "+> /etc/issue" );
	if ( defined $FHandle ) {
		print $FHandle  "Fedora Linux lts" , "\n\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , " Cannot write to file. " )
	}

	HackerArch::FuncHeaders::CategoryHeading( 'Removing  "install" autostart point' );
	`shred -u /root/.extend.bashrc &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );
}
