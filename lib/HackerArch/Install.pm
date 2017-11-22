use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Install;
use HackerArch::Setup;
require ConsolePrintTemplates;
use IO::File;
use Cwd;
use WWW::Mechanize;
use LWP::UserAgent;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( UpdateDnsServers InitUsermode InstallFirefoxESR InstallVirtBox AddGdbAsm Nvidia );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &UpdateDnsServers &InitUsermode &InstallFirefoxESR &InstallVirtBox &AddGdbAsm &Nvidia ) ] );


sub UpdateDnsServers {
	ConsolePrintTemplates::OperHeading( "Replacing DNS servers for faster response" );
	system( "cp  " . getcwd() . " /install/resolv.conf /etc/resolv.conf " );
	ConsolePrintTemplates::CheckReturn( 0 , "DNS server are defaulted through your DHCP server" );
}

sub InitUsermode {
	ConsolePrintTemplates::CategoryHeading( " Initializing usermode - adding graphically interface (Xorg) + Gnome packages " );

	my $Xserver = " libglvnd xorg-server xorg-server-common mesa mesa-vdpau libvdpau libva-vdpau-driver libvdpau-va-gl xf86-video-intel ";
	my $XserverUtils = " libx264 xorg-xrandr xorg-xinput xorg-xev xorg-xbacklight xorg-xkill xorg-xprop xorg-xinit xorg-mkfontdir xorg-fonts-75dpi xorg-fonts-100dpi ";

	my $DeskMgr = " lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings gnome-terminal gksu polkit-gnome xdg-user-dirs-gtk ";
	my $UserEnvUtils1 = " gnome-control-center gnome-system-monitor gnome-nettool gparted gnome-disk-utility file-roller gnome-calendar gnome-logs gnome-todo gnome-calculator  ";
	$UserEnvUtils1 .= " baobab eog evince grilo grilo-plugins gucharmap gvfs gvfs-smb ";

	my $Networking = " networkmanager nm-connection-editor networkmanager-openvpn blueman bluez bluez-tools bluez-utils openssh ";

	system( " pacman -S --noconfirm --needed $Xserver $XserverUtils " );
	system( " pacman -S --noconfirm --needed $DeskMgr " );
	system( " pacman -S --noconfirm --needed $Networking $UserEnvUtils1 " );

	ConsolePrintTemplates::OperTitle( " Installing and changing default shell to ZSH " );
	system( " pacman -S --noconfirm zsh zsh-completions zsh-syntax-highlighting zsh-theme-powerlevel9k powerline2 powerline-common powerline-vim " );

	system( " chsh -s /usr/bin/zsh root " );
	system( " chsh -s /usr/bin/zsh  " . ConsolePrintTemplates::GetUsername());

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
	my $PerlBasics = " perl-yaml perl-tidy perl-lwp-protocol-https";

	ConsolePrintTemplates::OperTitle( " Installing complete environment - all necessary user packages " );
	system( "pacman -S --noconfirm --needed $SysBaseFont $Internet $fileMgr $fileIndexer $TorrClient $Utils $Editors $AudioPkgs $VidPkgs $VidCodecs $Android $PicEditor " );
	system( "pacman -S --noconfirm --needed $WebTech $Dbs $ExtdPythonLibraries $PerlBasics " );

	ConsolePrintTemplates::OperTitle( " Install python module (extension for zsh) - thefuck " );
	system( "pip3 install thefuck " );
}

sub InstallFirefoxESR {
	ConsolePrintTemplates::CategoryHeading( "Installing Firefox ESR edition to system " );

	my $url = "https://download.mozilla.org/?product=firefox-esr-latest-ssl&amp;os=linux64&amp;lang=en-US";
	my $FileSaveto = getcwd() . "/install/firefox/firefox.tar.bz2";
	HackerArch::Setup::DownloadFile( $url , $FileSaveto );

	ConsolePrintTemplates::OperTitle( "Extracting contents of download " );
	system( "tar --extract -f $FileSaveto --overwrite --directory=/opt/ 1>/dev/null 2>&1 " );
	ConsolePrintTemplates::CheckReturn( 0 , "Firefox was not successfully added to your system " );

	if ( "$?" == 0 ) {
		ConsolePrintTemplates::OperTitle( " Installing Firefox symlink " );
		`ln -s /opt/firefox/firefox /usr/local/bin/firefox`;
		ConsolePrintTemplates::CheckReturn( 0 , " Firefox was not successfully installed " );
	}
}

sub InstallVirtBox {
	ConsolePrintTemplates::CategoryHeading( "Installing VirtualBox" );
	system( "pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-dkms" );

	ConsolePrintTemplates::CheckReturn( 0 , "VirtualBox WAS NOT installed!" );
}

sub AddGdbAsm {
	ConsolePrintTemplates::CategoryHeading( "Installing GDB + Peda for GDB" );
	system( "pacman -S --noconfirm gdb nasm yasm" );

	ConsolePrintTemplates::OperHeading( "Creating directory for Peda" );
	system( " mkdir -p /home/" . ConsolePrintTemplates::GetUsername() . "/.peda  &>/dev/null " );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperTitle( "Git clone peda to formerly-created directory" );
	system( "git clone https://github.com/longld/peda.git /home/" . ConsolePrintTemplates::GetUsername() . "/.peda " );
	ConsolePrintTemplates::CheckReturn( 0 , "  " );

	ConsolePrintTemplates::OperTitle( "Adding peda autostart entry point for gdb" );
	my $FHandle = IO::File->new( " +> /home/" . ConsolePrintTemplates::GetUsername() . "/.gdbinit" );
	if ( defined $FHandle ) {
		print $FHandle  "source /home/" . ConsolePrintTemplates::GetUsername() . "/.peda/peda.py" , "\n";

		$FHandle->close;
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
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
		ConsolePrintTemplates::SuccessMessage();
	}
	else {
		ConsolePrintTemplates::ErrorOutMessage( 0 , "Cannot write to file." );
	}

}

1;
