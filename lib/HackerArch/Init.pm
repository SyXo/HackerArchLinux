use strict;
use warnings 'FATAL' => 'all';
use Exporter qw( import );


package HackerArch::Init;
use Term::ANSIColor;
use Net::Ping;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( VerifyConnectivity VerifyDiskPrep SystemMount Pacstrap InsertStagingEntryPoint );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &VerifyConnectivity &VerifyDiskPrep &SystemMount &Pacstrap &InsertStagingEntryPoint ) ] );


sub VerifyConnectivity {
	HackerArch::FuncHeaders::CategoryHeading( "Verifying you have internet connectivity" );
	my $conn = Net::Ping->new( "icmp" );
	unless ( $conn->ping( "www.google.com" ) ) {
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , "Please connect to the internet and then rerun the install." );
	}
	HackerArch::FuncHeaders::SuccessMessage();

	HackerArch::FuncHeaders::CategoryFooter( "Internet connectivity discovered successfully" );
}

sub VerifyDiskPrep {
	HackerArch::FuncHeaders::CategoryHeading( "Verifying your disk partitioning" );

	unless ( -e "/dev/sda1" && -e "/dev/sda2" && -e "/dev/sda5" && -e "/dev/sda6" && -e "/dev/sda7" ) {
		my $errormsg = "You have not properly partitioned the primary disk as expected!  \n";
		$errormsg += "Please refer to the README for further instructions.";
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , $errormsg );
	}
	HackerArch::FuncHeaders::SuccessMessage();

	HackerArch::FuncHeaders::CategoryFooter( "Verification complete - disk is ready for install." );
}

sub SystemMount {
	HackerArch::FuncHeaders::CategoryHeading( "Preparing primary drive partitions and mounting" );

	HackerArch::FuncHeaders::OperHeading( "Mounting new root to /mnt" );
	`mount /dev/sda5 /mnt &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify sda5 exists and is not already mounted." );

	HackerArch::FuncHeaders::OperHeading( "Making directory /mnt/tmp" );
	`mkdir -m 1777 -p /mnt/tmp &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify /mnt/tmp has not already been created." );

	HackerArch::FuncHeaders::OperHeading( "Making directories /mnt/{sys,proc}" );
	`mkdir -m 0555 -p /mnt/{sys,proc} &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify /mnt/sys AND /mnt/proc have not already been created." );

	HackerArch::FuncHeaders::OperHeading( "Making directories /mnt/{boot,home}" );
	`mkdir /mnt/{boot,home} &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify /mnt/boot AND /mnt/home have not already been created." );

	HackerArch::FuncHeaders::OperHeading( "Mounting BOOT to /mnt/boot" );
	`mount /dev/sda1 /mnt/boot &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify sda5 exists and is not already mounted." );

	HackerArch::FuncHeaders::OperHeading( "Mounting TMP to /mnt/tmp" );
	`mount /dev/sda6 /mnt/tmp &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify sda5 exists and is not already mounted." );

	HackerArch::FuncHeaders::OperHeading( "Mounting HOME to /mnt/home" );
	`mount /dev/sda7 /mnt/home &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Please verify sda5 exists and is not already mounted." );

	HackerArch::FuncHeaders::CategoryFooter( "Successfully prepared primary drive." );
}

sub Pacstrap {
	my @args = @_;
	unless ( ( $#args + 1 ) >= 0 ) {
		HackerArch::FuncHeaders::ErrorOutMessage( 1 , "Pacstrap must contain argument of grub conf file." );
	}

	HackerArch::FuncHeaders::CategoryHeading( "Preparing pacman for PACSTRAP install" );

	HackerArch::FuncHeaders::OperHeading( "Creating new directories for pacman" );
	`mkdir -m 0755 -p /mnt/var/{cache/pacman,db,log} /mnt/{dev,run,etc} &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 1 , "Cannot create folders for pacman." );

	system( 'pacman -Syy' );

	HackerArch::FuncHeaders::CategoryHeading( "PACSTRAP install to your system root" );
	my $BasePkgs1 = "acpid autoconf automake bash binutils bison bzip2 coreutils cryptsetup device-mapper diffutils fakeroot file filesystem findutils flex gawk";
	my $BasePkgs2 = "gettext glibc grep groff gzip htop inetutils less libtool licenses logrotate lvm2 m4 make man-db man-pages mdadm pacman patch pciutils perl pkg-config";
	my $BasePkgs3 = "procps-ng psmisc sed shadow sudo sysfsutils systemd systemd-sysvcompat texinfo usbutils util-linux vim which";
	my $MainPkgs = "gcc-multilib gcc-libs-multilib linux-lts linux-lts-headers";

	#connectivity
	my $Networking = "dnsmasq dhclient dhcpcd iproute2 iptables iputils netctl rsync curl git wget";

	#wireless
	my $BaseWifi = "crda easy-rsa wpa_supplicant";

	#filesystems
	my $BaseFs = "e2fsprogs exfat-utils dosfstools f2fs-tools jfsutils nilfs-utils ntfs-3g reiserfsprogs xfsprogs udftools";

	# base extended necessary
	my $Utils = "python2 python python2-pip python-pip hdparm hwinfo hwloc lshw lsof sysstat smartmontools tar zip unzip p7zip lzop cpio unrar unace";

	system( "pacstrap /mnt --config=$args[0] --cachedir=\"/mnt/var/cache/pacman/\" --logfile=\"/mnt/var/log/pacman.log\" $BasePkgs1 $BasePkgs2 $BasePkgs3 $MainPkgs $Networking $BaseWifi $BaseFs $Utils" );
}

sub InsertStagingEntryPoint {
	HackerArch::FuncHeaders::CategoryHeading( 'Adding "install" entry point in the new system' );

	HackerArch::FuncHeaders::OperHeading( "Writing to file" );
	my $FHandle = IO::File->new( "+>> /mnt/etc/bash.bashrc" );
	if ( defined $FHandle ) {
		print $FHandle "\n\n";
		print $FHandle "cd /root" , "\n";
		print $FHandle "perl MikiArchStaging.pl" , "\n";
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}
	$FHandle->close;
	HackerArch::FuncHeaders::SuccessMessage();
}

1;
