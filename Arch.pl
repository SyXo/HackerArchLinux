# !/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Term::ANSIColor;
use IO::File;
use Cwd;

use lib sprintf( "%s/lib" , getcwd());
use HackerArch::FuncHeaders qw( :ALL );
use HackerArch::Init qw( :ALL );
use HackerArch::Staging qw( InsertInstallEntryPoint );


sub InitStart {
	HackerArch::Init::VerifyConnectivity();
	HackerArch::Init::VerifyDiskPrep();
	HackerArch::Init::SystemMount();
	HackerArch::Init::Pacstrap( sprintf( "%s/init/pacman.conf" , getcwd()));
}

sub InitToStaging {
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
	system( "cp MikiArchStaging.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "New root must have files in order to continue!" );

	HackerArch::FuncHeaders::OperHeading( "Copying install script" );
	system( "cp MikiArchInstall.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );

	HackerArch::FuncHeaders::OperHeading( "Copying extras (blackarch, sublime, AUR) script" );
	system( "cp MikiArchExtras.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );

	HackerArch::FuncHeaders::OperHeading( "Copying ricing script" );
	system( "cp MikiArchRicing.pl /mnt/root &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Install cannot continue without script file!" );

	HackerArch::Init::InsertStagingEntryPoint();

	HackerArch::FuncHeaders::CategoryHeading( "Chroot into new system" );
	system( "arch-chroot /mnt" );
}


BEGIN{
	print color ( "bold cyan" );
	print "\t\t" , "Welcome to Miki's custom Arch Linux + Gnome base + i3 install." , "\n";
	print "\t\t" , "Please be aware that this script will reboot your computer" , "\n";
	print "\t\t" , "->when necessary and then continue automatically until the end." , "\n";
	print color ( "bold red" );
	print "\t\t" , " Please do not use the computer until configuration has completed." , "\n";
	print color ( "reset" );
	print "\n\n";
	print "\t\t\t\t\t" , "Thank you. And ENJOY!! ))" , "\n\n";

	print "Press 'ENTER' to continue" , "\n";
	<>;

	InitStart();
	InitToStaging();
}

END {
	HackerArch::Staging::InsertInstallEntryPoint();

	# unmount all new system
	system( "umount /mnt/{boot,tmp,home} " );
	system( "umount /mnt" );
	system( "reboot" );
}
