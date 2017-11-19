use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Install;
use IO::File;
use Cwd;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( UpdateDnsServers InitUsermode InstallFirefoxESR InstallVirtBox AddGdbAsm Nvidia );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &UpdateDnsServers &InitUsermode &InstallFirefoxESR &InstallVirtBox &AddGdbAsm &Nvidia ) ] );


sub UpdateDnsServers {
	HackerArch::FuncHeaders::OperHeading( "Replacing DNS servers for faster response" );
	system( "cp  " . getcwd() . " /install/resolv.conf /etc/resolv.conf " );
	HackerArch::FuncHeaders::CheckReturn( 0 , "DNS server are defaulted through your DHCP server" );
}

sub InitUsermode {
	HackerArch::FuncHeaders::CategoryHeading( " Initializing usermode - adding graphically interface (Xorg) + Gnome packages " );

	my $Xserver = " libglvnd xorg-server xorg-server-common mesa mesa-vdpau libvdpau libva-vdpau-driver libvdpau-va-gl xf86-video-intel ";
	my $XserverUtils = " libx264 xorg-xrandr xorg-xinput xorg-xev xorg-xbacklight xorg-xkill xorg-xprop xorg-xinit xorg-mkfontdir xorg-fonts-75dpi xorg-fonts-100dpi ";

	my $DeskMgr = " lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings gnome-terminal gksu polkit-gnome xdg-user-dirs-gtk ";
	my $UserEnvUtils1 = " gnome-control-center gnome-system-monitor gnome-nettool gparted gnome-disk-utility file-roller gnome-calendar gnome-logs gnome-todo gnome-calculator  ";
	$UserEnvUtils1 .= " baobab eog evince grilo grilo-plugins gucharmap gvfs gvfs-smb ";

	my $Networking = " networkmanager nm-connection-editor networkmanager-openvpn blueman bluez bluez-tools bluez-utils opernssh ";

	system( " pacman -S --noconfirm --needed $Xserver $XserverUtils " );
	system( " pacman -S --noconfirm --needed $DeskMgr " );
	system( " pacman -S --noconfirm --needed $Networking $UserEnvUtils1 " );

	HackerArch::FuncHeaders::OperTitle( " Installing and changing default shell to ZSH " );
	system( " pacman -S --noconfirm zsh zsh-completions zsh-syntax-highlighting zsh-theme-powerlevel9k powerline2 powerline-common powerline-vim " );

	system( " chsh -s /usr/bin/zsh root " );
	system( " chsh -s /usr/bin/zsh  " . HackerArch::FuncHeaders::GetUsername());

	my $SysBaseFont = " ttf-ubuntu-font-family  ";
	my $Internet = " chromium flashplugin pepper-flash opera ";
	my $fileMgr = " pcmanfm-gtk3 ";
	my $fileIndexer = " recoll pstotext antiword catdoc unrtf id3lib ";
	my $TorrClient = " qbittorrent ";
	my $Utils = " bleachbit ";
	my $Editors = " libreoffice-still calibre atom ";
	my $PicEditor = " gimp ";
	my $AudioPkgs = " libcanberra-pulse paprefs pavucontrol pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-gconf pulseaudio-jack quodlibet ";
	my $VidPkgs = " mpv youtube-dl x265 kodi kodi-addon-audioencoder-flac kodi-addon-audioencoder-lame kodi-addon-audioencoder-vorbis kodi-addon-audioencoder-wav ";
	my $VidCodecs = " gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer gstreamer-vaapi ";
	my $Android = " libmtp mtpfs android-tools android-file-transfer android-udev gvfs-mtp ";

	my $WebTech = " apm npm nodejs uglify-js bower php php-phpdbg phpmyadmin ";
	my $Dbs = " postgresql postgresql-libs pgadmin4 php-pgsql phppgadmin php-sqlite ";
	my $ExtdPythonLibraries = " python-yaml python-psutil python-regex python-pillow python-qrencode python-pytools python-logbook python-pygithub python-billiard python-requests ";
	$ExtdPythonLibraries .= " python-mysql-connector python-simplejson python-pycryptodomex python-twisted python-numpy python-ptrace python-capstone ";
	my $PerlBasics = " perl-yaml perl-tidy perl-libwww perl-www-curl perl-www-mechanize perl-lwp-protocol-https ";

	HackerArch::FuncHeaders::OperTitle( " Installing complete environment - all necessary user packages " );
	system( "pacman -S --noconfirm --needed $SysBaseFont $Internet $fileMgr $fileIndexer $TorrClient $Utils $Editors $AudioPkgs $VidPkgs $VidCodecs $Android $PicEditor " );
	system( "pacman -S --noconfirm --needed $WebTech $Dbs $ExtdPythonLibraries $PerlBasics " );

	HackerArch::FuncHeaders::OperTitle( " Install python module (extension for zsh) - thefuck " );
	system( "pip3 install thefuck " );
}

