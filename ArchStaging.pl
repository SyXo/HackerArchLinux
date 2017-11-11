#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use Term::ANSIColor;
use IO::File;

use lib sprintf( "%s/lib" , getcwd());
use HackerArch::FuncHeaders qw( :ALL );
use HackerArch::Staging qw( :ALL );

sub Start {
	HackerArch::Staging::InitSystem();
	HackerArch::Staging::RemoveEntryPoint();
	HackerArch::Staging::ReflectorPacmanUpdate( sprintf( "%s/staging/pacman.conf" , getcwd()));
	HackerArch::Staging::StageInstall();
	HackerArch::Staging::BuildFstab();

	HackerArch::FuncHeaders::OperHeading( "Copying default grub settings and reinitiallizing compiled images" );
	`cp staging/etc-default/grub /etc/default/grub &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "Grub defaults HAVE NOT changed." );

	system( "pacman -S --noconfirm linux-lts" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );
}

sub HardeningSystem {
	HackerArch::FuncHeaders::CategoryHeading( "Hardening your new system" );

	HackerArch::FuncHeaders::OperHeading( "Replacing makepkg - added compilation security" );
	`cp staging/makepkg.conf /etc/makepkg.conf &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "Pkg compiling NOT secured." );

	HackerArch::FuncHeaders::OperHeading( "Replacing default-passwd - stronger hashes for shadom file" );
	`cp staging/etc-default/passwd /etc/default/passwd &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "passwd default configuration." );

	HackerArch::FuncHeaders::OperHeading( "Adding : iptables basic ; system journaling verbosity ; sysctl - kernel hardening" );
	`cp -R staging/etc / &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "NO added debugging features." );
}

sub BashrcConfs {
	HackerArch::FuncHeaders::CategoryHeading( "Overwriting .bashrc files for both root and your created user" );

	my $FHandle = IO::File->new( "<  " . getcwd() . "/staging/bashrc" );
	my @bashrc;
	if ( defined $FHandle ) {
		@bashrc = <$FHandle>;
	}
	$FHandle->close;

	HackerArch::FuncHeaders::OperHeading( "Writing to " . HackerArch::FuncHeaders::GetUsername() . "'s profile bashrc" );

	$FHandle = IO::File->new( "+> /home/" . HackerArch::FuncHeaders::GetUsername() . "/.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle 'function nonzero_return() {' , "\n";
		print $FHandle 'RETVAL=$?' , "\n";
		print $FHandle '[ $RETVAL -ne 0 ] && echo "$RETVAL" ' , "\n";
		print $FHandle '}' , "\n\n";
		print $FHandle 'export PS1="\A |> \u @ \w [\`nonzero_return\`]:\\\$ " ' , "\n";
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;
	HackerArch::FuncHeaders::SuccessMessage();

	HackerArch::FuncHeaders::OperHeading( "Writing to root's profile bashrc" );
	$FHandle = IO::File->new( "+> /root/.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle 'function nonzero_return() {' , "\n";
		print $FHandle 'RETVAL=$?' , "\n";
		print $FHandle '[ $RETVAL -ne 0 ] && echo "$RETVAL" ' , "\n";
		print $FHandle '}' , "\n\n";
		print $FHandle 'export PS1="\A |> \u @ \w [\`nonzero_return\`]:\\\$ " ' , "\n";
		$FHandle->close();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	HackerArch::FuncHeaders::SuccessMessage();

	`source ~/.bashrc`;
	HackerArch::FuncHeaders::CategoryFooter( 'root\'s bashrc file has been successfully source and can now add install entry point.' );
}


BEGIN {
	Start();
	HardeningSystem();
	BashrcConfs();
}

END{
	my $FHandle = IO::File->new( "+> /etc/issue " );
	if ( defined $FHandle ) {
		print $FHandle "Please login as root for the install to coninue ..." , "\n";
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;

	my $msg = 'This completes the new system install - base configuration and NO [UI]!' . "\n\n";
	$msg .= 'This script is now closed and you need to manually type "exit" in order to continue.';

	HackerArch::FuncHeaders::CategoryFooter( $msg );
}
