use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package HackerArch::Ricing;
require ConsolePrintTemplates;
use Cwd;


our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( AddMouseStyling BumblebeeStatusStyling );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &AddMouseStyling &BumblebeeStatusStyling ) ] );

sub AddMouseStyling {
	ConsolePrintTemplates::OperHeading( "Copying mouse cursors as default mouse styling" );
	system( "cp -r " . getcwd() . "/ricing/cursor/cursors /usr/share/icons/default/" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "Overwriting theme file to enable previous" );
	system( "cp " . getcwd() . "/ricing/cursor/index.theme /usr/share/icons/default/" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "NEED to change folder accessibility" );
	system( "chmod -R 755 /usr/share/icons/default/cursors/ " );
	ConsolePrintTemplates::CheckReturn( 0 , "" );

	ConsolePrintTemplates::OperHeading( "NEED to change theme file accessibility" );
	system( "chmod 644 /usr/share/icons/default/index.theme" );
	ConsolePrintTemplates::CheckReturn( 0 , "" );
}

sub BumblebeeStatusStyling {
	ConsolePrintTemplates::CategoryHeading( "Restyling bumblebee status bars with black (to make it easier to read)" );
	system( "cp " . getcwd() . "/ricing/bbstatus_solarized-powerline.json /usr/share/bumblebee-status/themes/solarized-powerline.json" );
	ConsolePrintTemplates::CheckReturn( 0 , "Status bars will NOT BE black!" );
}

sub AddZimZshFramework {
	ConsolePrintTemplates::OperTitle( "Installing Zim - for zsh - framework" );
	system( "git clone --recursive https://github.com/Eriner/zim.git \${ZDOTDIR:-\${HOME}}/.zim" );
	system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " git clone --recursive https://github.com/Eriner/zim.git \${ZDOTDIR:-\${HOME}}/.zim" );
}

sub AddVundleVimFramework {
	ConsolePrintTemplates::OperTitle( "Installing Vundle - for vim - framework and copying configs" );
	system( "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim" );
	system( "git clone https://github.com/VundleVim/Vundle.vim.git /home/" . ConsolePrintTemplates::GetUsername() . "/.vim/bundle/Vundle.vim" );
}