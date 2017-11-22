use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::ExtrasInstall;
require ConsolePrintTemplates;
use HackerArch::Setup;
use IO::File;
use POSIX;
use Cwd;
use WWW::Mechanize;
use LWP::Simple;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( InitPkgMgrs ExtraPkgs AddAur AurPkgs AurFonts InstallConfigI3 VirtEnv );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &InitPkgMgrs &ExtraPkgs &AddAur &AurPkgs &AurFonts &InstallConfigI3 &VirtEnv ) ] );


sub InitPkgMgrs {
	ConsolePrintTemplates::CategoryHeading( "Initializing and adding additional repositories to local system." );

	ConsolePrintTemplates::OperTitle( "Downloading Sublime Text dev keyring and adding to repository list" );
	system( "curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && shred -u sublimehq-pub.gpg" );

	my $FHandle = IO::File->new( ">> /etc/pacman.conf" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n" , "[sublime-text]" , "\n";
		print $FHandle 'Server = https://download.sublimetext.com/arch/dev/x86_64' , "\n\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperTitle( "Downloading and adding BlackArch repository to local system" );

	my $mirror = "https://blackarch.tamcore.eu/";

	my $sysarch = ( POSIX::uname )[4];
	my $blackarch = "blackarch/os/$sysarch/";

	my $url = $mirror . $blackarch;
	my $regexKeyring = '^blackarch-keyring(?:.+)xz$';
	my $regexKeyringSig = '^blackarch-keyring(?:.+)xz.sig$';
	my $FileKeyring = getcwd() . "/install/repos/blackarch-keyring.pkg.tar.xz";
	my $FileKeyringSig = getcwd() . "/install/repos/blackarch-keyring.pkg.tar.xz.sig";

	HackerArch::Setup::SearchWebpageLink( $url , $regexKeyring , $FileKeyring );
	HackerArch::Setup::SearchWebpageLink( $url , $regexKeyringSig , $FileKeyringSig );

	ConsolePrintTemplates::OperHeading( "Verifying keyring package signature" );
	system( "gpg --recv-keys 7533BAFE69A25079 &>/dev/null" );
	system( "pacman-key --lsign 7533BAFE69A25079 &>/dev/null" );
	my @VerifyOutput = qx(gpg --verify $FileKeyringSig 2>&1);
	my $status = 0;
	for my $line ( @VerifyOutput ) {
		if ( $line =~ /Good signature/ ) {
			$status = 1;
			last;
		}
	}
	if ( $status ) {
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "" );
	}

	system( "pacman-key --init &>/dev/null " );
	system( 'pacman --config /dev/null --noconfirm -U $(find ' . getcwd() . '/install -type f -iname "*.pkg.tar.xz")' );
	if ( "$?" == 0 ) {
		system( "pacman-key --populate" );
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "keyring installation failed!" );
	}

	$FHandle = IO::File->new( ">> /etc/pacman.conf" );
	if ( defined $FHandle ) {
		print $FHandle "[blackarch]" , "\n";
		print $FHandle "Server = $mirror" . $blackarch;
	}

	system( "pacman -Syy" );
}

sub ExtraPkgs {
	my $TextEditor = "sublime-text";
	my $AndroidHacking = "android-sdk android-sdk-build-tools android-sdk-platform-tools python2-frida frida jadx android-apktool dex2jar smali";
	my $NetworkHacking = "burpsuite wireshark-gtk jdk8-openjdk jre8-openjdk-headless wxhexeditor nmap ssldump ";
	my $BreakingTools = "steghide binwalk dirbuster etherape ettercap-gtk john johnny scapy3k";

	system( "pacman -S --noconfirm --force $TextEditor $AndroidHacking $NetworkHacking $BreakingTools" );
}

