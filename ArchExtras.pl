#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use IO::File;

require ConsolePrintTemplates;
use lib sprintf( "%s/lib" , getcwd());
use HackerArch::ExtrasInstall qw( :ALL );


sub Start {
	HackerArch::ExtrasInstall::InitPkgMgrs();
	HackerArch::ExtrasInstall::ExtraPkgs();
	HackerArch::ExtrasInstall::AddAur();
	HackerArch::ExtrasInstall::AurPkgs();
	HackerArch::ExtrasInstall::AurFonts();
	HackerArch::ExtrasInstall::InstallConfigI3();
	HackerArch::ExtrasInstall::VirtEnv();
}

BEGIN {
	Start();
}

END {
	ConsolePrintTemplates::CategoryHeading( "CONGRATULATIONS! Your system is now ready! Enjoy ))" );
	`systemctl enable lightdm`;
	ConsolePrintTemplates::CategoryFooter( "That's it folks." );

	system( "chown -R " . ConsolePrintTemplates::GetUsername() . ":users /home/" . ConsolePrintTemplates::GetUsername());
}
