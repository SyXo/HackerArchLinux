use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::ExtrasInstall;
use Term::ANSIColor;
use IO::File;
use Cwd;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( InitPkgMgrs ExtraPkgs AddAur AurPkgs AurFonts InstallConfigI3 VirtEnv );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &InitPkgMgrs &ExtraPkgs &AddAur &AurPkgs &AurFonts &InstallConfigI3 &VirtEnv ) ] );


sub InitPkgMgrs {
	HackerArch::FuncHeaders::CategoryHeading( "Initializing and adding additional repositories to local system." );

	HackerArch::FuncHeaders::OperTitle( "Downloading Sublime Text dev keyring and adding to repository list" );
	system( "curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && shred -u sublimehq-pub.gpg" );

	my $FHandle = IO::File->new( "+>> /etc/pacman.conf" );
	if ( defined $FHandle ) {
		print $FHandle "\n" , "[sublime-text]" , "\n";
		print $FHandle 'Server = https://download.sublimetext.com/arch/dev/x86_64' , "\n\n";
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;

	HackerArch::FuncHeaders::OperTitle( "Downloading and adding BlackArch repository to local system" );
	system( "curl -O https://blackarch.org/strap.sh" );
	system( "chmod u+x strap.sh" );

	$FHandle = IO::File->new( "< strap.sh" );
	my @lines;
	if ( defined $FHandle ) {
		@lines = <$FHandle>;
		foreach ( @lines ) {
			if ( /^MIRROR/ ) {
				$_ = "MIRROR='https://blackarch.tamcore.eu/' ";
			}
			if ( /get_mirror$/ ) {
				$_ = ""
			}
		}
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;

	$FHandle = IO::File->new( "+> strap.sh" );
	if ( defined $FHandle ) {
		foreach ( @lines ) {
			chomp( $_ );
			print $FHandle $_ , "\n";
		}
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;

	`sh strap.sh`;
	`shred -u strap.sh`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "FAILED to add Sublime Text and/or BlackArch to local system." );
}

sub ExtraPkgs {
	my $TextEditor = "sublime-text";
	my $AndroidHacking = "android-sdk android-sdk-build-tools android-sdk-platform-tools python2-frida frida jadx android-apktool dex2jar smali";
	my $NetworkHacking = "burpsuite wireshark-gtk jdk8-openjdk jre8-openjdk-headless wxhexeditor nmap ssldump ";
	my $BreakingTools = "steghide binwalk dirbuster etherape ettercap-gtk john johnny scapy3k";

	system( "pacman -S --noconfirm $TextEditor $AndroidHacking $NetworkHacking $BreakingTools" );
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
}

sub AurFonts {
	HackerArch::FuncHeaders::CategoryHeading( "Installing AUR font packages + font manager" );

	my @FontPkgs = ( "font-manager" , "ttf-ms-fonts" , "nerd-fonts-git" , "ttf-google-fonts-git" , "ttf-input" );

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
	my $FHandle = IO::File->new( "+>> /etc/modprobe.d/vmware-fuse.conf" );
	if ( defined $FHandle ) {
		print $FHandle "options loop max_loop=256" , "\n";
		$FHandle->close;
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	HackerArch::FuncHeaders::SuccessMessage();

	system( "modprobe loop" );

	HackerArch::FuncHeaders::OperTitle( "Reinitializing the kernel and grub to reset DKMS virtualization modules" );
	system( "pacman -S --noconfirm linux-lts" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );
}

1;