sub AddAur {
	my $username = ConsolePrintTemplates::GetUsername();

	ConsolePrintTemplates::CategoryHeading( "Adding Arch User Repository to local system" );
	chdir( "/home/" . ConsolePrintTemplates::GetUsername());

	ConsolePrintTemplates::OperTitle( "Installing dependencies" );
	system( "pacman -S --noconfirm expac yajl" );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperTitle( "Adding gpg key for the rest of AUR install" );
	`gpg --recv 1EB2638FF56C0C53`;
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );
	`pacman-key --lsign 1EB2638FF56C0C53`;
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "git clone cower - dependency" );
	`git clone https://aur.archlinux.org/cower.git 2>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Changing git folder to local user for compilation access" );
	system( "chown -R $username:users cower &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Compiling cower package (please wait)" );
	system( "cd cower && sudo -u $username makepkg --skippgpcheck && cd .. &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Manually verifying cower signature" );
	my $CowerPath = getcwd() . "/cower";
	my @SigCheckOutput = qx(find $CowerPath -type f -iname "*.tar.gz.sig" -exec pacman-key --verify {} \\; 2>&1);

	my $truth = 0;
	for my $line ( @SigCheckOutput ) {
		if ( $line =~ /Good signature/ ) {
			ConsolePrintTemplates::SuccessMessage();
			$truth = 1;
			last;
		}
	}
	unless ( $truth ) {
		ConsolePrintTemplates::ErrorOutMessage( 1 , "Script cannot proceed without pacaur!" );
	}

	ConsolePrintTemplates::OperTitle( "Installing cower" );
	system( 'pacman -U --noconfirm $(find cower/ -type f -iname "*.pkg.tar.xz")' );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "git clone pacaur" );
	`git clone https://aur.archlinux.org/pacaur.git &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Changing git folder to local user for compilation access" );
	system( "chown -R $username:users pacaur &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Compiling cower package (please wait)" );
	system( "cd pacaur && sudo -u $username makepkg && cd .. &>/dev/null" );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperTitle( "Installing pacaur" );
	system( 'pacman -U --noconfirm $(find pacaur/ -type f -iname "*.pkg.tar.xz")' );
	ConsolePrintTemplates::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	ConsolePrintTemplates::OperHeading( "Configuring pacaur" );
	my $FHandle = IO::File->new( "+> /etc/xdg/pacaur/config" );
	if ( defined $FHandle ) {
		print $FHandle "#!/bin/bash" , "\n";
		print $FHandle "#" , "\n";
		print $FHandle "#==================================================" , "\n";
		print $FHandle "#             /etc/xdg/pacaur/config" , "\n";
		print $FHandle "#==================================================" , "\n\n";
		print $FHandle 'editor="${VISUAL:-${EDITOR:-vim}}"   # build files editor' , "\n";
		print $FHandle 'displaybuildfiles=full               # display build files (none|diff|full)' , "\n";
		print $FHandle 'fallback=true                        # pacman fallback to the AUR' , "\n";
		print $FHandle 'silent=false                         # silence output' , "\n";
		print $FHandle 'clean=true                           # clean up after package install - default: true' , "\n";
		print $FHandle 'sudoloop=true                        # prevent sudo timeout' , "\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 1 , "Cannot write to file." );
	}

	system ( "sudo -u $username pacaur -Syy" );
	ConsolePrintTemplates::CheckReturn( 1 , "FAILED to update repositories." );

	ConsolePrintTemplates::CategoryFooter( "Successfully installed PACAUR and added AUR to local system" );
	chdir( "/root" );
}

sub AurPkgs {
	ConsolePrintTemplates::CategoryHeading( "Installing AUR necessary packages" );

	my $AUR_Zip = "peazip-gtk2-portable";
	my $AUR_SysUtils = "etcher";
	my $AUR_PdfEdit = "masterpdfeditor";
	my $AUR_VideoCodec = "ffhevc";
	my $AUR_NetworkUtils = "networkminer";

	my @AUR_IDEs = ( "intellij-idea-ue-bundled-jre" , "pycharm-professional" );

	my @AUR_pkgs = ( $AUR_Zip , $AUR_SysUtils , $AUR_PdfEdit , $AUR_VideoCodec , <@AUR_IDEs> , $AUR_NetworkUtils );

	foreach ( @AUR_pkgs ) {
		system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " pacaur -S --noedit --noconfirm $_ " );
	}

	ConsolePrintTemplates::OperHeading( "Unlinking intellij-idea-UE" );
	`unlink /usr/bin/intellij-idea-ue-bundled-jre`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Unlinking pycharm" );
	`unlink \$(which pycharm)`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Moving intellij-idea-UE to /opt" );
	`mv /usr/share/intellij-idea-ue-bundled-jre /opt`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Creating new link to intellij-idea-UE" );
	`ln -s /opt/intellij-idea-ue-bundled-jre/bin/idea.sh /usr/local/bin/intellij-idea-ue`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Creating new link to pycharm" );
	`ln -s /opt/pycharm-professional/bin/pycharm.sh /usr/local/bin/pycharm`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );
}

sub AurFonts {
	ConsolePrintTemplates::CategoryHeading( "Installing AUR font packages + font manager" );

	my @FontPkgs = ( "font-manager" , "ttf-ms-fonts" , "nerd-fonts-git" , "ttf-google-fonts-typewolf" , "ttf-input" );

	foreach ( @FontPkgs ) {
		system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " pacaur -S --noedit --noconfirm $_" );
	}
}

sub InstallConfigI3 {
	ConsolePrintTemplates::CategoryHeading( "Installing the i3 window manager" );

	ConsolePrintTemplates::OperTitle( "Installing dependencies" );
	system( "pacman -S --noconfirm i3lock rofi compton udiskie feh numactl numlockx" );

	ConsolePrintTemplates::OperTitle( "Installing i3 - AUR packages" );
	my $AUR_i3 = "i3-gaps brightnessctl bumblebee-status-git clipit pulseaudio-equalizer-ladspa";

	foreach( split / / , $AUR_i3 ) {
		system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " pacaur -S --noedit --noconfirm $_" )
	}
}

sub VirtEnv {
	ConsolePrintTemplates::CategoryHeading( "Installing VMware Workstation and Genymotion virtualization engines" );

	my @VirtEngines = ( "vmware-workstation" , "genymotion" );
	foreach( @VirtEngines ) {
		system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " pacaur -S --noedit --noconfirm $_" );
	}

	ConsolePrintTemplates::OperHeading( "Adding loopback configuration to modprobe" );
	my $FHandle = IO::File->new( ">> /etc/modprobe.d/vmware-fuse.conf" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n" , "options loop max_loop=256" , "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	system( "modprobe loop" );

	ConsolePrintTemplates::OperTitle( "Reinitializing the kernel and grub to reset DKMS virtualization modules" );
	system( "pacman -S --noconfirm linux-lts" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );
}

1;