#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use Term::ANSIColor;
use IO::File;

use lib sprintf( "%s/lib" , getcwd());
use HackerArch::FuncHeaders qw( :ALL );
use HackerArch::Install qw( :ALL );

sub Start {
	HackerArch::Install::InitUsermode();
	HackerArch::Install::RemoveInstallEntryPoint();
	HackerArch::Install::InstallFirefoxESR();
	HackerArch::Install::InstallVirtBox();
	HackerArch::Install::AddGdbAsm();
	HackerArch::Install::Nvidia();
}

BEGIN {
	Start();

	HackerArch::FuncHeaders::CategoryHeading( "This is the section that add Arch User Repository to your system." );
	print "Press 'ENTER' to continue.";
	<>;
}

END {
	print "\n\n" , "<<|  Adjusting your newly-installed system with some more personalization ... |>>" , "\n\n";

	HackerArch::FuncHeaders::OperTitle( "Enabling services - reboot into your new system will UI" );
	`systemctl enable lightdm`;
	`systemctl enable iptables`;
	`systemctl enable bluetooth`;
	`systemctl enable NetworkManager`;
	`systemctl enable acpid`;
	`systemctl enable vboxweb`;

	HackerArch::FuncHeaders::OperHeading( "Adjusting Xorg server video output layout" );
	system( "cp " . getcwd() . "/install/video/intel-nvidia.conf /etc/X11/xorg.conf.d/" );
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Adjusting for i3 registration to look like GNOME" );
	system( "cp " . getcwd() . "/install/profile /home/" . HackerArch::FuncHeaders::GetUsername() . "/.profile" );
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Adding DNS servers for faster installations" );
	system( "cp " . getcwd() . "/install/resolv.conf /etc/" );

	HackerArch::FuncHeaders::OperHeading( "Adding Jetbrains activation server" );
	system( "cp -R " . getcwd() . "/install/jetbrainsrv /opt" );
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Adding symlink for execution" );
	system( "ln -s /opt/jetbrainsrv/jetbrains_licsrv.linux.amd64 /usr/local/bin/jetbrainsrv" );
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperTitle( "Copy exec to usr-local-bin" );
	system( "cp " . getcwd() . "/install/usr-local-bin/* /usr/local/bin" );
	system( "chown root.root /usr/local/bin/* " );
	system( "chmod 555 /usr/local/bin/* " );

	print "Press 'ENTER' to continue";
	<>;
}