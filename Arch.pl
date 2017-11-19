# !/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Term::ANSIColor;
use IO::File;
use Cwd;

use lib sprintf( "%s/lib" , getcwd());
use HackerArch::FuncHeaders qw( :ALL );
use HackerArch::Init qw( :ALL );
use HackerArch::Setup qw( :ALL );


sub Start {
	HackerArch::Init::VerifyConnectivity();
	HackerArch::Init::VerifyDiskPrep();
	HackerArch::Init::SystemMount();

	`pacman -S --noconfirm reflector`;
	`reflector --verbose --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist`;

	HackerArch::Init::Pacstrap( getcwd() . "/init/pacman.conf" );
}


BEGIN{
	print color ( "bold cyan" );
	print "\t\t" , "Welcome to Miki's custom Arch Linux + Gnome base + i3 install." , "\n";
	print "\t\t" , "This project is a completely automated installation process." , "\n";
	print "\t\t" , "Please be patient - installation total size is about 20GB!" , "\n\n";

	print color ( "reset" );
	print "\t\t\t\t\t" , "Thank you. And ENJOY!! ))" , "\n\n";

	print "Press 'ENTER' to continue" , "\n";
	<>;

	Start();

	HackerArch::Setup::CodeCopy();
	HackerArch::Setup::AddStagingAutostart();

	HackerArch::FuncHeaders::CategoryHeading( "Chroot into new system" );
	system( "arch-chroot /mnt" );
}

END {
	HackerArch::Setup::AddInstallAutostart();

	# unmount all new system
	system( "umount /mnt/{boot,tmp,home} " );
	system( "umount /mnt" );
	system( "reboot" );
}
