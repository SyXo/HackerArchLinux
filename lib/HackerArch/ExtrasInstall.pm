use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::ExtrasInstall;
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
	HackerArch::FuncHeaders::CategoryHeading( "Initializing and adding additional repositories to local system." );

	HackerArch::FuncHeaders::OperTitle( "Downloading Sublime Text dev keyring and adding to repository list" );
	system( "curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && shred -u sublimehq-pub.gpg" );

	my $FHandle = IO::File->new( ">> /etc/pacman.conf" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n" , "[sublime-text]" , "\n";
		print $FHandle 'Server = https://download.sublimetext.com/arch/dev/x86_64' , "\n\n";

		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	HackerArch::FuncHeaders::OperTitle( "Downloading and adding BlackArch repository to local system" );

	my $mirror = "https://blackarch.tamcore.eu/";

	my $sysarch = ( POSIX::uname )[4];
	my $blackarch = "blackarch/os/$sysarch/";

	my $mech = WWW::Mechanize->new();

	HackerArch::FuncHeaders::OperHeading( "Retrieving blackarch package db" );
	$mech->get( $mirror . $blackarch );
	if ( $mech->status() == 200 ) {
		HackerArch::FuncHeaders::SuccessMessage();

		HackerArch::FuncHeaders::OperTitle( "Searching for Blackarch keyring" );
		my @page_links = $mech->find_all_links( 'text_regex' => qr/^blackarch-keyring(?:.+)/ );
		my $filename = "";
		foreach ( @page_links ) {
			$filename = $_->[0];
			my $file_dl = get( $mirror . $blackarch . $filename );
			HackerArch::FuncHeaders::OperHeading( "Saving file to localhost" );
			$FHandle = IO::File->new( "+> " . getcwd() . "/install/repos/$filename" );
			if ( defined $FHandle ) {
				binmode( $FHandle );
				print $FHandle $file_dl;
				$FHandle->close;
				HackerArch::FuncHeaders::SuccessMessage();
			}
			else {
				HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file!" );
			}
		}

		HackerArch::FuncHeaders::OperHeading( "Verifying keyring package signature" );
		system( "gpg --recv-keys 4345771566D76038C7FEB43863EC0ADBEA87E4E3 &>/dev/null" );
		system( "pacman-key --lsign 4345771566D76038C7FEB43863EC0ADBEA87E4E3 &>/dev/null" );
		my $verifier = getcwd() . "/install/repos/$filename";
		my @VerifyOutput = qx(gpg --verify $verifier 2>&1);
		my $status = 0;
		for my $line ( @VerifyOutput ) {
			if ( $line =~ /Good signature/ ) {
				$status = 1;
				last;
			}
		}
		if ( $status ) {
			HackerArch::FuncHeaders::SuccessMessage();
		}
		else {
			HackerArch::FuncHeaders::ErrorOutMessage( 0 , "" );
		}

		system( "pacman-key --init &>/dev/null " );
		system( 'pacman --config /dev/null --noconfirm -U $(find ' . getcwd() . '/install -type f -iname "*.pkg.tar.xz")' );
		if ( "$?" == 0 ) {
			system( "pacman-key --populate" );
		}
		else {
			HackerArch::FuncHeaders::ErrorOutMessage( 0 , "keyring installation failed!" );
		}
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "" );
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
	my $username = HackerArch::FuncHeaders::GetUsername();

	HackerArch::FuncHeaders::CategoryHeading( "Adding Arch User Repository to local system" );
	chdir( "/home/" . HackerArch::FuncHeaders::GetUsername());

	HackerArch::FuncHeaders::OperTitle( "Installing dependencies" );
	system( "pacman -S --noconfirm expac yajl" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperTitle( "Adding gpg key for the rest of AUR install" );
	`gpg --recv 1EB2638FF56C0C53`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );
	`pacman-key --lsign 1EB2638FF56C0C53`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "git clone cower - dependency" );
	`git clone https://aur.archlinux.org/cower.git 2>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Changing git folder to local user for compilation access" );
	system( "chown -R $username:users cower &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Compiling cower package (please wait)" );
	system( "cd cower && sudo -u $username makepkg --skippgpcheck && cd .. &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Manually verifying cower signature" );
	my $CowerPath = getcwd() . "/cower";
	my @SigCheckOutput = qx(find $CowerPath -type f -iname "*.tar.gz.sig" -exec pacman-key --verify {} \\; 2>&1);

	my $truth = 0;
	for my $line ( @SigCheckOutput ) {
		if ( $line =~ /Good signature/ ) {
			HackerArch::FuncHeaders::SuccessMessage();
			$truth = 1;
			last;
		}
	}
	unless ( $truth ) {
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , "Script cannot proceed without pacaur!" );
	}

	HackerArch::FuncHeaders::OperTitle( "Installing cower" );
	system( 'pacman -U --noconfirm $(find cower/ -type f -iname "*.pkg.tar.xz")' );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "git clone pacaur" );
	`git clone https://aur.archlinux.org/pacaur.git &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Changing git folder to local user for compilation access" );
	system( "chown -R $username:users pacaur &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Compiling cower package (please wait)" );
	system( "cd pacaur && sudo -u $username makepkg && cd .. &>/dev/null" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperTitle( "Installing pacaur" );
	system( 'pacman -U --noconfirm $(find pacaur/ -type f -iname "*.pkg.tar.xz")' );
	HackerArch::FuncHeaders::CheckReturn( 1 , "The rest of the script is based on AUR. Setup cannot proceed." );

	HackerArch::FuncHeaders::OperHeading( "Configuring pacaur" );
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
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , "Cannot write to file." );
	}

	system ( "sudo -u $username pacaur -Syy" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "FAILED to update repositories." );

	HackerArch::FuncHeaders::CategoryFooter( "Successfully installed PACAUR and added AUR to local system" );
	chdir( "/root" );
}

