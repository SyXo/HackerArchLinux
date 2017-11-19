use strict;
use warnings 'FATAL' => 'all';
use Exporter qw( import );


package HackerArch::Staging;
use Cwd;
use IO::File;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( InitSystem AdjustUpdatePacman StageInstall BuildFstab );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &InitSystem &AdjustUpdatePacman &StageInstall &BuildFstab ) ] );

our ($username);

sub InitSystem {
	HackerArch::FuncHeaders::CategoryHeading( "Initializing your new system" );

	#    set & compile locale
	HackerArch::FuncHeaders::OperHeading( "Generating locale format" );
	my $FHandle = IO::File->new( "+> /etc/locale.gen" );
	if ( defined $FHandle ) {
		print $FHandle "en_US.UTF-8 UTF-8" , "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	`locale-gen &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Setup cannot proceed without establishing locale." );

	HackerArch::FuncHeaders::OperHeading( "Adding language locale ... " );
	$FHandle = IO::File->new( "+> /etc/locale.conf" );
	if ( defined $FHandle ) {
		print $FHandle "LANG=en_US.UTF-8" , "\n";
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#    set timezone link
	HackerArch::FuncHeaders::OperHeading( "Establishing timezone for local time ..." );
	if ( -e "/etc/localtime" ) {
		`unlink /etc/localtime &>/dev/null`;
	}
	`ln -s /usr/share/zoneinfo/Asia/Jerusalem /etc/localtime &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "The default localtime is still active." );

	#    set time : BIOS clock to UTC
	HackerArch::FuncHeaders::OperHeading( "Setting system clock (BIOS) to UTC ..." );
	`hwclock --systohc --utc &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	#    set hostname and adjust /etc/hosts file
	HackerArch::FuncHeaders::OperTitle( "Please enter your desired hostname: " );
	my $hostname = <>;
	$FHandle = IO::File->new( "+> /etc/hostname" );
	if ( defined $FHandle ) {
		print $FHandle "$hostname" , "\n";
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	HackerArch::FuncHeaders::OperHeading( "Adding recursive hostname for hosts file" );
	$FHandle = IO::File->new( "+>> /etc/hosts" );
	if ( defined $FHandle ) {
		print $FHandle "127.0.1.1" , "\t" , "localhost.localdomain" , "\t" , "$hostname" , "\n";
		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#	passwd root (create new root passwd)
	HackerArch::FuncHeaders::OperTitle( "Please change the default root password:" );
	`passwd`;
	until ( "$?" == 0 ) {
		`passwd`;
	}

	HackerArch::FuncHeaders::CategoryFooter( "Successfully completely initialization." );

	HackerArch::FuncHeaders::OperTitle( "Activating auto-networking for after reboot" );
	`systemctl enable dhcpcd`;
}

sub AdjustUpdatePacman {
	if ( ( $#_ + 1 ) != 1 ) {
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , "Reflector func must get input arg of pacman.conf" );
	}

	HackerArch::FuncHeaders::CategoryHeading( "Pacman - Reflector : updating pacman." );

	HackerArch::FuncHeaders::OperHeading( "Adjusting pacman folders" );
	`mv /var/lib/pacman /var/db/ &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Setup cannot continue since conf file contains pointer to new folder." );

	HackerArch::FuncHeaders::OperHeading( "Copying pacman.conf to new system" );
	system( "cp $_[0] /etc/pacman.conf &>/dev/null " );
	HackerArch::FuncHeaders::CheckReturn( 1 , "" );

	HackerArch::FuncHeaders::OperHeading( "Creating symlink to pacman default dir" );
	`ln -s /var/db/pacman/ /var/lib/pacman &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Setup cannot continue without it." );

	HackerArch::FuncHeaders::OperTitle( "Download package lists and updating local dbs" );
	system( "pacman -Syy" );

	HackerArch::FuncHeaders::OperTitle( "Creating new mirror-list file from arch repository" );
	system( "pacman -S --noconfirm reflector" );
	system( "reflector --verbose --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist " );
	system( "pacman -Rscn \$(pacman -Qtdq) ; pacman -Scc --noconfirm && pacman-optimize && sync && pacman -Syyu" );

	HackerArch::FuncHeaders::CategoryFooter( "Successfully completed updating pacman." );
}

sub StageInstall {
	HackerArch::FuncHeaders::CategoryHeading( "Configuring chroot mounted system" );

	HackerArch::FuncHeaders::OperHeading( "ReWriting sudoers - uncommenting sudo group for root access" );
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
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

	#    add new regular (restricted user)
	HackerArch::FuncHeaders::UserInput( "Please enter new username" );
	$username = <>;
	chomp( $username );
	`useradd -m -g users $username &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please manually add new user." );

	HackerArch::FuncHeaders::UserInput( "Please enter $username\'s " );
	`passwd $username`;
	until ( "$?" == 0 ) {
		`passwd $username`;
	}

	HackerArch::FuncHeaders::OperHeading( "Adding $username to sudo group" );
	`usermod -a -G wheel $username &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "Please manually add $username to sudo group later." );

	HackerArch::FuncHeaders::OperTitle( "Installing and configuring grub" );
	system( "pacman -S --noconfirm grub llvm llvm-libs mtools os-prober lsb-release intel-ucode dkms" );
	system( "pacman -S --noconfirm --force linux-lts" );

	HackerArch::FuncHeaders::OperTitle( "Configuring and grub to primary drive" );
	system( "grub-install /dev/sda" );
	system( "grub-mkconfig -o /boot/grub/grub.cfg" );

	HackerArch::FuncHeaders::CategoryFooter( "Successfully configured chroot mounted system" );
}

sub BuildFstab {
	HackerArch::FuncHeaders::CategoryHeading( "Generating and configuring new fstab file" );

	HackerArch::FuncHeaders::OperHeading( "Creating fstab - with hardened mount points" );

	system( "python2 " . getcwd() . "/lib/HackerArch/BuildFstab.py" );
	HackerArch::FuncHeaders::CheckReturn( 1 , "Your disk won't boot into your new system without fstab!" )
}

1;
