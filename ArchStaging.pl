#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use IO::File;

require ConsolePrintTemplates;
use lib sprintf( "%s/lib" , getcwd());
use HackerArch::Staging qw( :ALL );
use HackerArch::Setup qw( :ALL );

sub Start {
	HackerArch::Staging::InitSystem();
	HackerArch::Staging::AdjustUpdatePacman( sprintf( "%s/staging/pacman.conf" , getcwd()));
	HackerArch::Staging::StageInstall();
	HackerArch::Staging::BuildFstab();

	ConsolePrintTemplates::OperHeading( "Copying default grub settings and reinitiallizing compiled images" );
	`cp staging/etc-default/grub /etc/default/grub &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "Grub defaults HAVE NOT changed." );

	system( "pacman -S --noconfirm linux-lts" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );
}

sub HardeningSystem {
	ConsolePrintTemplates::CategoryHeading( "Hardening your new system" );

	ConsolePrintTemplates::OperHeading( "Replacing makepkg - added compilation security" );
	`cp staging/makepkg.conf /etc/makepkg.conf &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "Pkg compiling NOT secured." );

	ConsolePrintTemplates::OperHeading( "Replacing default-passwd - stronger hashes for shadom file" );
	`cp staging/etc-default/passwd /etc/default/passwd &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "passwd default configuration." );

	ConsolePrintTemplates::OperHeading( "Adding : iptables basic ; system journaling verbosity ; sysctl - kernel hardening" );
	`cp -R staging/etc / &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "NO added debugging features." );
}

sub BashrcConfs {
	ConsolePrintTemplates::CategoryHeading( "Overwriting .bashrc files for both root and your created user" );

	my $FHandle = IO::File->new( "<  " . getcwd() . "/staging/bashrc" );
	my @bashrc;
	if ( defined $FHandle ) {
		@bashrc = <$FHandle>;
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperHeading( "Writing to " . ConsolePrintTemplates::GetUsername() . "'s profile bashrc" );

	$FHandle = IO::File->new( "+> /home/" . ConsolePrintTemplates::GetUsername() . "/.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle 'function nonzero_return() {' , "\n";
		print $FHandle 'RETVAL=$?' , "\n";
		print $FHandle '[ $RETVAL -ne 0 ] && echo "$RETVAL" ' , "\n";
		print $FHandle '}' , "\n\n";
		print $FHandle 'export PS1="$BCyan \A |> \u @ \w [\`nonzero_return\`]:\\\$ $COLOR_RESET" ' , "\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperHeading( "Writing to root's profile bashrc" );
	$FHandle = IO::File->new( "+> /root/.bashrc" );
	if ( defined $FHandle ) {
		foreach( @bashrc ) {
			print $FHandle $_;
		}
		print $FHandle 'function nonzero_return() {' , "\n";
		print $FHandle 'RETVAL=$?' , "\n";
		print $FHandle '[ $RETVAL -ne 0 ] && echo "$RETVAL" ' , "\n";
		print $FHandle '}' , "\n\n";
		print $FHandle 'export PS1="$BRed \A |> \u @ \w [\`nonzero_return\`]:\\\$ $COLOR_RESET" ' , "\n";

		$FHandle->close();
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperHeading( 'Sourcing root\'s bashrc profile file' );
	`source ~/.bashrc`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );
}


BEGIN {
	print "\n\n";

	HackerArch::Setup::RemoveStagingAutostart();

	Start();
	HardeningSystem();
	BashrcConfs();
}

END{
	my $msg = 'This completes the new system install - base configuration and NO [UI]!' . "\n\n";
	$msg .= 'This script is now closed and you need to manually type "exit" in order to continue.';

	ConsolePrintTemplates::CategoryFooter( $msg );
}
