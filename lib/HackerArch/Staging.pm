use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Staging;
require ConsolePrintTemplates;
use Cwd;
use IO::File;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( InitSystem AdjustUpdatePacman StageInstall BuildFstab );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &InitSystem &AdjustUpdatePacman &StageInstall &BuildFstab ) ] );

our ($username);

sub InitSystem {
	ConsolePrintTemplates::CategoryHeading( "Initializing your new system" );

	#    set & compile locale
	ConsolePrintTemplates::OperHeading( "Generating locale format" );
	my $FHandle = IO::File->new( "+> /etc/locale.gen" );
	if ( defined $FHandle ) {
		print $FHandle "en_US.UTF-8 UTF-8" , "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	`locale-gen &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "Setup cannot proceed without establishing locale." );

	ConsolePrintTemplates::OperHeading( "Adding language locale ... " );
	$FHandle = IO::File->new( "+> /etc/locale.conf" );
	if ( defined $FHandle ) {
		print $FHandle "LANG=en_US.UTF-8" , "\n";
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#    set timezone link
	ConsolePrintTemplates::OperHeading( "Establishing timezone for local time ..." );
	if ( -e "/etc/localtime" ) {
		`unlink /etc/localtime &>/dev/null`;
	}
	`ln -s /usr/share/zoneinfo/Asia/Jerusalem /etc/localtime &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "The default localtime is still active." );

	#    set time : BIOS clock to UTC
	ConsolePrintTemplates::OperHeading( "Setting system clock (BIOS) to UTC ..." );
	`hwclock --systohc --utc &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	#    set hostname and adjust /etc/hosts file
	ConsolePrintTemplates::OperTitle( "Please enter your desired hostname: " );
	my $hostname = <>;
	$FHandle = IO::File->new( "+> /etc/hostname" );
	if ( defined $FHandle ) {
		print $FHandle "$hostname" , "\n";
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	ConsolePrintTemplates::OperHeading( "Adding recursive hostname for hosts file" );
	$FHandle = IO::File->new( "+>> /etc/hosts" );
	if ( defined $FHandle ) {
		print $FHandle "127.0.1.1" , "\t" , "localhost.localdomain" , "\t" , "$hostname" , "\n";
		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#	passwd root (create new root passwd)
	ConsolePrintTemplates::OperTitle( "Please change the default root password:" );
	`passwd`;
	until ( "$?" == 0 ) {
		`passwd`;
	}

	ConsolePrintTemplates::CategoryFooter( "Successfully completely initialization." );

	ConsolePrintTemplates::OperTitle( "Activating auto-networking for after reboot" );
	`systemctl enable dhcpcd`;
}

sub AdjustUpdatePacman {
	if ( ( $#_ + 1 ) != 1 ) {
		ConsolePrintTemplates::ErrorOutMessage( 1 , "Reflector func must get input arg of pacman.conf" );
	}

	ConsolePrintTemplates::CategoryHeading( "Pacman - Reflector : updating pacman." );

	ConsolePrintTemplates::OperHeading( "Adjusting pacman folders" );
	`mv /var/lib/pacman /var/db/ &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "Setup cannot continue since conf file contains pointer to new folder." );

	ConsolePrintTemplates::OperHeading( "Copying pacman.conf to new system" );
	system( "cp $_[0] /etc/pacman.conf &>/dev/null " );
	ConsolePrintTemplates::CheckReturn( 1 , "" );

	ConsolePrintTemplates::OperHeading( "Creating symlink to pacman default dir" );
	`ln -s /var/db/pacman/ /var/lib/pacman &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "Setup cannot continue without it." );

	ConsolePrintTemplates::OperTitle( "Download package lists and updating local dbs" );
	system( "pacman -Syy" );

	ConsolePrintTemplates::OperTitle( "Creating new mirror-list file from arch repository" );
	system( "pacman -S --noconfirm reflector" );
	system( "reflector --verbose --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist " );
	system( "pacman -Rscn \$(pacman -Qtdq) ; pacman -Scc --noconfirm && pacman-optimize && sync && pacman -Syyu" );

	ConsolePrintTemplates::CategoryFooter( "Successfully completed updating pacman." );
}

sub StageInstall {
	ConsolePrintTemplates::CategoryHeading( "Configuring chroot mounted system" );

	ConsolePrintTemplates::OperHeading( "ReWriting sudoers - uncommenting sudo group for root access" );
	my $FHandle = IO::File->new( "+> /etc/sudoers " );
	if ( defined $FHandle ) {
		print $FHandle "#======================================" , "\n";
		print $FHandle "#        User privilege specification" , "\n";
		print $FHandle "#======================================" , "\n";
		print $FHandle "root ALL=(ALL) ALL" , "\n\n";
		print $FHandle "#== Uncomment to allow members of group wheel to execute any command" , "\n";
		print $FHandle "%wheel ALL=(ALL) ALL" , "\n\n";
		print $FHandle "#== Same thing without a password" , "\n";
		print $FHandle "# %wheel ALL=(ALL) NOPASSWD: ALL" , "\n\n";
		print $FHandle "#== Uncomment to allow members of group sudo to execute any command" , "\n";
		print $FHandle "# %sudo ALL=(ALL) ALL" , "\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#    add new regular (restricted user)
	ConsolePrintTemplates::UserInput( "Please enter new username" );
	$username = <>;
	chomp( $username );
	`useradd -m -g users $username &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 1 , "Please manually add new user." );

	ConsolePrintTemplates::UserInput( "Please enter $username\'s " );
	`passwd $username`;
	until ( "$?" == 0 ) {
		`passwd $username`;
	}

	ConsolePrintTemplates::OperHeading( "Adding $username to sudo group" );
	`usermod -a -G wheel $username &>/dev/null`;
	ConsolePrintTemplates::CheckReturn( 0 , "Please manually add $username to sudo group later." );

	ConsolePrintTemplates::OperTitle( "Installing and configuring grub" );
	system( "pacman -S --noconfirm grub llvm llvm-libs mtools os-prober lsb-release intel-ucode dkms" );
	system( "pacman -S --noconfirm --force linux-lts" );

	ConsolePrintTemplates::OperTitle( "Configuring and grub to primary drive" );
	system( "grub-install /dev/sda" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );

	ConsolePrintTemplates::CategoryFooter( "Successfully configured chroot mounted system" );
}

sub BuildFstab {
	ConsolePrintTemplates::CategoryHeading( "Generating and configuring new fstab file" );

	ConsolePrintTemplates::OperHeading( "Creating fstab - with hardened mount points" );

	system( "python2 " . getcwd() . "/lib/HackerArch/BuildFstab.py 1" );
	ConsolePrintTemplates::CheckReturn( 1 , "Your disk won't boot into your new system without fstab!" )
}

1;
