#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use Term::ANSIColor;
use IO::File;

use lib sprintf( "%s/lib" , getcwd());
use HackerArch::FuncHeaders qw( :ALL );
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