sub AurPkgs {
	HackerArch::FuncHeaders::CategoryHeading( "Installing AUR necessary packages" );

	my $AUR_Zip = "peazip-gtk2-portable";
	my $AUR_SysUtils = "etcher";
	my $AUR_PdfEdit = "masterpdfeditor";
	my $AUR_VideoCodec = "ffhevc";
	my $AUR_NetworkUtils = "networkminer";

	my @AUR_IDEs = ( "intellij-idea-ue-bundled-jre" , "pycharm-professional" );

	my @AUR_pkgs = ( $AUR_Zip , $AUR_SysUtils , $AUR_PdfEdit , $AUR_VideoCodec , <@AUR_IDEs> , $AUR_NetworkUtils );

	foreach ( @AUR_pkgs ) {
		system( "sudo -u " . HackerArch::FuncHeaders::GetUsername() . " pacaur -S --noedit --noconfirm $_ " );
	}

	HackerArch::FuncHeaders::OperHeading( "Unlinking intellij-idea-UE" );
	`unlink /usr/bin/intellij-idea-ue-bundled-jre`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Unlinking pycharm" );
	`unlink \$(which pycharm)`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Moving intellij-idea-UE to /opt" );
	`mv /usr/share/intellij-idea-ue-bundled-jre /opt`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Creating new link to intellij-idea-UE" );
	`ln -s /opt/intellij-idea-ue-bundled-jre/bin/idea.sh /usr/local/bin/intellij-idea-ue`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperHeading( "Creating new link to pycharm" );
	`ln -s /opt/pycharm-professional/bin/pycharm.sh /usr/local/bin/pycharm`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );
}

sub AurFonts {
	HackerArch::FuncHeaders::CategoryHeading( "Installing AUR font packages + font manager" );

	my @FontPkgs = ( "font-manager" , "ttf-ms-fonts" , "nerd-fonts-git" , "ttf-google-fonts-typewolf" , "ttf-input" );

	foreach ( @FontPkgs ) {
		system( "sudo -u " . HackerArch::FuncHeaders::GetUsername() . " pacaur -S --noedit --noconfirm $_" );
	}
}

sub InstallConfigI3 {
	HackerArch::FuncHeaders::CategoryHeading( "Installing the i3 window manager" );

	HackerArch::FuncHeaders::OperTitle( "Installing dependencies" );
	system( "pacman -S --noconfirm i3lock rofi compton udiskie feh numactl numlockx" );

	HackerArch::FuncHeaders::OperTitle( "Installing i3 - AUR packages" );
	my $AUR_i3 = "i3-gaps brightnessctl bumblebee-status-git clipit pulseaudio-equalizer-ladspa";

	foreach( split / / , $AUR_i3 ) {
		system( "sudo -u " . HackerArch::FuncHeaders::GetUsername() . " pacaur -S --noedit --noconfirm $_" )
	}
}

sub VirtEnv {
	HackerArch::FuncHeaders::CategoryHeading( "Installing VMware Workstation and Genymotion virtualization engines" );

	my @VirtEngines = ( "vmware-workstation" , "genymotion" );
	foreach( @VirtEngines ) {
		system( "sudo -u " . HackerArch::FuncHeaders::GetUsername() . " pacaur -S --noedit --noconfirm $_" );
	}

	HackerArch::FuncHeaders::OperHeading( "Adding loopback configuration to modprobe" );
	my $FHandle = IO::File->new( ">> /etc/modprobe.d/vmware-fuse.conf" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n" , "options loop max_loop=256" , "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	system( "modprobe loop" );

	HackerArch::FuncHeaders::OperTitle( "Reinitializing the kernel and grub to reset DKMS virtualization modules" );
	system( "pacman -S --noconfirm linux-lts" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );
}

1;