sub InstallFirefoxESR {
	HackerArch::FuncHeaders::CategoryHeading( "Installing Firefox ESR edition to system " );

	HackerArch::FuncHeaders::OperTitle( "Downloading file " );
	system( "python2  " . getcwd() . " /lib/HackerArch/FirefoxEsr.py " );
	HackerArch::FuncHeaders::CheckReturn( 0 , "  " );

	HackerArch::FuncHeaders::OperTitle( "Extracting contents of download " );
	`tar --extract -f firefox.tar.bz2 --overwrite --directory=/opt/ &>/dev/null`;
	HackerArch::FuncHeaders::CheckReturn( 0 , "Firefox was not successfully added to your system " );

	if ( "$?" == 0 ) {
		HackerArch::FuncHeaders::OperTitle( " Installing Firefox symlink " );
		`ln -s /opt/firefox/firefox /usr/local/bin/firefox`;
		HackerArch::FuncHeaders::CheckReturn( 0 , " Firefox was not successfully installed " );
	}
}

sub InstallVirtBox {
	HackerArch::FuncHeaders::CategoryHeading( "Installing VirtualBox" );
	system( "pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-dkms" );

	HackerArch::FuncHeaders::CheckReturn( 0 , "VirtualBox WAS NOT installed!" );
}

sub AddGdbAsm {
	HackerArch::FuncHeaders::CategoryHeading( "Installing GDB + Peda for GDB" );
	system( "pacman -S --noconfirm gdb nasm yasm" );

	HackerArch::FuncHeaders::OperHeading( "Creating directory for Peda" );
	system( " mkdir -p /home/" . HackerArch::FuncHeaders::GetUsername() . "/.peda  &>/dev/null " );
	HackerArch::FuncHeaders::CheckReturn( 0 , "" );

	HackerArch::FuncHeaders::OperTitle( "Git clone peda to formerly-created directory" );
	system( "git clone https://github.com/longld/peda.git /home/" . HackerArch::FuncHeaders::GetUsername() . "/.peda " );
	HackerArch::FuncHeaders::CheckReturn( 0 , "  " );

	HackerArch::FuncHeaders::OperTitle( "Adding peda autostart entry point for gdb" );
	my $FHandle = IO::File->new( " +> /home/" . HackerArch::FuncHeaders::GetUsername() . "/.gdbinit" );
	if ( defined $FHandle ) {
		print $FHandle  "source /home/" . HackerArch::FuncHeaders::GetUsername() . "/.peda/peda.py" , "\n";

		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

}

sub Nvidia {
	system( "pacman -S --noconfirm lib32-libvdpau lib32-nvidia-utils lib32-opencl-nvidia libvdpau nvidia-lts nvidia-settings nvidia-utils opencl-nvidia" );

	my $FHandle = IO::File->new( "+>> /etc/modprobe.d/blacklist-nouveau.conf" );
	if ( defined $FHandle ) {
		print $FHandle  "blacklist nouveau" , "\n";
		print $FHandle  "options nouveau modeset=0" , "\n";
		print $FHandle  "alias nouveau off" , "\n";

		$FHandle->close;
		HackerArch::FuncHeaders::SuccessMessage();
	}
	else {
		HackerArch::FuncHeaders::ErrorOutMessage( 0 , "Cannot write to file." );
	}

}

1;
